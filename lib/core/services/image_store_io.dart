import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

/// Native storage: one PNG per piece in `<documents>/wardrobe/`.
class ImageStore {
  ImageStore.at(this.directory);

  final Directory directory;

  static Future<ImageStore> open() async {
    try {
      final docs = await getApplicationDocumentsDirectory();
      final dir = Directory('${docs.path}${Platform.pathSeparator}wardrobe');
      if (!dir.existsSync()) {
        await dir.create(recursive: true);
      }
      return ImageStore.at(dir);
    } on Exception {
      // Some Android skins lock down the documents directory. Losing
      // persistence is far better than failing to launch.
      return ImageStore.at(Directory.systemTemp);
    }
  }

  /// Writes the cropped photo and returns its absolute path.
  Future<String> savePng(Uint8List bytes, String id) async {
    final file = File('${directory.path}${Platform.pathSeparator}$id.png');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<void> delete(String? source) async {
    if (source == null || source.isEmpty) return;
    final file = File(source);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
