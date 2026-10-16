import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/garment_tile.dart';
import '../../../core/widgets/ornaments.dart';
import '../../../core/widgets/panels.dart';
import '../domain/wardrobe_item.dart';

/// The "really outfity" screen: what the wardrobe actually looks like once it
/// stops being a list of things and starts being a palette.
class InsightsPage extends ConsumerWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(wardrobeProvider);
    final breakdown = ref.watch(paletteBreakdownProvider);
    final t = Theme.of(context).textTheme;

    final byCategory = <GarmentCategory, int>{};
    for (final i in items) {
      byCategory[i.category] = (byCategory[i.category] ?? 0) + 1;
    }

    final mostWorn = [...items]..sort((a, b) => b.wornCount.compareTo(a.wornCount));
    final resting = items.where((i) => i.wornCount <= 2).toList();
    final maxCount = breakdown.isEmpty ? 1 : breakdown.first.$2;

    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 4, 22, 40),
        children: [
          MicroLabel('the wardrobe', color: AppColors.wine),
          const SizedBox(height: 8),
          Text('What you reach for', style: t.displayMedium),
          const SizedBox(height: 12),
          Text(
            'Outfitz reads your wardrobe the way a stylist would: colour first, '
            'then what actually gets worn.',
            style: AppText.body,
          ),
          const SizedBox(height: 26),

          const LabelledRule('colour story'),
          const SizedBox(height: 16),
          if (breakdown.isEmpty)
            Text('Add a few pieces to see your palette.', style: AppText.bodyMuted)
          else
            for (final (colour, count) in breakdown) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: colour.color,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: AppColors.line),
                      ),
                    ),
                    const SizedBox(width: 14),
                    SizedBox(
                      width: 74,
                      child: Text(
                        colour.name,
                        style: AppText.sans(13, FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: count / maxCount,
                          minHeight: 8,
                          color: colour.color,
                          backgroundColor: AppColors.sand,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 20,
                      child: Text(
                        '$count',
                        textAlign: TextAlign.right,
                        style: AppText.sans(13, FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],

          const SizedBox(height: 20),
          const LabelledRule('category split'),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final c in GarmentCategory.values)
                OutfitzChip(
                  label: '${c.label} ${byCategory[c] ?? 0}',
                  dense: true,
                  selected: (byCategory[c] ?? 0) > 0,
                ),
            ],
          ),
          const SizedBox(height: 30),

          const LabelledRule('most worn'),
          const SizedBox(height: 16),
          if (mostWorn.isEmpty)
            Text('Nothing worn yet.', style: AppText.bodyMuted)
          else
            Panel(
              child: Column(
                children: [
                  for (var i = 0; i < mostWorn.length && i < 4; i++) ...[
                    if (i > 0) const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: HairlineRule(),
                    ),
                    Row(
                      children: [
                        GarmentTile(item: mostWorn[i], size: 46, radius: 12),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(mostWorn[i].name,
                                  style: AppText.sans(13.5, FontWeight.w500)),
                              const SizedBox(height: 3),
                              MicroLabel(
                                '${mostWorn[i].colourName} · ${mostWorn[i].category.singular}',
                                spacing: 1.4,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${mostWorn[i].wornCount}×',
                          style: AppText.serif(17, color: AppColors.wine),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

          const SizedBox(height: 30),
          const LabelledRule('resting'),
          const SizedBox(height: 12),
          Text(
            resting.isEmpty
                ? 'Everything in your wardrobe has had a turn. Nicely edited.'
                : '${resting.length} pieces have been worn twice or less. Outfitz will '
                    'start surfacing them in your morning suggestion.',
            style: AppText.bodyMuted,
          ),
          if (resting.isNotEmpty) ...[
            const SizedBox(height: 16),
            OutfitStrip(items: resting.take(4).toList(), tileSize: 62, labels: true),
          ],
          const SizedBox(height: 30),
          Center(
            child: TextButton(
              onPressed: () => ref.read(wardrobeProvider.notifier).restoreDemoWardrobe(),
              child: const MicroLabel('restore the demo wardrobe', spacing: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}
