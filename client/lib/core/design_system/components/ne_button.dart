import 'package:flutter/material.dart';
import '../tokens/ne_tokens.dart';

enum NEButtonVariant { primary, secondary, ghost }
enum NEButtonSize { small, medium, large }

class NEButton extends StatelessWidget {
  NEButton({
    super.key,
    required this.label,
    required this.onPressed,
    dynamic icon,
    this.variant = NEButtonVariant.primary,
    this.size = NEButtonSize.large,
    this.isFullWidth = false,
    this.isLoading = false,
    this.semanticLabel,
  }) : iconWidget = icon is IconData ? Icon(icon, size: 18) : (icon as Widget?);

  final String label;
  final VoidCallback? onPressed;
  final Widget? iconWidget;
  final NEButtonVariant variant;
  final NEButtonSize size;
  final bool isFullWidth;
  final bool isLoading;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case NEButtonVariant.primary:
        bg = NEColors.primary;
        fg = Colors.white;
        break;
      case NEButtonVariant.secondary:
        bg = NEColors.surface;
        fg = NEColors.primary;
        borderSide = const BorderSide(color: NEColors.border, width: 1.2);
        break;
      case NEButtonVariant.ghost:
        bg = Colors.transparent;
        fg = NEColors.primary;
        break;
    }

    double height;
    EdgeInsets padding;
    TextStyle style;

    switch (size) {
      case NEButtonSize.small:
        height = 36.0;
        padding = const EdgeInsets.symmetric(horizontal: 14.0);
        style = NETypography.labelSmall.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        );
        break;
      case NEButtonSize.medium:
        height = 46.0;
        padding = const EdgeInsets.symmetric(horizontal: 20.0);
        style = NETypography.labelLarge.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        );
        break;
      case NEButtonSize.large:
        height = 54.0;
        padding = const EdgeInsets.symmetric(horizontal: 24.0);
        style = NETypography.labelLarge.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: 15.0,
        );
        break;
    }

    final Widget content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        else ...[
          if (iconWidget != null) ...[
            iconWidget!,
            const SizedBox(width: 8.0),
          ],
          Text(label, style: style),
        ],
      ],
    );

    return Semantics(
      button: true,
      label: semanticLabel ?? label,
      enabled: onPressed != null && !isLoading,
      child: SizedBox(
        height: height,
        width: isFullWidth ? double.infinity : null,
        child: Material(
          color: bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(height / 2),
            side: borderSide,
          ),
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(height / 2),
            child: Padding(
              padding: padding,
              child: Center(child: content),
            ),
          ),
        ),
      ),
    );
  }
}

typedef NeButton = NEButton;
typedef NeButtonVariant = NEButtonVariant;
typedef NeButtonSize = NEButtonSize;

