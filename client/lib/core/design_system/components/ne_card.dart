import 'package:flutter/material.dart';

import '../tokens/ne_tokens.dart';

class NECard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final double borderRadius;

  const NECard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.backgroundColor,
    this.border,
    this.boxShadow,
    this.borderRadius = NETokens.radiusLg,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ?? NETokens.surfaceContainerLow;
    final effectiveBorder =
        border ?? Border.all(color: NETokens.outlineVariant, width: 1);

    Widget container = Container(
      padding: padding ?? const EdgeInsets.all(NETokens.space16),
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: effectiveBorder,
        boxShadow: boxShadow,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: container,
        ),
      );
    }

    return container;
  }
}
