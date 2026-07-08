import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class SparklineChart extends StatelessWidget {
  final List<double> data;
  final Color color;
  final double height;
  final double strokeWidth;

  const SparklineChart({
    super.key,
    required this.data,
    required this.color,
    this.height = 40,
    this.strokeWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return SizedBox(height: height);

    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _SparklinePainter(
          data: data,
          color: color,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final double strokeWidth;

  _SparklinePainter({
    required this.data,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final double max = data.reduce((a, b) => a > b ? a : b);
    final double min = data.reduce((a, b) => a < b ? a : b);
    final double range = (max - min) == 0 ? 1 : (max - min);

    final double stepX = size.width / (data.length - 1);

    final Path path = Path();

    for (int i = 0; i < data.length; i++) {
      final double x = i * stepX;
      // Invert Y axis because Canvas 0,0 is top-left
      final double normalizedY = (data[i] - min) / range;
      final double y = size.height - (normalizedY * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        // Create smooth curve
        final double prevX = (i - 1) * stepX;
        final double prevNormalizedY = (data[i - 1] - min) / range;
        final double prevY = size.height - (prevNormalizedY * size.height);

        final double controlPointX = prevX + (x - prevX) / 2;
        path.cubicTo(controlPointX, prevY, controlPointX, y, x, y);
      }
    }

    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, paint);

    // Draw gradient fill below sparkline
    final Path fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final Paint fillPaint = Paint()
      ..shader = ui.Gradient.linear(Offset.zero, Offset(0, size.height), [
        color.withValues(alpha: 0.3),
        color.withValues(alpha: 0.0),
      ])
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.color != color;
  }
}
