import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/wallet/data/models/scheduled_payment_model.dart';
import 'package:fn_tracker/theme/themes.dart';

/// Виджет выбора даты/дня в зависимости от частоты платежа.
/// Для [ScheduledPaymentFrequency.weekly] и [monthly] поддерживается
/// мультивыбор (несколько дней недели / чисел месяца).
/// Для [ScheduledPaymentFrequency.daily] — выбор интервала «каждые X дней» и даты начала.
class ScheduledPaymentDatePickerWidget extends StatefulWidget {
  const ScheduledPaymentDatePickerWidget({
    required this.frequency,
    required this.initialDate,
    required this.onDateSelected,
    this.initialDates,
    this.onDatesSelected,
    this.initialDailyInterval,
    this.onDailyScheduleSelected,
    super.key,
  });

  final ScheduledPaymentFrequency frequency;
  final DateTime? initialDate;
  final ValueChanged<DateTime> onDateSelected;

  /// Начальный список выбранных дат (для мультивыбора weekly/monthly/yearly).
  final List<DateTime>? initialDates;

  /// Колбэк при мультивыборе (weekly — дни недели, monthly — числа месяца, yearly — список дат в году).
  final ValueChanged<List<DateTime>>? onDatesSelected;

  /// Начальный интервал для daily (каждые X дней). Используется с [onDailyScheduleSelected].
  final int? initialDailyInterval;

  /// Колбэк для daily: интервал в днях и дата начала платежей.
  final void Function(int intervalDays, DateTime startDate)?
  onDailyScheduleSelected;

  static Future<void> show(
    BuildContext context, {
    required ScheduledPaymentFrequency frequency,
    required DateTime? initialDate,
    required ValueChanged<DateTime> onDateSelected,
    List<DateTime>? initialDates,
    ValueChanged<List<DateTime>>? onDatesSelected,
    int? initialDailyInterval,
    void Function(int intervalDays, DateTime startDate)?
    onDailyScheduleSelected,
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
        initialDailyInterval: initialDailyInterval,
        onDailyScheduleSelected: onDailyScheduleSelected,
      ),
    );
  }

  @override
  State<ScheduledPaymentDatePickerWidget> createState() =>
      _ScheduledPaymentDatePickerWidgetState();
}

class _ScheduledPaymentDatePickerWidgetState
    extends State<ScheduledPaymentDatePickerWidget> {
  late Set<Weekday> _selectedWeekdays;
  late Set<int> _selectedMonthDays;

  /// Выбранные даты для yearly (месяц+день, год — опорный для сортировки).
  List<DateTime> _selectedYearlyDates = [];

  /// Интервал для daily: каждые N дней.
  int _dailyInterval = 1;

  /// Выбранная дата начала для daily (null = не выбрана, использовать initial).
  DateTime? _dailyStartDate;

  late PageController _dailyIntervalPageController;

  bool get _isMultiSelect =>
      widget.onDatesSelected != null &&
      (widget.frequency == ScheduledPaymentFrequency.weekly ||
          widget.frequency == ScheduledPaymentFrequency.monthly ||
          widget.frequency == ScheduledPaymentFrequency.yearly);

  @override
  void initState() {
    super.initState();
    if (widget.frequency == ScheduledPaymentFrequency.weekly) {
      _selectedWeekdays =
          widget.initialDates?.map((d) => Weekday.fromDateTime(d)).toSet() ??
          (widget.initialDate != null
              ? {Weekday.fromDateTime(widget.initialDate!)}
              : <Weekday>{});
    } else {
      _selectedWeekdays = <Weekday>{};
    }
    if (widget.frequency == ScheduledPaymentFrequency.monthly) {
      _selectedMonthDays =
          widget.initialDates?.map((d) => d.day.clamp(1, 28)).toSet() ??
          (widget.initialDate != null
              ? {widget.initialDate!.day.clamp(1, 28)}
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
    if (widget.frequency == ScheduledPaymentFrequency.daily &&
        widget.onDailyScheduleSelected != null) {
      _dailyInterval = (widget.initialDailyInterval ?? 1).clamp(
        1,
        _dailyIntervalMax,
      );
      _dailyStartDate = widget.initialDate != null
          ? DateUtils.dateOnly(widget.initialDate!)
          : null;
      _dailyIntervalPageController = PageController(
        initialPage: _dailyInterval - 1,
        viewportFraction: 1 / 3,
      );
    }
    if (widget.frequency == ScheduledPaymentFrequency.once) {
      _onceSelectedDate = widget.initialDate != null
          ? DateUtils.dateOnly(widget.initialDate!)
          : DateUtils.dateOnly(DateTime.now());
    }
  }

  bool get _isDailyWithSchedule =>
      widget.frequency == ScheduledPaymentFrequency.daily &&
      widget.onDailyScheduleSelected != null;

  /// Выбранная дата для once (одноразовый платёж).
  DateTime? _onceSelectedDate;

  @override
  void dispose() {
    if (widget.frequency == ScheduledPaymentFrequency.daily &&
        widget.onDailyScheduleSelected != null) {
      _dailyIntervalPageController.dispose();
    }
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
          ModalSheetTitleWidget(title: _sheetTitle(context)),
          const SizedBox(height: AppSizing.spaceBtwSections),
          switch (widget.frequency) {
            ScheduledPaymentFrequency.once => _buildOncePicker(context),
            ScheduledPaymentFrequency.daily => _buildDailyPicker(context),
            ScheduledPaymentFrequency.weekly => _buildWeeklyPicker(context),
            ScheduledPaymentFrequency.monthly => _buildMonthlyPicker(context),
            ScheduledPaymentFrequency.yearly => _buildYearlyPicker(context),
          },
          if (_isMultiSelect ||
              _isDailyWithSchedule ||
              widget.frequency == ScheduledPaymentFrequency.once) ...[
            const SizedBox(height: AppSizing.spaceBtwSections),
            PrimaryButton(
              text: 'Done',
              onPressed: widget.frequency == ScheduledPaymentFrequency.once
                  ? _onOnceSave
                  : (_isDailyWithSchedule ? _onDailyDone : _onMultiSelectDone),
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
      ScheduledPaymentFrequency.once => 'Once',
      ScheduledPaymentFrequency.daily =>
        widget.onDailyScheduleSelected != null ? 'Every X days' : 'Start date',
      ScheduledPaymentFrequency.weekly =>
        _isMultiSelect ? 'Days of week' : 'Day of week',
      ScheduledPaymentFrequency.monthly =>
        _isMultiSelect ? 'Days of month' : 'Day of month',
      ScheduledPaymentFrequency.yearly =>
        _isMultiSelect ? 'Payment dates in year' : 'Date (month & day)',
    };
  }

  void _onDailyDone() {
    final startDate = DateUtils.dateOnly(
      _dailyStartDate ?? widget.initialDate ?? DateTime.now(),
    );
    widget.onDailyScheduleSelected!(_dailyInterval, startDate);
    Navigator.of(context).pop();
  }

  void _onOnceSave() {
    if (_onceSelectedDate != null) {
      widget.onDateSelected(_onceSelectedDate!);
      Navigator.of(context).pop();
    }
  }

  void _onMultiSelectDone() {
    final list = switch (widget.frequency) {
      ScheduledPaymentFrequency.weekly =>
        _selectedWeekdays.map(_nextWeekday).toList()
          ..sort((a, b) => a.compareTo(b)),
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

  /// Модалка выбора даты для одноразового платежа + кнопка сохранения.
  Widget _buildOncePicker(BuildContext context) {
    final ref = _onceSelectedDate ?? widget.initialDate ?? DateTime.now();
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
              setState(() => _onceSelectedDate = DateUtils.dateOnly(picked));
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

  Widget _buildDailyPicker(BuildContext context) {
    if (widget.onDailyScheduleSelected != null) {
      return _buildDailyIntervalPicker(context);
    }
    final ref = widget.initialDate ?? DateTime.now();
    final dateOnly = DateUtils.dateOnly(ref);
    return PrimaryButton(
      text: 'Choose date',
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: dateOnly,
          firstDate: dateOnly,
          lastDate: DateTime(dateOnly.year + 2, 12, 31),
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

  static const int _dailyIntervalMax = 90;

  /// Горизонтальный скролл выбора «каждые X дней» и кнопка выбора даты начала.
  Widget _buildDailyIntervalPicker(BuildContext context) {
    final ref = widget.initialDate ?? DateTime.now();
    final dateOnly = DateUtils.dateOnly(ref);
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Repeat every',
          style: AppTextStyles.text14w400(
            context,
          ).copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSizing.spaceBtwItems),
        SizedBox(
          height: AppSizing.heightS,
          child: PageView.builder(
            controller: _dailyIntervalPageController,
            onPageChanged: (index) {
              setState(() => _dailyInterval = index + 1);
            },
            itemCount: _dailyIntervalMax,
            itemBuilder: (context, index) {
              final n = index + 1;
              final isCenter = index == _dailyInterval - 1;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: isCenter
                    ? null
                    : () => _dailyIntervalPageController.animateToPage(
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
                  child: Center(child: Text(n == 1 ? '1 day' : '$n days')),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSizing.spaceBtwSections),
        PrimaryButton(
          text: _dailyStartDateButtonLabel(dateOnly),
          onPressed: () async {
            final initial = _dailyStartDate ?? dateOnly;
            final picked = await showDatePicker(
              context: context,
              initialDate: initial,
              firstDate: dateOnly,
              lastDate: DateTime(dateOnly.year + 2, 12, 31),
            );
            if (!context.mounted) return;
            if (picked != null) {
              setState(() => _dailyStartDate = DateUtils.dateOnly(picked));
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

  String _dailyStartDateButtonLabel(DateTime defaultDate) {
    final d = DateUtils.dateOnly(
      _dailyStartDate ?? widget.initialDate ?? defaultDate,
    );
    return 'Start date: ${d.formatDotDate}';
  }

  Widget _buildWeeklyPicker(BuildContext context) {
    return SizedBox(
      height: AppSizing.heightL,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        separatorBuilder: (_, _) =>
            const SizedBox(width: AppSizing.spaceBtwItemsExtra),
        itemBuilder: (context, index) {
          final weekday = Weekday.values[index];
          final isSelected = _isMultiSelect
              ? _selectedWeekdays.contains(weekday)
              : widget.initialDate != null &&
                    Weekday.fromDateTime(widget.initialDate!) == weekday;
          return AspectRatio(
            aspectRatio: 1,
            child: SelectableCard(
              isSelected: isSelected,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              selectedBackgroundColor: Theme.of(context).colorScheme.primary,
              onTap: () {
                if (_isMultiSelect) {
                  setState(() {
                    if (_selectedWeekdays.contains(weekday)) {
                      _selectedWeekdays.remove(weekday);
                    } else {
                      _selectedWeekdays.add(weekday);
                    }
                  });
                } else {
                  widget.onDateSelected(_nextWeekday(weekday));
                  Navigator.of(context).pop();
                }
              },
              child: Center(
                child: Text(
                  weekday.localizedShortName(context),
                  style: AppTextStyles.text16w400(context).copyWith(
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Пресеты дней месяца: число и подпись.
  static const List<({int day, String label})> _monthDayPresets = [
    (day: 1, label: 'Every 1st day of the month'),
    (day: 5, label: 'Every 5th day of the month'),
    (day: 10, label: 'Every 10th day of the month'),
    (day: 15, label: 'Every 15th day of the month'),
    (day: 20, label: 'Every 20th day of the month'),
    (day: 25, label: 'Every 25th day of the month'),
    (day: 28, label: 'Every 28th day of the month'),
  ];

  /// Список дней месяца: [FormCardWidget] с отступами и логикой радиусов [CardRadius].
  Widget _buildMonthlyPicker(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final total = _monthDayPresets.length;

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
        const SizedBox(height: AppSizing.spaceBtwItems),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: total,
          separatorBuilder: (_, _) =>
              const SizedBox(height: AppSizing.spaceBtwItems),
          itemBuilder: (context, index) {
            final preset = _monthDayPresets[index];
            final day = preset.day;
            final isSelected = _isMultiSelect
                ? _selectedMonthDays.contains(day)
                : widget.initialDate != null &&
                      widget.initialDate!.day.clamp(1, 28) == day;
            return FormCardWidget(
              title: preset.label,
              backgroundColor: isSelected
                  ? colorScheme.primary
                  : colorScheme.secondary,
              foregroundColor: isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurface,
              borderRadius: borderRadiusFor(radiusForIndex(index, total)),
              onTap: () {
                if (_isMultiSelect) {
                  setState(() {
                    if (_selectedMonthDays.contains(day)) {
                      _selectedMonthDays.remove(day);
                    } else {
                      _selectedMonthDays.add(day);
                    }
                  });
                } else {
                  widget.onDateSelected(_nextDayOfMonth(day));
                  Navigator.of(context).pop();
                }
              },
            );
          },
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

  static DateTime _nextWeekday(Weekday weekday) {
    final now = DateUtils.dateOnly(DateTime.now());
    var d = now;
    for (var i = 0; i < 7; i++) {
      if (Weekday.fromDateTime(d) == weekday) return d;
      d = d.add(const Duration(days: 1));
    }
    return now;
  }

  static DateTime _nextDayOfMonth(int day) {
    final now = DateTime.now();
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
