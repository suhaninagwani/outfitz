import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets.dart';
import '../domain/clothing_item.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});
  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  Category cat = Category.layer;
  int colour = 0;
  RangeValues warmth = const RangeValues(18, 26);
  static const swatches = [AppColors.peach, AppColors.ink, AppColors.butter,
    Color(0xFFB76E79), Colors.white];

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final label = t.labelSmall?.copyWith(color: AppColors.muted);
    return SafeArea(
      child: ListView(padding: const EdgeInsets.all(20), children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('New item', style: t.headlineSmall),
          const Pill('Auto-detected ✨'),
        ]),
        const SizedBox(height: 16),
        Container(
          height: 210,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: AppColors.blush, borderRadius: BorderRadius.circular(28)),
          child: Container(
            width: 150, height: 150, alignment: Alignment.center,
            decoration: BoxDecoration(
                border: Border.all(color: AppColors.roseGold, width: 2),
                borderRadius: BorderRadius.circular(16)),
            child: const Text('🧥', style: TextStyle(fontSize: 80)),
          ),
        ),
        const SizedBox(height: 16),
        Text('CATEGORY', style: label),
        const SizedBox(height: 6),
        Wrap(spacing: 8, children: [
          for (final c in Category.values)
            ChoiceChip(label: Text(c.name), selected: cat == c,
                onSelected: (_) => setState(() => cat = c)),
        ]),
        const SizedBox(height: 14),
        Text('COLOUR', style: label),
        const SizedBox(height: 8),
        Row(children: [
          for (var i = 0; i < swatches.length; i++)
            GestureDetector(
              onTap: () => setState(() => colour = i),
              child: Container(
                margin: const EdgeInsets.only(right: 10), width: 30, height: 30,
                decoration: BoxDecoration(
                  color: swatches[i], shape: BoxShape.circle,
                  border: Border.all(
                      color: colour == i ? AppColors.roseGold : AppColors.blush, width: 2.5),
                ),
              ),
            ),
        ]),
        const SizedBox(height: 14),
        Text('WARMTH · ${warmth.start.round()}–${warmth.end.round()}°C', style: label),
        RangeSlider(
          values: warmth, min: 0, max: 45,
          activeColor: AppColors.roseGold,
          inactiveColor: AppColors.peach.withValues(alpha: .35),
          onChanged: (v) => setState(() => warmth = v),
        ),
        const SizedBox(height: 8),
        FilledButton(onPressed: () {}, child: const Text('Save to wardrobe')),
      ]),
    );
  }
}
