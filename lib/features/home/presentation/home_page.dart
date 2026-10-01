import 'package:flutter/material.dart';
import '../../../core/mock.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets.dart';
import '../../outfits/presentation/outfit_detail_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    const w = todayWeather;
    final ink = t.bodySmall?.copyWith(color: AppColors.ink);
    return SafeArea(
      child: ListView(padding: const EdgeInsets.all(20), children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Good morning ☀️', style: t.bodySmall),
            Text('Suhani', style: t.headlineSmall),
          ]),
          const Pill('📍 Greater Noida'),
        ]),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
                colors: [AppColors.peach, AppColors.butter],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Today · ${w.label}', style: ink),
            Text('${w.temp}°',
                style: t.displayLarge?.copyWith(fontWeight: FontWeight.w700, color: AppColors.ink)),
            Text('Feels like ${w.feels}°  ·  💧${w.humidity}%  ·  🌧${w.rain}%', style: ink),
          ]),
        ),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text("Today's pick", style: t.titleMedium),
          TextButton(
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const OutfitDetailPage())),
            child: const Text('Why this?'),
          ),
        ]),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.blush, width: 2)),
          child: Column(children: [
            const Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              EmojiTile('👕', size: 76), EmojiTile('👖', size: 76), EmojiTile('👟', size: 76),
            ]),
            const SizedBox(height: 16),
            FilledButton(onPressed: () {}, child: const Text('Wear this')),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: () {}, child: const Text('Show another')),
          ]),
        ),
      ]),
    );
  }
}
