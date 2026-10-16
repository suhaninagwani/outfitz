import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/garment_tile.dart';
import '../../../core/widgets/ornaments.dart';
import '../../../core/widgets/panels.dart';
import '../domain/wardrobe_item.dart';
import 'confirm_item_page.dart';

class ItemDetailPage extends ConsumerWidget {
  const ItemDetailPage({required this.itemId, super.key});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = _find(ref.watch(wardrobeProvider), itemId);

    if (item == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: MicroLabel('this piece is no longer in your wardrobe')),
      );
    }

    final t = Theme.of(context).textTheme;
    final worn = item.daysSinceWorn();
    final wornLine = switch (worn) {
      null => 'Never worn yet',
      0 => 'Worn today',
      1 => 'Worn yesterday',
      _ => 'Last worn $worn days ago',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(item.category.label),
        actions: [
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: () => _confirmDelete(context, ref, item),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 4, 22, 40),
        children: [
          AspectRatio(
            aspectRatio: 4 / 5,
            child: LayoutBuilder(
              builder: (context, c) => GarmentTile(
                item: item,
                size: c.maxWidth,
                radius: AppTheme.panel,
              ),
            ),
          ),
          const SizedBox(height: 22),
          MicroLabel('${item.colourName} · ${item.category.singular}', color: AppColors.wine),
          const SizedBox(height: 8),
          Text(item.name, style: t.displayMedium),
          const SizedBox(height: 18),
          const HairlineRule(),
          const SizedBox(height: 18),

          _Row(label: 'Category', value: item.category.label),
          _Row(
            label: 'Colour',
            value: item.colourName,
            colour: item.colour,
          ),
          _Row(label: 'Warmth band', value: item.warmthLabel),
          _Row(label: 'Wears', value: '${item.wornCount}'),
          _Row(label: 'Freshness', value: wornLine),
          const SizedBox(height: 8),
          const LabelledRule('feels like'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final m in item.moods)
                OutfitzChip(label: m.label, dense: true, selected: false),
            ],
          ),
          const SizedBox(height: 26),
          FilledButton(
            onPressed: () async {
              await ref.read(wardrobeProvider.notifier).markWorn(item);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${item.name} logged as worn today')),
              );
            },
            child: const Text('Wear today'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ConfirmItemPage(
                  imageBytes: _emptyBytes,
                  detectedColour:
                      WardrobeColour.byHex(item.colourHex) ?? WardrobeColour.palette.first,
                  existing: item,
                ),
              ),
            ),
            child: const Text('Edit tags'),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Photographed and tagged by you. Nothing leaves your phone.',
              style: AppText.bodyMuted,
            ),
          ),
        ],
      ),
    );
  }

  static final _emptyBytes = Uint8List(0);

  static WardrobeItem? _find(List<WardrobeItem> items, String id) {
    for (final i in items) {
      if (i.id == id) return i;
    }
    return null;
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    WardrobeItem item,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Remove ${item.name}?', style: Theme.of(context).textTheme.titleLarge),
        content: Text(
          'It will be deleted from your wardrobe and its photo removed from the device.',
          style: AppText.bodyMuted,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const MicroLabel('keep it', color: AppColors.muted, spacing: 1.6),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const MicroLabel('remove', color: AppColors.wine, spacing: 1.6),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !context.mounted) return;
    await ref.read(wardrobeProvider.notifier).remove(item);
    if (context.mounted) Navigator.of(context).pop();
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.colour});

  final String label;
  final String value;
  final Color? colour;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          children: [
            MicroLabel(label, spacing: 2),
            const Spacer(),
            if (colour != null) ...[
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: colour,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.line),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(value, style: AppText.sans(13.5, FontWeight.w500, color: AppColors.ink)),
          ],
        ),
      );
}
