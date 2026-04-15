import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';

class AddTransactionView extends StatefulWidget {
  const AddTransactionView({
    super.key,
    this.initialType,
    this.initialWallet,
    this.initialGoal,
    this.initialCategory,
  });

  final TransactionType? initialType;
  final WalletModel? initialWallet;
  final GoalModel? initialGoal;
  final CategoryModel? initialCategory;

  @override
  State<AddTransactionView> createState() => _AddTransactionViewState();
}

class _AddTransactionViewState extends State<AddTransactionView> {
  String _amount = '';
  DateTime _selectedDate = DateTime.now();
  TransactionType _selectedType = TransactionType.expense;
  CategoryModel? _selectedCategory;
  String _note = '';
  WalletModel? _selectedWallet;
  GoalModel? _selectedGoal;

  /// For transfer: source and destination accounts
  WalletModel? _selectedWalletFrom;
  GoalModel? _selectedGoalFrom;
  WalletModel? _selectedWalletTo;
  GoalModel? _selectedGoalTo;

  @override
  void initState() {
    super.initState();
    context.read<AddTransactionCubit>().reset();
    if (widget.initialType != null) {
      _selectedType = widget.initialType!;
    }
    if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory;
    }
    if (widget.initialWallet != null) {
      _selectedWallet = widget.initialWallet;
      _selectedGoal = null;
    } else if (widget.initialGoal != null) {
      _selectedGoal = widget.initialGoal;
      _selectedWallet = null;
    } else {
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
    final currency = context.watch<CurrencyProvider>().currency;
    final txState = context.watch<AddTransactionCubit>().state;
    final isSaving = txState is AddTransactionCreating;
    final l10n = context.l10n;
    final segments = [
      SegmentItem<TransactionType>(
        value: TransactionType.expense,
        label: l10n.expense,
        icon: Icons.arrow_downward,
      ),
      SegmentItem<TransactionType>(
        value: TransactionType.transfer,
        label: l10n.transfer,
        icon: Icons.swap_horiz,
      ),
      SegmentItem<TransactionType>(
        value: TransactionType.income,
        label: l10n.income,
        icon: Icons.arrow_upward,
      ),
    ];

    return BlocListener<AddTransactionCubit, AddTransactionState>(
      listener: (context, state) {
        if (state is AddTransactionSuccess) {
          Navigator.of(context).pop(state.createdTransactions);
          return;
        }

        if (state is AddTransactionError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(context.l10n.addTransaction)),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizing.defaultPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedControl<TransactionType>(
                  segments: segments,
                  height: AppSizing.heightM,
                  selectedValue: _selectedType,
                  onChanged: (value) => setState(() {
                    _selectedType = value;
                    if (value != TransactionType.transfer) {
                      _selectedWalletFrom = null;
                      _selectedGoalFrom = null;
                      _selectedWalletTo = null;
                      _selectedGoalTo = null;
                    }
                  }),
                ),
                const SizedBox(height: AppSizing.spaceBtwSections),
                AmountDisplay(
                  amount: _amount,
                  currency: currency,
                  expression: _expressionForDisplay,
                  computedResult: _computedResultForDisplay,
                ),
                const Spacer(),
                AddTransactionActionWidget(
                  selectedWallet: _selectedWallet,
                  selectedGoal: _selectedGoal,
                  selectedType: _selectedType,
                  onAccountSelected: (account) {
                    setState(() {
                      if (account is WalletModel) {
                        _selectedWallet = account;
                        _selectedGoal = null;
                      } else if (account is GoalModel) {
                        _selectedGoal = account;
                        _selectedWallet = null;
                      }
                    });
                  },
                  selectedWalletFrom: _selectedWalletFrom,
                  selectedGoalFrom: _selectedGoalFrom,
                  selectedWalletTo: _selectedWalletTo,
                  selectedGoalTo: _selectedGoalTo,
                  onTransferFromSelected: (account) {
                    setState(() {
                      if (account is WalletModel) {
                        _selectedWalletFrom = account;
                        _selectedGoalFrom = null;
                      } else if (account is GoalModel) {
                        _selectedGoalFrom = account;
                        _selectedWalletFrom = null;
                      }
                    });
                  },
                  onTransferToSelected: (account) {
                    setState(() {
                      if (account is WalletModel) {
                        _selectedWalletTo = account;
                        _selectedGoalTo = null;
                      } else if (account is GoalModel) {
                        _selectedGoalTo = account;
                        _selectedWalletTo = null;
                      }
                    });
                  },
                  selectedDate: _selectedDate,
                  onDateChanged: (date) {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                  selectedCategory: _selectedCategory,
                  onCategoryChanged: (category) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  note: _note,
                  onNoteChanged: (note) {
                    setState(() {
                      _note = note;
                    });
                  },
                ),
                const SizedBox(height: AppSizing.spaceBtwElements),
                AmountKeyboard(
                  onKeyPressed: _onKeyPressed,
                  showOperators: true,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: AppSizing.spaceBtwItemsExtra,
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        text: context.l10n.save,
                        size: PrimaryButtonSize.medium,
                        rounded: true,
                        isLoading: isSaving,
                        fullWidth: false,
                        onPressed: isSaving ? null : _onSavePressed,
                      ),
                    ),
                    PrimaryButton(
                      text: '',
                      size: PrimaryButtonSize.medium,
                      rounded: true,
                      fullWidth: false,
                      iconOnly: true,
                      icon: Icons.auto_awesome,
                      onPressed: () => Navigator.of(context).pushNamed(
                        AppRouter.aiLogic,
                        arguments: const AiLogicEntryArgs(
                          mode: AiLogicEntryMode.voice,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizing.spaceBtwElements),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double get _effectiveAmount {
    return AmountInputLogic.parseAmount(_amount);
  }

  String? get _expressionForDisplay =>
      ExpressionEvaluator.hasOperator(_amount) ? _amount : null;

  String? get _computedResultForDisplay {
    if (!ExpressionEvaluator.hasOperator(_amount)) return null;
    final r = ExpressionEvaluator.evaluate(_amount);
    final currency = context.read<CurrencyProvider>().currency;
    if (r != null) {
      final str = r == r.truncateToDouble()
          ? r.toInt().toString()
          : r.toStringAsFixed(currency.decimalPlaces);
      return currency.decimalSeparator == DecimalSeparator.comma
          ? str.replaceAll('.', ',')
          : str;
    }
    final lastOp = _lastOperatorIndex();
    return lastOp != null && lastOp > 0 ? _amount.substring(0, lastOp) : '';
  }

  void _onKeyPressed(String key) {
    final currency = context.read<CurrencyProvider>().currency;
    final decimalSep = currency.decimalSeparator == DecimalSeparator.comma
        ? ','
        : '.';
    final nextAmount = AmountInputLogic.applyKey(
      currentAmount: _amount,
      key: key,
      decimalPlaces: currency.decimalPlaces,
      decimalSeparator: decimalSep,
      enableCalculator: true,
    );
    if (nextAmount != _amount) {
      setState(() => _amount = nextAmount);
    }
  }

  int? _lastOperatorIndex() {
    for (int i = _amount.length - 1; i >= 0; i--) {
      if ('+-*/'.contains(_amount[i])) return i;
    }
    return null;
  }

  String? _validateInputs() {
    if (_amount.isEmpty) return context.l10n.amountCannotBeEmpty;
    if (_effectiveAmount <= 0) return context.l10n.amountMustBeGreaterThanZero;
    if (_selectedType == TransactionType.transfer) {
      final from = _selectedWalletFrom != null || _selectedGoalFrom != null;
      final to = _selectedWalletTo != null || _selectedGoalTo != null;
      if (!from || !to) return context.l10n.selectBothSourceAndDestinationAccounts;
      final fromId = _selectedWalletFrom?.id ?? _selectedGoalFrom?.id;
      final toId = _selectedWalletTo?.id ?? _selectedGoalTo?.id;
      if (fromId == toId) return context.l10n.sourceAndDestinationMustBeDifferent;
    } else {
      if (_selectedWallet == null && _selectedGoal == null) {
        return context.l10n.selectWalletOrGoal;
      }
    }
    if (_selectedType == TransactionType.expense &&
        _selectedCategory == null &&
        _selectedGoal == null) {
      return context.l10n.categoryCannotBeEmpty;
    }
    return null;
  }

  void _onSavePressed() {
    final error = _validateInputs();
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    final (
      walletId,
      goalId,
      transferToWalletId,
      transferToGoalId,
    ) = _selectedType == TransactionType.transfer
        ? (
            _selectedWalletFrom?.id,
            _selectedGoalFrom?.id,
            _selectedWalletTo?.id,
            _selectedGoalTo?.id,
          )
        : (_selectedWallet?.id, _selectedGoal?.id, null, null);

    final model = TransactionModel(
      id: '',
      categoryId: _selectedCategory?.categoryId ?? '',
      walletId: walletId,
      goalId: goalId,
      transferToWalletId: transferToWalletId,
      transferToGoalId: transferToGoalId,
      dayKey: _selectedDate.dayKey,
      periodKey: _selectedDate.periodKey,
      note: _note,
      amount: _effectiveAmount,
      type: _selectedType,
      createdAt: DateTime.now(),
      date: _selectedDate,
    );

    context.read<AddTransactionCubit>().addTransaction(transaction: model);
  }
}
