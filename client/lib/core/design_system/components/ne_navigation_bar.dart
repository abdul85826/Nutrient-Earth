import 'package:flutter/material.dart';

import '../tokens/ne_tokens.dart';

/// The authoritative bottom navigation bar for Nutrient Earth.
/// STRICT REQUIREMENT: Exactly TWO primary tabs:
/// Index 0: Your Health
/// Index 1: Learn & Discover
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
        color: NETokens.surface,
        border: Border(top: BorderSide(color: NETokens.borderSubtle, width: 1)),
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
                  label: 'Your Health',
                  icon: Icons.favorite_border_rounded,
                  activeIcon: Icons.favorite_rounded,
                  isActive: currentIndex == 0,
                  onTap: () => onTabSelected(0),
                ),
              ),
              const SizedBox(width: NETokens.space16),
              Expanded(
                child: _NavBarItem(
                  label: 'Learn & Discover',
                  icon: Icons.explore_outlined,
                  activeIcon: Icons.explore_rounded,
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
    final fg = isActive ? NETokens.primary : NETokens.textMuted;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(NETokens.radiusMd),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          vertical: NETokens.space8,
          horizontal: NETokens.space12,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? NETokens.primary.withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(NETokens.radiusMd),
          border: isActive
              ? Border.all(color: NETokens.primary.withOpacity(0.2), width: 1)
              : Border.all(color: Colors.transparent, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isActive ? activeIcon : icon, color: fg, size: 22),
            const SizedBox(height: NETokens.space4),
            Text(
              label,
              style: TextStyle(
                color: fg,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
