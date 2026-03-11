import 'package:flutter/material.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/theme/themes.dart';

/// Диапазон лет для прокрутки (включительно).
const int _startYear = 2000;
const int _endYear = 2100;

int _monthIndexFromDate(int year, int month) {
  return (year - _startYear) * 12 + (month - 1);
}

(int year, int month) _dateFromMonthIndex(int index) {
  final year = _startYear + index ~/ 12;
  final month = (index % 12) + 1;
  return (year, month);
}

/// Универсальный виджет горизонтальной прокрутки по месяцам: по центру активный
/// месяц, по бокам — соседние. Год отображается над активным месяцем и меняется
/// при переходе на другой год. Подходит для бюджета, отчётов и любых экранов
/// с выбором месяца.
///
/// Поддерживает свайп по контенту [child] для смены месяца.
class MonthPickerScrollWidget extends StatefulWidget {
  const MonthPickerScrollWidget({
    required this.onDateChange,
    super.key,
    this.initialYear,
    this.initialMonth,
    this.child,
  });

  /// Вызывается при смене выбранного месяца (после завершения скролла).
  final void Function(Month month, int year) onDateChange;

  /// Начальный год. По умолчанию — текущий.
  final int? initialYear;

  /// Начальный месяц (1–12). По умолчанию — текущий.
  final int? initialMonth;

  /// Контент под пикером. Поддерживает свайп влево/вправо для смены месяца.
  final Widget? child;

  @override
  State<MonthPickerScrollWidget> createState() => _MonthPickerScrollWidgetState();
}

/// Пикселей свайпа на один месяц (меньше = чувствительнее).
const double _pixelsPerMonth = 60;

class _MonthPickerScrollWidgetState extends State<MonthPickerScrollWidget> {
  late PageController _pageController;
  late int _currentIndex;
  int _totalPages = 0;
  double _dragAccumulator = 0;

  int get _currentYear => _dateFromMonthIndex(_currentIndex).$1;
  int get _currentMonth => _dateFromMonthIndex(_currentIndex).$2;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final year = widget.initialYear ?? now.year;
    final month = widget.initialMonth ?? now.month;
    _totalPages = _monthIndexFromDate(_endYear, 12) + 1;
    _currentIndex = _monthIndexFromDate(year, month).clamp(0, _totalPages - 1);
    _pageController = PageController(
      initialPage: _currentIndex,
      viewportFraction: 1 / 3,
    );
    _notifyDateChange();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _notifyDateChange() {
    final month = Month.fromValue(_currentMonth);
    widget.onDateChange(month, _currentYear);
  }

  void _onPageChanged(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    _notifyDateChange();
  }

  void _goToNextMonth() {
    if (_currentIndex >= _totalPages - 1) return;
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goToPrevMonth() {
    if (_currentIndex <= 0) return;
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _animateToNextMonth() {
    if (_currentIndex >= _totalPages - 1) return;
    _pageController.nextPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void _animateToPrevMonth() {
    if (_currentIndex <= 0) return;
    _pageController.previousPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void _onHorizontalDragStart(DragStartDetails _) {
    _dragAccumulator = 0;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    _dragAccumulator += details.delta.dx;

    while (_dragAccumulator <= -_pixelsPerMonth) {
      _dragAccumulator += _pixelsPerMonth;
      _animateToNextMonth();
    }
    while (_dragAccumulator >= _pixelsPerMonth) {
      _dragAccumulator -= _pixelsPerMonth;
      _animateToPrevMonth();
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    const velocityThreshold = 50.0;
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < -velocityThreshold) {
      _goToNextMonth();
    } else if (velocity > velocityThreshold) {
      _goToPrevMonth();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Text(
            '$_currentYear',
            style: AppTextStyles.segmentedButtonLabel(context),
          ),
        ),
        SizedBox(
          height: AppSizing.heightS,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _totalPages,
            itemBuilder: (context, index) {
              final (_, month) = _dateFromMonthIndex(index);
              final isCenter = index == _currentIndex;
              final monthEnum = Month.fromValue(month);

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: isCenter
                    ? null
                    : () => _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 150),
                  style: TextStyle(
                    fontSize: isCenter ? 18 : 16,
                    fontWeight: isCenter ? FontWeight.w600 : FontWeight.w400,
                    color: isCenter
                        ? colorScheme.onSurface
                        : colorScheme.onSecondary,
                  ),
                  child: Center(
                    child: Text(monthEnum.localizedName(context)),
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.child != null)
          GestureDetector(
            onHorizontalDragStart: _onHorizontalDragStart,
            onHorizontalDragUpdate: _onHorizontalDragUpdate,
            onHorizontalDragEnd: _onHorizontalDragEnd,
            behavior: HitTestBehavior.translucent,
            child: widget.child,
          ),
      ],
    );
  }
}
