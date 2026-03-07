import 'package:flutter/material.dart';
import 'package:fn_tracker/theme/themes.dart';

class EmptyCardWidget extends StatelessWidget {
  const EmptyCardWidget({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSizing.spaceBtwSections,
        ),
        child: Center(
          child: Column(
            children: [
              Text(title, style: AppTextStyles.text16w400(context)),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: AppTextStyles.text16w400(
                    context,
                  ).copyWith(color: Theme.of(context).colorScheme.onSecondary),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
