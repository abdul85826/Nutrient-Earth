import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import 'learn_section.dart';
import 'exercise_section.dart';
import 'store_section.dart';

class LearnDiscoverTabScreen extends StatefulWidget {
  const LearnDiscoverTabScreen({super.key});

  @override
  State<LearnDiscoverTabScreen> createState() => _LearnDiscoverTabScreenState();
}

class _LearnDiscoverTabScreenState extends State<LearnDiscoverTabScreen> {
  int _activeSection = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn & Discover'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: NETokens.space16,
              vertical: NETokens.space8,
            ),
            child: NESegmentedTabBar(
              selectedIndex: _activeSection,
              tabs: const [
                NESegmentedTabItem(
                  label: 'Learn',
                  icon: Icons.menu_book_rounded,
                ),
                NESegmentedTabItem(
                  label: 'Exercise',
                  icon: Icons.fitness_center_rounded,
                ),
                NESegmentedTabItem(
                  label: 'Store',
                  icon: Icons.shopping_bag_outlined,
                ),
              ],
              onTabChanged: (index) => setState(() => _activeSection = index),
            ),
          ),
        ),
      ),
      body: IndexedStack(
        index: _activeSection,
        children: const [LearnSection(), ExerciseSection(), StoreSection()],
      ),
    );
  }
}
