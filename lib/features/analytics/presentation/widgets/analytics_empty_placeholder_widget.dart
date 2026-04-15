import 'package:flutter/material.dart';
import 'package:fn_tracker/l10n/l10.dart';
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
            context.l10n.noDataForSelectedPeriod,
            style: AppTextStyles.text16w400(context),
          ),
        ),
      ),
    );
  }
}
