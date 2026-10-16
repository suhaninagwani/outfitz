import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/garment_tile.dart';
import '../../../core/widgets/ornaments.dart';
import '../../../core/widgets/panels.dart';
import '../../planner/domain/planned_day.dart';
import '../../outfits/presentation/outfit_detail_page.dart';

class PlannerPage extends ConsumerWidget {
  const PlannerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(weekPlanProvider);
    final t = Theme.of(context).textTheme;
    final wetDay = plan.where((d) => d.weather.isWet).isEmpty
        ? null
        : plan.firstWhere((d) => d.weather.isWet);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 120),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const MicroLabel('next five days', color: AppColors.wine),
                    const SizedBox(height: 8),
                    Text('This week', style: t.displayMedium),
                  ],
                ),
              ),
              OutfitzChip(
                label: 'Auto-plan',
                leading: const Ornament(kind: OrnamentKind.plus, size: 9, stroke: 1.2),
                onTap: () {
                  ref.read(autoPlanSeedProvider.notifier).regenerate();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Re-planned around the forecast')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 22),

          if (wetDay != null) ...[
            Panel(
              color: AppColors.butter,
              border: false,
              child: Row(
                children: [
                  const Icon(Icons.grain, size: 18),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Rain on ${wetDay.weekday} — Outfitz put boots and a layer in '
                      'that day and added an umbrella reminder.',
                      style: AppText.sans(12.5, FontWeight.w400, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
          ],

          const LabelledRule('the plan'),
          const SizedBox(height: 16),

          for (final day in plan) ...[
            _DayCard(day: day),
            const SizedBox(height: 12),
          ],

          const SizedBox(height: 14),
          Row(
            children: [
              const Ornament(kind: OrnamentKind.circle, size: 12),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Days left open stay open. Open one to see what Outfitz would '
                  'put together for that forecast.',
                  style: AppText.bodyMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({required this.day});

  final PlannedDay day;

  @override
  Widget build(BuildContext context) {
    final outfit = day.outfit;
    final isToday = day.isToday;

    return Panel(
      border: true,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      color: isToday ? AppColors.butterSoft : AppColors.white,
      onTap: outfit == null
          ? null
          : () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const OutfitDetailPage()),
              ),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MicroLabel(
                  isToday ? 'today' : day.weekday,
                  color: isToday ? AppColors.wine : AppColors.muted,
                  spacing: 1.4,
                  weight: isToday ? FontWeight.w600 : FontWeight.w500,
                ),
                const SizedBox(height: 6),
                Text(
                  '${day.date.day}',
                  style: AppText.serif(26, height: 1, color: AppColors.ink),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 56, color: AppColors.line),
          const SizedBox(width: 14),
          Expanded(
            child: outfit == null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Left open', style: AppText.sans(13.5, FontWeight.w500)),
                      const SizedBox(height: 4),
                      const MicroLabel('tap to plan this day', spacing: 1.3),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OutfitStrip(items: outfit.items, tileSize: 40),
                      const SizedBox(height: 10),
                      Text(
                        outfit.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.sans(13, FontWeight.w500),
                      ),
                    ],
                  ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(day.weather.icon, size: 18, color: AppColors.ink),
              const SizedBox(height: 8),
              Text(
                '${day.weather.temp}°',
                style: AppText.serif(17, color: AppColors.ink),
              ),
              const SizedBox(height: 3),
              MicroLabel('rain ${day.weather.rainChance}%', spacing: 1.2, size: 8.5),
            ],
          ),
        ],
      ),
    );
  }
}
