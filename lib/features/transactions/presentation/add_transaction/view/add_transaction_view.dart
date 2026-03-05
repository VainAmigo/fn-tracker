import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

class AddTransactionView extends StatefulWidget {
  const AddTransactionView({super.key});

  @override
  State<AddTransactionView> createState() => _AddTransactionViewState();
}

class _AddTransactionViewState extends State<AddTransactionView> {
  String _amount = '';
  DateTime _selectedDate = DateTime.now();
  TransactionType _selectedType = TransactionType.expense;
  CategoryModel? _selectedCategory;
  String _note = '';

  @override
  void initState() {
    super.initState();
    context.read<AddTransactionCubit>().reset();
  }

  static const _segments = [
    SegmentItem<TransactionType>(
      value: TransactionType.expense,
      label: 'Expense',
      icon: Icons.arrow_downward,
    ),
    SegmentItem<TransactionType>(
      value: TransactionType.income,
      label: 'Income',
      icon: Icons.arrow_upward,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyProvider>().currency;
    final txState = context.watch<AddTransactionCubit>().state;
    final isSaving = txState is AddTransactionCreating;

    return BlocListener<AddTransactionCubit, AddTransactionState>(
      listener: (context, state) {
        if (state is AddTransactionSuccess) {
          Navigator.of(context).pop(state.createdTransaction);
          return;
        }

        if (state is AddTransactionError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Add Transaction')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizing.defaultPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedControl<TransactionType>(
                  segments: _segments,
                  height: AppSizing.heightM,
                  selectedValue: _selectedType,
                  onChanged: (value) => setState(() {
                    _selectedType = value;
                  }),
                ),
                const SizedBox(height: AppSizing.spaceBtwSections),
                AmountDisplay(amount: _amount, currency: currency),
                const Spacer(),
                AddTransactionActionWidget(
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
                AmountKeyboard(onKeyPressed: _onKeyPressed),
                PrimaryButton(
                  text: 'Save',
                  size: PrimaryButtonSize.medium,
                  rounded: true,
                  isLoading: isSaving,
                  fullWidth: false,
                  onPressed: isSaving ? null : _onSavePressed,
                ),
                const SizedBox(height: AppSizing.spaceBtwElements),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onSavePressed() {
    if (_amount.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Amount cannot be empty')));
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Category cannot be empty')));
      return;
    }
    final model = TransactionModel(
      id: '',
      categoryId: _selectedCategory?.categoryId ?? '',
      note: _note,
      amount: _amount.isNotEmpty ? double.parse(_amount) : 0,
      type: _selectedType,
      createdAt: _selectedDate,
    );

    context.read<AddTransactionCubit>().addTransaction(transaction: model);
  }

  void _onKeyPressed(String key) {
    if (key == 'backspace') {
      if (_amount.isNotEmpty) {
        setState(() => _amount = _amount.substring(0, _amount.length - 1));
      }
      return;
    }

    if (key == '.') {
      if (_amount.contains('.') || _amount.contains(',')) return;
      final currency = context.read<CurrencyProvider>().currency;
      final decimalSep = currency.decimalSeparator == DecimalSeparator.comma
          ? ','
          : '.';
      setState(() {
        _amount = _amount.isEmpty ? '0$decimalSep' : '$_amount$decimalSep';
      });
      return;
    }

    final currency = context.read<CurrencyProvider>().currency;
    if (_amount.contains('.') || _amount.contains(',')) {
      final parts = _amount.split(RegExp(r'[.,]'));
      if (parts.length == 2 && parts[1].length >= currency.decimalPlaces) {
        return;
      }
    } else if (_amount.length >= 12) {
      return;
    }

    setState(() {
      if (_amount.isEmpty || _amount == '0') {
        _amount = key == '0' ? '0' : key;
      } else {
        _amount = '$_amount$key';
      }
    });
  }
}
