import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import 'search_ai_workspace.dart';
import 'body_progress_screen.dart';

class YourHealthTabScreen extends StatefulWidget {
  const YourHealthTabScreen({super.key});

  @override
  State<YourHealthTabScreen> createState() => _YourHealthTabScreenState();
}

class _YourHealthTabScreenState extends State<YourHealthTabScreen> {
  int _activeSection = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Health'),
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
                  label: 'Search & AI',
                  icon: Icons.chat_bubble_outline_rounded,
                ),
                NESegmentedTabItem(
                  label: 'Body & Progress',
                  icon: Icons.trending_up_rounded,
                ),
              ],
              onTabChanged: (index) => setState(() => _activeSection = index),
            ),
          ),
        ),
      ),
      body: IndexedStack(
        index: _activeSection,
        children: const [SearchAIWorkspace(), BodyProgressScreen()],
      ),
    );
  }
}
