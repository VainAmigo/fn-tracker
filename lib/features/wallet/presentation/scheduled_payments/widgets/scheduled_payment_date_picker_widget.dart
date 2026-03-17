import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/wallet/data/models/scheduled_payment_model.dart';
import 'package:fn_tracker/theme/themes.dart';

/// Виджет выбора даты/дня в зависимости от частоты платежа.
/// Для [ScheduledPaymentFrequency.monthly] и [yearly] поддерживается
/// мультивыбор (несколько чисел месяца / дат в году).
class ScheduledPaymentDatePickerWidget extends StatefulWidget {
  const ScheduledPaymentDatePickerWidget({
    required this.frequency,
    required this.initialDate,
    required this.onDateSelected,
    this.initialDates,
    this.onDatesSelected,
    super.key,
  });

  final ScheduledPaymentFrequency frequency;
  final DateTime? initialDate;
  final ValueChanged<DateTime> onDateSelected;

  /// Начальный список выбранных дат (для мультивыбора monthly/yearly).
  final List<DateTime>? initialDates;

  /// Колбэк при мультивыборе (monthly — числа месяца, yearly — список дат в году).
  final ValueChanged<List<DateTime>>? onDatesSelected;

  static Future<void> show(
    BuildContext context, {
    required ScheduledPaymentFrequency frequency,
    required DateTime? initialDate,
    required ValueChanged<DateTime> onDateSelected,
    List<DateTime>? initialDates,
    ValueChanged<List<DateTime>>? onDatesSelected,
  }) {
    return AppBottomSheet.showFittedModalBottomSheet(
      context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: ScheduledPaymentDatePickerWidget(
        frequency: frequency,
        initialDate: initialDate,
        onDateSelected: onDateSelected,
        initialDates: initialDates,
        onDatesSelected: onDatesSelected,
      ),
    );
  }

  @override
  State<ScheduledPaymentDatePickerWidget> createState() =>
      _ScheduledPaymentDatePickerWidgetState();
}

class _ScheduledPaymentDatePickerWidgetState
    extends State<ScheduledPaymentDatePickerWidget> {
  late Set<int> _selectedMonthDays;

  /// Выбранные даты для yearly (месяц+день, год — опорный для сортировки).
  List<DateTime> _selectedYearlyDates = [];

  /// PageController для monthly: скролл по числам 1–28 и «конец месяца».
  PageController? _monthlyDayPageController;

  /// Специальное значение для «конец месяца» (день 31 в DateTime).
  static const int _endOfMonthDay = 31;

  static bool _isLastDayOfMonth(DateTime d) =>
      d.day == DateTime(d.year, d.month + 1, 0).day;

  bool get _isMultiSelect =>
      widget.onDatesSelected != null &&
      (widget.frequency == ScheduledPaymentFrequency.monthly ||
          widget.frequency == ScheduledPaymentFrequency.yearly);

  @override
  void initState() {
    super.initState();
    if (widget.frequency == ScheduledPaymentFrequency.monthly) {
      _selectedMonthDays =
          widget.initialDates
              ?.map((d) => _isLastDayOfMonth(d) ? _endOfMonthDay : d.day)
              .toSet() ??
          (widget.initialDate != null
              ? {
                  _isLastDayOfMonth(widget.initialDate!)
                      ? _endOfMonthDay
                      : widget.initialDate!.day,
                }
              : <int>{});
    } else {
      _selectedMonthDays = <int>{};
    }
    if (widget.frequency == ScheduledPaymentFrequency.yearly &&
        widget.onDatesSelected != null) {
      final year = DateTime.now().year;
      _selectedYearlyDates =
          widget.initialDates
              ?.map((d) => DateTime(year, d.month, d.day.clamp(1, 28)))
              .toSet()
              .toList() ??
          (widget.initialDate != null
              ? [
                  DateTime(
                    year,
                    widget.initialDate!.month,
                    widget.initialDate!.day.clamp(1, 28),
                  ),
                ]
              : <DateTime>[]);
      _selectedYearlyDates.sort((a, b) {
        final c = a.month.compareTo(b.month);
        return c != 0 ? c : a.day.compareTo(b.day);
      });
    }
    if (widget.frequency == ScheduledPaymentFrequency.monthly) {
      final initialDay = _selectedMonthDays.isNotEmpty
          ? _selectedMonthDays.first
          : (widget.initialDate?.day.clamp(1, 28) ?? 1);
      final initialPage = initialDay == _endOfMonthDay ? 28 : (initialDay - 1);
      _monthlyDayPageController = PageController(
        initialPage: initialPage.clamp(0, 28),
        viewportFraction: 1 / 3,
      );
    }
    if (widget.frequency == ScheduledPaymentFrequency.oneTime) {
      _daySelectedDate = widget.initialDate != null
          ? DateUtils.dateOnly(widget.initialDate!)
          : DateUtils.dateOnly(DateTime.now());
    }
  }

  /// Выбранная дата для day (одноразовый платёж).
  DateTime? _daySelectedDate;

  @override
  void dispose() {
    _monthlyDayPageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: AppSizing.bottomPadding,
        left: AppSizing.defaultPadding,
        right: AppSizing.defaultPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ModalSheetTitleWidget(
            title: _sheetTitle(context),
            subtitle: _sheetSubtitle(context),
          ),
          const SizedBox(height: AppSizing.spaceBtwSections),
          switch (widget.frequency) {
            ScheduledPaymentFrequency.oneTime => _buildDayPicker(context),
            ScheduledPaymentFrequency.monthly => _buildMonthlyPicker(context),
            ScheduledPaymentFrequency.yearly => _buildYearlyPicker(context),
          },
          if (_isMultiSelect ||
              widget.frequency == ScheduledPaymentFrequency.oneTime) ...[
            const SizedBox(height: AppSizing.spaceBtwSections),
            PrimaryButton(
              text: 'Done',
              onPressed: widget.frequency == ScheduledPaymentFrequency.oneTime
                  ? _onDaySave
                  : _onMultiSelectDone,
              size: PrimaryButtonSize.medium,
              rounded: true,
            ),
          ],
        ],
      ),
    );
  }

  String _sheetTitle(BuildContext context) {
    return switch (widget.frequency) {
      ScheduledPaymentFrequency.oneTime => 'Единожды',
      ScheduledPaymentFrequency.monthly =>
        _isMultiSelect ? 'Days of month' : 'Day of month',
      ScheduledPaymentFrequency.yearly =>
        _isMultiSelect ? 'Payment dates in year' : 'Date (month & day)',
    };
  }

  String _sheetSubtitle(BuildContext context) {
    return switch (widget.frequency) {
      ScheduledPaymentFrequency.oneTime => 'Выберите дату для одноразового платежа',
      ScheduledPaymentFrequency.monthly =>
        _isMultiSelect
            ? 'Payment will be made on selected days of month every month'
            : 'Payment will be made on selected day of month every month',
      ScheduledPaymentFrequency.yearly =>
        _isMultiSelect
            ? 'Payment will be made on selected dates every year'
            : 'Payment will be made on selected date (month & day) every year',
    };
  }

  void _onDaySave() {
    if (_daySelectedDate != null) {
      widget.onDateSelected(_daySelectedDate!);
      Navigator.of(context).pop();
    }
  }

  void _onMultiSelectDone() {
    final list = switch (widget.frequency) {
      ScheduledPaymentFrequency.monthly =>
        _selectedMonthDays.map(_nextDayOfMonth).toList()
          ..sort((a, b) => a.compareTo(b)),
      ScheduledPaymentFrequency.yearly =>
        _selectedYearlyDates
            .map((d) => _nextYearlyDate(d.month, d.day))
            .toList()
          ..sort((a, b) => a.compareTo(b)),
      _ => <DateTime>[],
    };
    widget.onDatesSelected!(list);
    Navigator.of(context).pop();
  }

  /// Модалка выбора даты для day (одноразовый платёж) + кнопка сохранения.
  Widget _buildDayPicker(BuildContext context) {
    final ref = _daySelectedDate ?? widget.initialDate ?? DateTime.now();
    final dateOnly = DateUtils.dateOnly(ref);
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        PrimaryButton(
          text: dateOnly.formatDotDate,
          onPressed: () async {
            final now = DateUtils.dateOnly(DateTime.now());
            final picked = await showDatePicker(
              context: context,
              initialDate: dateOnly,
              firstDate: now,
              lastDate: DateTime(now.year + 2, 12, 31),
            );
            if (!context.mounted) return;
            if (picked != null) {
              setState(() => _daySelectedDate = DateUtils.dateOnly(picked));
            }
          },
          size: PrimaryButtonSize.large,
          icon: Icons.calendar_month,
          backgroundColor: colorScheme.secondary,
          foregroundColor: colorScheme.onSurface,
        ),
      ],
    );
  }

  /// Текущий выбранный день месяца из скролла (1–28 или 31 для конца месяца).
  int get _monthlyScrollDay {
    if (_monthlyDayPageController == null ||
        !_monthlyDayPageController!.hasClients) {
      return _selectedMonthDays.isNotEmpty
          ? _selectedMonthDays.first
          : (widget.initialDate?.day.clamp(1, 28) ?? 1);
    }
    final page = _monthlyDayPageController!.page?.round() ?? 0;
    return page < 28 ? page + 1 : _endOfMonthDay;
  }

  static String _monthDayLabel(int day) {
    if (day == _endOfMonthDay) return 'End of month';
    return switch (day) {
      1 => '1st',
      2 => '2nd',
      3 => '3rd',
      _ => '${day}th',
    };
  }

  /// Горизонтальный скролл выбора дня месяца (1–28, конец месяца).
  Widget _buildMonthlyPicker(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const itemCount = 29; // 1–28 + end of month

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Day of each month',
          style: AppTextStyles.text14w400(
            context,
          ).copyWith(color: colorScheme.onSurfaceVariant),
        ),
        Text(
          _selectedMonthDays.isNotEmpty
              ? 'Selected days: ${_selectedMonthDays.map(_monthDayLabel).join(', ')}'
              : 'Press to select days',
          style: AppTextStyles.text14w400(context),
        ),
        const SizedBox(height: AppSizing.spaceBtwItems),
        SizedBox(
          height: AppSizing.heightS,
          child: PageView.builder(
            controller: _monthlyDayPageController,
            onPageChanged: (_) => setState(() {}),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              final day = index < 28 ? index + 1 : _endOfMonthDay;
              final isCenter = day == _monthlyScrollDay;
              final isSelected = _isMultiSelect
                  ? _selectedMonthDays.contains(day)
                  : isCenter;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (_isMultiSelect) {
                    setState(() {
                      if (_selectedMonthDays.contains(day)) {
                        _selectedMonthDays.remove(day);
                      } else {
                        _selectedMonthDays.add(day);
                      }
                    });
                  } else if (isCenter) {
                    widget.onDateSelected(_nextDayOfMonth(day));
                    Navigator.of(context).pop();
                  } else {
                    _monthlyDayPageController?.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 150),
                  style: TextStyle(
                    fontSize: isCenter ? 18 : 16,
                    fontWeight: (isCenter || isSelected)
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: isSelected
                        ? colorScheme.primary
                        : (isCenter
                              ? colorScheme.onSurface
                              : colorScheme.onSecondary),
                  ),
                  child: Center(child: Text(_monthDayLabel(day))),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildYearlyPicker(BuildContext context) {
    if (_isMultiSelect) {
      return _buildYearlyDatesList(context);
    }
    final ref = widget.initialDate ?? DateTime.now();
    return PrimaryButton(
      text: 'Choose month and day',
      onPressed: () async {
        final now = DateTime.now();
        final initial = DateTime(now.year, ref.month, ref.day.clamp(1, 28));
        final picked = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: DateTime(now.year, 1, 1),
          lastDate: DateTime(now.year, 12, 31),
        );
        if (!context.mounted) return;
        if (picked != null) {
          widget.onDateSelected(picked);
          Navigator.of(context).pop();
        }
      },
      size: PrimaryButtonSize.large,
      icon: Icons.calendar_month,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
    );
  }

  /// Список выбранных дат в году: [FormCardWidget] с отступами и логикой радиусов [CardRadius].
  Widget _buildYearlyDatesList(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final year = DateTime.now().year;
    const maxListHeight = 280.0;
    final total = _selectedYearlyDates.length + 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Repeat on selected dates every year',
          style: AppTextStyles.text14w400(
            context,
          ).copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSizing.spaceBtwItems),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: maxListHeight),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: total,
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppSizing.spaceBtwItemsExtra),
            itemBuilder: (context, index) {
              final borderRadius = borderRadiusFor(
                radiusForIndex(index, total),
              );
              if (index == _selectedYearlyDates.length) {
                return FormCardWidget(
                  title: 'Add date',
                  icon: Icon(
                    Icons.add,
                    size: AppSizing.iconSizeM,
                    color: colorScheme.onSurface,
                  ),
                  backgroundColor: colorScheme.secondary,
                  foregroundColor: colorScheme.onSurface,
                  borderRadius: borderRadius,
                  onTap: () => _addYearlyDate(context, year),
                );
              }
              final d = _selectedYearlyDates[index];
              return FormCardWidget(
                title: d.formatMonthDay,
                backgroundColor: colorScheme.secondary,
                foregroundColor: colorScheme.onSurface,
                borderRadius: borderRadius,
                trailing: IconButton(
                  icon: Icon(
                    Icons.close,
                    size: AppSizing.iconSizeM,
                    color: colorScheme.error,
                  ),
                  onPressed: () {
                    setState(() => _selectedYearlyDates.removeAt(index));
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _addYearlyDate(BuildContext context, int year) async {
    final now = DateTime.now();
    final initial = _selectedYearlyDates.isNotEmpty
        ? _selectedYearlyDates.last
        : DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year, 1, 1),
      lastDate: DateTime(now.year, 12, 31),
    );
    if (!context.mounted) return;
    if (picked != null) {
      final normalized = DateTime(year, picked.month, picked.day.clamp(1, 28));
      final isDuplicate = _selectedYearlyDates.any(
        (d) => d.month == normalized.month && d.day == normalized.day,
      );
      if (!isDuplicate) {
        setState(() {
          _selectedYearlyDates.add(normalized);
          _selectedYearlyDates.sort((a, b) {
            final c = a.month.compareTo(b.month);
            return c != 0 ? c : a.day.compareTo(b.day);
          });
        });
      }
    }
  }

  static DateTime _nextDayOfMonth(int day) {
    final now = DateTime.now();
    if (day == _endOfMonthDay) {
      // Последний день месяца: DateTime(year, month+1, 0)
      var d = DateTime(now.year, now.month + 1, 0);
      if (d.isBefore(now)) {
        d = DateTime(now.year, now.month + 2, 0);
      }
      return DateUtils.dateOnly(d);
    }
    var d = DateTime(now.year, now.month, day.clamp(1, 28));
    if (d.isBefore(now)) {
      d = DateTime(now.year, now.month + 1, day.clamp(1, 28));
    }
    return DateUtils.dateOnly(d);
  }

  static DateTime _nextYearlyDate(int month, int day) {
    final now = DateUtils.dateOnly(DateTime.now());
    var d = DateTime(now.year, month, day.clamp(1, 28));
    if (d.isBefore(now)) {
      d = DateTime(now.year + 1, month, day.clamp(1, 28));
    }
    return DateUtils.dateOnly(d);
  }
}
