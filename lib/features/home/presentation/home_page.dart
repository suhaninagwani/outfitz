import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/garment_tile.dart';
import '../../../core/widgets/ornaments.dart';
import '../../../core/widgets/panels.dart';
import '../../outfits/presentation/outfit_detail_page.dart';
import '../../outfits/domain/outfit.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weather = ref.watch(weatherProvider);
    final outfit = ref.watch(todaysOutfitProvider);
    final mood = ref.watch(selectedMoodProvider);
    final breakdown = ref.watch(paletteBreakdownProvider);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 120),
        children: [
          _Greeting(city: weather.city),
          const SizedBox(height: 22),
          _WeatherPanel(
            temp: weather.temp,
            feels: weather.feels,
            label: weather.label,
            humidity: weather.humidity,
            wind: weather.wind,
            rain: weather.rainChance,
            onPlanTap: () => ref.read(shellTabProvider.notifier).go(2),
          ),
          const SizedBox(height: 26),

          const LabelledRule('how do you feel today?'),
          const SizedBox(height: 14),
          MoodChips(
            selected: {if (mood != null) mood},
            singleSelect: true,
            onToggle: (m) => ref
                .read(selectedMoodProvider.notifier)
                .select(mood == m ? null : m),
          ),
          const SizedBox(height: 28),

          SectionHeader(
            'Today\'s pick',
            eyebrow: '${outfit.items.length} pieces · ${outfit.match}% match',
            action: 'why this?',
            onAction: () => _openOutfit(context, ref),
          ),
          const SizedBox(height: 16),
          _OutfitCard(
            outfit: outfit,
            onOpen: () => _openOutfit(context, ref),
            onWear: () async {
              final repo = ref.read(wardrobeProvider.notifier);
              for (final i in outfit.items) {
                await repo.markWorn(i);
              }
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged as worn today')),
              );
            },
            onAnother: () => ref.read(outfitVariantProvider.notifier).next(),
          ),
          const SizedBox(height: 30),

          LabelledRule(
            'in your palette',
            trailing: MicroLabel('${breakdown.length} shades', spacing: 1.4),
          ),
          const SizedBox(height: 14),
          const PaletteStrip(),
          const SizedBox(height: 10),
          Text(
            'Sixty per cent neutrals, thirty per cent wine and maroon, ten per cent '
            'butter. Everything you add gets pulled toward this palette.',
            style: AppText.bodyMuted,
          ),
          const SizedBox(height: 30),

          _PlannerTeaser(
            onTap: () => ref.read(shellTabProvider.notifier).go(2),
          ),
        ],
      ),
    );
  }

  void _openOutfit(BuildContext context, WidgetRef ref) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const OutfitDetailPage()),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────
class _Greeting extends ConsumerWidget {
  const _Greeting({required this.city});

  final String city;

  String get _salutation {
    final h = DateTime.now().hour;
    if (h < 12) return 'good morning';
    if (h < 17) return 'good afternoon';
    return 'good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MicroLabel(_salutation, color: AppColors.wine),
                const SizedBox(height: 8),
                Text(
                  'Suhani',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              ],
            ),
          ),
          OutfitzChip(
            label: city,
            leading: const Icon(Icons.place_outlined, size: 13, color: AppColors.ink),
            onTap: () => _showMenu(context, ref),
          ),
        ],
      );

  void _showMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 4, 22, 34),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MicroLabel('outfitz', color: AppColors.wine),
            const SizedBox(height: 8),
            Text('Scaffold settings', style: Theme.of(sheetContext).textTheme.headlineSmall),
            const SizedBox(height: 18),
            const HairlineRule(),
            _SheetAction(
              label: 'Replay the intro',
              icon: Icons.replay_outlined,
              onTap: () {
                Navigator.pop(sheetContext);
                ref.read(onboardingSeenProvider.notifier).replay();
              },
            ),
            _SheetAction(
              label: 'Restore the demo wardrobe',
              icon: Icons.inventory_2_outlined,
              onTap: () {
                Navigator.pop(sheetContext);
                ref.read(wardrobeProvider.notifier).restoreDemoWardrobe();
              },
            ),
            _SheetAction(
              label: 'Change city',
              icon: Icons.place_outlined,
              onTap: () => Navigator.pop(sheetContext),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetAction extends StatelessWidget {
  const _SheetAction({required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.ink),
              const SizedBox(width: 14),
              Text(label, style: AppText.sans(14, FontWeight.w400, color: AppColors.ink)),
              const Spacer(),
              const MicroLabel('›', spacing: 0),
            ],
          ),
        ),
      );
}

// ── Weather ───────────────────────────────────────────────────────────────────
class _WeatherPanel extends StatelessWidget {
  const _WeatherPanel({
    required this.temp,
    required this.feels,
    required this.label,
    required this.humidity,
    required this.wind,
    required this.rain,
    required this.onPlanTap,
  });

  final int temp;
  final int feels;
  final String label;
  final int humidity;
  final int wind;
  final int rain;
  final VoidCallback onPlanTap;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
        decoration: BoxDecoration(
          color: AppColors.butter,
          borderRadius: BorderRadius.circular(AppTheme.panel),
        ),
        child: Stack(
          children: [
            Positioned(
              right: 0,
              top: 2,
              child: Ornament(
                kind: OrnamentKind.circle,
                size: 44,
                stroke: 1,
                color: AppColors.ink.withValues(alpha: .18),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    MicroLabel('today · $label', color: AppColors.wine),
                    const Spacer(),
                    const Ornament(kind: OrnamentKind.plus, size: 10, stroke: 1.1),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$temp°',
                      style: AppText.serif(62, height: .95, color: AppColors.ink),
                    ),
                    const SizedBox(width: 14),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        'feels like $feels°',
                        style: AppText.sans(12, FontWeight.w400, color: AppColors.ink),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(height: 1, color: AppColors.ink.withValues(alpha: .14)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _Reading(icon: Icons.water_drop_outlined, value: '$humidity%', label: 'humidity'),
                    _Reading(icon: Icons.air, value: '$wind km/h', label: 'wind'),
                    _Reading(icon: Icons.grain, value: '$rain%', label: 'rain'),
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: onPlanTap,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.ink,
                    minimumSize: const Size.fromHeight(46),
                  ),
                  child: const Text('Plan my week'),
                ),
              ],
            ),
          ],
        ),
      );
}

class _Reading extends StatelessWidget {
  const _Reading({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: AppColors.ink.withValues(alpha: .8)),
            const SizedBox(height: 8),
            Text(value, style: AppText.sans(13, FontWeight.w500, color: AppColors.ink)),
            const SizedBox(height: 2),
            MicroLabel(label, spacing: 1.2, size: 8.5),
          ],
        ),
      );
}

// ── Outfit card ───────────────────────────────────────────────────────────────
class _OutfitCard extends StatelessWidget {
  const _OutfitCard({
    required this.outfit,
    required this.onOpen,
    required this.onWear,
    required this.onAnother,
  });

  final Outfit outfit;
  final VoidCallback onOpen;
  final VoidCallback onWear;
  final VoidCallback onAnother;

  @override
  Widget build(BuildContext context) => Panel(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
        onTap: onOpen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OutfitStrip(items: outfit.items, tileSize: 78),
            const SizedBox(height: 20),
            const HairlineRule(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    outfit.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                MicroLabel('${outfit.match}% match', color: AppColors.wine, spacing: 1.4),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              outfit.reason,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppText.bodyMuted,
            ),
            const SizedBox(height: 18),
            FilledButton(onPressed: onWear, child: const Text('Wear this')),
            const SizedBox(height: 10),
            OutlinedButton(onPressed: onAnother, child: const Text('Show another')),
          ],
        ),
      );
}

// ── Planner teaser ────────────────────────────────────────────────────────────
class _PlannerTeaser extends StatelessWidget {
  const _PlannerTeaser({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Panel(
        onTap: onTap,
        color: AppColors.white,
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.butterSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.calendar_today_outlined, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tomorrow is unplanned', style: AppText.sans(13.5, FontWeight.w500)),
                  const SizedBox(height: 3),
                  const MicroLabel('auto-plan the next five days', spacing: 1.2),
                ],
              ),
            ),
            const Ornament(kind: OrnamentKind.plus, size: 10, stroke: 1.2),
          ],
        ),
      );
}
