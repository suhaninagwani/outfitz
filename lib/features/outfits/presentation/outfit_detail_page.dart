import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets.dart';

class OutfitDetailPage extends StatelessWidget {
  const OutfitDetailPage({super.key});
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart casual'),
        backgroundColor: Colors.white,
        actions: const [Padding(padding: EdgeInsets.only(right: 16), child: Pill('92% match'))],
      ),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Container(
          height: 170,
          decoration: BoxDecoration(color: AppColors.blush, borderRadius: BorderRadius.circular(28)),
          child: const Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [EmojiTile('👕', size: 80), EmojiTile('👖', size: 80), EmojiTile('👟', size: 80)]),
        ),
        const SizedBox(height: 18),
        Text('Weather fit', style: t.labelMedium?.copyWith(color: AppColors.muted)),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: const LinearProgressIndicator(value: .92, minHeight: 10,
              color: AppColors.roseGold, backgroundColor: AppColors.blush),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.blush, width: 2)),
          child: const Text(
              '31° and dry, so a light cotton tee and breathable jeans. Sneakers are fine, '
              'no rain expected. You wore this tee 4 days ago, so it feels fresh.'),
        ),
        const SizedBox(height: 18),
        FilledButton(onPressed: () {}, child: const Text('Wear today')),
        const SizedBox(height: 8),
        OutlinedButton(onPressed: () {}, child: const Text('Save to planner')),
      ]),
    );
  }
}
