import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/providers.dart';
import 'core/services/image_store.dart';
import 'features/wardrobe/data/wardrobe_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // All local, all offline. The scaffold has to open instantly on a phone with
  // no signal, so nothing here talks to the network.
  final prefs = await SharedPreferences.getInstance();
  final imageStore = await ImageStore.open();
  final wardrobe = await WardrobeRepository.open(prefs);

  runApp(
    ProviderScope(
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        imageStoreProvider.overrideWithValue(imageStore),
        wardrobeRepositoryProvider.overrideWithValue(wardrobe),
      ],
      child: const OutfitzApp(),
    ),
  );
}
