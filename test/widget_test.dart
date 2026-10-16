import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:outfitz/app.dart';
import 'package:outfitz/core/providers.dart';
import 'package:outfitz/features/outfits/data/outfit_engine.dart';
import 'package:outfitz/features/wardrobe/data/seed_wardrobe.dart';
import 'package:outfitz/features/wardrobe/data/wardrobe_repository.dart';
import 'package:outfitz/features/wardrobe/domain/wardrobe_item.dart';
import 'package:outfitz/features/weather/data/weather_repository.dart';
import 'package:outfitz/features/weather/domain/weather.dart';

Weather _weatherAt(int temp) => Weather(
      city: 'Test',
      label: 'Clear',
      temp: temp,
      feels: temp,
      humidity: 40,
      wind: 5,
      rainChance: 5,
      sunrise: '06:00',
      sunset: '18:00',
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('outfit engine', () {
    const engine = OutfitEngine();

    test('builds a complete outfit from the seed wardrobe', () {
      final outfit = engine.build(
        weather: const WeatherRepository().today(),
        wardrobe: seedWardrobe(),
      );

      expect(outfit.items, isNotEmpty);
      expect(outfit.match, greaterThan(50));
      expect(outfit.reason, isNotEmpty);
    });

    test('leaves the layer behind when it is too warm for one', () {
      final outfit = engine.build(
        weather: _weatherAt(33),
        wardrobe: seedWardrobe(),
      );

      expect(
        outfit.items.where((i) => i.category == GarmentCategory.layers),
        isEmpty,
      );
    });

    test('"show another" returns a different outfit', () {
      final first = engine.build(weather: _weatherAt(25), wardrobe: seedWardrobe());
      final second =
          engine.build(weather: _weatherAt(25), wardrobe: seedWardrobe(), variant: 1);

      expect(
        first.items.map((i) => i.id).join(),
        isNot(second.items.map((i) => i.id).join()),
      );
    });
  });

  testWidgets('boots through the splash screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final wardrobe = await WardrobeRepository.open(prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          wardrobeRepositoryProvider.overrideWithValue(wardrobe),
        ],
        child: const OutfitzApp(),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Outfitz'), findsWidgets);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });
}
