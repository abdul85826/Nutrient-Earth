import 'package:flutter/material.dart';

import '../tokens/ne_tokens.dart';

class NESegmentedTabItem {
  final String label;
  final IconData? icon;

  const NESegmentedTabItem({required this.label, this.icon});
}

class NESegmentedTabBar extends StatelessWidget {
  final List<NESegmentedTabItem> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  const NESegmentedTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(NETokens.space4),
      decoration: BoxDecoration(
        color: NETokens.surfaceElevated,
        borderRadius: BorderRadius.circular(NETokens.radiusMd),
        border: Border.all(color: NETokens.borderSubtle, width: 1),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final tab = tabs[index];
          final isSelected = selectedIndex == index;

          return Expanded(
            child: InkWell(
              onTap: () => onTabChanged(index),
              borderRadius: BorderRadius.circular(NETokens.radiusSm),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: NETokens.space8),
                decoration: BoxDecoration(
                  color: isSelected ? NETokens.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(NETokens.radiusSm),
                  border: isSelected
                      ? Border.all(color: NETokens.borderDefault, width: 1)
                      : null,
                  boxShadow: isSelected ? NETokens.cardShadow : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (tab.icon != null) ...[
                      Icon(
                        tab.icon,
                        size: 16,
                        color: isSelected
                            ? NETokens.primary
                            : NETokens.textMuted,
                      ),
                      const SizedBox(width: NETokens.space8),
                    ],
                    Text(
                      tab.label,
                      style: TextStyle(
                        color: isSelected
                            ? NETokens.textPrimary
                            : NETokens.textMuted,
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
