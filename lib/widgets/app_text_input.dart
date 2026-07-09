import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

class AppTextInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final String? label;
  final String? hintText;
  final int maxLines;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;

  const AppTextInput({
    super.key,
    this.controller,
    this.initialValue,
    this.label,
    this.hintText,
    this.maxLines = 1,
    this.readOnly = false,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = InputDecoration(labelText: label, hintText: hintText);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: controller != null
          ? TextField(
              controller: controller,
              maxLines: maxLines,
              readOnly: readOnly,
              onChanged: onChanged,
              onTap: onTap,
              decoration: decoration,
            )
          : TextFormField(
              initialValue: initialValue,
              maxLines: maxLines,
              readOnly: readOnly,
              onChanged: onChanged,
              onTap: onTap,
              decoration: decoration,
            ),
    );
  }
}
