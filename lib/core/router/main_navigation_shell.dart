import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

/// Main navigation shell with 4 tabs + fixed NE Assistant FAB (bottom-right).
/// The FAB is anchored via Scaffold.floatingActionButton — it never drifts,
/// never overlaps form fields, and is unaffected by scroll or keyboard events.
class MainNavigationShell extends StatelessWidget {
  const MainNavigationShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _onTabTapped(int index) {
    HapticFeedback.selectionClick();
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  void _openAssistant(BuildContext context) {
    HapticFeedback.mediumImpact();
    context.push('/assistant');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NEColors.background,
      extendBody: true,
      body: navigationShell,
      floatingActionButton: _NEAssistantOrb(
        onTap: () => _openAssistant(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _BottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTabTapped: _onTabTapped,
      ),
    );
  }
}

// ─── NE Assistant Global Orb ─────────────────────────────────────────────────

class _NEAssistantOrb extends StatefulWidget {
  final VoidCallback onTap;
  const _NEAssistantOrb({required this.onTap});

  @override
  State<_NEAssistantOrb> createState() => _NEAssistantOrbState();
}

class _NEAssistantOrbState extends State<_NEAssistantOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _breatheController;
  late Animation<double> _breatheAnimation;

  @override
  void initState() {
    super.initState();
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _breatheAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breatheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _breatheAnimation,
      builder: (context, child) {
        return Transform.scale(scale: _breatheAnimation.value, child: child);
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [NEColors.accentLight, NEColors.accent],
              center: Alignment.topLeft,
              radius: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: NEColors.accent.withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: 4,
              ),
              BoxShadow(
                color: NEColors.accent.withValues(alpha: 0.2),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: const Icon(
            Icons.spa_rounded,
            color: NEColors.textInverse,
            size: 26,
          ),
        ),
      ),
    );
  }
}

// ─── Bottom Navigation Bar ────────────────────────────────────────────────────

class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabTapped;

  const _BottomNavBar({required this.currentIndex, required this.onTabTapped});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: NEColors.surface,
        border: Border(top: BorderSide(color: NEColors.divider, width: 0.5)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(
                icon: Icons.calendar_today_outlined,
                activeIcon: Icons.calendar_today_rounded,
                label: 'Today',
                isSelected: currentIndex == 0,
                onTap: () => onTabTapped(0),
              ),
              _NavItem(
                icon: Icons.favorite_outline_rounded,
                activeIcon: Icons.favorite_rounded,
                label: 'Body',
                isSelected: currentIndex == 1,
                onTap: () => onTabTapped(1),
              ),
              _NavItem(
                icon: Icons.trending_up_rounded,
                activeIcon: Icons.insights_rounded,
                label: 'Insights',
                isSelected: currentIndex == 2,
                onTap: () => onTabTapped(2),
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Me',
                isSelected: currentIndex == 3,
                onTap: () => onTabTapped(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? NEColors.accent : NEColors.textTertiary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? NEColors.accent : NEColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
