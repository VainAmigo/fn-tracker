import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

/// Список категорий с иконкой, названием и цветным баром суммы.
/// Используется в Donut-табе аналитики и совместим по дизайну с [PeriodSegmentChart].
class SpendingCategoriesListWidget extends StatelessWidget {
  const SpendingCategoriesListWidget({
    super.key,
    required this.categorySpending,
  });

  final List<CategorySpending> categorySpending;

  @override
  Widget build(BuildContext context) {
    final segments = categorySpending
        .map((s) => CategorySegmentData.fromCategorySpending(s))
        .where((s) => s.value > 0)
        .toList();
    if (segments.isEmpty) return const SizedBox.shrink();

    final maxValue = segments
        .map((s) => s.value)
        .fold<double>(0, (a, b) => math.max(a, b));
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < segments.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSizing.spaceBtwItems),
          _SpendingCategoryRow(
            segment: segments[i],
            maxValue: maxValue,
            colorScheme: colorScheme,
          ),
        ],
      ],
    );
  }
}

class _SpendingCategoryRow extends StatelessWidget {
  const _SpendingCategoryRow({
    required this.segment,
    required this.maxValue,
    required this.colorScheme,
  });

  static const double _minBarWidth = 90;
  static const double _maxBarWidth = 140;

  final CategorySegmentData segment;
  final double maxValue;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final fraction = maxValue > 0
        ? (segment.value / maxValue).clamp(0.0, 1.0)
        : 0.0;
    final barWidth = _minBarWidth + (_maxBarWidth - _minBarWidth) * fraction;

    return Row(
      children: [
        Container(
          height: AppSizing.heightS,
          width: AppSizing.heightS,
          decoration: BoxDecoration(
            color: segment.color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppSizing.borderRadius8),
          ),
          child: Icon(
            segment.icon ?? Icons.category,
            size: AppSizing.iconSizeM,
            color: segment.color,
          ),
        ),
        const SizedBox(width: AppSizing.spaceBtwItems),
        Expanded(
          child: Text(
            segment.name,
            style: AppTextStyles.listTileTitle(context),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSizing.spaceBtwItems),
        Container(
          height: AppSizing.heightS,
          constraints: const BoxConstraints(minWidth: _minBarWidth),
          width: barWidth,
          decoration: BoxDecoration(
            color: segment.color.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(AppSizing.borderRadius8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.centerRight,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: AmountTextWidget(
              amount: segment.value,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: AppTextStyles.text14w400(
                context,
              ).copyWith(color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }
}
