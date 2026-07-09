import 'package:flutter/material.dart';

import 'app_text_input.dart';

class PrivacyPolicySheetContent extends StatelessWidget {
  final String body;
  final String urlLabel;
  final String url;

  const PrivacyPolicySheetContent({
    super.key,
    required this.body,
    required this.urlLabel,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(body),
        const SizedBox(height: 12),
        AppTextInput(label: urlLabel, initialValue: url, readOnly: true),
        const SizedBox(height: 12),
      ],
    );
  }
}
