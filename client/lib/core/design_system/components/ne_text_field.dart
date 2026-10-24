import 'package:flutter/material.dart';

import '../tokens/ne_tokens.dart';

class NETextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final String? errorText;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final int maxLines;
  final bool enabled;
  final VoidCallback? onTap;

  const NETextField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.errorText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.validator,
    this.maxLines = 1,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: NETokens.onSurface,
            ),
          ),
          const SizedBox(height: NETokens.space6),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
          validator: validator,
          maxLines: maxLines,
          enabled: enabled,
          onTap: onTap,
          style: const TextStyle(
            fontSize: 15,
            color: NETokens.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: NETokens.outline,
              fontSize: 14,
            ),
            errorText: errorText,
            filled: true,
            fillColor: enabled
                ? NETokens.surfaceContainerLowest
                : NETokens.surfaceContainerLow,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: NETokens.space16,
              vertical: NETokens.space12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(NETokens.radiusMd),
              borderSide: const BorderSide(color: NETokens.outlineVariant, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(NETokens.radiusMd),
              borderSide: const BorderSide(color: NETokens.outlineVariant, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(NETokens.radiusMd),
              borderSide: const BorderSide(color: NETokens.secondary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(NETokens.radiusMd),
              borderSide: const BorderSide(color: NETokens.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(NETokens.radiusMd),
              borderSide: const BorderSide(color: NETokens.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
