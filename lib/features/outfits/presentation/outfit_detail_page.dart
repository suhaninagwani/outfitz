import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/garment_tile.dart';
import '../../../core/widgets/ornaments.dart';
import '../../../core/widgets/panels.dart';

class OutfitDetailPage extends ConsumerWidget {
  const OutfitDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outfit = ref.watch(todaysOutfitProvider);
    final weather = ref.watch(weatherProvider);
    final mood = ref.watch(selectedMoodProvider);
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s outfit'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: Center(
              child: MicroLabel(
                '${outfit.match}% match',
                color: AppColors.wine,
                spacing: 1.6,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 4, 22, 40),
        children: [
          MicroLabel(
            mood == null ? 'weather-led' : '${mood.label} · ${mood.hint}',
            color: AppColors.wine,
          ),
          const SizedBox(height: 10),
          Text(outfit.title, style: t.displayMedium),
          const SizedBox(height: 22),

          Panel(
            padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
            color: AppColors.sand,
            border: false,
            child: OutfitStrip(items: outfit.items, tileSize: 74),
          ),
          const SizedBox(height: 26),

          LabelledRule(
            'weather fit',
            trailing: MicroLabel('${outfit.weatherFit}%', color: AppColors.wine),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: outfit.weatherFit / 100,
              minHeight: 8,
              color: AppColors.wine,
              backgroundColor: AppColors.sand,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${weather.summary} · ${weather.umbrellaNote}',
            style: AppText.bodyMuted,
          ),
          const SizedBox(height: 26),

          const LabelledRule('why it works'),
          const SizedBox(height: 14),
          Panel(
            child: Text(outfit.reason, style: AppText.body),
          ),
          const SizedBox(height: 26),

          const LabelledRule('the pieces'),
          const SizedBox(height: 10),
          for (final item in outfit.items)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Row(
                children: [
                  GarmentTile(item: item, size: 44, radius: 12),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: AppText.sans(13.5, FontWeight.w500)),
                        const SizedBox(height: 3),
                        MicroLabel(
                          '${item.colourName} · ${item.category.singular} · ${item.warmthLabel}',
                          spacing: 1.3,
                        ),
                      ],
                    ),
                  ),
                  if ((item.daysSinceWorn() ?? 99) <= 2)
                    const MicroLabel('repeat', color: AppColors.maroon, spacing: 1.3),
                ],
              ),
            ),
          const SizedBox(height: 30),

          FilledButton(
            onPressed: () async {
              for (final item in outfit.items) {
                await ref.read(wardrobeProvider.notifier).markWorn(item);
              }
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged as worn today')),
              );
            },
            child: const Text('Wear today'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Saved to Friday in your planner')),
              );
            },
            child: const Text('Save to planner'),
          ),
        ],
      ),
    );
  }
}
