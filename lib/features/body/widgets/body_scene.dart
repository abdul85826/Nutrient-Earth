import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

// ─── BodyScene ────────────────────────────────────────────────────────────────
//
// AG-14: Upgraded from a static CustomPainter to a full interactive model with:
//   • Drag-to-rotate on X and Y axes
//   • Momentum/inertia on flick release
//   • Pinch-to-zoom
//   • Male/Female toggle (camera state preserved on toggle)
//   • Holographic scanline intro animation (1.5s, first build only)
//   • Glowing rim-light on the body outline
//   • HUD callout label (thin line + floating label) when an organ is selected
//
// The public API is unchanged:
//   selectedSystemKey → currently selected organ key (nullable)
//   onSystemSelected  → callback when user taps an organ hotspot
//   interactive       → set to false for the compact Today-tab preview (disables
//                       gesture handlers and removes the gender toggle)

class BodyScene extends StatefulWidget {
  final String? selectedSystemKey;
  final Function(String)? onSystemSelected;
  final bool interactive;

  const BodyScene({
    super.key,
    required this.selectedSystemKey,
    this.onSystemSelected,
    this.interactive = true,
  });

  @override
  State<BodyScene> createState() => _BodySceneState();
}

class _BodySceneState extends State<BodyScene> with TickerProviderStateMixin {
  // Camera state
  double _rotationY = 0.0; // horizontal drag → Y-axis rotation
  double _rotationX = 0.08; // slight forward tilt by default
  double _zoom = 1.0;

  // Inertia
  double _velocityX = 0.0;
  double _velocityY = 0.0;
  Timer? _inertiaTimer;
  Offset? _lastFocalPoint;

  // Gender toggle
  bool _isMale = true;

  // Intro scanline animation
  late AnimationController _scanlineController;
  late Animation<double> _scanlineAnimation;
  bool _introComplete = false;

  // Ambient glow pulse animation
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  // Organ hotspot definitions — (relX, relY) as fractions of the widget size
  static const Map<String, _HotspotDef> _hotspots = {
    'nervous': _HotspotDef(relX: 0.50, relY: 0.14, color: Color(0xFFCE93D8), label: 'Nervous'),
    'cardiovascular': _HotspotDef(relX: 0.56, relY: 0.33, color: Color(0xFFEF5350), label: 'Heart'),
    'respiratory': _HotspotDef(relX: 0.40, relY: 0.30, color: Color(0xFF4DD0E1), label: 'Lungs'),
    'digestive': _HotspotDef(relX: 0.50, relY: 0.46, color: Color(0xFFFFB300), label: 'Digestive'),
    'musculoskeletal': _HotspotDef(relX: 0.44, relY: 0.73, color: Color(0xFF69F0AE), label: 'Muscles'),
  };

  @override
  void initState() {
    super.initState();

    // Scanline intro: sweeps top→bottom in 1.5 s
    _scanlineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scanlineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanlineController, curve: Curves.easeInOut),
    );
    _scanlineController.forward().then((_) {
      if (mounted) setState(() => _introComplete = true);
    });

    // Ambient glow pulse: subtle breathing
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.04, end: 0.12).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _inertiaTimer?.cancel();
    _scanlineController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  // ── Gesture handlers ───────────────────────────────────────────────────────

  void _onScaleStart(ScaleStartDetails d) {
    _lastFocalPoint = d.localFocalPoint;
    _inertiaTimer?.cancel();
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    setState(() {
      _zoom = (_zoom * d.scale).clamp(0.7, 2.0);

      if (_lastFocalPoint != null) {
        final delta = d.localFocalPoint - _lastFocalPoint!;
        _rotationY += delta.dx * 0.008;
        _rotationX += delta.dy * 0.004;
        _rotationX = _rotationX.clamp(-0.4, 0.4);
        _velocityX = delta.dy * 0.004;
        _velocityY = delta.dx * 0.008;
      }
      _lastFocalPoint = d.localFocalPoint;
    });
  }

  void _onScaleEnd(ScaleEndDetails d) {
    _lastFocalPoint = null;
    _velocityX = d.velocity.pixelsPerSecond.dy * 0.00002;
    _velocityY = d.velocity.pixelsPerSecond.dx * 0.00002;
    _startInertia();
  }

  void _startInertia() {
    _inertiaTimer?.cancel();
    _inertiaTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted) { timer.cancel(); return; }
      setState(() {
        _rotationX += _velocityX;
        _rotationY += _velocityY;
        _rotationX = _rotationX.clamp(-0.4, 0.4);
        _velocityX *= 0.92; // friction
        _velocityY *= 0.92;
        if (_velocityX.abs() < 0.0001 && _velocityY.abs() < 0.0001) {
          timer.cancel();
        }
      });
    });
  }

  // ── Hit-test for organ tap ─────────────────────────────────────────────────

  void _onTapDown(TapDownDetails d, Size size) {
    if (widget.onSystemSelected == null) return;
    for (final entry in _hotspots.entries) {
      final projected = _projectHotspot(entry.value, size);
      final tapped = d.localPosition;
      if ((tapped - projected).distance < 28) {
        widget.onSystemSelected!(entry.key);
        return;
      }
    }
  }

  /// Project a hotspot from body-relative coords into current rotated/zoomed
  /// screen coordinates (simple perspective approximation).
  Offset _projectHotspot(_HotspotDef h, Size size) {
    // Body centre
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Raw position relative to centre
    final rawX = (h.relX - 0.5) * size.width;
    final rawY = (h.relY - 0.5) * size.height;

    // Apply Y-rotation (horizontal spin) — simple 2D cosine foreshortening
    final rotatedX = rawX * math.cos(_rotationY);
    // Apply X-rotation (tilt) — moves points up/down based on Y position
    final rotatedY = rawY * math.cos(_rotationX) - rawX * math.sin(_rotationX) * 0.15;

    return Offset(
      cx + rotatedX * _zoom,
      cy + rotatedY * _zoom,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Gender toggle (interactive mode only) ──────────────────────────
        if (widget.interactive)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _GenderChip(
                  label: 'Male',
                  icon: Icons.man_rounded,
                  selected: _isMale,
                  onTap: () => setState(() => _isMale = true),
                ),
                const SizedBox(width: 8),
                _GenderChip(
                  label: 'Female',
                  icon: Icons.woman_rounded,
                  selected: !_isMale,
                  onTap: () => setState(() => _isMale = false),
                ),
              ],
            ),
          ),

        // ── 3D model canvas ────────────────────────────────────────────────
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(
                constraints.maxWidth,
                constraints.maxHeight,
              );

              Widget canvas = AnimatedBuilder(
                animation: Listenable.merge([_scanlineAnimation, _glowAnimation]),
                builder: (_, __) => CustomPaint(
                  size: size,
                  painter: _HolographicBodyPainter(
                    rotationX: _rotationX,
                    rotationY: _rotationY,
                    zoom: _zoom,
                    isMale: _isMale,
                    selectedKey: widget.selectedSystemKey,
                    hotspots: _hotspots,
                    scanlineProgress: _introComplete ? 1.0 : _scanlineAnimation.value,
                    introComplete: _introComplete,
                    glowAlpha: _glowAnimation.value,
                    projectHotspot: (h) => _projectHotspot(h, size),
                  ),
                ),
              );

              if (widget.interactive) {
                canvas = GestureDetector(
                  onScaleStart: _onScaleStart,
                  onScaleUpdate: _onScaleUpdate,
                  onScaleEnd: _onScaleEnd,
                  onTapDown: (d) => _onTapDown(d, size),
                  child: canvas,
                );
              } else {
                // Non-interactive (Today snapshot): still allow tap to select
                canvas = GestureDetector(
                  onTapDown: (d) => _onTapDown(d, size),
                  child: canvas,
                );
              }

              return canvas;
            },
          ),
        ),

        // ── Interaction hint (interactive mode only) ───────────────────────
        if (widget.interactive && _introComplete)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Drag to rotate  ·  Pinch to zoom  ·  Tap organ',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.25),
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Hotspot definition ───────────────────────────────────────────────────────

class _HotspotDef {
  final double relX, relY;
  final Color color;
  final String label;
  const _HotspotDef({
    required this.relX,
    required this.relY,
    required this.color,
    required this.label,
  });
}

// ─── Gender toggle chip ───────────────────────────────────────────────────────

class _GenderChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _GenderChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? NEColors.accent.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? NEColors.accent.withValues(alpha: 0.6) : Colors.white12,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: selected ? NEColors.accent : Colors.white38),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                color: selected ? NEColors.accent : Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Holographic Body Painter ─────────────────────────────────────────────────

class _HolographicBodyPainter extends CustomPainter {
  final double rotationX;
  final double rotationY;
  final double zoom;
  final bool isMale;
  final String? selectedKey;
  final Map<String, _HotspotDef> hotspots;
  final double scanlineProgress; // 0.0 → 1.0
  final bool introComplete;
  final double glowAlpha;
  final Offset Function(_HotspotDef) projectHotspot;

  _HolographicBodyPainter({
    required this.rotationX,
    required this.rotationY,
    required this.zoom,
    required this.isMale,
    required this.selectedKey,
    required this.hotspots,
    required this.scanlineProgress,
    required this.introComplete,
    required this.glowAlpha,
    required this.projectHotspot,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // ── 1. Ambient radial glow ─────────────────────────────────────────────
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          NEColors.accent.withValues(alpha: glowAlpha),
          NEColors.accent.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: size.height * 0.45));
    canvas.drawCircle(Offset(cx, cy), size.height * 0.45, glowPaint);

    // ── 2. Body outline with holographic rim glow ──────────────────────────
    final bodyPath = _buildBodyPath(size);

    // Outer glow (rim-light)
    final rimPaint = Paint()
      ..color = NEColors.accent.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(bodyPath, rimPaint);

    // Core outline
    final outlinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(bodyPath, outlinePaint);

    // ── 3. Scanline shimmer (intro only) ───────────────────────────────────
    if (!introComplete) {
      final scanY = size.height * scanlineProgress;
      // Sweep line
      final linePaint = Paint()
        ..color = NEColors.accent.withValues(alpha: 0.7)
        ..strokeWidth = 1.5;
      canvas.drawLine(Offset(0, scanY), Offset(size.width, scanY), linePaint);
      // Glow trail below sweep line (fades upward)
      final trailPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            NEColors.accent.withValues(alpha: 0),
            NEColors.accent.withValues(alpha: 0.08),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, scanY));
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, scanY), trailPaint);
    }

    // ── 4. Organ hotspots ──────────────────────────────────────────────────
    for (final entry in hotspots.entries) {
      final h = entry.value;
      final pos = projectHotspot(h);
      final isSelected = selectedKey == entry.key;
      _drawHotspot(canvas, pos, h.color, isSelected);
    }

    // ── 5. HUD callout for selected organ ─────────────────────────────────
    if (selectedKey != null && hotspots.containsKey(selectedKey)) {
      final h = hotspots[selectedKey]!;
      final pos = projectHotspot(h);
      _drawHUDCallout(canvas, pos, h, size);
    }
  }

  /// Draws the body outline path with rotation applied (simple 2D projection).
  Path _buildBodyPath(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    // Perspective scale: things rotate "into" the screen based on rotationY
    final scaleX = math.cos(rotationY) * zoom;
    final scaleY = zoom;

    // Helper: transform a body-space point (0..1, 0..1) to canvas coords
    Offset t(double rx, double ry) {
      final bx = (rx - 0.5) * w * scaleX;
      final by = (ry - 0.5) * h * scaleY - (rx - 0.5) * w * math.sin(rotationX) * 0.25 * zoom;
      return Offset(w / 2 + bx, h / 2 + by);
    }

    // Female body is slightly narrower at shoulders, wider at hips
    final shoulderW = isMale ? 0.38 : 0.33;
    final hipW = isMale ? 0.22 : 0.26;

    // Head
    final headC = t(0.50, 0.12);
    final headRx = w * 0.08 * scaleX.abs();
    final headRy = h * 0.07 * scaleY;
    path.addOval(Rect.fromCenter(center: headC, width: headRx * 2, height: headRy * 2));

    // Neck
    path.moveTo(t(0.47, 0.19).dx, t(0.47, 0.19).dy);
    path.lineTo(t(0.53, 0.19).dx, t(0.53, 0.19).dy);

    // Shoulders
    path.moveTo(t(0.47, 0.22).dx, t(0.47, 0.22).dy);
    path.lineTo(t(0.50 - shoulderW, 0.26).dx, t(0.50 - shoulderW, 0.26).dy);
    path.moveTo(t(0.53, 0.22).dx, t(0.53, 0.22).dy);
    path.lineTo(t(0.50 + shoulderW, 0.26).dx, t(0.50 + shoulderW, 0.26).dy);

    // Torso sides
    final tL1 = t(0.50 - shoulderW, 0.26);
    final tL2 = t(0.50 - hipW, 0.55);
    final tR1 = t(0.50 + shoulderW, 0.26);
    final tR2 = t(0.50 + hipW, 0.55);

    path.moveTo(tL1.dx, tL1.dy);
    path.quadraticBezierTo((tL1.dx + tL2.dx) / 2 - 4, (tL1.dy + tL2.dy) / 2, tL2.dx, tL2.dy);

    path.moveTo(tR1.dx, tR1.dy);
    path.quadraticBezierTo((tR1.dx + tR2.dx) / 2 + 4, (tR1.dy + tR2.dy) / 2, tR2.dx, tR2.dy);

    // Hip line
    path.moveTo(tL2.dx, tL2.dy);
    path.lineTo(tR2.dx, tR2.dy);

    // Arms
    path.moveTo(t(0.50 - shoulderW, 0.26).dx, t(0.50 - shoulderW, 0.26).dy);
    path.lineTo(t(0.50 - shoulderW - 0.08, 0.43).dx, t(0.50 - shoulderW - 0.08, 0.43).dy);
    path.lineTo(t(0.50 - shoulderW - 0.12, 0.58).dx, t(0.50 - shoulderW - 0.12, 0.58).dy);

    path.moveTo(t(0.50 + shoulderW, 0.26).dx, t(0.50 + shoulderW, 0.26).dy);
    path.lineTo(t(0.50 + shoulderW + 0.08, 0.43).dx, t(0.50 + shoulderW + 0.08, 0.43).dy);
    path.lineTo(t(0.50 + shoulderW + 0.12, 0.58).dx, t(0.50 + shoulderW + 0.12, 0.58).dy);

    // Legs
    path.moveTo(t(0.50 - hipW * 0.6, 0.55).dx, t(0.50 - hipW * 0.6, 0.55).dy);
    path.lineTo(t(0.46, 0.75).dx, t(0.46, 0.75).dy);
    path.lineTo(t(0.44, 0.92).dx, t(0.44, 0.92).dy);

    path.moveTo(t(0.50 + hipW * 0.6, 0.55).dx, t(0.50 + hipW * 0.6, 0.55).dy);
    path.lineTo(t(0.54, 0.75).dx, t(0.54, 0.75).dy);
    path.lineTo(t(0.56, 0.92).dx, t(0.56, 0.92).dy);

    return path;
  }

  void _drawHotspot(Canvas canvas, Offset pos, Color color, bool isSelected) {
    // Outer pulse ring
    if (isSelected) {
      final ringPaint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(pos, 18, ringPaint);
    }

    // Fill circle
    final fillPaint = Paint()
      ..color = (isSelected ? color : color.withValues(alpha: 0.5))
      ..maskFilter = isSelected ? const MaskFilter.blur(BlurStyle.normal, 5) : null;
    canvas.drawCircle(pos, isSelected ? 10 : 7, fillPaint);

    // Core bright dot
    final dotPaint = Paint()..color = Colors.white.withValues(alpha: isSelected ? 1.0 : 0.7);
    canvas.drawCircle(pos, isSelected ? 4 : 3, dotPaint);
  }

  void _drawHUDCallout(Canvas canvas, Offset organPos, _HotspotDef h, Size size) {
    // Callout line offset: go to the right or left depending on position
    final goRight = organPos.dx < size.width * 0.55;
    final labelX = goRight ? organPos.dx + 48 : organPos.dx - 48;
    final labelY = organPos.dy - 20;
    final labelEnd = Offset(labelX, labelY);

    // Connecting elbow line
    final linePaint = Paint()
      ..color = h.color.withValues(alpha: 0.8)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(organPos.dx, organPos.dy);
    path.lineTo(organPos.dx, labelY);
    path.lineTo(labelEnd.dx, labelY);
    canvas.drawPath(path, linePaint);

    // Endpoint dot
    canvas.drawCircle(labelEnd, 2.5, Paint()..color = h.color);

    // Label box
    const labelPad = EdgeInsets.symmetric(horizontal: 8, vertical: 4);
    final textSpan = TextSpan(
      text: h.label.toUpperCase(),
      style: TextStyle(
        color: h.color,
        fontSize: 9,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
      ),
    );
    final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();

    final boxW = tp.width + labelPad.horizontal;
    final boxH = tp.height + labelPad.vertical;
    final boxRect = Rect.fromLTWH(
      goRight ? labelEnd.dx : labelEnd.dx - boxW,
      labelEnd.dy - boxH / 2,
      boxW,
      boxH,
    );

    // Box background
    final boxPaint = Paint()
      ..color = h.color.withValues(alpha: 0.12);
    canvas.drawRRect(RRect.fromRectAndRadius(boxRect, const Radius.circular(4)), boxPaint);

    // Box border
    final borderPaint = Paint()
      ..color = h.color.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawRRect(RRect.fromRectAndRadius(boxRect, const Radius.circular(4)), borderPaint);

    // Text
    tp.paint(
      canvas,
      Offset(
        boxRect.left + labelPad.left,
        boxRect.top + labelPad.top,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _HolographicBodyPainter old) {
    return old.rotationX != rotationX ||
        old.rotationY != rotationY ||
        old.zoom != zoom ||
        old.isMale != isMale ||
        old.selectedKey != selectedKey ||
        old.scanlineProgress != scanlineProgress ||
        old.glowAlpha != glowAlpha;
  }
}
