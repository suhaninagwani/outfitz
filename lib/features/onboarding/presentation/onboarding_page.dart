import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/garment_tile.dart';
import '../../../core/widgets/ornaments.dart';
import '../../../core/widgets/panels.dart';
import '../../wardrobe/domain/wardrobe_item.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _controller = PageController();
  int _page = 0;

  static const _slides = [
    _Slide(
      eyebrow: '01 — the wardrobe',
      title: 'Everything you own,\nfinally in one place.',
      body: 'Photograph a piece once and it lives in your pocket wardrobe, '
          'sorted by category, colour and warmth.',
      art: _WardrobeArt(),
    ),
    _Slide(
      eyebrow: '02 — the scan',
      title: 'Snap it. We do the\ntedious part.',
      body: 'Outfitz crops the photo, reads the colour and proposes the tags. '
          'You confirm — that confirmation is what trains your wardrobe.',
      art: _ScanArt(),
    ),
    _Slide(
      eyebrow: '03 — the mood',
      title: 'Dressed for the sky\nand for your mood.',
      body: 'Weather decides how heavy to dress. Mood decides how it should '
          'feel. Outfitz puts the two together every morning.',
      art: _MoodArt(),
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page == _slides.length - 1) {
      ref.read(onboardingSeenProvider.notifier).finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final last = _page == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 18, 6),
              child: Row(
                children: [
                  const BrandMark(size: 20),
                  const Spacer(),
                  TextButton(
                    onPressed: () => ref.read(onboardingSeenProvider.notifier).finish(),
                    child: const MicroLabel('skip', color: AppColors.muted, spacing: 2),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _slides.length,
                itemBuilder: (_, i) => _slides[i],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 8, 28, 26),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < _slides.length; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == _page ? 22 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: i == _page ? AppColors.wine : AppColors.line,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  FilledButton(
                    onPressed: _next,
                    child: Text(last ? 'Enter my wardrobe' : 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.art,
  });

  final String eyebrow;
  final String title;
  final String body;
  final Widget art;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(28, 26, 28, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MicroLabel(eyebrow, color: AppColors.wine, spacing: 2.4),
            const SizedBox(height: 18),
            Text(title, style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 16),
            Text(body, style: AppText.body),
            const SizedBox(height: 26),
            Expanded(child: art),
          ],
        ),
      );
}

// ── Art ───────────────────────────────────────────────────────────────────────
class _WardrobeArt extends StatelessWidget {
  const _WardrobeArt();

  static const _demo = [
    WardrobeItem(
      id: 'o1',
      name: 'Wine knit',
      category: GarmentCategory.tops,
      colourHex: 0xFF580202,
    ),
    WardrobeItem(
      id: 'o2',
      name: 'Butter linen',
      category: GarmentCategory.tops,
      colourHex: 0xFFF6DE8D,
    ),
    WardrobeItem(
      id: 'o3',
      name: 'Black trouser',
      category: GarmentCategory.bottoms,
      colourHex: 0xFF121110,
    ),
    WardrobeItem(
      id: 'o4',
      name: 'Cream blouse',
      category: GarmentCategory.tops,
      colourHex: 0xFFF1E7D6,
    ),
  ];

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LabelledRule('the house palette'),
          const SizedBox(height: 14),
          const PaletteStrip(height: 40),
          const SizedBox(height: 20),
          // A 2 × 2 grid rather than a single row: it fills the slide the way a
          // wardrobe grid fills a screen, instead of leaving dead bands above
          // and below one thin line of tiles.
          Expanded(
            child: Column(
              children: [
                for (var row = 0; row < 2; row++) ...[
                  if (row > 0) const SizedBox(height: 12),
                  Expanded(
                    child: Row(
                      children: [
                        for (var col = 0; col < 2; col++) ...[
                          if (col > 0) const SizedBox(width: 12),
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, c) => Center(
                                child: GarmentTile(
                                  item: _demo[row * 2 + col],
                                  size: math.min(c.maxWidth, c.maxHeight),
                                  radius: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          const MicroLabel('one grid, every category'),
        ],
      );
}

class _ScanArt extends StatelessWidget {
  const _ScanArt();

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.sand,
                borderRadius: BorderRadius.circular(AppTheme.panel),
              ),
              padding: const EdgeInsets.all(22),
              child: Stack(
                children: [
                  Center(
                    child: AspectRatio(
                      aspectRatio: 3 / 4,
                      child: _CropFrame(
                        child: Center(
                          child: Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: AppColors.wine,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.checkroom,
                              color: Color(0xFFE9DCCB),
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    right: 0,
                    top: 0,
                    child: Ornament(kind: OrnamentKind.cross, size: 10, stroke: 1.2),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              OutfitzChip(label: 'Top', selected: true, dense: true),
              SizedBox(width: 8),
              OutfitzChip(label: 'Wine', selected: true, dense: true),
              SizedBox(width: 8),
              OutfitzChip(label: '18–26°C', selected: true, dense: true),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Ornament(kind: OrnamentKind.plus, size: 9),
              const SizedBox(width: 8),
              const Expanded(
                child: MicroLabel('auto-detected · you confirm', spacing: 1.8),
              ),
            ],
          ),
        ],
      );
}

/// The crop window: a hairline outline with four corner ticks.
class _CropFrame extends StatelessWidget {
  const _CropFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _FramePainter(),
        child: child,
      );
}

class _FramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final hair = Paint()
      ..color = AppColors.wine.withValues(alpha: .35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRect(Offset.zero & size, hair);

    final tick = Paint()
      ..color = AppColors.wine
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.square;
    const len = 18.0;
    for (final corner in [
      (Offset.zero, 1.0, 1.0),
      (Offset(size.width, 0), -1.0, 1.0),
      (Offset(0, size.height), 1.0, -1.0),
      (Offset(size.width, size.height), -1.0, -1.0),
    ]) {
      final (o, sx, sy) = corner;
      canvas.drawLine(o, o.translate(len * sx, 0), tick);
      canvas.drawLine(o, o.translate(0, len * sy), tick);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _MoodArt extends StatelessWidget {
  const _MoodArt();

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Panel(
            color: AppColors.butter,
            border: false,
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const MicroLabel('today · clear', color: AppColors.wine),
                    const Spacer(),
                    const Icon(Icons.wb_sunny_outlined, size: 18, color: AppColors.ink),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '31°',
                      style: AppText.serif(46, height: 1, color: AppColors.ink),
                    ),
                    const SizedBox(width: 12),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        'feels 34°',
                        style: AppText.sans(12, FontWeight.w400, color: AppColors.ink),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Light cotton, breathable denim, no jacket needed.',
                  style: AppText.sans(12.5, FontWeight.w400, height: 1.5, color: AppColors.ink),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const LabelledRule('how do you feel?'),
          const SizedBox(height: 14),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutfitzChip(label: 'Elegant', selected: true, dense: true),
              OutfitzChip(label: 'Minimal', dense: true),
              OutfitzChip(label: 'Bold', dense: true),
              OutfitzChip(label: 'Cosy', dense: true),
              OutfitzChip(label: 'Romantic', dense: true),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              const Ornament(kind: OrnamentKind.circle, size: 12),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Mood steers the tone. Weather steers the weight.',
                  style: AppText.bodyMuted,
                ),
              ),
            ],
          ),
        ],
      );
}
