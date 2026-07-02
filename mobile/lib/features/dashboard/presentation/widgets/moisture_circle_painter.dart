import 'package:farmtec/core/themes/pallete.dart';
import 'package:flutter/material.dart';

class MoistureCirclePainter extends CustomPainter {
  final double value;
  final bool isDark;

  const MoistureCirclePainter(this.value, this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 7;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color =
            (isDark ? Pallete.darkSurfaceVariant : const Color(0xFFEEF2EC))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -3.14159 / 2,
      6.28318 * value,
      false,
      Paint()
        ..color = Pallete.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
