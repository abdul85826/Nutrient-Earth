// ==============================================================================
// Nutrient Earth — Reactive Circadian Avatar Engine & Creation Modal
// Strict Ralph Graph Unidirectional Flow & CodeRabbit Null Safety
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../profile/presentation/widgets/avatar_state_switcher.dart';

export '../../../profile/presentation/widgets/avatar_state_switcher.dart';

final avatarSkinToneProvider = StateProvider<Color>((ref) => const Color(0xFFE0AC69));
final isAvatarCreatedProvider = StateProvider<bool>((ref) => false);

class ReactiveAvatarWidget extends ConsumerWidget {
  const ReactiveAvatarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const AvatarStateSwitcher(size: 110.0);
  }
}
