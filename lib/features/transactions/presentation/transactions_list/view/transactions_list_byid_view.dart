import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

class TransactionsListByIdView extends StatefulWidget {
  const TransactionsListByIdView({
    super.key,
    required this.idType,
    required this.id,
  });

  final TransactionIdType idType;
  final String id;

  @override
  State<TransactionsListByIdView> createState() =>
      _TransactionsListByIdViewState();
}

class _TransactionsListByIdViewState extends State<TransactionsListByIdView> {
  TransactionPeriod _selectedPeriod = TransactionPeriod.month;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    context.read<TransactionsCubit>().loadTransactionsById(
      widget.idType,
      widget.id,
      _selectedPeriod,
    );
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
              Expanded(
                child: TransactionsListWidget(
                  filterHidden: widget.idType != TransactionIdType.wallet &&
                      widget.idType != TransactionIdType.goal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
