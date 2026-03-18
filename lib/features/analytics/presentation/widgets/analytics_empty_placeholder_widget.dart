import 'package:flutter/material.dart';
import 'package:fn_tracker/theme/themes.dart';

class AnalyticsEmptyPlaceholderWidget extends StatelessWidget {
  const AnalyticsEmptyPlaceholderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSizing.spaceBtwSections,
        ),
        child: Center(
          child: Text(
            'Нет данных за выбранный период',
            style: AppTextStyles.text16w400(context),
          ),
        ),
      ),
    );
  }
}
