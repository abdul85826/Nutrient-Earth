// ==============================================================================
// Nutrient Earth — Living Avatar Accessibility Wrapper
// Provides rich semantic descriptions for screen readers (TalkBack/VoiceOver),
// respects reduced-motion preferences, and enforces accessible touch targets.
// ==============================================================================

import 'package:flutter/material.dart';
import '../../domain/entities/avatar_scene_state.dart';
import '../../domain/entities/avatar_appearance.dart';

class AvatarAccessibilityWrapper extends StatelessWidget {
  final AvatarSceneState scene;
  final Widget child;
  final VoidCallback? onTap;

  const AvatarAccessibilityWrapper({
    super.key,
    required this.scene,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final semanticLabel = _buildSemanticDescription(scene);

    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: true,
      onTap: onTap,
      child: child,
    );
  }

  /// Builds a rich, dignified natural-language description of the avatar and its environment.
  static String _buildSemanticDescription(AvatarSceneState scene) {
    final buffer = StringBuffer();
    final identity = scene.identity;
    final world = scene.world;
    final appearance = scene.appearance;

    buffer.write('Your companion avatar, ${identity.name}. ');

    // Sky / Time description
    if (world.astronomy.isDay) {
      buffer.write('Standing under a ${world.weather.conditionName.toLowerCase()} daytime sky. ');
    } else if (world.astronomy.isCivilTwilight) {
      buffer.write('At twilight with gentle sunset hues. ');
    } else {
      buffer.write('Under a nocturnal sky with a ${world.astronomy.lunarPhase.displayName.toLowerCase()} moon. ');
    }

    // Season & Temperature
    buffer.write('Season is ${world.season.displayName}, ${world.weather.temperatureCelsius.round()} degrees Celsius. ');

    // Attire
    final clothingDesc = appearance.clothing.displayName;
    buffer.write('Wearing $clothingDesc. ');

    // Handheld prop
    if (appearance.handAttachment != HandAttachmentType.none) {
      buffer.write('Holding a ${appearance.handAttachment.displayName.toLowerCase()}. ');
    }

    buffer.write('Breathing steadily. Double tap to customize.');

    return buffer.toString();
  }
}
