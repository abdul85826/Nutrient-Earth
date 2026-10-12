import 'package:flutter/material.dart';
import '../tokens/ne_tokens.dart';

class NENavigationBar extends StatelessWidget {
  const NENavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.biotech_rounded, Icons.biotech_outlined, 'Ask'),
      (Icons.explore_rounded, Icons.explore_outlined, 'Explore'),
      (Icons.trending_up_rounded, Icons.trending_up_outlined, 'Growth'),
      (
        Icons.accessibility_new_rounded,
        Icons.accessibility_new_outlined,
        'Body',
      ),
      (Icons.storefront_rounded, Icons.storefront_outlined, 'Store'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: NEColors.surface,
        border: Border(
          top: BorderSide(
            color: NEColors.border.withValues(alpha: 0.8),
            width: 1.0,
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: NEColors.shadowSubtle,
            blurRadius: 10.0,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final item = items[i];
              final isSelected = i == currentIndex;
              return InkWell(
                onTap: () => onTap(i),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 4.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? item.$1 : item.$2,
                        size: 24,
                        color: isSelected
                            ? NEColors.primary
                            : NEColors.textTertiary,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.$3,
                        style: NETypography.labelSmall.copyWith(
                          color: isSelected
                              ? NEColors.primary
                              : NEColors.textTertiary,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

typedef NeNavigationBar = NENavigationBar;
