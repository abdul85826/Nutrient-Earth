import 'package:flutter/material.dart';

import '../tokens/ne_tokens.dart';

enum NEButtonVariant { primary, secondary, outline, text }

class NEButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final NEButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  const NEButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = NEButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide border = BorderSide.none;

    switch (variant) {
      case NEButtonVariant.primary:
        bg = NETokens.primary;
        fg = NETokens.textInverse;
        break;
      case NEButtonVariant.secondary:
        bg = NETokens.surfaceElevated;
        fg = NETokens.textPrimary;
        border = const BorderSide(color: NETokens.borderDefault);
        break;
      case NEButtonVariant.outline:
        bg = Colors.transparent;
        fg = NETokens.textPrimary;
        border = const BorderSide(color: NETokens.borderDefault);
        break;
      case NEButtonVariant.text:
        bg = Colors.transparent;
        fg = NETokens.primary;
        break;
    }

    if (onPressed == null) {
      bg = NETokens.surfaceElevated.withOpacity(0.5);
      fg = NETokens.textMuted;
      border = BorderSide.none;
    }

    Widget content = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        else if (icon != null) ...[
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: NETokens.space8),
        ],
        if (!isLoading)
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
      ],
    );

    return InkWell(
      onTap: isLoading ? null : onPressed,
      borderRadius: BorderRadius.circular(NETokens.radiusMd),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: NETokens.space16,
          vertical: NETokens.space12,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(NETokens.radiusMd),
          border: border == BorderSide.none
              ? null
              : Border.fromBorderSide(border),
          boxShadow: variant == NEButtonVariant.primary && onPressed != null
              ? NETokens.glowShadow
              : null,
        ),
        child: content,
      ),
    );
  }
}
