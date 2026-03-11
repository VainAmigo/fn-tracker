import 'package:flutter/material.dart';
import 'package:fn_tracker/theme/themes.dart';

/// Универсальный текстовый таб-бар с горизонтальной прокруткой.
///
/// - Простой текст без фона и индикаторов
/// - Активная вкладка: белый, полужирный
/// - Неактивные: светло-серый, обычный шрифт
/// - Горизонтальный скролл при большом количестве элементов
/// - Отступ слева для первого элемента
class CustomTabWidget<T> extends StatelessWidget {
  const CustomTabWidget({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    this.labelBuilder,
    this.leftPadding,
    this.itemSpacing,
  });

  /// Список элементов для отображения
  final List<T> items;

  /// Выбранное значение
  final T selectedValue;

  /// Колбек при смене вкладки
  final ValueChanged<T> onChanged;

  /// Опциональный билдер для отображения текста.
  /// По умолчанию вызывается [toString] для элемента.
  final String Function(T)? labelBuilder;

  /// Отступ слева. По умолчанию [AppSizing.defaultPadding]
  final double? leftPadding;

  /// Расстояние между элементами. По умолчанию [AppSizing.spaceBtwItems]
  final double? itemSpacing;

  String _labelFor(T value) => labelBuilder?.call(value) ?? value.toString();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final left = leftPadding ?? AppSizing.defaultPadding;
    final spacing = itemSpacing ?? AppSizing.spaceBtwElements;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Padding(
        padding: EdgeInsets.only(left: left),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) SizedBox(width: spacing),
              _TabItem<T>(
                value: items[i],
                label: _labelFor(items[i]),
                isSelected: items[i] == selectedValue,
                onTap: () => onChanged(items[i]),
                colorScheme: colorScheme,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TabItem<T> extends StatelessWidget {
  const _TabItem({
    required this.value,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.colorScheme,
  });

  final T value;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final textColor = isSelected
        ? colorScheme.onSurface
        : colorScheme.onSecondary;
    final fontWeight = isSelected ? FontWeight.w700 : FontWeight.w400;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          label,
          style: AppTextStyles.text16w400(
            context,
          ).copyWith(color: textColor, fontWeight: fontWeight),
        ),
      ),
    );
  }
}
