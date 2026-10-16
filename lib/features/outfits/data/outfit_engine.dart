import 'dart:math';

import '../../wardrobe/domain/wardrobe_item.dart';
import '../../weather/domain/weather.dart';
import '../domain/outfit.dart';

/// The rules that stand in for the model.
///
/// This is intentionally explainable: weather decides the *weight* of the
/// outfit, mood decides its *tone*, and a freshness rule stops the same tee
/// showing up three days running. When the trained classifier lands it will only
/// replace [OutfitEngine._score] — everything downstream already works.
class OutfitEngine {
  const OutfitEngine();

  /// [variant] is the "Show another" counter. It rotates through the top few
  /// candidates so the suggestion visibly changes without turning random.
  Outfit build({
    required Weather weather,
    required List<WardrobeItem> wardrobe,
    Mood? mood,
    int variant = 0,
  }) {
    final slots = _slots(weather);
    final picks = <WardrobeItem>[];

    for (final slot in slots) {
      final pick = _pick(
        category: slot,
        weather: weather,
        wardrobe: wardrobe,
        mood: mood,
        variant: variant,
      );
      if (pick != null) picks.add(pick);
    }

    // A bag or accessory is the finishing note — never the headline.
    final finishing = _pick(
      category: variant.isEven ? GarmentCategory.bags : GarmentCategory.accessories,
      weather: weather,
      wardrobe: wardrobe,
      mood: mood,
      variant: variant,
    );
    if (finishing != null) picks.add(finishing);

    if (picks.isEmpty) {
      return Outfit(
        title: 'Add a piece',
        items: const [],
        match: 0,
        weatherFit: 0,
        reason: 'Your wardrobe is empty. Photograph a top, a bottom and shoes '
            'and Outfitz can start dressing you for the day.',
      );
    }

    final fit = _weatherFit(picks, weather);
    final harmony = _colourHarmony(picks);
    final moodHit = mood == null || picks.any((p) => p.moods.contains(mood)) ? 1.0 : 0.0;

    return Outfit(
      title: _title(weather, picks, mood),
      items: picks,
      match: (62 + fit * 22 + harmony * 12 + moodHit * 4).round().clamp(64, 98),
      weatherFit: (fit * 100).round().clamp(50, 100),
      reason: _reason(weather, picks, mood),
    );
  }

  // ── Slots ──────────────────────────────────────────────────────────────────
  /// What a complete outfit needs at this temperature. Layers only appear when
  /// it is actually cool enough to want one.
  List<GarmentCategory> _slots(Weather weather) {
    final slots = <GarmentCategory>[];
    if (weather.temp < 24) slots.add(GarmentCategory.layers);
    slots.add(GarmentCategory.tops);
    slots.add(GarmentCategory.bottoms);
    slots.add(GarmentCategory.shoes);
    return slots;
  }

  // ── Selection ──────────────────────────────────────────────────────────────
  WardrobeItem? _pick({
    required GarmentCategory category,
    required Weather weather,
    required List<WardrobeItem> wardrobe,
    required Mood? mood,
    required int variant,
  }) {
    final all = wardrobe.where((i) => i.category == category).toList();
    if (all.isEmpty) return null;

    // Prefer pieces whose comfort band contains today's temperature. If nothing
    // fits (a very odd day), fall back to the whole category rather than
    // returning nothing.
    final inBand = all
        .where((i) => weather.temp >= i.warmthMin && weather.temp <= i.warmthMax)
        .toList();
    final pool = inBand.isNotEmpty ? inBand : all;

    pool.sort((a, b) {
      final s = _score(b, weather, mood).compareTo(_score(a, weather, mood));
      return s != 0 ? s : a.id.compareTo(b.id); // stable, so results are repeatable
    });

    // Rotate through the top three so "Show another" gives a different but still
    // good answer.
    final window = min(3, pool.length);
    return pool[variant % window];
  }

  double _score(WardrobeItem item, Weather weather, Mood? mood) {
    var score = 50.0;

    if (mood != null && item.moods.contains(mood)) score += 20;

    if (weather.temp >= item.warmthMin && weather.temp <= item.warmthMax) {
      score += 18;
    } else {
      final gap = weather.temp < item.warmthMin
          ? item.warmthMin - weather.temp
          : weather.temp - item.warmthMax;
      score -= gap * 2.5;
    }

    // Freshness: something worn in the last two days drops down the list.
    final days = item.daysSinceWorn();
    if (days == null) {
      score += 5; // never worn — good to surface
    } else if (days == 0) {
      score -= 22;
    } else if (days <= 2) {
      score -= 12;
    }

    if (item.isHouseColour) score += 7;

    // Tiny deterministic wobble so equally-scored pieces alternate.
    score += (item.id.hashCode.abs() % 7) - 3;
    return score;
  }

  // ── Judging ────────────────────────────────────────────────────────────────
  double _weatherFit(List<WardrobeItem> items, Weather weather) {
    var total = 0.0;
    for (final i in items) {
      if (weather.temp >= i.warmthMin && weather.temp <= i.warmthMax) {
        total += 1;
      } else {
        final gap = weather.temp < i.warmthMin
            ? i.warmthMin - weather.temp
            : weather.temp - i.warmthMax;
        total += (1 - gap / 12).clamp(0.0, 1.0);
      }
    }
    return total / items.length;
  }

  /// How well the colours sit together. Two house colours plus a neutral is the
  /// house combination, so it scores highest.
  double _colourHarmony(List<WardrobeItem> items) {
    final house = items.where((i) => i.isHouseColour).length;
    final distinct = items.map((i) => i.colourHex).toSet().length;
    var score = 0.35;
    if (house >= 2) score += 0.3;
    if (distinct <= items.length) score += 0.15;
    if (house >= 3) score += 0.1;
    return score.clamp(0.0, 1.0);
  }

  // ── Copy ───────────────────────────────────────────────────────────────────
  String _title(Weather weather, List<WardrobeItem> items, Mood? mood) {
    final base = switch (weather.temp) {
      >= 32 => 'Heatwave ease',
      >= 28 => 'Warm-weather ease',
      >= 24 => 'Easy daytime',
      >= 19 => 'Soft layers',
      >= 13 => 'City layers',
      _ => 'Deep winter tailoring',
    };
    if (mood == null) return base;
    return '${mood.label} $base'.replaceFirst('Elegant', 'Quiet').toLowerCase();
  }

  String _reason(Weather weather, List<WardrobeItem> items, Mood? mood) {
    final top = items.firstWhere(
      (i) => i.category == GarmentCategory.tops,
      orElse: () => items.first,
    );
    final bottom = items.firstWhere(
      (i) => i.category == GarmentCategory.bottoms,
      orElse: () => items.first,
    );

    final buffer = StringBuffer()
      ..write('${weather.temp}° and ${weather.isWet ? 'damp' : 'dry'}, so ')
      ..write('the ${_describe(top)} and ')
      ..write('${_describe(bottom)} ')
      ..write(weather.isHot ? 'stay breathable. ' : 'hold their weight well. ');

    if (mood != null) {
      buffer.write('Kept ${mood.label.toLowerCase()} because that is the mood you '
          'picked — ${mood.hint.toLowerCase()}. ');
    }

    final stale = items.where((i) => (i.daysSinceWorn() ?? 99) <= 1).toList();
    if (stale.isEmpty) {
      buffer.write('Nothing here was worn in the last day, so it all reads fresh.');
    } else {
      buffer.write('${stale.first.name} went on yesterday, so keep it to one '
          'repeat today.');
    }
    return buffer.toString();
  }

  /// Piece names usually lead with their colour already ("Wine knit top"), so
  /// only add it when it is missing — otherwise the sentence reads "the wine
  /// wine knit top".
  String _describe(WardrobeItem item) {
    final name = item.name.toLowerCase();
    final colour = item.colourName.toLowerCase();
    return name.contains(colour) ? name : '$colour $name';
  }
}
