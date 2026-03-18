import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

class ScheduledPaymentFormView extends StatefulWidget {
  const ScheduledPaymentFormView({super.key, this.payment});

  final ScheduledPaymentModel? payment;

  @override
  State<ScheduledPaymentFormView> createState() =>
      _ScheduledPaymentFormViewState();
}

class _ScheduledPaymentFormViewState extends State<ScheduledPaymentFormView> {
  late CategoryIcon _selectedIcon;
  late CategoryShade _selectedShade;
  bool _defaultsInitialized = false;

  final TextEditingController _nameController = TextEditingController();

  /// Сумма платежа; null — ещё не задана.
  double? _paymentAmount;

  late ScheduledPaymentFrequency _frequency;
  ScheduledPaymentType _paymentType = ScheduledPaymentType.subscription;

  /// Дата/день платежа (одиночный — для oneTime).
  DateTime? _paymentDate;

  /// Несколько дат для мультивыбора (monthly — числа месяца, yearly — даты в году).
  List<DateTime> _paymentDates = [];

  bool _autoCreateTransaction = true;

  /// Выбранный кошелёк для списания.
  WalletModel? _selectedWallet;

  /// Выбранная цель (для regularIncome).
  GoalModel? _selectedGoal;

  /// Выбранная категория расхода.
  CategoryModel? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedIcon = categoryIconGroups[0].icons.first;
    _selectedShade = categoryColorPalettes[0].shades.first;
    _frequency = ScheduledPaymentFrequency.oneTime;
    final p = widget.payment;
    if (p != null) {
      _nameController.text = p.name;
      _paymentAmount = p.amount;
      _frequency = p.frequency;
      _paymentType = p.type;
      _autoCreateTransaction = p.autoCreateTransaction;
      _paymentDate = p.paymentDate;
      _paymentDates = _datesFromModel(p);
      _selectedIcon = findIconById(p.iconId) ?? _selectedIcon;
      _selectedShade = findShadeById(p.colorId) ?? _selectedShade;
    }
  }

  List<DateTime> _datesFromModel(ScheduledPaymentModel p) {
    if (p.monthDays != null && p.monthDays!.isNotEmpty) {
      const endOfMonth = 31;
      final now = DateTime.now();
      return p.monthDays!.map((d) {
        if (d == endOfMonth) {
          return DateTime(now.year, now.month + 1, 0);
        }
        return DateTime(now.year, now.month, d);
      }).toList();
    }
    if (p.yearlyDates != null && p.yearlyDates!.isNotEmpty) {
      final now = DateTime.now();
      return p.yearlyDates!.map((md) {
        final parts = md.split('-');
        if (parts.length != 2) return DateTime(now.year, 1, 1);
        final m = int.tryParse(parts[0]) ?? 1;
        final d = int.tryParse(parts[1]) ?? 1;
        return DateTime(now.year, m, d.clamp(1, 28));
      }).toList();
    }
    if (p.paymentDate != null) return [p.paymentDate!];
    return [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_defaultsInitialized) {
      _defaultsInitialized = true;
      final usedIds = _collectUsedIds(context);
      final p = widget.payment;
      if (p == null) {
        _selectedIcon = firstUnusedIcon(usedIds.iconIds);
        _selectedShade = firstUnusedShade(usedIds.colorIds);
      }
      final walletsState = context.read<WalletCubit>().state;
      if (walletsState is WalletsLoaded) {
        final wallets = walletsState.wallets;
        if (p != null && p.walletId != null) {
          _selectedWallet =
              wallets.cast<WalletModel?>().firstWhere(
                (w) => w!.id == p.walletId,
                orElse: () => null,
              ) ??
              wallets.cast<WalletModel?>().firstWhere(
                (w) => w!.isDefault,
                orElse: () => null,
              );
          _selectedGoal = null;
        } else {
          _selectedWallet = wallets.cast<WalletModel?>().firstWhere(
            (w) => w!.isDefault,
            orElse: () => null,
          );
        }
      }
      final categories = context.read<CategoriesCubit>().currentCategories;
      if (p != null && p.categoryId != null) {
        _selectedCategory = categories.cast<CategoryModel?>().firstWhere(
          (c) => c!.categoryId == p.categoryId,
          orElse: () => null,
        );
      }
      final goals = context.read<GoalsCubit>().currentGoals;
      if (p != null && p.goalId != null) {
        _selectedGoal = goals.cast<GoalModel?>().firstWhere(
          (g) => g!.id == p.goalId,
          orElse: () => null,
        );
        if (_selectedGoal != null) _selectedWallet = null;
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
                              controller: _nameController,
                              label: 'Название',
                              hintText: 'например, Аренда',
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
                          enableCalculator: true,
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
                      if (_previewNextDate != null) ...[
                        const SizedBox(height: AppSizing.spaceBtwItemsExtra),
                        Text(
                          'Следующий платёж: ${_previewNextDate!.formatDotDate}',
                          style: AppTextStyles.text14w400(context),
                        ),
                      ],
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
                          onTypeSelected: (value) {
                            setState(() {
                              _paymentType = value;
                              if (value == ScheduledPaymentType.regularIncome) {
                                _selectedCategory = null;
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: AppSizing.spaceBtwItemsExtra),
                      _paymentType == ScheduledPaymentType.regularIncome
                          ? FormCardWidget(
                              title: _selectedGoal?.name ??
                                  _selectedWallet?.name ??
                                  'Кошелёк или цель',
                              subtitle: 'Выберите кошелёк или цель',
                              icon: _buildAccountIcon(colorScheme),
                              onTap: () => _openAccountPicker(context),
                            )
                          : Row(
                              spacing: AppSizing.spaceBtwItemsExtra,
                              children: [
                                Expanded(
                                  child: FormCardWidget(
                                    title: _selectedGoal?.name ??
                                        _selectedWallet?.name ??
                                        'Wallet',
                                    subtitle: 'Выберите кошелёк',
                                    icon: _buildAccountIcon(colorScheme),
                                    onTap: () => _openAccountPicker(context),
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
                          Switch(
                            value: _autoCreateTransaction,
                            onChanged: (value) =>
                                setState(() => _autoCreateTransaction = value),
                          ),
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
              PrimaryButton(
                text: widget.payment != null ? 'Сохранить' : 'Создать',
                onPressed: _isSaving ? null : _save,
              ),
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

  DateTime? get _previewNextDate =>
      ScheduledPaymentDateService.calculateNextDate(
        frequency: _frequency,
        paymentDate: _paymentDate,
        monthDays: _monthDaysFromDates,
        yearlyDates: _yearlyDatesFromDates,
      );

  List<int>? get _monthDaysFromDates {
    if (_frequency != ScheduledPaymentFrequency.monthly ||
        _paymentDates.isEmpty) {
      return null;
    }
    const endOfMonth = 31;
    return _paymentDates
        .map((d) {
          if (d.day == DateTime(d.year, d.month + 1, 0).day) return endOfMonth;
          return d.day;
        })
        .toSet()
        .toList();
  }

  List<String>? get _yearlyDatesFromDates {
    if (_frequency != ScheduledPaymentFrequency.yearly || _paymentDates.isEmpty) {
      return null;
    }
    return _paymentDates
        .map(
          (d) =>
              '${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}',
        )
        .toSet()
        .toList();
  }

  bool _isSaving = false;

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Введите название')));
      return;
    }
    if (_paymentAmount == null || _paymentAmount! <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Укажите сумму')));
      return;
    }
    if (_paymentType == ScheduledPaymentType.regularIncome) {
      if (_selectedWallet == null && _selectedGoal == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Выберите кошелёк или цель')),
        );
        return;
      }
    } else {
      if (_selectedWallet == null && _selectedGoal == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Выберите кошелёк')));
        return;
      }
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Выберите категорию')));
        return;
      }
    }
    if (_frequency == ScheduledPaymentFrequency.oneTime &&
        _paymentDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Выберите дату')));
      return;
    }
    if (_isMultiSelect && _paymentDates.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Выберите дату или дни')));
      return;
    }

    setState(() => _isSaving = true);

    final nextDate = ScheduledPaymentDateService.calculateNextDate(
      frequency: _frequency,
      paymentDate: _paymentDate,
      monthDays: _monthDaysFromDates,
      yearlyDates: _yearlyDatesFromDates,
    );
    if (nextDate == null && _frequency == ScheduledPaymentFrequency.oneTime) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Дата платежа должна быть в будущем')),
      );
      return;
    }

    final model = ScheduledPaymentModel(
      id: widget.payment?.id ?? '',
      name: name,
      amount: _paymentAmount!,
      nextDate: nextDate ?? DateTime.now(),
      iconId: _selectedIcon.id,
      colorId: _selectedShade.id,
      type: _paymentType,
      frequency: _frequency,
      autoCreateTransaction: _autoCreateTransaction,
      isPaused: widget.payment?.isPaused ?? false,
      walletId: _selectedWallet?.id,
      goalId: _selectedGoal?.id,
      categoryId: _paymentType == ScheduledPaymentType.regularIncome
          ? null
          : _selectedCategory?.categoryId,
      paymentDate: _frequency == ScheduledPaymentFrequency.oneTime
          ? _paymentDate
          : null,
      monthDays: _monthDaysFromDates,
      yearlyDates: _yearlyDatesFromDates,
    );

    final cubit = context.read<ScheduledPaymentsCubit>();
    try {
      if (widget.payment != null) {
        await cubit.updatePayment(model);
      } else {
        await cubit.createPayment(model);
      }
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    }
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

  Widget _buildAccountIcon(ColorScheme colorScheme) {
    if (_selectedGoal != null) {
      final shade = findShadeById(_selectedGoal!.colorId);
      final icon = findIconById(_selectedGoal!.iconId);
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
            icon?.icon ?? Icons.flag_rounded,
            size: AppSizing.iconSizeM,
            color: color,
          ),
        ),
      );
    }
    return _buildWalletIcon(colorScheme);
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

  Future<void> _openAccountPicker(BuildContext context) async {
    final walletCubit = context.read<WalletCubit>();
    final goalsCubit = context.read<GoalsCubit>();
    final selected = await AppBottomSheet.showFittedModalBottomSheet<Object>(
      context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: BlocProvider<WalletCubit>.value(
        value: walletCubit,
        child: BlocProvider<GoalsCubit>.value(
          value: goalsCubit,
          child: const AddTransactionAccountsSheetWidget(),
        ),
      ),
    );
    if (!context.mounted) return;
    if (selected != null) {
      setState(() {
        if (selected is WalletModel) {
          _selectedWallet = selected;
          _selectedGoal = null;
        } else if (selected is GoalModel) {
          _selectedGoal = selected;
          _selectedWallet = null;
        }
      });
    }
  }

  Future<void> _openDatePicker(BuildContext context) async {
    if (_frequency == ScheduledPaymentFrequency.oneTime) {
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
      ScheduledPaymentFrequency.oneTime => 'Единожды',
      ScheduledPaymentFrequency.monthly => 'Ежемесячно',
      ScheduledPaymentFrequency.yearly => 'Ежегодно',
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
      ScheduledPaymentFrequency.oneTime => d.formatDotDate,
      ScheduledPaymentFrequency.monthly =>
        d.day == DateTime(d.year, d.month + 1, 0).day
            ? 'End of month'
            : '${d.day}',
      ScheduledPaymentFrequency.yearly => d.formatMonthDay,
    };
  }
}
