import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Registers the brand fonts (and the icon font) for headless rendering.
///
/// Widget tests start with a placeholder font, so without this every heading
/// renders as boxes and any captured image is useless.
Future<void> loadBrandFonts() async {
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

/// Icons do not ship in the app bundle, so there is no asset to load — they
/// have to be pulled out of whichever Flutter SDK is running this test.
Future<void> _loadMaterialIcons() async {
  final candidates = <String>[
    if (Platform.environment['FLUTTER_ROOT'] case final root?)
      '$root/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
  ];

  // flutter_tester lives at <sdk>/bin/cache/artifacts/engine/<platform>/.
  var dir = File(Platform.resolvedExecutable).parent;
  for (var i = 0; i < 8 && dir.parent.path != dir.path; i++) {
    candidates
        .add('${dir.path}/bin/cache/artifacts/material_fonts/materialicons-regular.otf');
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

/// A phone-shaped viewport with no insets, so captures read like a handset.
void usePhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(430 * 2, 932 * 2);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
}
