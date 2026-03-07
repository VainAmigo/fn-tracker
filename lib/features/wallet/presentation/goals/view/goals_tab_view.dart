import 'package:flutter/material.dart';
import 'package:fn_tracker/theme/themes.dart';

class GoalsTabWidget extends StatelessWidget {
  const GoalsTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Goals',
            style: AppTextStyles.tabTitle(context),
          ),
          const SizedBox(height: AppSizing.spaceBtwSections),
          const SizedBox(height: 200),
        ],
      ),
    );
  }
}
