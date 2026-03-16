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
  ScheduledPaymentType _paymentType = ScheduledPaymentType.subscription;

  /// Дата/день платежа (одиночный — для day/yearly).
  DateTime? _paymentDate;

  /// Несколько дат для мультивыбора (monthly — числа месяца, yearly — даты в году).
  List<DateTime> _paymentDates = [];

  bool _remindMeEnabled = false;
  ScheduledReminderOption _remindMeOption =
      ScheduledReminderOption.oneDayBefore;

  /// Выбранный кошелёк для списания.
  WalletModel? _selectedWallet;

  /// Выбранная категория расхода.
  CategoryModel? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedIcon = categoryIconGroups[0].icons.first;
    _selectedShade = categoryColorPalettes[0].shades.first;
    _frequency = ScheduledPaymentFrequency.day;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_defaultsInitialized) {
      _defaultsInitialized = true;
      final usedIds = _collectUsedIds(context);
      _selectedIcon = firstUnusedIcon(usedIds.iconIds);
      _selectedShade = firstUnusedShade(usedIds.colorIds);
      final walletsState = context.read<WalletCubit>().state;
      if (walletsState is WalletsLoaded) {
        _selectedWallet = walletsState.wallets.cast<WalletModel?>().firstWhere(
          (w) => w!.isDefault,
          orElse: () => null,
        );
      }
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
                      Row(
                        spacing: AppSizing.spaceBtwItemsExtra,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildPreview(context),
                          Expanded(
                            child: CustomTextFormField(
                              label: 'Payment name',
                              hintText: 'e.g. Rent',
                            ),
                          ),
                        ],
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
                      const SizedBox(height: AppSizing.spaceBtwItemsExtra),
                      FormCardWidget(
                        title: _paymentType.label,
                        subtitle: 'Тип планового платежа',
                        icon: Icon(
                          Icons.subscriptions,
                          size: AppSizing.iconSizeM,
                          color: colorScheme.onSecondary,
                        ),
                        onTap: () => ScheduledPaymentTypePickerWidget.show(
                          context,
                          initialType: _paymentType,
                          onTypeSelected: (value) =>
                              setState(() => _paymentType = value),
                        ),
                      ),
                      const SizedBox(height: AppSizing.spaceBtwItemsExtra),
                      FormCardWidget(
                        title: _remindMeEnabled
                            ? _remindMeOption.label
                            : 'Remind me',
                        subtitle: 'When should I remind you?',
                        icon: Icon(
                          Icons.notifications,
                          size: AppSizing.iconSizeM,
                          color: colorScheme.onSecondary,
                        ),
                        trailing: Switch(
                          value: _remindMeEnabled,
                          onChanged: (value) {
                            if (value) {
                              _openReminderPicker(context);
                            } else {
                              setState(() => _remindMeEnabled = false);
                            }
                          },
                        ),
                        onTap: () => _openReminderPicker(context),
                      ),
                      const SizedBox(height: AppSizing.spaceBtwItemsExtra),
                      Row(
                        spacing: AppSizing.spaceBtwItemsExtra,
                        children: [
                          Expanded(
                            child: FormCardWidget(
                              title: _selectedWallet?.name ?? 'Wallet',
                              subtitle: 'Выберите кошелёк',
                              icon: _buildWalletIcon(colorScheme),
                              onTap: () => _openWalletPicker(context),
                            ),
                          ),
                          Expanded(
                            child: FormCardWidget(
                              title: _selectedCategory?.name ?? 'Category',
                              subtitle: 'Выберите категорию',
                              icon: _buildCategoryIcon(colorScheme),
                              onTap: () => _openCategoryPicker(context),
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

  bool get _isMultiSelect =>
      _frequency == ScheduledPaymentFrequency.monthly ||
      _frequency == ScheduledPaymentFrequency.yearly;

  void _openReminderPicker(BuildContext context) {
    ScheduledReminderPickerWidget.show(
      context,
      initialOption: _remindMeOption,
      onOptionSelected: (option) {
        setState(() {
          _remindMeEnabled = true;
          _remindMeOption = option;
        });
      },
    );
  }

  Widget _buildPreview(BuildContext context) {
    return Container(
      height: AppSizing.heightM,
      decoration: BoxDecoration(
        color: _selectedShade.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSizing.borderRadius4),
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: Icon(
          _selectedIcon.icon,
          size: AppSizing.iconSizeM,
          color: _selectedShade.color,
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(ColorScheme colorScheme) {
    if (_selectedCategory != null) {
      final shade = findShadeById(_selectedCategory!.colorId);
      final icon = findIconById(_selectedCategory!.iconId);
      final color = shade?.color ?? colorScheme.onSecondary;
      return Container(
        height: AppSizing.heightS,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius:
              BorderRadius.circular(AppSizing.borderRadius8),
        ),
        child: AspectRatio(
          aspectRatio: 1,
          child: Icon(
            icon?.icon ?? Icons.category,
            size: AppSizing.iconSizeM,
            color: color,
          ),
        ),
      );
    }
    return Icon(
      Icons.category,
      size: AppSizing.iconSizeM,
      color: colorScheme.onSecondary,
    );
  }

  Widget _buildWalletIcon(ColorScheme colorScheme) {
    if (_selectedWallet != null) {
      final shade = findShadeById(_selectedWallet!.colorId);
      final icon = findIconById(_selectedWallet!.iconId);
      final color = shade?.color ?? colorScheme.onSecondary;
      return Container(
        height: AppSizing.heightS,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppSizing.borderRadius8),
        ),
        child: AspectRatio(
          aspectRatio: 1,
          child: Icon(
            icon?.icon ?? Icons.account_balance_wallet,
            size: AppSizing.iconSizeM,
            color: color,
          ),
        ),
      );
    }
    return Icon(
      Icons.account_balance_wallet,
      size: AppSizing.iconSizeM,
      color: colorScheme.onSecondary,
    );
  }

  Future<void> _openCategoryPicker(BuildContext context) async {
    final selected =
        await AppBottomSheet.showFittedModalBottomSheet<CategoryModel>(
          context,
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: const AddTransactionCategorySheetWidget(),
        );
    if (!context.mounted) return;
    if (selected != null) {
      setState(() => _selectedCategory = selected);
    }
  }

  Future<void> _openWalletPicker(BuildContext context) async {
    final selected =
        await AppBottomSheet.showFittedModalBottomSheet<WalletModel>(
          context,
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.only(
              left: AppSizing.defaultPadding,
              right: AppSizing.defaultPadding,
              bottom: AppSizing.bottomPadding,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ModalSheetTitleWidget(title: 'Выберите кошелёк'),
                const SizedBox(height: AppSizing.spaceBtwSections),
                WalletVerticalListWidget(
                  shrinkWrap: true,
                  autoLoad: true,
                  cardStyle: CategoryCardStyle.filled,
                  onWalletSelected: (wallet) =>
                      Navigator.of(context).pop(wallet),
                ),
              ],
            ),
          ),
        );
    if (!context.mounted) return;
    if (selected != null) {
      setState(() => _selectedWallet = selected);
    }
  }

  Future<void> _openDatePicker(BuildContext context) async {
    if (_frequency == ScheduledPaymentFrequency.day) {
      final now = DateTime.now();
      final initial = _paymentDate ?? now;
      final picked = await showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: DateUtils.dateOnly(now),
        lastDate: DateTime(now.year + 2, 12, 31),
      );
      if (!context.mounted) return;
      if (picked != null) {
        setState(() {
          _paymentDate = DateUtils.dateOnly(picked);
          _paymentDates = [_paymentDate!];
        });
      }
      return;
    }
    ScheduledPaymentDatePickerWidget.show(
      context,
      frequency: _frequency,
      initialDate: _paymentDates.isNotEmpty
          ? _paymentDates.first
          : _paymentDate,
      initialDates: _isMultiSelect ? _paymentDates : null,
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
      ScheduledPaymentFrequency.day => 'Day',
      ScheduledPaymentFrequency.monthly => 'Monthly',
      ScheduledPaymentFrequency.yearly => 'Yearly',
    };
  }

  String _dateTitle(BuildContext context) {
    if (_isMultiSelect && _paymentDates.isNotEmpty) {
      return switch (_frequency) {
        ScheduledPaymentFrequency.monthly =>
          _paymentDates
              .map(
                (d) => d.day == DateTime(d.year, d.month + 1, 0).day
                    ? 'End of month'
                    : d.day.toString(),
              )
              .join(', '),
        ScheduledPaymentFrequency.yearly =>
          _paymentDates.map((d) => d.formatMonthDay).join(', '),
        _ => 'Date',
      };
    }
    if (_paymentDate == null) return 'Date';
    final d = _paymentDate!;
    return switch (_frequency) {
      ScheduledPaymentFrequency.day => d.formatDotDate,
      ScheduledPaymentFrequency.monthly =>
        d.day == DateTime(d.year, d.month + 1, 0).day
            ? 'End of month'
            : '${d.day}',
      ScheduledPaymentFrequency.yearly => d.formatMonthDay,
    };
  }
}
