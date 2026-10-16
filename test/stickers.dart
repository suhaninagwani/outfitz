import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:outfitz/core/theme/app_theme.dart';
import 'package:outfitz/core/widgets/brand_seal.dart';

import 'test_fonts.dart';

/// Renders the brand sticker to a PNG asset.
///
/// Run with:
///   flutter test test/stickers.dart --update-goldens
///
/// Not named `*_test.dart`, so a plain `flutter test` skips it — it writes
/// `assets/stickers/outfitz-seal.png` rather than asserting anything. Rendered
/// at 3× on a transparent background, with a little breathing room around the
/// disc so the drop shadow on the splash has somewhere to land.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(loadBrandFonts);

  testWidgets('brand seal', (tester) async {
    tester.view.physicalSize = const Size(240 * 3, 240 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      // A MaterialApp so the seal inherits the same Directionality, text
      // defaults and theme it gets in the running app. Only the seal's own
      // subtree ends up in the PNG, on a transparent background.
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const Center(child: BrandSeal(size: 220)),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(BrandSeal),
      matchesGoldenFile('../assets/stickers/outfitz-seal.png'),
    );
  });
}
