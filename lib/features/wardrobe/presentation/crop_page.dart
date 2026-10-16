import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/crop_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/ornaments.dart';
import 'confirm_item_page.dart';

/// Step 2: crop the garment out of the photo, then hand the pixels to the
/// background isolate for colour detection.
class CropPage extends ConsumerStatefulWidget {
  const CropPage({required this.source, super.key});

  /// An upright, already-normalised image (see [normalisePhoto]).
  final Uint8List source;

  @override
  ConsumerState<CropPage> createState() => _CropPageState();
}

class _CropPageState extends ConsumerState<CropPage> {
  ui.Image? _image;
  Size _imageSize = Size.zero;
  String? _error;

  Rect? _crop;
  bool _working = false;

  /// Portrait crop — how garments are usually shot.
  static const _aspect = 3 / 4;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final buffer = await ui.ImmutableBuffer.fromUint8List(widget.source);
      final descriptor = await ui.ImageDescriptor.encoded(buffer);
      final sourceWidth = descriptor.width;

      // Decode down for the preview only; the crop itself always runs on the
      // full-resolution bytes.
      final codec = await descriptor.instantiateCodec(
        targetWidth: sourceWidth > 1200 ? 1200 : null,
      );
      final frame = await codec.getNextFrame();

      if (!mounted) return;
      setState(() {
        _image = frame.image;
        _imageSize = Size(
          descriptor.width.toDouble(),
          descriptor.height.toDouble(),
        );
      });
    } on Exception catch (error) {
      if (mounted) setState(() => _error = '$error');
    }
  }

  Rect _photoRect(Size box) {
    final fitted = applyBoxFit(BoxFit.contain, _imageSize, box);
    return Alignment.center.inscribe(fitted.destination, Offset.zero & box);
  }

  Rect _initialCrop(Rect photo) {
    var h = photo.height * .82;
    var w = h * _aspect;
    if (w > photo.width * .92) {
      w = photo.width * .92;
      h = w / _aspect;
    }
    return Rect.fromCenter(center: photo.center, width: w, height: h);
  }

  Rect _clamp(Rect crop, Rect photo) {
    final w = crop.width.clamp(_aspect * 60, photo.width);
    final h = w / _aspect;
    var left = crop.left.clamp(photo.left, photo.right - w);
    var top = crop.top.clamp(photo.top, photo.bottom - h);
    if (top + h > photo.bottom) top = photo.bottom - h;
    if (left + w > photo.right) left = photo.right - w;
    return Rect.fromLTWH(left, top, w, h);
  }

  Future<void> _confirm(Rect photo) async {
    final crop = _crop!;
    setState(() => _working = true);

    try {
      final result = await cropAndDetect(
        CropRequest(
          source: widget.source,
          left: (crop.left - photo.left) / photo.width,
          top: (crop.top - photo.top) / photo.height,
          width: crop.width / photo.width,
          height: crop.height / photo.height,
          // A browser's local storage cannot hold a shelf of full-size photos,
          // so the web build keeps them small and lossy.
          maxWidth: kIsWeb ? 900 : 1400,
          lossless: !kIsWeb,
        ),
      );
      if (!mounted) return;
      setState(() => _working = false);
      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => ConfirmItemPage(
            imageBytes: result.imageBytes,
            detectedColour: result.detectedColour,
          ),
        ),
      );
    } on Exception catch (error) {
      if (!mounted) return;
      setState(() => _working = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cropping failed: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ready = _image != null && _imageSize != Size.zero;

    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        backgroundColor: AppColors.ink,
        foregroundColor: AppColors.white,
        titleTextStyle: AppText.serif(19, color: AppColors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Crop'),
        actions: [
          TextButton(
            onPressed: ready ? () => setState(() => _crop = null) : null,
            child: const MicroLabel('reset', color: AppColors.butter, spacing: 1.8),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(34),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
            child: Row(
              children: [
                const MicroLabel('01 source', size: 9, spacing: 1.4, color: Colors.white38),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: HairlineRule(color: Colors.white24),
                  ),
                ),
                const MicroLabel('02 crop', size: 9, spacing: 1.4, color: AppColors.butter),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: HairlineRule(color: Colors.white24),
                  ),
                ),
                const MicroLabel('03 tags', size: 9, spacing: 1.4, color: Colors.white38),
              ],
            ),
          ),
        ),
      ),
      body: _error != null
          ? _ErrorState(message: _error!)
          : !ready
              ? const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 1.6),
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final box = Size(constraints.maxWidth, constraints.maxHeight - 132);
                    final photo = _photoRect(box);
                    _crop ??= _initialCrop(photo);
                    _crop = _clamp(_crop!, photo);
                    final crop = _crop!;

                    return Column(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onPanUpdate: (d) => setState(() {
                              _crop = _clamp(crop.shift(d.delta), photo);
                            }),
                            child: Stack(
                              children: [
                                Positioned.fromRect(
                                  rect: photo,
                                  child: RawImage(
                                    image: _image,
                                    fit: BoxFit.fill,
                                    filterQuality: FilterQuality.medium,
                                  ),
                                ),
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: _CropOverlayPainter(
                                      crop: crop,
                                      photo: photo,
                                    ),
                                  ),
                                ),
                                // Resize handle, bottom-right.
                                Positioned(
                                  left: crop.right - 26,
                                  top: crop.bottom - 26,
                                  width: 52,
                                  height: 52,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onPanUpdate: (d) => setState(() {
                                      final grown = crop.width + d.delta.dx;
                                      _crop = _clamp(
                                        Rect.fromLTWH(
                                          crop.left,
                                          crop.top,
                                          grown,
                                          grown / _aspect,
                                        ),
                                        photo,
                                      );
                                    }),
                                    child: const _Handle(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        _CropFooter(
                          working: _working,
                          onConfirm: () => _confirm(photo),
                        ),
                      ],
                    );
                  },
                ),
    );
  }
}

class _CropFooter extends StatelessWidget {
  const _CropFooter({required this.working, required this.onConfirm});

  final bool working;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 26),
        color: AppColors.ink,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Ornament(kind: OrnamentKind.circle, size: 12, color: AppColors.butter),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Drag to move the window, pull the corner to size it. Keep it to '
                    'one garment.',
                    style: AppText.sans(12, FontWeight.w400, height: 1.5, color: Colors.white70),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: working ? null : onConfirm,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.wine,
                disabledBackgroundColor: AppColors.wine.withValues(alpha: .5),
              ),
              child: working
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.6,
                        color: AppColors.white,
                      ),
                    )
                  : const Text('Use this crop'),
            ),
          ],
        ),
      );
}

class _Handle extends StatelessWidget {
  const _Handle();

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.bottomRight,
        child: Container(
          width: 34,
          height: 34,
          margin: const EdgeInsets.only(right: 12, bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.butter,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.wine, width: 1.4),
          ),
          child: const Icon(Icons.open_in_full, size: 15, color: AppColors.wine),
        ),
      );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.broken_image_outlined, color: AppColors.white, size: 34),
              const SizedBox(height: 16),
              Text(
                'That photo could not be read.',
                style: AppText.sans(15, FontWeight.w500, color: AppColors.white),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppText.sans(12, FontWeight.w400, color: Colors.white70),
              ),
            ],
          ),
        ),
      );
}

/// Darkens everything outside the crop window and draws the rule of thirds.
class _CropOverlayPainter extends CustomPainter {
  _CropOverlayPainter({required this.crop, required this.photo});

  final Rect crop;
  final Rect photo;

  @override
  void paint(Canvas canvas, Size size) {
    final scrim = Paint()..color = AppColors.black.withValues(alpha: .62);
    canvas.save();
    canvas.clipRect(crop, clipOp: ui.ClipOp.difference);
    canvas.drawRect(Offset.zero & size, scrim);
    canvas.restore();

    final hair = Paint()
      ..color = AppColors.white.withValues(alpha: .28)
      ..strokeWidth = 1;
    for (var i = 1; i < 3; i++) {
      final dx = crop.left + crop.width * i / 3;
      final dy = crop.top + crop.height * i / 3;
      canvas.drawLine(Offset(dx, crop.top), Offset(dx, crop.bottom), hair);
      canvas.drawLine(Offset(crop.left, dy), Offset(crop.right, dy), hair);
    }

    final tick = Paint()
      ..color = AppColors.butter
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.square;
    const len = 20.0;
    for (final (o, sx, sy) in [
      (crop.topLeft, 1.0, 1.0),
      (crop.topRight, -1.0, 1.0),
      (crop.bottomLeft, 1.0, -1.0),
      (crop.bottomRight, -1.0, -1.0),
    ]) {
      canvas.drawLine(o, o.translate(len * sx, 0), tick);
      canvas.drawLine(o, o.translate(0, len * sy), tick);
    }
  }

  @override
  bool shouldRepaint(_CropOverlayPainter old) =>
      old.crop != crop || old.photo != photo;
}
