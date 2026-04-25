import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../../features/assistant/ne_assistant_orb.dart';

class MainNavigationShell extends StatelessWidget {
  const MainNavigationShell({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return NEAssistantOrb(
      child: Scaffold(
        backgroundColor: AppTheme.forestDeep,
        body: navigationShell,
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: AppTheme.forestDeep,
            border: Border(
              top: BorderSide(color: AppTheme.glassBorder, width: 0.5),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: BottomNavigationBar(
                currentIndex: navigationShell.currentIndex,
                onTap: (index) => navigationShell.goBranch(index),
                backgroundColor: Colors.transparent,
                type: BottomNavigationBarType.fixed,
                elevation: 0,
                selectedItemColor: AppTheme.earth,
                unselectedItemColor: AppTheme.cloud.withValues(alpha: 0.4),
                selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                unselectedLabelStyle: const TextStyle(fontSize: 10),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.today_outlined),
                    activeIcon: Icon(Icons.today),
                    label: 'TODAY',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.favorite_border),
                    activeIcon: Icon(Icons.favorite),
                    label: 'BODY',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.water_drop_outlined),
                    activeIcon: Icon(Icons.water_drop),
                    label: 'FLOW',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.explore_outlined),
                    activeIcon: Icon(Icons.explore),
                    label: 'EXPLORE',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    activeIcon: Icon(Icons.person),
                    label: 'ME',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
