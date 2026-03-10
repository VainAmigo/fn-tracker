import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/theme/themes.dart';

class AnalyticsErrorPlaceholderWidget extends StatelessWidget {
  const AnalyticsErrorPlaceholderWidget({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message,
          style: AppTextStyles.text16w400(context),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSizing.spaceBtwItems),
        PrimaryButton(
          text: 'Повторить',
          size: PrimaryButtonSize.xSmall,
          rounded: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.primary,
          onPressed: onRetry,
        ),
      ],
    );
  }
}
