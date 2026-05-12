import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';

class TransactionsListView extends StatefulWidget {
  const TransactionsListView({super.key, this.embedded = false});

  /// Без [Scaffold] и [AppBar] — для вкладки «Финансы» (родитель задаёт высоту).
  final bool embedded;

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
    final body = Padding(
      padding: EdgeInsetsGeometry.symmetric(
        horizontal:
            widget.embedded ? 0 : AppSizing.defaultPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
    );

    if (widget.embedded) {
      return body;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.transactions),
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(child: body),
    );
  }
}
