import 'package:flutter/material.dart';

import '../../features/wardrobe/domain/wardrobe_item.dart';
import '../theme/app_theme.dart';
import 'garment_image.dart';
import 'ornaments.dart';

/// A garment, rendered as its own colour field.
///
/// Until the user has photographed a piece we show the swatch rather than a
/// stock photo or an emoji — it keeps the grid honest about what it knows, and it
/// is the same language as the printed palette card in the brand kit.
class GarmentTile extends StatelessWidget {
  const GarmentTile({
    required this.item,
    this.size = 72,
    this.radius = 14,
    this.showOrnament = true,
    super.key,
  });

  final WardrobeItem item;
  final double size;
  final double radius;
  final bool showOrnament;

  @override
  Widget build(BuildContext context) {
    final path = item.imagePath;

    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (path == null)
              _swatch()
            else
              garmentImage(path, fallback: _swatch),
            // Hairline keeps near-white garments (and white photos) from
            // dissolving into the card behind them.
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(color: AppColors.line),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _swatch() => ColoredBox(
        color: item.colour,
        child: Stack(
          children: [
            Positioned.fill(
              child: Center(
                child: Icon(
                  Icons.checkroom,
                  size: size * .40,
                  color: item.onColour.withValues(alpha: .8),
                ),
              ),
            ),
            if (showOrnament && size >= 60)
              Positioned(
                right: size * .09,
                top: size * .09,
                child: Ornament(
                  kind: OrnamentKind.plus,
                  size: size * .11,
                  stroke: 1,
                  color: item.onColour.withValues(alpha: .5),
                ),
              ),
          ],
        ),
      );
}

/// The wardrobe grid cell: garment, name, and the two facts that matter
/// (category · colour).
class ItemCard extends StatelessWidget {
  const ItemCard({required this.item, this.onTap, super.key});

  final WardrobeItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: LayoutBuilder(
                builder: (context, c) => GarmentTile(
                  item: item,
                  size: c.maxWidth,
                  radius: AppTheme.tile,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.sans(13.5, FontWeight.w500, color: AppColors.ink),
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: item.colour,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.line),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: MicroLabel(
                    '${item.colourName} · ${item.category.singular}',
                    spacing: 1.6,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

/// A horizontal run of garments with hairline separators — the outfit "story".
class OutfitStrip extends StatelessWidget {
  const OutfitStrip({
    required this.items,
    this.tileSize = 76,
    this.labels = false,
    super.key,
  });

  final List<WardrobeItem> items;
  final double tileSize;
  final bool labels;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return MicroLabel('no pieces yet', spacing: 1.6);
    }
    final children = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      if (i > 0) {
        children.add(
          Container(
            width: 1,
            height: tileSize,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: AppColors.line,
          ),
        );
      }
      children.add(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GarmentTile(item: items[i], size: tileSize),
            if (labels) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: tileSize + 12,
                child: Text(
                  items[i].name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.sans(10.5, FontWeight.w400, color: AppColors.muted),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        // A run of garments is wider than a planner card, so it scrolls instead
        // of overflowing; when it does fit, the min-width keeps it centred.
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }
}

/// The colour palette as a printed strip. Used on Home and in Insights.
class PaletteStrip extends StatelessWidget {
  const PaletteStrip({this.height = 46, this.showNames = true, super.key});

  final double height;
  final bool showNames;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Row(
              children: [
                for (final c in AppColors.swatchStrip)
                  Expanded(child: Container(height: height, color: c)),
              ],
            ),
          ),
          if (showNames) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                for (final c in AppColors.swatchStrip)
                  Expanded(
                    child: MicroLabel(
                      _name(c),
                      spacing: .8,
                      size: 8.5,
                      color: AppColors.muted,
                    ),
                  ),
              ],
            ),
          ],
        ],
      );

  static String _name(Color c) {
    if (c == AppColors.wine) return 'wine';
    if (c == AppColors.maroon) return 'maroon';
    if (c == AppColors.black) return 'black';
    if (c == AppColors.white) return 'white';
    if (c == AppColors.butter) return 'butter';
    return '';
  }
}
