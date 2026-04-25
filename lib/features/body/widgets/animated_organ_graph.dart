import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AnimatedOrganGraph extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final String label;

  const AnimatedOrganGraph({
    super.key,
    required this.progress,
    required this.label,
  });

  @override
  State<AnimatedOrganGraph> createState() => _AnimatedOrganGraphState();
}

class _AnimatedOrganGraphState extends State<AnimatedOrganGraph> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart);
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedOrganGraph oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.label, style: Theme.of(context).textTheme.bodyLarge),
            Text('${(widget.progress * 100).toInt()}%', style: const TextStyle(color: AppTheme.moss, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              size: const Size(double.infinity, 40),
              painter: _GraphPainter(progress: _animation.value * widget.progress),
            );
          },
        ),
      ],
    );
  }
}

class _GraphPainter extends CustomPainter {
  final double progress;

  _GraphPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final barPaint = Paint()
      ..color = AppTheme.forestMid
      ..style = PaintingStyle.fill;

    final progressPaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppTheme.moss, AppTheme.earth],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    const radius = Radius.circular(8);
    
    // Background bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 10, size.width, 20), radius),
      barPaint,
    );

    // Progress bar
    if (progress > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(0, 10, size.width * progress, 20), radius),
        progressPaint,
      );
    }
    
    // Glowing tip
    if (progress > 0) {
      final glowPaint = Paint()
        ..color = AppTheme.earth.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      
      canvas.drawCircle(Offset(size.width * progress, 20), 10, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GraphPainter oldDelegate) => oldDelegate.progress != progress;
}
