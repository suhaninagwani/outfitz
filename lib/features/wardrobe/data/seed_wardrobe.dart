import '../domain/wardrobe_item.dart';

/// Starter wardrobe so the app is never empty on first launch.
/// Colours are deliberately drawn from the house palette (wine · maroon ·
/// black · white · butter) plus a few wardrobe neutrals.
List<WardrobeItem> seedWardrobe() {
  final now = DateTime.now();
  DateTime ago(int days) => now.subtract(Duration(days: days));

  return <WardrobeItem>[
    // ── Tops ────────────────────────────────────────────────────────────────
    const WardrobeItem(
      id: 's-white-shirt',
      name: 'Silk shirt',
      category: GarmentCategory.tops,
      colourHex: 0xFFFBFBF9,
      warmthMin: 18,
      warmthMax: 30,
      moods: {Mood.elegant, Mood.minimal},
      wornCount: 6,
    ),
    const WardrobeItem(
      id: 's-wine-knit',
      name: 'Wine knit top',
      category: GarmentCategory.tops,
      colourHex: 0xFF580202,
      warmthMin: 12,
      warmthMax: 24,
      moods: {Mood.elegant, Mood.bold},
      wornCount: 3,
    ),
    const WardrobeItem(
      id: 's-black-tee',
      name: 'Ribbed tee',
      category: GarmentCategory.tops,
      colourHex: 0xFF121110,
      warmthMin: 16,
      warmthMax: 31,
      moods: {Mood.minimal, Mood.bold},
      wornCount: 11,
    ),
    const WardrobeItem(
      id: 's-butter-linen',
      name: 'Butter linen shirt',
      category: GarmentCategory.tops,
      colourHex: 0xFFF6DE8D,
      warmthMin: 22,
      warmthMax: 34,
      moods: {Mood.playful, Mood.minimal},
      wornCount: 2,
    ),
    const WardrobeItem(
      id: 's-maroon-turtle',
      name: 'Maroon turtleneck',
      category: GarmentCategory.tops,
      colourHex: 0xFF800000,
      warmthMin: 2,
      warmthMax: 17,
      moods: {Mood.elegant, Mood.cosy},
      wornCount: 4,
    ),

    // ── Bottoms ─────────────────────────────────────────────────────────────
    const WardrobeItem(
      id: 's-tailored',
      name: 'Tailored trousers',
      category: GarmentCategory.bottoms,
      colourHex: 0xFF121110,
      warmthMin: 10,
      warmthMax: 28,
      moods: {Mood.elegant, Mood.minimal},
      wornCount: 9,
    ),
    const WardrobeItem(
      id: 's-jeans',
      name: 'Straight jeans',
      category: GarmentCategory.bottoms,
      colourHex: 0xFF3F5B7A,
      warmthMin: 6,
      warmthMax: 26,
      moods: {Mood.minimal, Mood.sporty},
      wornCount: 14,
    ),
    const WardrobeItem(
      id: 's-cream-wide',
      name: 'Wide-leg trousers',
      category: GarmentCategory.bottoms,
      colourHex: 0xFFF1E7D6,
      warmthMin: 16,
      warmthMax: 32,
      moods: {Mood.elegant, Mood.romantic},
      wornCount: 5,
    ),
    const WardrobeItem(
      id: 's-camel-skirt',
      name: 'Pleated skirt',
      category: GarmentCategory.bottoms,
      colourHex: 0xFFC08A54,
      warmthMin: 12,
      warmthMax: 26,
      moods: {Mood.elegant, Mood.cosy},
      wornCount: 3,
    ),

    // ── Layers ──────────────────────────────────────────────────────────────
    const WardrobeItem(
      id: 's-wool-coat',
      name: 'Wool coat',
      category: GarmentCategory.layers,
      colourHex: 0xFF800000,
      warmthMin: -2,
      warmthMax: 15,
      moods: {Mood.elegant, Mood.bold},
      wornCount: 2,
    ),
    const WardrobeItem(
      id: 's-cardigan',
      name: 'Oatmeal cardigan',
      category: GarmentCategory.layers,
      colourHex: 0xFFF1E7D6,
      warmthMin: 5,
      warmthMax: 20,
      moods: {Mood.cosy, Mood.romantic},
      wornCount: 7,
    ),
    const WardrobeItem(
      id: 's-denim-jacket',
      name: 'Denim jacket',
      category: GarmentCategory.layers,
      colourHex: 0xFF3F5B7A,
      warmthMin: 8,
      warmthMax: 22,
      moods: {Mood.sporty, Mood.minimal},
      wornCount: 6,
    ),
    const WardrobeItem(
      id: 's-blazer',
      name: 'Black blazer',
      category: GarmentCategory.layers,
      colourHex: 0xFF121110,
      warmthMin: 8,
      warmthMax: 24,
      moods: {Mood.elegant, Mood.bold},
      wornCount: 8,
    ),

    // ── Dresses ─────────────────────────────────────────────────────────────
    const WardrobeItem(
      id: 's-slip-dress',
      name: 'Satin slip dress',
      category: GarmentCategory.dresses,
      colourHex: 0xFF580202,
      warmthMin: 18,
      warmthMax: 32,
      moods: {Mood.romantic, Mood.bold},
      wornCount: 2,
    ),
    const WardrobeItem(
      id: 's-midi',
      name: 'Black midi dress',
      category: GarmentCategory.dresses,
      colourHex: 0xFF121110,
      warmthMin: 12,
      warmthMax: 28,
      moods: {Mood.elegant, Mood.minimal},
      wornCount: 4,
    ),

    // ── Shoes ───────────────────────────────────────────────────────────────
    const WardrobeItem(
      id: 's-loafers',
      name: 'Leather loafers',
      category: GarmentCategory.shoes,
      colourHex: 0xFF4A3226,
      warmthMin: 8,
      warmthMax: 28,
      moods: {Mood.elegant, Mood.minimal},
      wornCount: 10,
    ),
    const WardrobeItem(
      id: 's-sneakers',
      name: 'White sneakers',
      category: GarmentCategory.shoes,
      colourHex: 0xFFFBFBF9,
      warmthMin: 5,
      warmthMax: 32,
      moods: {Mood.sporty, Mood.minimal},
      wornCount: 22,
    ),
    const WardrobeItem(
      id: 's-boots',
      name: 'Heeled boots',
      category: GarmentCategory.shoes,
      colourHex: 0xFF121110,
      warmthMin: -2,
      warmthMax: 18,
      moods: {Mood.bold, Mood.elegant},
      wornCount: 3,
    ),

    // ── Bags & accessories ──────────────────────────────────────────────────
    const WardrobeItem(
      id: 's-butter-bag',
      name: 'Butter shoulder bag',
      category: GarmentCategory.bags,
      colourHex: 0xFFF6DE8D,
      warmthMin: -5,
      warmthMax: 45,
      moods: {Mood.playful, Mood.elegant},
      wornCount: 6,
    ),
    const WardrobeItem(
      id: 's-tote',
      name: 'Structured tote',
      category: GarmentCategory.bags,
      colourHex: 0xFF121110,
      warmthMin: -5,
      warmthMax: 45,
      moods: {Mood.elegant, Mood.minimal},
      wornCount: 12,
    ),
    const WardrobeItem(
      id: 's-scarf',
      name: 'Silk scarf',
      category: GarmentCategory.accessories,
      colourHex: 0xFF580202,
      warmthMin: -5,
      warmthMax: 45,
      moods: {Mood.romantic, Mood.bold},
      wornCount: 1,
    ),
    const WardrobeItem(
      id: 's-hoops',
      name: 'Gold hoops',
      category: GarmentCategory.accessories,
      colourHex: 0xFFC08A54,
      warmthMin: -5,
      warmthMax: 45,
      moods: {Mood.playful, Mood.elegant},
      wornCount: 18,
    ),
  ]
      .map((i) => i.copyWith(wornCount: i.wornCount, lastWorn: _lastWorn(i, ago)))
      .toList();
}

/// Deterministic "recently worn" dates so the freshness logic has something to
/// chew on in the demo.
DateTime? _lastWorn(WardrobeItem item, DateTime Function(int) ago) {
  final offset = item.id.hashCode.abs() % 9;
  return offset > 3 ? null : ago(offset);
}
