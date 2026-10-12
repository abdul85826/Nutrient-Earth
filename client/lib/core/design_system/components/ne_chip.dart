import 'package:flutter/material.dart';
import '../tokens/ne_tokens.dart';

enum NEChipVariant { primary, neutral, outline }

class NEChip extends StatelessWidget {
  const NEChip({
    super.key,
    required this.label,
    this.icon,
    this.variant = NEChipVariant.primary,
    this.onTap,
    this.isSelected = false,
  });

  final String label;
  final Widget? icon;
  final NEChipVariant variant;
  final VoidCallback? onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case NEChipVariant.primary:
        bg = isSelected
            ? NEColors.primary
            : NEColors.primary.withValues(alpha: 0.08);
        fg = isSelected ? Colors.white : NEColors.primary;
        borderSide = BorderSide(
          color: NEColors.primary.withValues(alpha: isSelected ? 1.0 : 0.2),
          width: 1.0,
        );
        break;
      case NEChipVariant.neutral:
        bg = isSelected ? NEColors.textPrimary : NEColors.surfaceSubtle;
        fg = isSelected ? Colors.white : NEColors.textSecondary;
        borderSide = const BorderSide(color: NEColors.border, width: 1.0);
        break;
      case NEChipVariant.outline:
        bg = Colors.transparent;
        fg = NEColors.textPrimary;
        borderSide = const BorderSide(color: NEColors.border, width: 1.0);
        break;
    }

    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NERadius.chip),
        side: borderSide,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(NERadius.chip),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 6.0)],
              Text(
                label,
                style: NETypography.labelSmall.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

typedef NeChip = NEChip;
