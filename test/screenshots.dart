import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:outfitz/app.dart';
import 'package:outfitz/core/providers.dart';
import 'package:outfitz/features/splash/presentation/splash_page.dart';
import 'package:outfitz/features/wardrobe/data/wardrobe_repository.dart';

import 'test_fonts.dart';

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

  setUpAll(loadBrandFonts);

  Future<void> capture(WidgetTester tester, String name) =>
      expectLater(find.byType(OutfitzApp), matchesGoldenFile('../images/$name'));

  testWidgets('splash', (tester) async {
    usePhoneViewport(tester);
    await mountApp(tester, onboarded: true);
    // Catch the sequence just after the sticker has landed and the wordmark has
    // arrived, while the rule is still drawing.
    await tester.pump(const Duration(milliseconds: 1500));
    await capture(tester, '00-splash.png');
  });

  testWidgets('onboarding', (tester) async {
    usePhoneViewport(tester);
    await mountApp(tester, onboarded: false);
    await settlePastSplash(tester);
    await capture(tester, '01-onboarding.png');
  });

  testWidgets('home', (tester) async {
    usePhoneViewport(tester);
    await mountApp(tester, onboarded: true);
    await settlePastSplash(tester);
    await capture(tester, '02-home.png');
  });

  testWidgets('home palette', (tester) async {
    usePhoneViewport(tester);
    await mountApp(tester, onboarded: true);
    await settlePastSplash(tester);
    await tester.drag(find.byType(ListView).first, const Offset(0, -780));
    await tester.pumpAndSettle();
    await capture(tester, '06-home-palette.png');
  });

  testWidgets('wardrobe', (tester) async {
    usePhoneViewport(tester);
    await mountApp(tester, onboarded: true);
    await settlePastSplash(tester);
    await tester.tap(find.text('WARDROBE'));
    await tester.pumpAndSettle();
    await capture(tester, '03-wardrobe.png');
  });

  testWidgets('wardrobe insights', (tester) async {
    usePhoneViewport(tester);
    await mountApp(tester, onboarded: true);
    await settlePastSplash(tester);
    await tester.tap(find.text('WARDROBE'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.bar_chart));
    await tester.pumpAndSettle();
    await capture(tester, '04-insights.png');
  });

  testWidgets('planner', (tester) async {
    usePhoneViewport(tester);
    await mountApp(tester, onboarded: true);
    await settlePastSplash(tester);
    await tester.tap(find.text('PLANNER'));
    await tester.pumpAndSettle();
    await capture(tester, '05-planner.png');
  });
}

Future<void> settlePastSplash(WidgetTester tester) async {
  await tester.pump(SplashPage.hold + const Duration(milliseconds: 600));
  await tester.pumpAndSettle();
}

Future<void> mountApp(WidgetTester tester, {required bool onboarded}) async {
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

  // The sticker is a real PNG asset and asset decoding is genuinely
  // asynchronous, which the test zone does not run on its own. Without this the
  // splash capture would have a hole where the seal should be.
  await tester.runAsync(
    () => precacheImage(
      const AssetImage('assets/stickers/outfitz-seal.png'),
      tester.element(find.byType(MaterialApp)),
    ),
  );
  await tester.pump();
}
