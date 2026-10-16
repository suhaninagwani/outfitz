import '../../wardrobe/domain/wardrobe_item.dart';

/// A finished suggestion: the pieces, how well they fit the day, and the
/// human-readable reason — the "Why this?" copy.
class Outfit {
  const Outfit({
    required this.title,
    required this.items,
    required this.match,
    required this.reason,
    required this.weatherFit,
  });

  final String title;
  final List<WardrobeItem> items;

  /// 0–100. Drives the match badge and the weather-fit bar.
  final int match;
  final int weatherFit;

  final String reason;

  WardrobeItem? itemIn(GarmentCategory c) {
    for (final i in items) {
      if (i.category == c) return i;
    }
    return null;
  }

  List<WardrobeItem> get colourStory => items;
}
