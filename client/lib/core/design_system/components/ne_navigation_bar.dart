import 'package:flutter/material.dart';

import '../tokens/ne_tokens.dart';

/// The authoritative bottom navigation bar for Nutrient Earth.
/// STRICT REQUIREMENT: Exactly TWO primary tabs:
/// Index 0: Research
/// Index 1: Goals
class NENavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const NENavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: NETokens.surfaceContainerLow,
        border: Border(
          top: BorderSide(color: NETokens.outlineVariant, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: NETokens.space24,
            vertical: NETokens.space8,
          ),
          child: Row(
            children: [
              Expanded(
                child: _NavBarItem(
                  label: 'Research',
                  icon: Icons.search_rounded,
                  activeIcon: Icons.saved_search_rounded,
                  isActive: currentIndex == 0,
                  onTap: () => onTabSelected(0),
                ),
              ),
              const SizedBox(width: NETokens.space16),
              Expanded(
                child: _NavBarItem(
                  label: 'Goals',
                  icon: Icons.flag_outlined,
                  activeIcon: Icons.flag_rounded,
                  isActive: currentIndex == 1,
                  onTap: () => onTabSelected(1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isActive,
      label: '$label tab',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(NETokens.radiusFull),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            vertical: NETokens.space8,
            horizontal: NETokens.space16,
          ),
          decoration: BoxDecoration(
            color: isActive ? NETokens.secondaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(NETokens.radiusFull),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                size: 20,
                color: isActive
                    ? NETokens.onSecondaryContainer
                    : NETokens.onSurfaceVariant,
              ),
              const SizedBox(width: NETokens.space8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive
                      ? NETokens.onSecondaryContainer
                      : NETokens.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
