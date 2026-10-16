import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Wide-tracked uppercase micro label. The workhorse of the brand kit.
class MicroLabel extends StatelessWidget {
  const MicroLabel(
    this.text, {
    this.color = AppColors.muted,
    this.spacing = 2.6,
    this.size = 9.5,
    this.weight = FontWeight.w500,
    super.key,
  });

  final String text;
  final Color color;
  final double spacing;
  final double size;
  final FontWeight weight;

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: AppText.sans(size, weight, spacing: spacing, height: 1.2, color: color),
      );
}

/// 1px rule. The layout is built out of these.
class HairlineRule extends StatelessWidget {
  const HairlineRule({this.color = AppColors.line, this.indent = 0, this.endIndent = 0, super.key});

  final Color color;
  final double indent;
  final double endIndent;

  @override
  Widget build(BuildContext context) =>
      Container(height: 1, margin: EdgeInsets.only(left: indent, right: endIndent), color: color);
}

/// Numbered progress rail used by the add-item flow: `01 source · 02 crop ·
/// 03 tags`, with the current step in wine.
class StepBar extends StatelessWidget {
  const StepBar({required this.step, required this.labels, super.key});

  final int step;
  final List<String> labels;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0)
              Expanded(
                child: Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: i <= step ? AppColors.wine : AppColors.line,
                ),
              ),
            MicroLabel(
              '0${i + 1} ${labels[i]}',
              size: 9,
              spacing: 1.4,
              color: i == step
                  ? AppColors.wine
                  : (i < step ? AppColors.ink : AppColors.muted),
              weight: i == step ? FontWeight.w600 : FontWeight.w400,
            ),
          ],
        ],
      );
}

/// A full-width rule with a label tucked into the left and an optional trailing
/// widget — the "COLOUR PALETTE ────────" treatment from the brand kit.
class LabelledRule extends StatelessWidget {
  const LabelledRule(this.label, {this.trailing, super.key});

  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          MicroLabel(label),
          const SizedBox(width: 12),
          const Expanded(child: HairlineRule()),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      );
}

enum OrnamentKind { plus, cross, circle }

/// The little printed marks that pepper the second brand kit.
class Ornament extends StatelessWidget {
  const Ornament({
    this.kind = OrnamentKind.plus,
    this.size = 10,
    this.color = AppColors.wine,
    this.stroke = 1,
    super.key,
  });

  final OrnamentKind kind;
  final double size;
  final Color color;
  final double stroke;

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size.square(size),
        painter: _OrnamentPainter(kind, color, stroke),
      );
}

class _OrnamentPainter extends CustomPainter {
  _OrnamentPainter(this.kind, this.color, this.stroke);

  final OrnamentKind kind;
  final Color color;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    switch (kind) {
      case OrnamentKind.plus:
        canvas.drawLine(Offset(c.dx, 0), Offset(c.dx, size.height), p);
        canvas.drawLine(Offset(0, c.dy), Offset(size.width, c.dy), p);
      case OrnamentKind.cross:
        canvas.drawLine(Offset.zero, Offset(size.width, size.height), p);
        canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), p);
      case OrnamentKind.circle:
        canvas.drawCircle(c, r - stroke / 2, p);
    }
  }

  @override
  bool shouldRepaint(_OrnamentPainter old) =>
      old.kind != kind || old.color != color || old.stroke != stroke;
}

/// The wordmark: `OUTFITZ` set in the display serif with a wine accent rule.
class BrandMark extends StatelessWidget {
  const BrandMark({this.size = 22, this.onDark = false, this.showTagline = false, super.key});

  final double size;
  final bool onDark;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    final fg = onDark ? AppColors.white : AppColors.ink;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Outfitz', style: AppText.serif(size, spacing: size * .06, color: fg)),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              width: size * .5,
              height: 1.4,
              color: onDark ? AppColors.butter : AppColors.wine,
            ),
            const SizedBox(width: 6),
            MicroLabel(
              showTagline ? 'found your fit' : 'personal wardrobe',
              color: onDark ? AppColors.butter : AppColors.wine,
              size: size * .34,
              spacing: size * .13,
            ),
          ],
        ),
      ],
    );
  }
}

/// Section heading used across every screen: display serif + optional action.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {this.eyebrow, this.action, this.onAction, super.key});

  final String title;
  final String? eyebrow;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (eyebrow != null) ...[
                  MicroLabel(eyebrow!, color: AppColors.wine),
                  const SizedBox(height: 6),
                ],
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
              ],
            ),
          ),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Row(
                  children: [
                    MicroLabel(action!, color: AppColors.wine, spacing: 1.8),
                    const SizedBox(width: 6),
                    const Ornament(kind: OrnamentKind.plus, size: 8, stroke: 1.2),
                  ],
                ),
              ),
            ),
        ],
      );
}
