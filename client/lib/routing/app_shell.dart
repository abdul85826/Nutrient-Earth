import 'package:flutter/material.dart';

import '../core/design_system/design_system.dart';
import '../features/your_health/presentation/your_health_tab_screen.dart';
import '../features/learn_discover/presentation/learn_discover_tab_screen.dart';

/// The Root Application Shell enforcing STRICTLY TWO primary tabs:
/// Index 0: Your Health
/// Index 1: Learn & Discover
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentTab = 0;

  final List<Widget> _tabs = const [
    YourHealthTabScreen(),
    LearnDiscoverTabScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentTab, children: _tabs),
      bottomNavigationBar: NENavigationBar(
        currentIndex: _currentTab,
        onTabSelected: (index) {
          if (index >= 0 && index <= 1) {
            setState(() => _currentTab = index);
          }
        },
      ),
    );
  }
}
