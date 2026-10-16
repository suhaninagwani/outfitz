import 'package:flutter/material.dart';

/// ── Categories ───────────────────────────────────────────────────────────────
/// Deliberately small. Each extra category makes tagging harder and outfit
/// generation noisier, so the wardrobe is built from these seven only.
enum GarmentCategory {
  tops('Tops', 'Top'),
  bottoms('Bottoms', 'Bottom'),
  layers('Layers', 'Layer'),
  dresses('Dresses', 'Dress'),
  shoes('Shoes', 'Shoes'),
  bags('Bags', 'Bag'),
  accessories('Accessories', 'Accessory');

  const GarmentCategory(this.label, this.singular);

  final String label;
  final String singular;

  static GarmentCategory? fromName(String? name) {
    for (final c in values) {
      if (c.name == name) return c;
    }
    return null;
  }
}

/// ── Mood ─────────────────────────────────────────────────────────────────────
/// The emotional half of the recommendation. Mood steers the *tone* of an
/// outfit; weather steers its *weight*.
enum Mood {
  elegant('Elegant', 'Sharp, quiet, tailored'),
  cosy('Cosy', 'Soft, warm, relaxed'),
  bold('Bold', 'Strong colour, big shapes'),
  minimal('Minimal', 'Clean lines, few pieces'),
  playful('Playful', 'Print, colour, movement'),
  romantic('Romantic', 'Flowing, soft, delicate'),
  sporty('Sporty', 'Easy, practical, moving');

  const Mood(this.label, this.hint);

  final String label;
  final String hint;

  static Mood? fromName(String? name) {
    for (final m in values) {
      if (m.name == name) return m;
    }
    return null;
  }
}

/// ── Colour ───────────────────────────────────────────────────────────────────
/// The five house colours lead the list; the rest are the neutrals that actually
/// live in a wardrobe. Everything the camera detects is snapped to this list.
class WardrobeColour {
  const WardrobeColour(this.name, this.hex);

  final String name;
  final int hex;

  Color get color => Color(hex);

  /// `true` for the five brand colours — used to reward on-brand outfits.
  bool get isHouseColour => palette.indexOf(this) < houseColours;

  static const houseColours = 5;

  static const palette = <WardrobeColour>[
    WardrobeColour('Wine', 0xFF580202),
    WardrobeColour('Maroon', 0xFF800000),
    WardrobeColour('Black', 0xFF121110),
    WardrobeColour('White', 0xFFFBFBF9),
    WardrobeColour('Butter', 0xFFF6DE8D),
    WardrobeColour('Cream', 0xFFF1E7D6),
    WardrobeColour('Camel', 0xFFC08A54),
    WardrobeColour('Denim', 0xFF3F5B7A),
    WardrobeColour('Olive', 0xFF6B7048),
    WardrobeColour('Slate', 0xFF8C8880),
    WardrobeColour('Blush', 0xFFE3B7B1),
    WardrobeColour('Chocolate', 0xFF4A3226),
  ];

  /// Snaps any colour to the closest palette entry — the "auto-detected colour"
  /// step, and the reason detected colours always look intentional.
  static WardrobeColour nearest(Color c) {
    WardrobeColour best = palette.first;
    var bestD = double.infinity;
    for (final p in palette) {
      final d = _distance(c, p.color);
      if (d < bestD) {
        bestD = d;
        best = p;
      }
    }
    return best;
  }

  /// Same as [nearest] but for a raw ARGB value, so background isolates don't
  /// need to know about the widget layer.
  static WardrobeColour nearestHex(int hex) => nearest(Color(hex));

  static WardrobeColour? byHex(int hex) {
    for (final p in palette) {
      if (p.hex == hex) return p;
    }
    return null;
  }

  static String nameOf(int hex) => byHex(hex)?.name ?? 'Custom';

  static double _distance(Color a, Color b) {
    // Perceptual-ish weighting: the eye is far more sensitive to green/red than
    // to blue, which stops navy lighting on a dark shirt reading as "black".
    final dr = (a.r - b.r) * 0.9;
    final dg = (a.g - b.g) * 1.2;
    final db = (a.b - b.b) * 0.7;
    return dr * dr + dg * dg + db * db;
  }
}

/// ── The item ─────────────────────────────────────────────────────────────────
class WardrobeItem {
  const WardrobeItem({
    required this.id,
    required this.name,
    required this.category,
    required this.colourHex,
    this.warmthMin = 16,
    this.warmthMax = 28,
    this.moods = const {Mood.minimal},
    this.imagePath,
    this.wornCount = 0,
    this.lastWorn,
    this.addedAt,
  });

  final String id;
  final String name;
  final GarmentCategory category;

  /// ARGB value, always one of [WardrobeColour.palette].
  final int colourHex;

  /// The comfortable temperature band, in °C. This is what makes the outfit
  /// engine weather-aware.
  final int warmthMin;
  final int warmthMax;

  final Set<Mood> moods;

  /// Absolute path of the cropped PNG in the app's documents directory.
  /// Null for seeded/demo items, which render as a colour swatch instead.
  final String? imagePath;

  final int wornCount;
  final DateTime? lastWorn;
  final DateTime? addedAt;

  Color get colour => Color(colourHex);
  String get colourName => WardrobeColour.nameOf(colourHex);
  bool get isDark => colour.computeLuminance() < 0.45;
  bool get isHouseColour => WardrobeColour.byHex(colourHex)?.isHouseColour ?? false;

  /// Colour that stays legible on top of [colour] — used by the swatch tiles.
  Color get onColour => isDark ? const Color(0xFFF6F1E8) : const Color(0xFF121110);

  /// Whole days since this piece was last worn, or null if never.
  int? daysSinceWorn([DateTime? now]) {
    if (lastWorn == null) return null;
    return (now ?? DateTime.now()).difference(lastWorn!).inDays;
  }

  String get warmthLabel => '$warmthMin–$warmthMax°C';

  WardrobeItem copyWith({
    String? name,
    GarmentCategory? category,
    int? colourHex,
    int? warmthMin,
    int? warmthMax,
    Set<Mood>? moods,
    String? imagePath,
    int? wornCount,
    DateTime? lastWorn,
  }) =>
      WardrobeItem(
        id: id,
        name: name ?? this.name,
        category: category ?? this.category,
        colourHex: colourHex ?? this.colourHex,
        warmthMin: warmthMin ?? this.warmthMin,
        warmthMax: warmthMax ?? this.warmthMax,
        moods: moods ?? this.moods,
        imagePath: imagePath ?? this.imagePath,
        wornCount: wornCount ?? this.wornCount,
        lastWorn: lastWorn ?? this.lastWorn,
        addedAt: addedAt,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'category': category.name,
        'colour': colourHex,
        'warmthMin': warmthMin,
        'warmthMax': warmthMax,
        'moods': moods.map((m) => m.name).toList(),
        'imagePath': imagePath,
        'wornCount': wornCount,
        'lastWorn': lastWorn?.toIso8601String(),
        'addedAt': addedAt?.toIso8601String(),
      };

  static WardrobeItem fromJson(Map<String, Object?> j) => WardrobeItem(
        id: j['id']! as String,
        name: j['name']! as String,
        category: GarmentCategory.fromName(j['category'] as String?) ?? GarmentCategory.tops,
        colourHex: (j['colour'] as num?)?.toInt() ?? 0xFF121110,
        warmthMin: (j['warmthMin'] as num?)?.toInt() ?? 16,
        warmthMax: (j['warmthMax'] as num?)?.toInt() ?? 28,
        moods: ((j['moods'] as List?) ?? const [])
            .map((e) => Mood.fromName(e as String?))
            .whereType<Mood>()
            .toSet(),
        imagePath: j['imagePath'] as String?,
        wornCount: (j['wornCount'] as num?)?.toInt() ?? 0,
        lastWorn: j['lastWorn'] == null ? null : DateTime.tryParse(j['lastWorn']! as String),
        addedAt: j['addedAt'] == null ? null : DateTime.tryParse(j['addedAt']! as String),
      );
}
