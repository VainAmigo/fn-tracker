import 'package:fn_tracker/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Сегмент для выбора в [SegmentedControl].
class SegmentItem<T> {
  const SegmentItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  final T value;
  final String label;
  final IconData icon;
}

/// Универсальный сегментированный контрол с pill-кнопками и иконками.
/// Поддерживает произвольный тип значения [T].
class SegmentedControl<T> extends StatelessWidget {
  const SegmentedControl({
    super.key,
    required this.segments,
    required this.selectedValue,
    required this.onChanged,
    this.height = 40,
  });

  final List<SegmentItem<T>> segments;
  final T selectedValue;
  final ValueChanged<T> onChanged;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Row(children: _buildSegments(context));
  }

  List<Widget> _buildSegments(BuildContext context) {
    final spacing = AppSizing.spaceBtwElementsExtra;
    final segmentCount = segments.length;

    return segments.asMap().entries.map((entry) {
      final index = entry.key;
      final segment = entry.value;
      final isSelected = segment.value == selectedValue;

      return Expanded(
        child: Padding(
          padding: EdgeInsets.only(
            right: index < segmentCount - 1 ? spacing : 0,
          ),
          child: _SegmentButton<T>(
            segment: segment,
            isSelected: isSelected,
            isFirst: index == 0,
            isLast: index == segmentCount - 1,
            onTap: () => onChanged(segment.value),
            height: height,
          ),
        ),
      );
    }).toList();
  }
}

class _SegmentButton<T> extends StatelessWidget {
  const _SegmentButton({
    required this.segment,
    required this.isSelected,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
    required this.height,
  });

  final SegmentItem<T> segment;
  final bool isSelected;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;
  final double height;

  BorderRadius _getBorderRadius() {
    final selectedBorderRadius = AppSizing.borderRadius100;
    final unselectedBorderRadius = AppSizing.borderRadius8;

    if (isSelected) {
      return BorderRadius.circular(selectedBorderRadius);
    }
    if (isFirst) {
      return BorderRadius.only(
        topLeft: Radius.circular(selectedBorderRadius),
        bottomLeft: Radius.circular(selectedBorderRadius),
        topRight: Radius.circular(unselectedBorderRadius),
        bottomRight: Radius.circular(unselectedBorderRadius),
      );
    }
    if (isLast) {
      return BorderRadius.only(
        topRight: Radius.circular(selectedBorderRadius),
        bottomRight: Radius.circular(selectedBorderRadius),
        topLeft: Radius.circular(unselectedBorderRadius),
        bottomLeft: Radius.circular(unselectedBorderRadius),
      );
    }
    return BorderRadius.circular(unselectedBorderRadius);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final backgroundColor = isSelected
        ? colorScheme.primary
        : colorScheme.secondary;

    final foregroundColor = isSelected
        ? colorScheme.onPrimary
        : colorScheme.onSecondary;

    final borderRadius = _getBorderRadius();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizing.borderRadius100),
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(segment.icon, size: 18, color: foregroundColor),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  segment.label,
                  style: AppTextStyles.segmentedButtonLabel(
                    context,
                  ).copyWith(color: foregroundColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
