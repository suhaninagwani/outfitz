import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:outfitz/app.dart';
import 'package:outfitz/core/providers.dart';
import 'package:outfitz/features/wardrobe/data/wardrobe_repository.dart';

/// Headless screenshots for the README.
///
/// Run with:
///   flutter test test/screenshots.dart --update-goldens
///
/// Deliberately not named `*_test.dart`, so a plain `flutter test` skips it — it
/// writes files into `images/` rather than asserting anything. It renders at a
/// phone viewport (430 × 932 @2x) so the README shows the app the way it
/// actually appears in a hand.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(_loadBrandFonts);

  Future<void> pumpApp(WidgetTester tester, {required bool onboarded}) async {
    SharedPreferences.setMockInitialValues({
      if (onboarded) 'outfitz.onboarding.seen': true,
    });
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

    // Past the splash.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  }

  Future<void> capture(WidgetTester tester, String name) =>
      expectLater(find.byType(OutfitzApp), matchesGoldenFile('../images/$name'));

  testWidgets('onboarding', (tester) async {
    await _phoneViewport(tester);
    await pumpApp(tester, onboarded: false);
    await capture(tester, '01-onboarding.png');
  });

  testWidgets('home', (tester) async {
    await _phoneViewport(tester);
    await pumpApp(tester, onboarded: true);
    await capture(tester, '02-home.png');
  });

  testWidgets('wardrobe', (tester) async {
    await _phoneViewport(tester);
    await pumpApp(tester, onboarded: true);
    await tester.tap(find.text('WARDROBE'));
    await tester.pumpAndSettle();
    await capture(tester, '03-wardrobe.png');
  });

  testWidgets('wardrobe insights', (tester) async {
    await _phoneViewport(tester);
    await pumpApp(tester, onboarded: true);
    await tester.tap(find.text('WARDROBE'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.bar_chart));
    await tester.pumpAndSettle();
    await capture(tester, '04-insights.png');
  });

  testWidgets('planner', (tester) async {
    await _phoneViewport(tester);
    await pumpApp(tester, onboarded: true);
    await tester.tap(find.text('PLANNER'));
    await tester.pumpAndSettle();
    await capture(tester, '05-planner.png');
  });
}

/// A tall, narrow viewport with no insets, so the screenshots read like a phone.
Future<void> _phoneViewport(WidgetTester tester) async {
  tester.view.physicalSize = const Size(430 * 2, 932 * 2);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
}

/// Widget tests start with a placeholder font; without this every heading would
/// render as boxes and the goldens would be useless.
Future<void> _loadBrandFonts() async {
  const families = {
    'Prata': ['assets/fonts/Prata-Regular.ttf'],
    'Jost': ['assets/fonts/Jost-Variable.ttf'],
  };

  for (final entry in families.entries) {
    final loader = FontLoader(entry.key);
    for (final path in entry.value) {
      loader.addFont(rootBundle.load(path));
    }
    await loader.load();
  }

  await _loadMaterialIcons();
}

/// Icons do not ship in the app bundle, so there is no asset to load — they have
/// to be pulled out of whichever Flutter SDK is running this test.
Future<void> _loadMaterialIcons() async {
  final candidates = <String>[
    if (Platform.environment['FLUTTER_ROOT'] case final root?)
      '$root/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
  ];

  // flutter_tester lives at <sdk>/bin/cache/artifacts/engine/<platform>/.
  var dir = File(Platform.resolvedExecutable).parent;
  for (var i = 0; i < 8 && dir.parent.path != dir.path; i++) {
    candidates.add('${dir.path}/bin/cache/artifacts/material_fonts/materialicons-regular.otf');
    dir = dir.parent;
  }

  for (final path in candidates) {
    final file = File(path);
    if (file.existsSync()) {
      final loader = FontLoader('MaterialIcons')
        ..addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())));
      await loader.load();
      return;
    }
  }
}
