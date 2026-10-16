import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/wardrobe_item.dart';
import 'seed_wardrobe.dart';

/// The wardrobe's single source of truth.
///
/// Deliberately dumb: it owns the list, persists it to [SharedPreferences] as
/// JSON, and nothing else. When the FastAPI backend lands this class is the only
/// thing that changes — every screen already reads through it.
class WardrobeRepository {
  WardrobeRepository._(this._prefs, this._items);

  static const _key = 'outfitz.wardrobe.v1';

  final SharedPreferences _prefs;
  List<WardrobeItem> _items;

  List<WardrobeItem> get items => List.unmodifiable(_items);

  static Future<WardrobeRepository> open(SharedPreferences prefs) async {
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      final repo = WardrobeRepository._(prefs, seedWardrobe());
      await repo._persist();
      return repo;
    }
    try {
      final decoded = jsonDecode(raw) as List;
      final items = decoded
          .map((e) => WardrobeItem.fromJson((e as Map).cast<String, Object?>()))
          .toList();
      return WardrobeRepository._(prefs, items);
    } catch (_) {
      // Corrupt store: fall back to the seed rather than booting into a crash.
      final repo = WardrobeRepository._(prefs, seedWardrobe());
      await repo._persist();
      return repo;
    }
  }

  Future<void> upsert(WardrobeItem item) async {
    final i = _items.indexWhere((e) => e.id == item.id);
    if (i == -1) {
      _items = [item, ..._items];
    } else {
      _items = [..._items]..[i] = item;
    }
    await _persist();
  }

  Future<void> remove(String id) async {
    _items = _items.where((e) => e.id != id).toList();
    await _persist();
  }

  /// Called when the user taps "Wear this". Feeds the freshness rule.
  Future<WardrobeItem?> markWorn(String id, {DateTime? at}) async {
    final i = _items.indexWhere((e) => e.id == id);
    if (i == -1) return null;
    final next = _items[i].copyWith(
      wornCount: _items[i].wornCount + 1,
      lastWorn: at ?? DateTime.now(),
    );
    _items = [..._items]..[i] = next;
    await _persist();
    return next;
  }

  Future<void> reset() async {
    _items = seedWardrobe();
    await _persist();
  }

  Future<void> _persist() async {
    await _prefs.setString(_key, jsonEncode(_items.map((e) => e.toJson()).toList()));
  }
}
