import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// A headless dress form — a tailor's dummy on a stand — wearing a wine blouse,
/// a maroon belt and a butter A-line midi skirt, with a small bag over one
/// shoulder.
///
/// Drawn rather than photographed: it stays crisp at any size, ships as a few
/// hundred bytes of code, and can wear the house colours exactly. Every
/// proportion is a fraction of a 220 x 380 box, so the figure is identical
/// wherever it is placed.
class Mannequin extends StatelessWidget {
  const Mannequin({this.height = 320, super.key});

  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        child: const AspectRatio(
          aspectRatio: 220 / 380,
          child: CustomPaint(painter: _MannequinPainter()),
        ),
      );
}

/// The measured figure: every landmark the painter needs, derived once from the
/// canvas size. Keeping the numbers in one place is what stops the silhouette
/// from drifting into something that is not a dress form.
class _Body {
  _Body(this.size);

  final Size size;

  double get w => size.width;
  double get h => size.height;
  double get cx => w / 2;

  // Heights, top to bottom.
  double get neckTop => h * .088;
  double get neckBase => h * .152;
  double get shoulder => h * .170;
  double get bust => h * .305;
  double get waist => h * .455;
  double get hip => h * .585;
  double get bottom => h * .782;
  double get base => h * .930;

  // Half widths. The bust is only a little wider than the hip and the waist only
  // a little narrower, which is what a real form looks like — pinch it harder and
  // it reads as a heart.
  double get neckW => w * .065;
  double get shoulderW => w * .275;
  double get bustW => w * .282;
  double get waistW => w * .205;
  double get hipW => w * .264;
  double get bottomW => w * .209;

  // The skirt hangs a touch outside the form, so no hip pokes through it.
  double get skirtTop => waist + h * .035;
  double get skirtHem => h * .790;
  double get skirtTopHalf => waistW + w * .036;
  double get skirtHemHalf => w * .390;

  /// Trunk and neck: a slim post on top, long sloping shoulders, a gently
  /// rounded bust, a soft waist, and a rounded hem.
  Path get outline {
    final p = Path()
      ..moveTo(cx - neckW, neckTop)
      // The cut neck: a shallow dome, so it reads as headless rather than hooded.
      ..quadraticBezierTo(cx, neckTop - h * .026, cx + neckW, neckTop)
      ..lineTo(cx + neckW, neckBase - h * .012)
      // Shoulders are the giveaway: long and almost straight, not a dome.
      ..quadraticBezierTo(
          cx + shoulderW * .55, shoulder - h * .012, cx + shoulderW, shoulder + h * .006)
      ..quadraticBezierTo(cx + bustW + w * .01, bust - h * .08, cx + bustW, bust)
      ..quadraticBezierTo(cx + waistW + w * .03, waist - h * .07, cx + waistW, waist)
      ..quadraticBezierTo(cx + hipW, hip - h * .07, cx + hipW, hip)
      ..quadraticBezierTo(cx + hipW - w * .01, bottom - h * .09, cx + bottomW, bottom)
      ..quadraticBezierTo(cx, bottom + h * .04, cx - bottomW, bottom)
      ..quadraticBezierTo(cx - hipW + w * .01, bottom - h * .09, cx - hipW, hip)
      ..quadraticBezierTo(cx - hipW, hip - h * .07, cx - waistW, waist)
      ..quadraticBezierTo(cx - waistW - w * .03, waist - h * .07, cx - bustW, bust)
      ..quadraticBezierTo(
          cx - bustW - w * .01, bust - h * .08, cx - shoulderW, shoulder + h * .006)
      ..quadraticBezierTo(
          cx - shoulderW * .55, shoulder - h * .012, cx - neckW, neckBase - h * .012)
      ..close();
    return p;
  }

  /// A blouse over the form: a shallow V, a hem just past the waist, and sides
  /// that sit a hair outside the body so it reads as cloth, not skin.
  Path get blouse {
    final left = cx - shoulderW - w * .012;
    final right = cx + shoulderW + w * .012;
    final top = shoulder + h * .008;

    return Path()
      ..moveTo(left, top)
      ..quadraticBezierTo(cx - shoulderW * .6, shoulder - h * .016, cx - w * .078, shoulder - h * .006)
      ..lineTo(cx, shoulder + h * .042)
      ..lineTo(cx + w * .078, shoulder - h * .006)
      ..quadraticBezierTo(cx + shoulderW * .6, shoulder - h * .016, right, top)
      ..quadraticBezierTo(cx + bustW + w * .014, bust - h * .08, cx + bustW + w * .012, bust)
      ..quadraticBezierTo(
          cx + waistW + w * .05, waist - h * .07, cx + waistW + w * .02, waist + h * .030)
      ..lineTo(cx - waistW - w * .02, waist + h * .030)
      ..quadraticBezierTo(
          cx - waistW - w * .05, waist - h * .07, cx - bustW - w * .012, bust)
      ..quadraticBezierTo(cx - bustW - w * .014, bust - h * .08, left, top)
      ..close();
  }

  Path get skirt {
    final mid = (skirtTop + skirtHem) / 2;
    return Path()
      ..moveTo(cx - skirtTopHalf, skirtTop)
      ..lineTo(cx + skirtTopHalf, skirtTop)
      ..quadraticBezierTo(
          cx + skirtHemHalf - w * .02, mid, cx + skirtHemHalf, skirtHem - h * .03)
      ..quadraticBezierTo(cx, skirtHem + h * .028, cx - skirtHemHalf, skirtHem - h * .03)
      ..quadraticBezierTo(
          cx - skirtHemHalf + w * .02, mid, cx - skirtTopHalf, skirtTop)
      ..close();
  }
}

class _MannequinPainter extends CustomPainter {
  const _MannequinPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final b = _Body(size);

    _glow(canvas, Offset(b.cx, b.h * .42), b.w * .74);
    _stand(canvas, b);
    _fill(canvas, b.outline, _sand, stroke: AppColors.ink.withValues(alpha: .10));
    _blouse(canvas, b);
    _belt(canvas, b);
    _skirt(canvas, b);
    _bag(canvas, b);
  }

  static const _sand = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFF6F1E8), AppColors.sand, Color(0xFFDACFBC)],
    stops: [0, .55, 1],
  );

  static const _wine = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF8A1414), AppColors.wine, Color(0xFF360101)],
    stops: [0, .45, 1],
  );

  static const _butter = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFFBEBAC), AppColors.butter, Color(0xFFD8BC6A)],
    stops: [0, .5, 1],
  );

  void _fill(Canvas canvas, Path path, Gradient gradient, {Color? stroke}) {
    canvas.drawPath(path, Paint()..shader = gradient.createShader(path.getBounds()));
    if (stroke != null) {
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = stroke,
      );
    }
  }

  /// A soft butter halo, so the figure lifts off the wine instead of sitting in it.
  void _glow(Canvas canvas, Offset centre, double radius) {
    canvas.drawCircle(
      centre,
      radius,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0x2EF6DE8D), Color(0x00F6DE8D)],
        ).createShader(Rect.fromCircle(center: centre, radius: radius)),
    );
  }

  void _stand(Canvas canvas, _Body b) {
    final top = b.bottom - b.h * .03;
    final left = b.cx - b.w * .019;
    final right = b.cx + b.w * .019;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(left, top, right, b.base),
        Radius.circular(b.w * .019),
      ),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFE9E0D1), Color(0xFFC3B49C)],
        ).createShader(Rect.fromLTRB(left, top, right, b.base)),
    );

    // Weighted foot: a disc, with a second ellipse under it for thickness.
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(b.cx, b.base + b.h * .007), width: b.w * .38, height: b.h * .024),
      Paint()..color = const Color(0x33000000),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(b.cx, b.base), width: b.w * .38, height: b.h * .026),
      Paint()..color = const Color(0xFFE2D8C6),
    );
  }

  void _blouse(Canvas canvas, _Body b) {
    _fill(canvas, b.blouse, _wine);

    // One fold from the bust to the hem: drape, without noise.
    canvas.drawPath(
      Path()
        ..moveTo(b.cx - b.bustW * .42, b.bust + b.h * .02)
        ..quadraticBezierTo(
            b.cx - b.waistW * .5, b.waist - b.h * .02, b.cx - b.waistW * .25, b.waist + b.h * .028),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..color = AppColors.white.withValues(alpha: .13),
    );
  }

  void _belt(Canvas canvas, _Body b) {
    final y = b.waist + b.h * .026;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(b.cx, y),
          width: (b.waistW + b.w * .036) * 2,
          height: b.h * .028,
        ),
        Radius.circular(b.h * .014),
      ),
      Paint()..color = AppColors.maroon,
    );
    canvas.drawCircle(Offset(b.cx, y), b.h * .0085, Paint()..color = AppColors.butter);
  }

  void _skirt(Canvas canvas, _Body b) {
    _fill(canvas, b.skirt, _butter);

    // Two soft pleats, and a shadow of a stitch line along the hem.
    final fold = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0x33A9843A);
    final mid = (b.skirtTop + b.skirtHem) / 2;
    for (final f in const [-.5, .5]) {
      canvas.drawPath(
        Path()
          ..moveTo(b.cx + b.skirtTopHalf * f * .5, b.skirtTop + 3)
          ..quadraticBezierTo(
              b.cx + b.skirtHemHalf * f * .85, mid, b.cx + b.skirtHemHalf * f * .8, b.skirtHem - b.h * .05),
        fold,
      );
    }
    canvas.drawPath(
      Path()
        ..moveTo(b.cx - b.skirtHemHalf * .8, b.skirtHem - b.h * .008)
        ..quadraticBezierTo(b.cx, b.skirtHem + b.h * .033, b.cx + b.skirtHemHalf * .8, b.skirtHem - b.h * .008),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0x1F000000),
    );
  }

  void _bag(Canvas canvas, _Body b) {
    canvas.drawPath(
      Path()
        ..moveTo(b.cx + b.shoulderW - b.w * .06, b.shoulder + b.h * .05)
        ..quadraticBezierTo(b.cx + b.w * .40, b.h * .42, b.cx + b.w * .275, b.hip - b.h * .02),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = b.w * .013
        ..strokeCap = StrokeCap.round
        ..color = AppColors.maroon,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(b.cx + b.w * .28, b.hip + b.h * .01),
          width: b.w * .16,
          height: b.h * .075,
        ),
        Radius.circular(b.w * .022),
      ),
      Paint()..color = AppColors.maroon,
    );
    canvas.drawCircle(
      Offset(b.cx + b.w * .28, b.hip - b.h * .012),
      b.w * .012,
      Paint()..color = AppColors.butter,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
