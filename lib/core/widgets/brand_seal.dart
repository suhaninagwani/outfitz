import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'ornaments.dart';

/// The butter-yellow die-cut sticker: `OUTFITZ` in wine inside a sealed disc.
///
/// Drawn in code so it stays crisp at any size, then rendered once to
/// `assets/stickers/outfitz-seal.png` by `test/stickers.dart`. The splash shows
/// that PNG, so the sticker is a real asset you can print, post or replace —
/// not something locked inside a build.
class BrandSeal extends StatelessWidget {
  const BrandSeal({this.size = 200, super.key});

  /// Outer diameter, ivory rim included.
  final double size;

  @override
  Widget build(BuildContext context) {
    // Everything below is laid out against a 200pt design, then scaled, so the
    // proportions never drift as the seal grows.
    final s = size / 200;

    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.butter,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.canvas, width: 10 * s),
            ),
            child: const SizedBox.expand(),
          ),
          Padding(
            padding: EdgeInsets.all(27 * s),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.wine.withValues(alpha: .26),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40 * s),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.checkroom, size: 44 * s, color: AppColors.wine),
                SizedBox(height: 12 * s),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'OUTFITZ',
                    style: AppText.serif(26 * s, spacing: 2 * s, color: AppColors.wine),
                  ),
                ),
                SizedBox(height: 9 * s),
                Container(
                  width: 38 * s,
                  height: 1.4 * s,
                  color: AppColors.wine.withValues(alpha: .45),
                ),
                SizedBox(height: 9 * s),
                MicroLabel('est. 2026', color: AppColors.wine, size: 8.5 * s, spacing: 2.2 * s),
              ],
            ),
          ),

          // Marginalia, as on the printed brand kit.
          Positioned(
            top: 30 * s,
            right: 36 * s,
            child: Ornament(
              kind: OrnamentKind.plus,
              size: 13 * s,
              stroke: 1.3 * s,
              color: AppColors.wine,
            ),
          ),
          Positioned(
            bottom: 38 * s,
            left: 32 * s,
            child: Ornament(
              kind: OrnamentKind.circle,
              size: 11 * s,
              stroke: 1.2 * s,
              color: AppColors.wine,
            ),
          ),
          Positioned(
            bottom: 56 * s,
            right: 32 * s,
            child: Ornament(
              kind: OrnamentKind.cross,
              size: 9 * s,
              stroke: 1.2 * s,
              color: AppColors.wine,
            ),
          ),
        ],
      ),
    );
  }
}
