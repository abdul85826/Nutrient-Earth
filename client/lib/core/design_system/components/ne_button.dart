import 'package:flutter/material.dart';

import '../tokens/ne_tokens.dart';

enum NEButtonVariant { primary, secondary, outline, text, danger }

class NEButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final NEButtonVariant variant;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool fullWidth;
  final double? height;

  const NEButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = NEButtonVariant.primary,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.fullWidth = false,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide border = BorderSide.none;

    switch (variant) {
      case NEButtonVariant.primary:
        bg = NETokens.primary;
        fg = NETokens.onPrimary;
        break;
      case NEButtonVariant.secondary:
        bg = NETokens.secondaryContainer;
        fg = NETokens.onSecondaryContainer;
        break;
      case NEButtonVariant.outline:
        bg = Colors.transparent;
        fg = NETokens.onSurface;
        border = const BorderSide(color: NETokens.outlineVariant, width: 1.2);
        break;
      case NEButtonVariant.text:
        bg = Colors.transparent;
        fg = NETokens.secondary;
        break;
      case NEButtonVariant.danger:
        bg = NETokens.errorContainer;
        fg = NETokens.onErrorContainer;
        break;
    }

    final isEnabled = onPressed != null && !isLoading;
    if (!isEnabled && variant != NEButtonVariant.text) {
      bg = NETokens.surfaceDim.withOpacity(0.4);
      fg = NETokens.outline;
      border = BorderSide.none;
    }

    Widget content = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          ),
          const SizedBox(width: NETokens.space8),
        ] else if (icon != null) ...[
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: NETokens.space8),
        ],
        Text(
          label,
          style: TextStyle(
            color: fg,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
        if (trailingIcon != null && !isLoading) ...[
          const SizedBox(width: NETokens.space8),
          Icon(trailingIcon, size: 18, color: fg),
        ],
      ],
    );

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: label,
      child: SizedBox(
        width: fullWidth ? double.infinity : null,
        height: height ?? 48,
        child: Material(
          color: bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NETokens.radiusFull),
            side: border,
          ),
          child: InkWell(
            onTap: isEnabled ? onPressed : null,
            borderRadius: BorderRadius.circular(NETokens.radiusFull),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: NETokens.space20,
                vertical: NETokens.space12,
              ),
              child: Center(child: content),
            ),
          ),
        ),
      ),
    );
  }
}
