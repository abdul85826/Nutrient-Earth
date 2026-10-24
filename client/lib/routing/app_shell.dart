import 'package:flutter/material.dart';

import '../core/design_system/components/ne_navigation_bar.dart';
import '../features/research/research_home_empty_screen.dart';
import '../features/goals/goals_home_empty_screen.dart';

/// The Root Application Shell enforcing STRICTLY TWO primary tabs:
/// Index 0: Research
/// Index 1: Goals
class AppShell extends StatefulWidget {
  final int initialTab;

  const AppShell({
    super.key,
    this.initialTab = 0,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _currentTab;

  final List<Widget> _tabs = const [
    ResearchHomeEmptyScreen(),
    GoalsHomeEmptyScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
  }

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
