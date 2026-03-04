import 'package:fn_tracker/theme/themes.dart';
import 'package:flutter/material.dart';

class TabTitleWidget extends StatelessWidget {
  const TabTitleWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
  });

  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: AppTextStyles.tabTitle(context),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppSizing.spaceBtwItemsExtra),
                Text(subtitle!, style: AppTextStyles.tabSubTitle(context)),
              ],
            ],
          ),
        ),
        if (action != null) ...[
          const SizedBox(width: AppSizing.spaceBtwItems),
          action!,
        ],
      ],
    );
  }
}
