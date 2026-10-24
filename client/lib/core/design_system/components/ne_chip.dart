import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../tokens/ne_tokens.dart';

enum NEChipType {
  defaultType,
  measured,
  userReported,
  aiEstimated,
  evidence,
  warning,
  outline,
}

class NEChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback? onTap;
  final NEChipType type;
  final bool isMono;

  const NEChip({
    super.key,
    required this.label,
    this.icon,
    this.isSelected = false,
    this.onTap,
    this.type = NEChipType.defaultType,
    this.isMono = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide border = BorderSide.none;

    switch (type) {
      case NEChipType.measured:
        bg = NETokens.secondaryContainer;
        fg = NETokens.onSecondaryContainer;
        border = const BorderSide(color: NETokens.secondary, width: 1);
        break;
      case NEChipType.evidence:
        bg = NETokens.secondaryContainer.withOpacity(0.4);
        fg = NETokens.secondary;
        border = const BorderSide(color: NETokens.secondary, width: 1);
        break;
      case NEChipType.userReported:
        bg = NETokens.surfaceContainerHigh;
        fg = NETokens.onSurfaceVariant;
        border = const BorderSide(color: NETokens.outlineVariant, width: 1);
        break;
      case NEChipType.aiEstimated:
        bg = NETokens.surfaceContainer;
        fg = NETokens.onSurface;
        border = const BorderSide(color: NETokens.outlineVariant, width: 1);
        break;
      case NEChipType.warning:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFF92400E);
        border = const BorderSide(color: Color(0xFFFDE68A), width: 1);
        break;
      case NEChipType.outline:
        bg = isSelected ? NETokens.primary : Colors.transparent;
        fg = isSelected ? NETokens.onPrimary : NETokens.onSurface;
        border = BorderSide(
          color: isSelected ? NETokens.primary : NETokens.outlineVariant,
          width: 1,
        );
        break;
      case NEChipType.defaultType:
        if (isSelected) {
          bg = NETokens.primary;
          fg = NETokens.onPrimary;
          border = const BorderSide(color: NETokens.primary, width: 1);
        } else {
          bg = NETokens.surfaceContainer;
          fg = NETokens.onSurfaceVariant;
          border = const BorderSide(color: NETokens.outlineVariant, width: 1);
        }
        break;
    }

    final TextStyle textStyle = isMono
        ? GoogleFonts.jetBrainsMono(
            color: fg,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          )
        : GoogleFonts.manrope(
            color: fg,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            letterSpacing: -0.1,
          );

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: NETokens.space4),
        ],
        Text(label, style: textStyle),
      ],
    );

    if (onTap == null) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: NETokens.space8,
          vertical: NETokens.space4,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(NETokens.radiusFull),
          border: border == BorderSide.none ? null : Border.fromBorderSide(border),
        ),
        child: content,
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(NETokens.radiusFull),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: NETokens.space12,
          vertical: NETokens.space6,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(NETokens.radiusFull),
          border: border == BorderSide.none ? null : Border.fromBorderSide(border),
        ),
        child: content,
      ),
    );
  }
}
