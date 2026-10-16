import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/brand_seal.dart';
import '../../../core/widgets/ornaments.dart';
import 'bubble_field.dart';
import 'mannequin.dart';

/// The cover: a wine page with a headless dress form on it, a line about the
/// person looking at it, and the whole thing alive under a fingertip.
///
/// It does not time out. It waits, and leaves when it is swiped left — tapping
/// only ever bursts bubbles, so a stray tap can never throw you into the app.
class SplashPage extends StatefulWidget {
  const SplashPage({required this.onEnter, super.key});

  /// Called once the page has finished sliding away.
  final VoidCallback onEnter;

  /// How far left a drag has to travel (or how fast it has to flick) to count.
  static const dismissDistance = 92.0;
  static const dismissVelocity = 620.0;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  static const _introLength = 1500;

  final _bubbles = GlobalKey<BubbleFieldState>();

  var _x = 0.0; // 0 at rest, negative as it is dragged away
  var _from = 0.0;
  var _to = 0.0;
  var _leaving = false;

  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: _introLength),
  )..forward();

  /// Never stops: the seal and the figure keep breathing.
  late final AnimationController _idle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4600),
  )..repeat(reverse: true);

  /// Settling back after an abandoned swipe, or leaving for good.
  late final AnimationController _motion = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 340),
  );

  @override
  void dispose() {
    _intro.dispose();
    _idle.dispose();
    _motion.dispose();
    super.dispose();
  }

  Animation<double> _beat(int start, int length, {Curve curve = Curves.easeOutCubic}) =>
      CurvedAnimation(
        parent: _intro,
        curve: Interval(
          start / _introLength,
          ((start + length) / _introLength).clamp(0, 1),
          curve: curve,
        ),
      );

  void _onDragUpdate(DragUpdateDetails details) {
    if (_leaving) return;
    _motion.stop();
    setState(() => _x = math.min(0, _x + details.delta.dx));
  }

  void _onDragEnd(DragEndDetails details) {
    if (_leaving) return;
    final velocity = details.primaryVelocity ?? 0;
    if (_x < -SplashPage.dismissDistance || velocity < -SplashPage.dismissVelocity) {
      _animateTo(-MediaQuery.sizeOf(context).width);
    } else {
      _animateTo(0);
    }
  }

  void _animateTo(double target) {
    _from = _x;
    _to = target;
    if (target != 0) _leaving = true;

    _motion.forward(from: 0).whenComplete(() {
      if (!mounted) return;
      if (_leaving) {
        widget.onEnter();
      } else {
        setState(() => _x = _to);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return AnimatedBuilder(
      animation: Listenable.merge([_intro, _idle, _motion]),
      builder: (context, _) {
        final x = _motion.isAnimating
            ? _from + (_to - _from) * Curves.easeOutCubic.transform(_motion.value)
            : _x;
        final slid = (x / -size.width).clamp(0.0, 1.0);

        return Material(
          // Every other screen sits under a Scaffold, which supplies the real
          // default text style. Without a Material here the cover's text would
          // inherit WidgetsApp's "unstyled text" error style — ivory type with
          // the signature yellow double underline.
          type: MaterialType.transparency,
          child: Opacity(
            // Nothing is left behind when it goes.
            opacity: 1 - slid * .75,
            child: Transform.translate(
              offset: Offset(x, 0),
              // The detector sits inside the transform, so a tap's local position
              // still lands where the finger actually is once the page has moved.
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (d) => _bubbles.currentState?.burst(d.localPosition),
                onHorizontalDragUpdate: _onDragUpdate,
                onHorizontalDragEnd: _onDragEnd,
                child: Stack(
                  children: [
                    Positioned.fill(child: _Backdrop(progress: _beat(0, 700))),
                    Positioned.fill(child: IgnorePointer(child: BubbleField(key: _bubbles))),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(28, 10, 28, 26),
                        child: Column(
                          children: [
                            _topBar(),
                            const Spacer(flex: 2),
                            _mannequin(size),
                            const SizedBox(height: 26),
                            _quote(),
                            const Spacer(flex: 3),
                            _hint(slid),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _topBar() => _fade(
        _beat(120, 620),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BrandMark(size: 19, onDark: true),
            const Spacer(),
            AnimatedBuilder(
              animation: _idle,
              builder: (context, child) => Transform.rotate(
                angle: (-10 + (_idle.value * 3)) * math.pi / 180,
                child: child,
              ),
              child: _fade(
                _beat(360, 780, curve: Curves.easeOutBack),
                const SizedBox(
                  height: 78,
                  width: 78,
                  child: FittedBox(fit: BoxFit.contain, child: BrandSeal(size: 200)),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _mannequin(Size size) {
    // Cap the figure so it never crowds the quote on a short screen.
    final height = math.min(330.0, size.height * .36);

    return _rise(
      _beat(240, 900),
      AnimatedBuilder(
        animation: _idle,
        builder: (context, child) => Transform.rotate(
          // A slow half-degree sway: the difference between a photograph and a
          // thing that is standing there.
          angle: (_idle.value - .5) * 1.1 * math.pi / 180,
          alignment: Alignment.bottomCenter,
          child: child,
        ),
        child: Mannequin(height: height),
      ),
    );
  }

  Widget _quote() => _rise(
        _beat(820, 780),
        Column(
          children: [
            Text(
              'You have better taste\nthan you give\nyourself credit for.',
              textAlign: TextAlign.center,
              style: AppText.serif(27, height: 1.26, color: AppColors.canvas),
            ),
            const SizedBox(height: 16),
            const MicroLabel(
              'your wardrobe, probably',
              color: AppColors.butter,
              spacing: 3,
              size: 9.5,
            ),
          ],
        ),
      );

  Widget _hint(double slid) => _fade(
        _beat(1240, 700).drive(Tween<double>(begin: 0, end: 1 - slid)),
        SizedBox(
          height: 22,
          child: Center(
            child: AnimatedBuilder(
              animation: _idle,
              builder: (context, child) => Transform.translate(
                // Nudging left, the direction it wants to be pushed.
                offset: Offset(-6 * _idle.value, 0),
                child: child,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back, size: 13, color: AppColors.butter),
                  SizedBox(width: 9),
                  MicroLabel('swipe left', color: AppColors.butter, spacing: 2.6),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _fade(Animation<double> t, Widget child) => AnimatedBuilder(
        animation: t,
        builder: (context, c) => Opacity(opacity: t.value.clamp(0, 1), child: c),
        child: child,
      );

  Widget _rise(Animation<double> t, Widget child) => AnimatedBuilder(
        animation: t,
        builder: (context, c) => Opacity(
          opacity: t.value.clamp(0, 1),
          child: Transform.translate(offset: Offset(0, 18 * (1 - t.value)), child: c),
        ),
        child: child,
      );
}

/// Wine deepening to near-black, with a warm glow off-centre and a fine speckle
/// so the flat colour reads like paper rather than a fill.
class _Backdrop extends StatelessWidget {
  const _Backdrop({required this.progress});

  final Animation<double> progress;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: progress,
        builder: (context, child) => Opacity(opacity: progress.value, child: child),
        child: const Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-.3, -.45),
                  radius: 1.25,
                  colors: [Color(0xFF7C0D0D), AppColors.wine, AppColors.wineDeep],
                  stops: [0, .5, 1],
                ),
              ),
            ),
            CustomPaint(painter: _SpecklePainter()),
          ],
        ),
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
