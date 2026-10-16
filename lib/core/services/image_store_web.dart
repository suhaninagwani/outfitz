import 'dart:convert';
import 'dart:typed_data';

/// Web storage: no file system, so the photo travels as a data URI.
///
/// Kept short on purpose — a browser's local storage will not hold a shelf of
/// full-size PNGs, which is why the web build crops to a smaller, lossy copy.
class ImageStore {
  ImageStore.at(this.directory);

  /// Unused on the web; kept so callers can construct the store the same way.
  final Object? directory;

  static Future<ImageStore> open() async => ImageStore.at(null);

  Future<String> savePng(Uint8List bytes, String id) async =>
      'data:image/png;base64,${base64Encode(bytes)}';

  Future<void> delete(String? source) async {
    // Nothing to clean up: the data URI disappears with the wardrobe record.
  }
}
