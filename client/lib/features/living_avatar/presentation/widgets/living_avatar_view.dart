// ==============================================================================
// Nutrient Earth — Living Avatar View
// High-performance Flutter multi-layer rendering widget.
// Manages 60 FPS animation ticker, lifecycle pausing, reduced-motion compliance,
// and semantic accessibility within the strictly bounded avatar container.
// ==============================================================================

import 'package:flutter/material.dart';
import '../../domain/entities/avatar_scene_state.dart';
import '../rendering/sky_environment_painter.dart';
import '../rendering/character_silhouette_painter.dart';
import '../rendering/lighting_overlay_painter.dart';
import 'avatar_accessibility_wrapper.dart';

class LivingAvatarView extends StatefulWidget {
  final AvatarSceneState scene;
  final double size;
  final VoidCallback? onTap;
  final bool enableAnimation;

  const LivingAvatarView({
    super.key,
    required this.scene,
    this.size = 110.0,
    this.onTap,
    this.enableAnimation = true,
  });

  @override
  State<LivingAvatarView> createState() => _LivingAvatarViewState();
}

class _LivingAvatarViewState extends State<LivingAvatarView>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _tickerController;
  double _elapsedSeconds = 0.0;
  bool _isAppActive = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _tickerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 120), // 2-minute loop for smooth periodicity
    )..addListener(_onTick);

    if (widget.enableAnimation) {
      _tickerController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant LivingAvatarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enableAnimation != oldWidget.enableAnimation) {
      if (widget.enableAnimation && _isAppActive) {
        _tickerController.repeat();
      } else {
        _tickerController.stop();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final isActive = (state == AppLifecycleState.resumed);
    if (_isAppActive != isActive) {
      _isAppActive = isActive;
      if (_isAppActive && widget.enableAnimation) {
        _tickerController.repeat();
      } else {
        _tickerController.stop();
      }
    }
  }

  void _onTick() {
    setState(() {
      _elapsedSeconds = _tickerController.value * 120.0;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tickerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final effectiveTime = disableAnimations ? 0.0 : _elapsedSeconds;

    final avatarContent = SizedBox(
      width: widget.size,
      height: widget.size,
      child: ClipOval(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Layer 1: Astronomical Sky & Celestial Bodies
            CustomPaint(
              painter: SkyEnvironmentPainter(
                world: widget.scene.world,
                animationTimeSeconds: effectiveTime,
              ),
            ),

            // Layer 2: Character Silhouette, Vitality & Clothing Props
            CustomPaint(
              painter: CharacterSilhouettePainter(
                identity: widget.scene.identity,
                appearance: widget.scene.appearance,
                behaviour: widget.scene.behaviour,
                world: widget.scene.world,
                animationTimeSeconds: effectiveTime,
              ),
            ),

            // Layer 3: Directional Lighting, Weather Particles & Depth Vignette
            CustomPaint(
              painter: LightingOverlayPainter(
                world: widget.scene.world,
                animationTimeSeconds: effectiveTime,
              ),
            ),
          ],
        ),
      ),
    );

    return AvatarAccessibilityWrapper(
      scene: widget.scene,
      onTap: widget.onTap,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF0A2E1F), // Botanical deep forest green border
              width: 2.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x180A2E1F),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: avatarContent,
        ),
      ),
    );
  }
}
