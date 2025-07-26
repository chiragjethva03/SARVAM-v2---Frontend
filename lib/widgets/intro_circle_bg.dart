import 'package:flutter/material.dart';

class IntroCircleBg extends StatelessWidget {
  final double radius;
  final double dx; // position from left (0–1 as percentage)
  final double dy; // position from top (0–1 as percentage)
  final Color color;

  const IntroCircleBg({
    super.key,
    required this.radius,
    required this.dx,
    required this.dy,
    this.color = const Color(0x1C2196F3), // default light blue with 11% opacity
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CirclePainter(
        radius: radius,
        dx: dx,
        dy: dy,
        color: color,
      ),
      size: Size.infinite,
    );
  }
}

class _CirclePainter extends CustomPainter {
  final double radius;
  final double dx;
  final double dy;
  final Color color;

  _CirclePainter({
    required this.radius,
    required this.dx,
    required this.dy,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    // dx, dy are percentages (0–1)
    final offset = Offset(size.width * dx, size.height * dy);

    canvas.drawCircle(offset, radius, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
