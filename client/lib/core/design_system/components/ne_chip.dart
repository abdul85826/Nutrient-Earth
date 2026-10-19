import 'package:flutter/material.dart';

import '../tokens/ne_tokens.dart';

enum NEChipType {
  defaultType,
  measured,
  userReported,
  aiEstimated,
  warning,
  outline,
}

class NEChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback? onTap;
  final NEChipType type;

  const NEChip({
    super.key,
    required this.label,
    this.icon,
    this.isSelected = false,
    this.onTap,
    this.type = NEChipType.defaultType,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide border = BorderSide.none;

    switch (type) {
      case NEChipType.measured:
        bg = NETokens.measuredBadge.withOpacity(0.15);
        fg = NETokens.measuredBadge;
        border = BorderSide(color: NETokens.measuredBadge.withOpacity(0.3));
        break;
      case NEChipType.userReported:
        bg = NETokens.userReportedBadge.withOpacity(0.15);
        fg = NETokens.userReportedBadge;
        border = BorderSide(color: NETokens.userReportedBadge.withOpacity(0.3));
        break;
      case NEChipType.aiEstimated:
        bg = NETokens.aiEstimatedBadge.withOpacity(0.15);
        fg = NETokens.aiEstimatedBadge;
        border = BorderSide(color: NETokens.aiEstimatedBadge.withOpacity(0.3));
        break;
      case NEChipType.warning:
        bg = NETokens.warning.withOpacity(0.15);
        fg = NETokens.warning;
        border = BorderSide(color: NETokens.warning.withOpacity(0.3));
        break;
      case NEChipType.outline:
        bg = Colors.transparent;
        fg = isSelected ? NETokens.primary : NETokens.textSecondary;
        border = BorderSide(
          color: isSelected ? NETokens.primary : NETokens.borderDefault,
        );
        break;
      case NEChipType.defaultType:
        if (isSelected) {
          bg = NETokens.primary.withOpacity(0.15);
          fg = NETokens.primaryLight;
          border = const BorderSide(color: NETokens.primary, width: 1);
        } else {
          bg = NETokens.surfaceElevated;
          fg = NETokens.textSecondary;
          border = const BorderSide(color: NETokens.borderSubtle, width: 1);
        }
        break;
    }

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: NETokens.space4),
        ],
        Text(
          label,
          style: TextStyle(
            color: fg,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            letterSpacing: -0.1,
          ),
        ),
      ],
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(NETokens.radiusFull),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: NETokens.space12,
          vertical: NETokens.space8,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(NETokens.radiusFull),
          border: border == BorderSide.none
              ? null
              : Border.fromBorderSide(border),
        ),
        child: content,
      ),
    );
  }
}
