import 'package:flutter/material.dart';
import '../../../core/mock.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets.dart';

class PlannerPage extends StatelessWidget {
  const PlannerPage({super.key});
  @override
  Widget build(BuildContext context) => SafeArea(
        child: ListView(padding: const EdgeInsets.all(20), children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('This week', style: Theme.of(context).textTheme.headlineSmall),
            const Pill('Auto-plan'),
          ]),
          const SizedBox(height: 14),
          for (var i = 0; i < week.length; i++)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: i == 0 ? AppColors.blush : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: i == 0 ? AppColors.roseGold : AppColors.blush, width: 2),
              ),
              child: Row(children: [
                SizedBox(width: 44, child: Text('${week[i].$1}\n${week[i].$2}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                Expanded(child: Text(week[i].$3, style: const TextStyle(fontSize: 24))),
                Text(week[i].$4, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
              ]),
            ),
          const Center(child: Text('🌧 Rain Monday: umbrella reminder added',
              style: TextStyle(color: AppColors.muted, fontSize: 12))),
        ]),
      );
}
