import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/outfits/data/outfit_engine.dart';
import '../features/outfits/domain/outfit.dart';
import '../features/planner/domain/planned_day.dart';
import '../features/wardrobe/data/wardrobe_repository.dart';
import '../features/wardrobe/domain/wardrobe_item.dart';
import '../features/weather/data/weather_repository.dart';
import '../features/weather/domain/weather.dart';
import 'services/image_store.dart';

/// ─────────────────────────────────────────────────────────────────────────────
///  Injected in `main()` once, before the first frame.
/// ─────────────────────────────────────────────────────────────────────────────
final prefsProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError('prefsProvider must be overridden in main()'),
);

final imageStoreProvider = Provider<ImageStore>(
  (_) => throw UnimplementedError('imageStoreProvider must be overridden in main()'),
);

final wardrobeRepositoryProvider = Provider<WardrobeRepository>(
  (_) => throw UnimplementedError('wardrobeRepositoryProvider must be overridden in main()'),
);

/// ─────────────────────────────────────────────────────────────────────────────
///  App chrome
/// ─────────────────────────────────────────────────────────────────────────────
class ShellTab extends Notifier<int> {
  @override
  int build() => 0;

  void go(int index) => state = index;
}

final shellTabProvider = NotifierProvider<ShellTab, int>(ShellTab.new);

class OnboardingSeen extends Notifier<bool> {
  static const _key = 'outfitz.onboarding.seen';

  @override
  bool build() => ref.watch(prefsProvider).getBool(_key) ?? false;

  Future<void> finish() async {
    await ref.read(prefsProvider).setBool(_key, true);
    state = true;
  }

  Future<void> replay() async {
    await ref.read(prefsProvider).setBool(_key, false);
    state = false;
  }
}

final onboardingSeenProvider =
    NotifierProvider<OnboardingSeen, bool>(OnboardingSeen.new);

/// ─────────────────────────────────────────────────────────────────────────────
///  Stateless services
/// ─────────────────────────────────────────────────────────────────────────────
final weatherRepositoryProvider = Provider<WeatherRepository>((_) => const WeatherRepository());

final outfitEngineProvider = Provider<OutfitEngine>((_) => const OutfitEngine());

final weatherProvider = Provider<Weather>(
  (ref) => ref.watch(weatherRepositoryProvider).today(),
);

/// ─────────────────────────────────────────────────────────────────────────────
///  Wardrobe
/// ─────────────────────────────────────────────────────────────────────────────
class WardrobeController extends Notifier<List<WardrobeItem>> {
  @override
  List<WardrobeItem> build() => ref.watch(wardrobeRepositoryProvider).items;

  Future<void> add(WardrobeItem item) async {
    final repo = ref.read(wardrobeRepositoryProvider);
    await repo.upsert(item);
    state = repo.items;
  }

  Future<void> update(WardrobeItem item) => add(item);

  Future<void> remove(WardrobeItem item) async {
    final repo = ref.read(wardrobeRepositoryProvider);
    await repo.remove(item.id);
    await ref.read(imageStoreProvider).delete(item.imagePath);
    state = repo.items;
  }

  Future<void> markWorn(WardrobeItem item) async {
    final repo = ref.read(wardrobeRepositoryProvider);
    await repo.markWorn(item.id);
    state = repo.items;
  }

  Future<void> restoreDemoWardrobe() async {
    final repo = ref.read(wardrobeRepositoryProvider);
    await repo.reset();
    state = repo.items;
  }
}

final wardrobeProvider =
    NotifierProvider<WardrobeController, List<WardrobeItem>>(WardrobeController.new);

class CategoryFilter extends Notifier<GarmentCategory?> {
  @override
  GarmentCategory? build() => null;

  void select(GarmentCategory? category) => state = category;
}

final categoryFilterProvider =
    NotifierProvider<CategoryFilter, GarmentCategory?>(CategoryFilter.new);

final visibleWardrobeProvider = Provider<List<WardrobeItem>>((ref) {
  final items = ref.watch(wardrobeProvider);
  final filter = ref.watch(categoryFilterProvider);
  return filter == null ? items : items.where((i) => i.category == filter).toList();
});

/// How much of the wardrobe sits in each house colour — powers the "in your
/// palette" strip on Home and the Insights screen.
final paletteBreakdownProvider = Provider<List<(WardrobeColour, int)>>((ref) {
  final items = ref.watch(wardrobeProvider);
  final counts = <WardrobeColour, int>{};
  for (final i in items) {
    final c = WardrobeColour.byHex(i.colourHex);
    if (c == null) continue;
    counts[c] = (counts[c] ?? 0) + 1;
  }
  final entries = counts.entries.map((e) => (e.key, e.value)).toList()
    ..sort((a, b) => b.$2.compareTo(a.$2));
  return entries;
});

/// ─────────────────────────────────────────────────────────────────────────────
///  Today's suggestion
/// ─────────────────────────────────────────────────────────────────────────────
class SelectedMood extends Notifier<Mood?> {
  @override
  Mood? build() => null;

  void select(Mood? mood) => state = mood;
}

final selectedMoodProvider = NotifierProvider<SelectedMood, Mood?>(SelectedMood.new);

class OutfitVariant extends Notifier<int> {
  @override
  int build() => 0;

  /// "Show another"
  void next() => state = state + 1;
}

final outfitVariantProvider = NotifierProvider<OutfitVariant, int>(OutfitVariant.new);

final todaysOutfitProvider = Provider<Outfit>((ref) {
  return ref.watch(outfitEngineProvider).build(
        weather: ref.watch(weatherProvider),
        wardrobe: ref.watch(wardrobeProvider),
        mood: ref.watch(selectedMoodProvider),
        variant: ref.watch(outfitVariantProvider),
      );
});

/// ─────────────────────────────────────────────────────────────────────────────
///  Planner
/// ─────────────────────────────────────────────────────────────────────────────
class AutoPlanSeed extends Notifier<int> {
  @override
  int build() => 0;

  void regenerate() => state = state + 1;
}

final autoPlanSeedProvider = NotifierProvider<AutoPlanSeed, int>(AutoPlanSeed.new);

/// The next five days, each with a generated outfit. Recomputed whenever the
/// wardrobe changes or the user taps Auto-plan.
final weekPlanProvider = Provider<List<PlannedDay>>((ref) {
  final weather = ref.watch(weatherRepositoryProvider).week();
  final wardrobe = ref.watch(wardrobeProvider);
  final engine = ref.watch(outfitEngineProvider);
  final seed = ref.watch(autoPlanSeedProvider);
  final today = DateTime.now();

  return [
    for (var i = 0; i < weather.length; i++)
      PlannedDay(
        date: DateTime(today.year, today.month, today.day + i),
        weather: weather[i],
        // Tomorrow is left empty on purpose — it shows the "plan a day" state.
        outfit: i == 1
            ? null
            : engine.build(
                weather: weather[i],
                wardrobe: wardrobe,
                variant: seed + i,
              ),
      ),
  ];
});
