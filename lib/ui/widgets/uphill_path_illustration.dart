import 'package:flutter/material.dart';

class UphillPathIllustration extends StatelessWidget {
  const UphillPathIllustration({super.key, required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'A path climbs to the top of a green hill',
      image: true,
      child: SizedBox(
        height: compact ? 190 : 250,
        child: CustomPaint(
          painter: const _UphillPathPainter(),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _UphillPathPainter extends CustomPainter {
  const _UphillPathPainter();

  static const _sun = Color(0xFFF2C66D);
  static const _hillLight = Color(0xFF8FA477);
  static const _hillMid = Color(0xFF6F895D);
  static const _hillDark = Color(0xFF4F6845);
  static const _pathEdge = Color(0xFF9D7A49);
  static const _path = Color(0xFFE5C58D);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawCircle(
      Offset(w * 0.76, h * 0.22),
      h * 0.105,
      Paint()..color = _sun,
    );

    _polygon(canvas, [
      Offset(w * 0.02, h * 0.78),
      Offset(w * 0.27, h * 0.51),
      Offset(w * 0.49, h * 0.72),
      Offset(w * 0.70, h * 0.42),
      Offset(w * 0.98, h * 0.78),
    ], _hillLight);

    _polygon(canvas, [
      Offset(w * 0.06, h * 0.90),
      Offset(w * 0.50, h * 0.28),
      Offset(w * 0.94, h * 0.90),
    ], _hillMid);

    _polygon(canvas, [
      Offset(w * 0.06, h * 0.90),
      Offset(w * 0.50, h * 0.28),
      Offset(w * 0.42, h * 0.90),
    ], _hillDark);

    _polygon(canvas, [
      Offset(w * 0.42, h * 0.90),
      Offset(w * 0.50, h * 0.28),
      Offset(w * 0.70, h * 0.90),
    ], const Color(0xFF789363));

    final route = Path()
      ..moveTo(w * 0.47, h * 0.93)
      ..cubicTo(w * 0.74, h * 0.80, w * 0.28, h * 0.67, w * 0.54, h * 0.56)
      ..cubicTo(w * 0.69, h * 0.49, w * 0.47, h * 0.42, w * 0.51, h * 0.32);

    canvas.drawPath(
      route,
      Paint()
        ..color = _pathEdge
        ..style = PaintingStyle.stroke
        ..strokeWidth = h * 0.075
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      route,
      Paint()
        ..color = _path
        ..style = PaintingStyle.stroke
        ..strokeWidth = h * 0.045
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawCircle(
      Offset(w * 0.51, h * 0.30),
      h * 0.026,
      Paint()..color = const Color(0xFFFFF7E8),
    );
  }

  void _polygon(Canvas canvas, List<Offset> points, Color color) {
    final shape = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      shape.lineTo(point.dx, point.dy);
    }
    shape.close();
    canvas.drawPath(shape, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
