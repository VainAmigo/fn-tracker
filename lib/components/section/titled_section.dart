import 'package:fn_tracker/theme/themes.dart';
import 'package:flutter/material.dart';

class TitledSection extends StatelessWidget {
  const TitledSection({
    super.key,
    required this.title,
    this.action,
    required this.children,
  });

  final String title;
  final Widget? action;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: Text(title, style: AppTextStyles.sectionTitle(context))),
            if (action != null) ...[
              const SizedBox(width: AppSizing.spaceBtwItems),
              action!,
            ],
          ],
        ),
        const SizedBox(height: AppSizing.spaceBtwItems),
        ...children,
      ],
    );
  }
}
