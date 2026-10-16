/// Where cropped garment images live.
///
/// The wardrobe needs somewhere to put a PNG. On a phone that is a real file in
/// the app's documents directory; on the web there are no files, so the bytes
/// are kept as a data URI and stashed alongside the rest of the wardrobe.
/// Everything downstream only ever sees an opaque [String] source.
export 'image_store_io.dart' if (dart.library.js_interop) 'image_store_web.dart';
