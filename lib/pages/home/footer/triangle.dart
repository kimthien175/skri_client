import 'package:cd_mobile/utils/styles.dart';
import 'package:flutter/material.dart';

class SvgTriangle extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = PanelStyles.color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(SvgTriangle oldDelegate) => false;
}

class Triangle extends StatelessWidget {
  const Triangle({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SvgTriangle(),
      size: const Size(double.infinity, 40),
    );
  }
}