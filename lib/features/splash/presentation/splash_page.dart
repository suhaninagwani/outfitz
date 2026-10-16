import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/ornaments.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Stack(
        children: [
          // A single butter disc, cropped by the frame — the second brand kit's
          // signature gesture.
          Positioned(
            right: -size.width * .22,
            top: -size.height * .06,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, t, child) => Transform.scale(scale: t, child: child),
              child: Container(
                width: size.width * .78,
                height: size.width * .78,
                decoration: const BoxDecoration(
                  color: AppColors.butter,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Positioned(
            left: 34,
            top: size.height * .18,
            child: const Ornament(kind: OrnamentKind.cross, size: 9, stroke: 1.2),
          ),
          Positioned(
            left: size.width * .42,
            top: size.height * .30,
            child: const Ornament(kind: OrnamentKind.plus, size: 11, stroke: 1.2),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(34, 0, 34, 46),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 3),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOut,
                  builder: (context, t, child) => Opacity(
                    opacity: t,
                    child: Transform.translate(
                      offset: Offset(0, 14 * (1 - t)),
                      child: child,
                    ),
                  ),
                  child: const _Wordmark(),
                ),
                const Spacer(flex: 4),
                const HairlineRule(),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const MicroLabel('weather-smart', color: AppColors.wine),
                    const Spacer(),
                    const MicroLabel('wardrobe-first'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Outfitz',
            style: AppText.serif(64, spacing: 1, height: 1, color: AppColors.ink),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(width: 46, height: 2, color: AppColors.wine),
              const SizedBox(width: 10),
              const MicroLabel(
                'dress from your own wardrobe',
                color: AppColors.wine,
                spacing: 3,
                size: 10,
              ),
            ],
          ),
        ],
      );
}
