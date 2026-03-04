import 'package:fn_tracker/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ModalSheetTitleWidget extends StatelessWidget {
  const ModalSheetTitleWidget({
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
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.modalSheetTitle(context)),
            if (subtitle != null) ...[
              const SizedBox(height: AppSizing.spaceBtwItemsExtra),
              Text(subtitle!, style: AppTextStyles.tabSubTitle(context)),
            ],
          ],
        ),
        if (action != null) ...[
          const Spacer(),
          action!,
        ],
      ],
    );
  }
}
