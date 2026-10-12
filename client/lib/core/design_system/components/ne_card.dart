import 'package:flutter/material.dart';
import '../tokens/ne_tokens.dart';

enum NECardVariant { primary, secondary, subtle }

class NECard extends StatelessWidget {
  const NECard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(NESpacing.s16),
    this.margin,
    this.variant = NECardVariant.primary,
    this.color,
    this.border,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final NECardVariant variant;
  final Color? color;
  final BoxBorder? border;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Color bg = color ?? NEColors.surface;
    BoxBorder effectiveBorder = border ?? Border.fromBorderSide(
      BorderSide(color: NEColors.border.withValues(alpha: 0.8), width: 1.0),
    );

    if (color == null && border == null) {
      switch (variant) {
        case NECardVariant.primary:
          bg = NEColors.surface;
          effectiveBorder = Border.fromBorderSide(
            BorderSide(color: NEColors.border.withValues(alpha: 0.8), width: 1.0),
          );
          break;
        case NECardVariant.secondary:
          bg = NEColors.surfaceSubtle;
          effectiveBorder = const Border.fromBorderSide(
            BorderSide(color: NEColors.borderSubtle, width: 1.0),
          );
          break;
        case NECardVariant.subtle:
          bg = NEColors.background;
          effectiveBorder = Border.fromBorderSide(
            BorderSide(color: NEColors.border.withValues(alpha: 0.5), width: 1.0),
          );
          break;
      }
    }

    final Widget content = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: NERadius.cardRadius,
        border: effectiveBorder,
        boxShadow: const [
          BoxShadow(
            color: NEColors.shadowSubtle,
            blurRadius: 8.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: NERadius.cardRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: NERadius.cardRadius,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );

    return content;
  }
}

typedef NeCard = NECard;

