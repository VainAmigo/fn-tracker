import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/theme/themes.dart';

class AmountDividerWidget extends StatelessWidget {
  const AmountDividerWidget({
    super.key,
    required this.leftAmount,
    required this.rightAmount,
    this.dividerType = DividerType.dot,
    this.styel,
  });

  final double leftAmount;
  final double rightAmount;
  final TextStyle? styel;
  final DividerType dividerType;

  @override
  Widget build(BuildContext context) {
    final divider = dividerType == DividerType.dot ? '•' : '/';
    return Row(
      spacing: AppSizing.spaceBtwItemsExtra,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AmountTextWidget(
          amount: leftAmount,
          style: styel ?? AppTextStyles.text14w400(context),
        ),
        Text(divider, style: AppTextStyles.text14w400(context)),
        AmountTextWidget(
          amount: rightAmount,
          style: styel ?? AppTextStyles.text14w400(context),
        ),
      ],
    );
  }
}

enum DividerType { dot, slash }
