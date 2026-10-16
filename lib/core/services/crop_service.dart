import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import '../../features/wardrobe/domain/wardrobe_item.dart';

/// Input for the crop step.
///
/// The window is expressed in *normalised* coordinates (0–1) against the
/// upright image, so the crop screen never has to know the photo's pixel
/// dimensions and EXIF rotation can be resolved in one place — here.
@immutable
class CropRequest {
  const CropRequest({
    required this.source,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    this.maxWidth = 1400,
    this.lossless = true,
  });

  final Uint8List source;
  final double left;
  final double top;
  final double width;
  final double height;

  /// Longest edge of the stored image. The web build keeps this small because a
  /// browser's local storage will not hold a shelf of full-size photos.
  final int maxWidth;

  /// PNG when true, JPEG when false.
  final bool lossless;
}

/// Output: the cropped image, ready to be written to storage, plus the garment
/// colour the detector believes it found.
@immutable
class CropResult {
  const CropResult({required this.imageBytes, required this.detectedColour});

  /// PNG on native, JPEG on the web (where storage is tight).
  final Uint8List imageBytes;
  final WardrobeColour detectedColour;
}

/// Crops, normalises and colour-detects in one background pass.
///
/// A 12 MP photo takes a beat to decode, so all of this runs off the UI isolate.
Future<CropResult> cropAndDetect(CropRequest request) =>
    compute(_cropWorker, request);

/// First pass over a freshly picked photo: resolve EXIF rotation and re-encode
/// as a plain upright JPEG.
///
/// Doing it once here means the preview, the crop maths and the detector all
/// agree on which way up the image is — the single most common source of
/// "the crop is on the wrong part of the photo" bugs.
Future<Uint8List> normalisePhoto(Uint8List source) =>
    compute(_normaliseWorker, source);

Uint8List _normaliseWorker(Uint8List source) {
  final decoded = img.decodeImage(source);
  if (decoded == null) {
    throw const FormatException('That file could not be read as an image.');
  }
  var upright = img.bakeOrientation(decoded);
  if (upright.width > 1600) {
    upright = img.copyResize(upright, width: 1600, interpolation: img.Interpolation.average);
  }
  return Uint8List.fromList(img.encodeJpg(upright, quality: 90));
}

CropResult _cropWorker(CropRequest r) {
  final decoded = img.decodeImage(r.source);
  if (decoded == null) {
    throw const FormatException('That file could not be read as an image.');
  }

  // Resolve EXIF rotation first, otherwise portrait shots come out sideways and
  // the normalised window points at the wrong place.
  final src = img.bakeOrientation(decoded);

  final x = (r.left * src.width).round().clamp(0, max(0, src.width - 1)).toInt();
  final y = (r.top * src.height).round().clamp(0, max(0, src.height - 1)).toInt();
  final w = (r.width * src.width).round().clamp(1, src.width - x).toInt();
  final h = (r.height * src.height).round().clamp(1, src.height - y).toInt();

  var frame = img.copyCrop(src, x: x, y: y, width: w, height: h);

  // Normalise: 1400px-wide images stay quick to scroll and cheap to sync later.
  if (frame.width > r.maxWidth) {
    frame = img.copyResize(frame, width: r.maxWidth, interpolation: img.Interpolation.average);
  }

  final hex = _dominantColour(frame);

  return CropResult(
    imageBytes: Uint8List.fromList(
      r.lossless
          ? img.encodePng(frame, level: 6)
          : img.encodeJpg(frame, quality: 88),
    ),
    detectedColour: WardrobeColour.nearestHex(hex),
  );
}

/// Placeholder for the classifier.
///
/// Not machine learning — a weighted colour histogram biased toward the centre
/// of the frame, where a garment photographed on a hanger or a flat surface
/// usually sits. Deliberately conservative, and the user confirms the result on
/// the next screen: exactly the hole the trained model will fill.
int _dominantColour(img.Image image) {
  final small = _thumbnail(image, 96);
  final cx = small.width / 2;
  final cy = small.height / 2;
  final maxDist = max(1.0, sqrt(cx * cx + cy * cy));

  final rSum = <int, double>{};
  final gSum = <int, double>{};
  final bSum = <int, double>{};
  final weight = <int, double>{};

  for (var y = 0; y < small.height; y++) {
    for (var x = 0; x < small.width; x++) {
      final p = small.getPixel(x, y);
      if (p.a.toInt() < 128) continue;

      final r = p.r.toInt().clamp(0, 255);
      final g = p.g.toInt().clamp(0, 255);
      final b = p.b.toInt().clamp(0, 255);

      final dist = sqrt(pow(x - cx, 2) + pow(y - cy, 2));
      var w = 1.0 + 3.0 * (1.0 - dist / maxDist);

      // Dim blown-out backdrop white and crushed shadow so the garment itself
      // wins the vote rather than the wall behind it.
      if (r > 240 && g > 240 && b > 240) w *= 0.45;
      if (r < 14 && g < 14 && b < 14) w *= 0.7;

      final key = (r >> 4) << 8 | (g >> 4) << 4 | (b >> 4);
      weight[key] = (weight[key] ?? 0) + w;
      rSum[key] = (rSum[key] ?? 0) + r * w;
      gSum[key] = (gSum[key] ?? 0) + g * w;
      bSum[key] = (bSum[key] ?? 0) + b * w;
    }
  }

  if (weight.isEmpty) return 0xFF121110;

  final best = weight.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  final total = weight[best]!;

  final r = (rSum[best]! / total).round().clamp(0, 255).toInt();
  final g = (gSum[best]! / total).round().clamp(0, 255).toInt();
  final b = (bSum[best]! / total).round().clamp(0, 255).toInt();
  return (0xFF << 24) | (r << 16) | (g << 8) | b;
}

img.Image _thumbnail(img.Image image, int maxSide) {
  if (image.width <= maxSide && image.height <= maxSide) return image;
  return image.width >= image.height
      ? img.copyResize(image, width: maxSide, interpolation: img.Interpolation.average)
      : img.copyResize(image, height: maxSide, interpolation: img.Interpolation.average);
}
