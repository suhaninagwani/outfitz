/// Renders a stored garment photo.
///
/// The wardrobe only stores an opaque source string: a file path on phones and
/// desktops, a data URI on the web. This is the single place that knows the
/// difference.
export 'garment_image_io.dart' if (dart.library.js_interop) 'garment_image_web.dart';
