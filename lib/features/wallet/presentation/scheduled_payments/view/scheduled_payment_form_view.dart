import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

class ScheduledPaymentFormView extends StatefulWidget {
  const ScheduledPaymentFormView({super.key});

  @override
  State<ScheduledPaymentFormView> createState() =>
      _ScheduledPaymentFormViewState();
}

class _ScheduledPaymentFormViewState extends State<ScheduledPaymentFormView> {
  late CategoryIcon _selectedIcon;
  late CategoryShade _selectedShade;
  bool _defaultsInitialized = false;

  /// Сумма платежа; null — ещё не задана.
  double? _paymentAmount;

  late ScheduledPaymentFrequency _frequency;

  /// Дата/день платежа (одиночный — для daily/yearly).
  DateTime? _paymentDate;

  /// Несколько дат для мультивыбора (weekly — дни недели, monthly — числа месяца).
  List<DateTime> _paymentDates = [];

  /// Для daily: каждые N дней (интервал повторения).
  int _dailyInterval = 1;

  @override
  void initState() {
    super.initState();
    _selectedIcon = categoryIconGroups[0].icons.first;
    _selectedShade = categoryColorPalettes[0].shades.first;
    _frequency = ScheduledPaymentFrequency.daily;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_defaultsInitialized) {
      _defaultsInitialized = true;
      final usedIds = _collectUsedIds(context);
      _selectedIcon = firstUnusedIcon(usedIds.iconIds);
      _selectedShade = firstUnusedShade(usedIds.colorIds);
    }
  }

  @override
  Widget build(BuildContext context) {
    final usedIds = _collectUsedIds(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scheduled Payment'),
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizing.defaultPadding),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      CustomTextFormField(
                        label: 'Payment name',
                        hintText: 'e.g. Rent',
                      ),
                      const SizedBox(height: AppSizing.spaceBtwItems),
                      FormCardWidget(
                        title: _paymentAmount != null
                            ? AmountFormatter.format(_paymentAmount!)
                            : 'Payment amount',
                        subtitle: 'How much do you want to pay?',
                        icon: Icon(
                          Icons.attach_money,
                          size: AppSizing.iconSizeM,
                          color: colorScheme.onSecondary,
                        ),
                        onTap: () => AmountFormModalSheet.show(
                          context,
                          initialAmount: _paymentAmount,
                          onSave: (amount) =>
                              setState(() => _paymentAmount = amount),
                          saveLabel: 'Save',
                        ),
                      ),
                      const SizedBox(height: AppSizing.spaceBtwItemsExtra),
                      Row(
                        spacing: AppSizing.spaceBtwItemsExtra,
                        children: [
                          FormCardWidget(
                            title: _frequencyTitle(context),
                            subtitle: 'Frequency',
                            icon: Icon(
                              Icons.cached,
                              size: AppSizing.iconSizeM,
                              color: colorScheme.onSecondary,
                            ),
                            expandLabel: false,
                            onTap: () => ScheduledFrequencyPickerWidget.show(
                              context,
                              initialFrequency: _frequency,
                              onFrequencySelected: (value) {
                                setState(() {
                                  _frequency = value;
                                  _paymentDate = null;
                                  _paymentDates = [];
                                  _dailyInterval = 1;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: FormCardWidget(
                              title: _dateTitle(context),
                              subtitle: 'Payment date',
                              icon: Icon(
                                Icons.date_range,
                                size: AppSizing.iconSizeM,
                                color: colorScheme.onSecondary,
                              ),
                              onTap: () => _openDatePicker(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizing.spaceBtwItems),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Enable auto-payment',
                              style: AppTextStyles.text14w400(context),
                            ),
                          ),
                          Switch(value: true, onChanged: (value) {}),
                        ],
                      ),
                      const SizedBox(height: AppSizing.spaceBtwItemsExtra),
                      CreateCategoryIconPickerWidget(
                        selectedIcon: _selectedIcon,
                        selectedColor: _selectedShade.color,
                        onIconSelected: (icon) =>
                            setState(() => _selectedIcon = icon),
                        usedIconIds: usedIds.iconIds,
                      ),
                      CreateCategoryColorPickerWidget(
                        selectedShade: _selectedShade,
                        onShadeSelected: (shade) =>
                            setState(() => _selectedShade = shade),
                        usedColorIds: usedIds.colorIds,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizing.spaceBtwElements),
              PrimaryButton(text: 'Create'),
              const SizedBox(height: AppSizing.spaceBtwElements),
            ],
          ),
        ),
      ),
    );
  }

  bool get _isDaily =>
      _frequency == ScheduledPaymentFrequency.daily;
  bool get _isMultiSelect =>
      _frequency == ScheduledPaymentFrequency.weekly ||
      _frequency == ScheduledPaymentFrequency.monthly ||
      _frequency == ScheduledPaymentFrequency.yearly;

  void _openDatePicker(BuildContext context) {
    ScheduledPaymentDatePickerWidget.show(
      context,
      frequency: _frequency,
      initialDate:
          _paymentDates.isNotEmpty ? _paymentDates.first : _paymentDate,
      initialDates: _isMultiSelect ? _paymentDates : null,
      initialDailyInterval: _isDaily ? _dailyInterval : null,
      onDateSelected: (value) {
        setState(() {
          _paymentDate = value;
          _paymentDates = [value];
        });
      },
      onDatesSelected: _isMultiSelect
          ? (list) {
              setState(() {
                _paymentDates = list;
                _paymentDate = list.isNotEmpty ? list.first : null;
              });
            }
          : null,
      onDailyScheduleSelected: _isDaily
          ? (interval, startDate) {
              setState(() {
                _dailyInterval = interval;
                _paymentDate = startDate;
                _paymentDates = [startDate];
              });
            }
          : null,
    );
  }

  ({Set<String> colorIds, Set<String> iconIds}) _collectUsedIds(
    BuildContext context,
  ) {
    final goals = context.read<GoalsCubit>().currentGoals;
    final wallets = context.read<WalletCubit>().currentWallets;
    final categories = context.read<CategoriesCubit>().currentCategories;
    return (
      colorIds: <String>{
        ...goals.map((g) => g.colorId),
        ...wallets.map((w) => w.colorId),
        ...categories.map((c) => c.colorId),
      },
      iconIds: <String>{
        ...goals.map((g) => g.iconId),
        ...wallets.map((w) => w.iconId),
        ...categories.map((c) => c.iconId),
      },
    );
  }

  String _frequencyTitle(BuildContext context) {
    return switch (_frequency) {
      ScheduledPaymentFrequency.once => 'Once',
      ScheduledPaymentFrequency.daily => 'Daily',
      ScheduledPaymentFrequency.weekly => 'Weekly',
      ScheduledPaymentFrequency.monthly => 'Monthly',
      ScheduledPaymentFrequency.yearly => 'Yearly',
    };
  }

  String _dateTitle(BuildContext context) {
    if (_isMultiSelect && _paymentDates.isNotEmpty) {
      return switch (_frequency) {
        ScheduledPaymentFrequency.weekly => _paymentDates
            .map((d) => Weekday.fromDateTime(d).localizedName(context))
            .join(', '),
        ScheduledPaymentFrequency.monthly =>
          _paymentDates.map((d) => d.day.toString()).join(', '),
        ScheduledPaymentFrequency.yearly =>
          _paymentDates.map((d) => d.formatMonthDay).join(', '),
        _ => 'Date',
      };
    }
    if (_isDaily) {
      final intervalText =
          _dailyInterval == 1 ? 'Every day' : 'Every $_dailyInterval days';
      return _paymentDate != null
          ? '$intervalText from ${_paymentDate!.formatDotDate}'
          : intervalText;
    }
    if (_paymentDate == null) return 'Date';
    final d = _paymentDate!;
    return switch (_frequency) {
      ScheduledPaymentFrequency.once => d.formatDotDate,
      ScheduledPaymentFrequency.weekly =>
        Weekday.fromDateTime(d).localizedName(context),
      ScheduledPaymentFrequency.monthly => '${d.day}',
      ScheduledPaymentFrequency.yearly => d.formatMonthDay,
      ScheduledPaymentFrequency.daily => d.formatDotDate,
    };
  }
}
