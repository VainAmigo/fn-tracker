import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

class TransactionsListView extends StatefulWidget {
  const TransactionsListView({super.key});

  @override
  State<TransactionsListView> createState() => _TransactionsListViewState();
}

class _TransactionsListViewState extends State<TransactionsListView> {
  TransactionPeriod _selectedPeriod = TransactionPeriod.month;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    context.read<TransactionsCubit>().loadTransactionsByPeriod(_selectedPeriod);
  }

  void _onPeriodChanged(TransactionPeriod period) {
    if (period == _selectedPeriod) return;
    setState(() => _selectedPeriod = period);
    _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(
            horizontal: AppSizing.defaultPadding,
          ),
          child: Column(
            children: [
              SegmentedControl<TransactionPeriod>(
                segments: TransactionPeriod.values
                    .map((p) => SegmentItem(value: p, label: p.label(context)))
                    .toList(),
                selectedValue: _selectedPeriod,
                onChanged: _onPeriodChanged,
              ),
              const SizedBox(height: AppSizing.spaceBtwElements),
              const Expanded(child: TransactionsListWidget()),
            ],
          ),
        ),
      ),
    );
  }
}
