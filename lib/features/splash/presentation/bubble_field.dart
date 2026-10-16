import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../core/theme/app_theme.dart';

/// Butter and ivory blooms wherever the screen is touched.
///
/// One ticker drives every bubble and the layer paints itself, so a screenful of
/// them costs a single repaint rather than a widget each. The ticker stops when
/// the last bubble dies — which keeps the screen still, the battery happy, and
/// `pumpAndSettle` able to settle.
class BubbleField extends StatefulWidget {
  const BubbleField({super.key});

  @override
  State<BubbleField> createState() => BubbleFieldState();
}

class BubbleFieldState extends State<BubbleField> with SingleTickerProviderStateMixin {
  /// Older bubbles are dropped first, so a manic tapper cannot grow the list
  /// without bound.
  static const _max = 240;

  final _bubbles = <_Bubble>[];
  final _random = math.Random();

  /// Created eagerly: a `late final` here would be first touched by `dispose`,
  /// and `createTicker` needs a live element.
  late final Ticker _ticker;

  /// Our own clock: a [Ticker] restarts from zero every time it is started, and
  /// bubbles outlive a start/stop cycle.
  var _now = Duration.zero;
  var _last = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  /// Bursts at [at], in this widget's local coordinates.
  void burst(Offset at) {
    final count = 5 + _random.nextInt(3);

    setState(() {
      for (var i = 0; i < count; i++) {
        final angle = _random.nextDouble() * math.pi * 2;
        final reach = 22 + _random.nextDouble() * 86;
        final kind = _BubbleKind.values[_random.nextInt(_BubbleKind.values.length)];

        _bubbles.add(
          _Bubble(
            origin: at.translate(_random.nextDouble() * 16 - 8, _random.nextDouble() * 16 - 8),
            travel: Offset(
              math.cos(angle) * reach,
              // Drift upward as they scatter: bubbles, not shrapnel.
              math.sin(angle) * reach * .7 - 28 - _random.nextDouble() * 44,
            ),
            // Marks stay small on purpose. A cluster of big printed crosses reads
            // as a stray glyph sitting on the page rather than a flourish.
            size: kind == _BubbleKind.print
                ? 2.4 + _random.nextDouble() * 4.0
                : 2.6 + _random.nextDouble() * 6.6,
            life: Duration(milliseconds: 780 + _random.nextInt(760)),
            born: _now,
            colour: _colour(),
            kind: kind,
            spin: (_random.nextDouble() - .5) * 2.4,
          ),
        );
      }

      if (_bubbles.length > _max) {
        _bubbles.removeRange(0, _bubbles.length - _max);
      }
    });

    if (!_ticker.isActive) {
      _last = Duration.zero;
      _ticker.start();
    }
  }

  Color _colour() {
    final r = _random.nextDouble();
    if (r < .60) return AppColors.butter;
    if (r < .88) return AppColors.canvas; // ivory
    return AppColors.maroon;
  }

  void _onTick(Duration elapsed) {
    final delta = elapsed - _last;
    _last = elapsed;

    setState(() {
      _now += delta;
      _bubbles.removeWhere((b) => _now - b.born >= b.life);
      if (_bubbles.isEmpty) _ticker.stop();
    });
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
        child: CustomPaint(
          painter: _BubblePainter(_bubbles, _now),
          size: Size.infinite,
        ),
      );
}

enum _BubbleKind { dot, ring, print }

@immutable
class _Bubble {
  const _Bubble({
    required this.origin,
    required this.travel,
    required this.size,
    required this.life,
    required this.born,
    required this.colour,
    required this.kind,
    required this.spin,
  });

  final Offset origin;
  final Offset travel;
  final double size;
  final Duration life;
  final Duration born;
  final Color colour;
  final _BubbleKind kind;
  final double spin;
}

class _BubblePainter extends CustomPainter {
  const _BubblePainter(this.bubbles, this.now);

  final List<_Bubble> bubbles;
  final Duration now;

  @override
  void paint(Canvas canvas, Size size) {
    for (final b in bubbles) {
      final t = ((now - b.born).inMicroseconds / b.life.inMicroseconds).clamp(0.0, 1.0);
      final centre = b.origin + b.travel * Curves.easeOutCubic.transform(t);

      // Pop in on the first third, then fade out to nothing.
      final grow = Curves.easeOutBack.transform(math.min(1, t / .34));
      final fade = t < .65 ? 1.0 : 1 - (t - .65) / .35;
      final radius = b.size * grow;
      if (radius <= 0) continue;

      final colour = b.colour.withValues(
        alpha: (fade * (b.kind == _BubbleKind.ring ? .9 : .95)).clamp(0, 1),
      );

      switch (b.kind) {
        case _BubbleKind.dot:
          canvas.drawCircle(centre, radius, Paint()..color = colour);
        case _BubbleKind.ring:
          canvas.drawCircle(
            centre,
            radius,
            Paint()
              ..color = colour
              ..style = PaintingStyle.stroke
              ..strokeWidth = math.max(1, radius * .22),
          );
        case _BubbleKind.print:
          canvas.save();
          canvas.translate(centre.dx, centre.dy);
          canvas.rotate(b.spin * t * 1.6);
          final stroke = Paint()
            ..color = colour
            ..strokeWidth = math.max(1, radius * .26)
            ..strokeCap = StrokeCap.round;
          canvas.drawLine(Offset(-radius, 0), Offset(radius, 0), stroke);
          canvas.drawLine(Offset(0, -radius), Offset(0, radius), stroke);
          canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_BubblePainter old) =>
      old.now != now || old.bubbles.length != bubbles.length;
}
