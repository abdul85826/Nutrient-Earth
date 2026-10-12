import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/design_system/components/ne_navigation_bar.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/today')) return 0;
    if (location.startsWith('/body')) return 1;
    if (location.startsWith('/growth')) return 2;
    if (location.startsWith('/explore')) return 3;
    if (location.startsWith('/store')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/today');
        break;
      case 1:
        context.go('/body');
        break;
      case 2:
        context.go('/growth');
        break;
      case 3:
        context.go('/explore');
        break;
      case 4:
        context.go('/store');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NeNavigationBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (int index) => _onItemTapped(index, context),
      ),
    );
  }
}
