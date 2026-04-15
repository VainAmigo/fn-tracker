import 'package:flutter/material.dart';
import 'package:fn_tracker/components/segmented/custom_tab_widget.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';

/// Режим пикера: год / месяц / неделя.
enum PickerMode { yearly, monthly, weekly }

/// Диапазон лет для прокрутки (включительно).
const int _startYear = 2000;

int _monthIndexFromDate(int year, int month) {
  return (year - _startYear) * 12 + (month - 1);
}

(int year, int month) _dateFromMonthIndex(int index) {
  final year = _startYear + index ~/ 12;
  final month = (index % 12) + 1;
  return (year, month);
}

DateTime _startOfWeek(DateTime d) {
  return DateTime(d.year, d.month, d.day - (d.weekday - 1));
}

/// Универсальный виджет горизонтальной прокрутки по периодам: год, месяц или неделя.
/// Табы для переключения режима; под активным периодом — [child] с поддержкой свайпа.
class MonthPickerScrollWidget extends StatefulWidget {
  const MonthPickerScrollWidget({
    required this.onPeriodChange,
    super.key,
    this.initialYear,
    this.initialMonth,
    this.initialMode = PickerMode.monthly,
    this.child,
    this.showModeTabs = true,
  });

  /// Вызывается при смене выбранного периода (год / месяц / неделя).
  final void Function(DatePickerPeriod period) onPeriodChange;

  /// Начальный год. По умолчанию — текущий.
  final int? initialYear;

  /// Начальный месяц (1–12). По умолчанию — текущий.
  final int? initialMonth;

  /// Начальный режим. По умолчанию — [PickerMode.monthly].
  final PickerMode initialMode;

  /// Контент под пикером. Поддерживает свайп влево/вправо для смены периода.
  final Widget? child;

  /// Показывать табы Yearly/Monthly/Weekly. По умолчанию — true.
  /// Если false — только скролл по месяцам (без переключения режимов).
  final bool showModeTabs;

  @override
  State<MonthPickerScrollWidget> createState() =>
      _MonthPickerScrollWidgetState();
}

const double _pixelsPerMonth = 60;

class _MonthPickerScrollWidgetState extends State<MonthPickerScrollWidget> {
  late PageController _pageController;
  late PickerMode _mode;

  int _yearIndex = 0;
  int _monthIndex = 0;
  int _weekIndex = 0;

  int _yearCount = 0;
  int _monthCount = 0;
  int _weekCount = 0;

  late DateTime _weeklyBaseStart;

  double _dragAccumulator = 0;

  static int get _nowYear => DateTime.now().year;

  int get _currentYear => _startYear + _yearIndex;
  (int year, int month) get _currentMonthPair =>
      _dateFromMonthIndex(_monthIndex);
  (DateTime start, DateTime end) get _currentWeekRange {
    final start = _weeklyBaseStart.add(Duration(days: _weekIndex * 7));
    final end = start.add(const Duration(days: 6));
    return (start, end);
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _mode = widget.showModeTabs ? widget.initialMode : PickerMode.monthly;

    // Yearly: от _startYear до now + 2 года
    _yearCount = _nowYear + 2 - _startYear + 1;
    final year = (widget.initialYear ?? now.year).clamp(
      _startYear,
      _nowYear + 2,
    );
    _yearIndex = year - _startYear;

    // Monthly: от _startYear до конец (now + 1 год), назад без ограничений
    final maxMonthIndex = _monthIndexFromDate(_nowYear + 1, 12);
    _monthCount = maxMonthIndex + 1;
    final yearM = widget.initialYear ?? now.year;
    final monthM = (widget.initialMonth ?? now.month).clamp(1, 12);
    _monthIndex = _monthIndexFromDate(yearM, monthM).clamp(0, maxMonthIndex);

    // Weekly: 6 месяцев назад — 4 недели вперёд
    _weeklyBaseStart = _startOfWeek(DateTime(now.year, now.month - 6, now.day));
    final endWeekStart = _startOfWeek(now.add(const Duration(days: 28)));
    _weekCount =
        (endWeekStart.difference(_weeklyBaseStart).inDays / 7).floor() + 1;
    final todayStart = _startOfWeek(now);
    _weekIndex = (todayStart.difference(_weeklyBaseStart).inDays / 7)
        .floor()
        .clamp(0, _weekCount - 1);

    _pageController = _createPageController();
    _notifyPeriodChange();
  }

  PageController _createPageController() {
    final index = switch (_mode) {
      PickerMode.yearly => _yearIndex,
      PickerMode.monthly => _monthIndex,
      PickerMode.weekly => _weekIndex,
    };
    return PageController(initialPage: index, viewportFraction: 1 / 3);
  }

  int get _currentPageIndex => switch (_mode) {
    PickerMode.yearly => _yearIndex,
    PickerMode.monthly => _monthIndex,
    PickerMode.weekly => _weekIndex,
  };

  int get _totalPages => switch (_mode) {
    PickerMode.yearly => _yearCount,
    PickerMode.monthly => _monthCount,
    PickerMode.weekly => _weekCount,
  };

  bool get _canGoNext => _currentPageIndex < _totalPages - 1;
  bool get _canGoPrev => _currentPageIndex > 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DatePickerPeriod get _currentPeriod => switch (_mode) {
    PickerMode.yearly => YearlyPeriod(_currentYear),
    PickerMode.monthly => MonthlyPeriod(
      year: _currentMonthPair.$1,
      month: Month.fromValue(_currentMonthPair.$2),
    ),
    PickerMode.weekly => WeeklyPeriod(
      start: _currentWeekRange.$1,
      end: _currentWeekRange.$2,
    ),
  };

  void _notifyPeriodChange() {
    widget.onPeriodChange(_currentPeriod);
  }

  void _onPageChanged(int index) {
    final prev = _currentPageIndex;
    if (index == prev) return;
    setState(() {
      switch (_mode) {
        case PickerMode.yearly:
          _yearIndex = index;
          break;
        case PickerMode.monthly:
          _monthIndex = index;
          break;
        case PickerMode.weekly:
          _weekIndex = index;
          break;
      }
    });
    _notifyPeriodChange();
  }

  void _goToNext() {
    if (!_canGoNext) return;
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goToPrev() {
    if (!_canGoPrev) return;
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _animateToNext() {
    if (!_canGoNext) return;
    _pageController.nextPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void _animateToPrev() {
    if (!_canGoPrev) return;
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
      _animateToNext();
    }
    while (_dragAccumulator >= _pixelsPerMonth) {
      _dragAccumulator -= _pixelsPerMonth;
      _animateToPrev();
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    const velocityThreshold = 50.0;
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < -velocityThreshold) {
      _goToNext();
    } else if (velocity > velocityThreshold) {
      _goToPrev();
    }
  }

  void _onModeChanged(PickerMode mode) {
    if (mode == _mode) return;

    _pageController.dispose();

    setState(() {
      final now = DateTime.now();

      switch (mode) {
        case PickerMode.yearly:
          final year = (widget.initialYear ?? now.year).clamp(
            _startYear,
            _nowYear + 2,
          );
          _yearIndex = year - _startYear;
          break;
        case PickerMode.monthly:
          final maxMonthIndex = _monthCount - 1;
          // При переключении на месяцы всегда ставим текущий месяц, чтобы избежать сдвигов.
          _monthIndex = _monthIndexFromDate(
            now.year,
            now.month,
          ).clamp(0, maxMonthIndex);
          break;
        case PickerMode.weekly:
          final todayStart = _startOfWeek(now);
          _weekIndex = (todayStart.difference(_weeklyBaseStart).inDays / 7)
              .floor()
              .clamp(0, _weekCount - 1);
          break;
      }

      _mode = mode;
      _pageController = _createPageController();
    });

    // Гарантируем, что нужный элемент окажется по центру (два кадра — PageView успевает принять контроллер).
    void scheduleJump() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final index = _currentPageIndex.clamp(0, _totalPages - 1);
          if (_pageController.hasClients) {
            _pageController.jumpToPage(index);
          }
        });
      });
    }

    scheduleJump();

    _notifyPeriodChange();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: widget.showModeTabs
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.start,
          children: [
            if (widget.showModeTabs)
              Expanded(
                child: CustomTabWidget<PickerMode>(
                  items: const [
                    PickerMode.yearly,
                    PickerMode.monthly,
                    PickerMode.weekly,
                  ],
                  selectedValue: _mode,
                  onChanged: _onModeChanged,
                  labelBuilder: (mode) => switch (mode) {
                    PickerMode.yearly => context.l10n.yearly,
                    PickerMode.monthly => context.l10n.monthly,
                    PickerMode.weekly => context.l10n.weekly,
                  },
                  leftPadding: 0,
                ),
              ),
            if (widget.showModeTabs)
              const SizedBox(width: AppSizing.spaceBtwItems),
            Text(
              _headerLabel(context),
              style: AppTextStyles.text16w400(
                context,
              ).copyWith(color: colorScheme.onSecondary),
            ),
          ],
        ),
        SizedBox(
          height: AppSizing.heightS,
          child: PageView.builder(
            key: ValueKey<PickerMode>(_mode),
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _totalPages,
            itemBuilder: (context, index) {
              final isCenter = index == _currentPageIndex;
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
                    fontSize: isCenter ? 16 : 14,
                    fontWeight: isCenter ? FontWeight.w600 : FontWeight.w400,
                    color: isCenter
                        ? colorScheme.onSurface
                        : colorScheme.onSecondary,
                  ),
                  child: Center(child: Text(_itemLabel(context, index))),
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
            child: widget.child!,
          ),
      ],
    );
  }

  String _headerLabel(BuildContext context) {
    if (!widget.showModeTabs && _mode == PickerMode.monthly) {
      return '${Month.fromValue(_currentMonthPair.$2).localizedName(context)} ${_currentMonthPair.$1}';
    }
    return switch (_mode) {
      PickerMode.yearly => '$_currentYear',
      PickerMode.monthly => '${_currentMonthPair.$1}',
      PickerMode.weekly => '${_currentMonthPair.$1}',
    };
  }

  String _itemLabel(BuildContext context, int index) {
    return switch (_mode) {
      PickerMode.yearly => '${_startYear + index}',
      PickerMode.monthly => Month.fromValue(
        _dateFromMonthIndex(index).$2,
      ).localizedName(context),
      PickerMode.weekly => _weekRangeShortLabel(
        context,
        _weeklyBaseStart.add(Duration(days: index * 7)),
        _weeklyBaseStart.add(Duration(days: index * 7 + 6)),
      ),
    };
  }

  String _weekRangeShortLabel(
    BuildContext context,
    DateTime start,
    DateTime end,
  ) {
    return '${start.formatDayMonthShort(context)} - ${end.formatDayMonthShort(context)}';
  }
}
