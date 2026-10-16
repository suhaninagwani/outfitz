import 'package:flutter/material.dart';

import '../../features/wardrobe/domain/wardrobe_item.dart';
import '../theme/app_theme.dart';

/// A white panel with an optional hairline border. The only card in the app.
class Panel extends StatelessWidget {
  const Panel({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color = AppColors.white,
    this.border = true,
    this.radius = AppTheme.panel,
    this.onTap,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final bool border;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: border ? Border.all(color: AppColors.line) : null,
      ),
      child: child,
    );
    if (onTap == null) return content;
    return GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: content);
  }
}

/// Selectable pill. Hand-rolled rather than a ChoiceChip so the selected state
/// can be wine-with-white-text at an exact size.
class OutfitzChip extends StatelessWidget {
  const OutfitzChip({
    required this.label,
    this.selected = false,
    this.onTap,
    this.dense = false,
    this.leading,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final bool dense;
  final Widget? leading;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: EdgeInsets.symmetric(
            horizontal: dense ? 12 : 15,
            vertical: dense ? 7 : 10,
          ),
          decoration: BoxDecoration(
            color: selected ? AppColors.wine : AppColors.white,
            borderRadius: BorderRadius.circular(AppTheme.pill),
            border: Border.all(color: selected ? AppColors.wine : AppColors.line),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 6)],
              Text(
                label,
                style: AppText.sans(
                  dense ? 11.5 : 12.5,
                  FontWeight.w500,
                  spacing: .8,
                  color: selected ? AppColors.white : AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      );
}

/// A colour dot. Used in swatch rows and on the palette strip.
class ColourDot extends StatelessWidget {
  const ColourDot({
    required this.colour,
    this.size = 26,
    this.selected = false,
    this.onTap,
    super.key,
  });

  final Color colour;
  final double size;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: colour,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? AppColors.wine : AppColors.line,
              width: selected ? 2.4 : 1,
            ),
            boxShadow: selected
                ? const [BoxShadow(color: Color(0x1A580202), blurRadius: 0, spreadRadius: 4)]
                : null,
          ),
          child: selected
              ? Center(
                  child: Icon(
                    Icons.check,
                    size: size * .52,
                    color: colour.computeLuminance() > .55 ? AppColors.wine : AppColors.white,
                  ),
                )
              : null,
        ),
      );
}

/// Multi-select mood pills.
class MoodChips extends StatelessWidget {
  const MoodChips({
    required this.selected,
    required this.onToggle,
    this.moods = Mood.values,
    this.singleSelect = false,
    super.key,
  });

  final Set<Mood> selected;
  final void Function(Mood) onToggle;
  final List<Mood> moods;
  final bool singleSelect;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final m in moods)
            OutfitzChip(
              label: m.label,
              dense: singleSelect,
              selected: selected.contains(m),
              onTap: () => onToggle(m),
            ),
        ],
      );
}
