import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/ornaments.dart';

/// The brand moment: a wine screen, an ivory wordmark, and the butter sticker
/// landing above it.
///
/// Everything runs off one controller so the beats stay legible — the sticker
/// drops, the name rises, the rule draws, the small print arrives — and then a
/// second, slower controller takes over so the sticker keeps breathing and the
/// screen is never quite still.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  /// How long the sequence runs before the gate moves on.
  static const hold = Duration(milliseconds: 2400);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  static const _total = 2400;
  static const _seal = 130.0;

  late final AnimationController _sequence =
      AnimationController(vsync: this, duration: SplashPage.hold)..forward();

  /// Takes over once the sticker has landed: a slow tilt and bob.
  late final AnimationController _idle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _sequence.dispose();
    _idle.dispose();
    super.dispose();
  }

  /// A slice of the sequence, so each element arrives in its own beat.
  Animation<double> _beat(
    int start,
    int length, {
    Curve curve = Curves.easeOutCubic,
  }) =>
      CurvedAnimation(
        parent: _sequence,
        curve: Interval(
          start / _total,
          ((start + length) / _total).clamp(0, 1),
          curve: curve,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final backdrop = _beat(0, 620, curve: Curves.easeOut);
    final landing = _beat(180, 950, curve: Curves.elasticOut);
    final sealFade = _beat(120, 460);
    final name = _beat(520, 720);
    final rule = _beat(900, 560, curve: Curves.easeOutQuart);
    final footer = _beat(1180, 760);

    return Scaffold(
      backgroundColor: AppColors.wineDeep,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: backdrop,
              builder: (context, child) =>
                  Opacity(opacity: backdrop.value, child: child),
              child: const _Backdrop(),
            ),
          ),

          // Two of the kit's printed marks, floating in the dark.
          Positioned(
            left: 36,
            top: MediaQuery.sizeOf(context).height * .16,
            child: _fadeIn(
              backdrop,
              const Ornament(
                kind: OrnamentKind.cross,
                size: 9,
                stroke: 1.2,
                color: Color(0x4DF7F3EC),
              ),
            ),
          ),
          Positioned(
            right: 42,
            top: MediaQuery.sizeOf(context).height * .30,
            child: _fadeIn(
              backdrop,
              const Ornament(
                kind: OrnamentKind.plus,
                size: 11,
                stroke: 1.2,
                color: Color(0x4DF7F3EC),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(34, 0, 34, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 3),
                  Center(
                    child: AnimatedBuilder(
                      animation: Listenable.merge([landing, _idle, sealFade]),                      builder: (context, child) {
                        final land = landing.value;
                        final idle = _idle.value;
                        return Opacity(
                          opacity: sealFade.value.clamp(0, 1),
                          child: Transform.translate(
                            // `elasticOut` overshoots past 1, so the seal dips
                            // slightly below its resting line and comes back.
                            offset: Offset(0, -74 * (1 - land) + (idle * 5 - 2.5)),
                            child: Transform.rotate(
                              angle: (-22 + 14 * land + (idle * 2.4 - 1.2)) * math.pi / 180,
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: const _Seal(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: _rise(
                      name,
                      Text(
                        'Outfitz',
                        style: AppText.serif(64, spacing: 1, height: 1, color: AppColors.canvas),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedBuilder(
                          animation: rule,
                          builder: (context, _) => Container(
                            width: 46 * rule.value,
                            height: 1.4,
                            color: AppColors.butter,
                          ),
                        ),
                        const SizedBox(width: 11),
                        _rise(
                          footer,
                          const MicroLabel(
                            'dress from your own wardrobe',
                            color: AppColors.butter,
                            spacing: 3,
                            size: 9.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 3),
                  _rise(
                    footer,
                    Row(
                      children: [
                        const MicroLabel(
                          'weather-smart',
                          color: AppColors.butter,
                          spacing: 2.4,
                        ),
                        const Spacer(),
                        MicroLabel(
                          'wardrobe-first',
                          color: AppColors.canvas.withValues(alpha: .55),
                          spacing: 2.4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fadeIn(Animation<double> t, Widget child) =>
      AnimatedBuilder(animation: t, builder: (context, c) => Opacity(opacity: t.value, child: c), child: child);

  Widget _rise(Animation<double> t, Widget child) => AnimatedBuilder(
        animation: t,
        builder: (context, c) => Opacity(
          opacity: t.value.clamp(0, 1),
          child: Transform.translate(offset: Offset(0, 16 * (1 - t.value)), child: c),
        ),
        child: child,
      );
}

/// Wine deepening to near-black, with a warm glow off-centre and a fine speckle
/// so the flat colour reads like paper rather than a fill.
class _Backdrop extends StatelessWidget {
  const _Backdrop();

  @override
  Widget build(BuildContext context) => Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-.3, -.5),
                radius: 1.25,
                colors: [Color(0xFF7C0D0D), AppColors.wine, AppColors.wineDeep],
                stops: [0, .5, 1],
              ),
            ),
          ),
          CustomPaint(painter: const _SpecklePainter()),
        ],
      );
}

class _SpecklePainter extends CustomPainter {
  const _SpecklePainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Seeded, so the speckle is identical on every launch and in every capture.
    final rnd = math.Random(7);
    final paint = Paint()..color = AppColors.canvas.withValues(alpha: .05);
    for (var i = 0; i < 110; i++) {
      canvas.drawCircle(
        Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height),
        rnd.nextDouble() * 1.2 + .35,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

/// The sticker, with a soft drop shadow and a butter halo so it lifts off the
/// wine instead of sitting in it.
class _Seal extends StatelessWidget {
  const _Seal();

  @override
  Widget build(BuildContext context) => Container(
        width: _SplashPageState._seal,
        height: _SplashPageState._seal,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: .34),
              blurRadius: 30,
              offset: const Offset(0, 14),
            ),
            BoxShadow(
              color: AppColors.butter.withValues(alpha: .20),
              blurRadius: 54,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Image.asset(
          'assets/stickers/outfitz-seal.png',
          width: _SplashPageState._seal,
          height: _SplashPageState._seal,
          filterQuality: FilterQuality.high,
        ),
      );
}
