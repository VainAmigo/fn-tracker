import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';

class TransactionsListByIdView extends StatefulWidget {
  const TransactionsListByIdView({
    super.key,
    required this.idType,
    required this.id,
    this.analyticsPeriod,
    this.listTitle,
  });

  final TransactionIdType idType;
  final String id;

  /// Когда задан — загрузка идёт за этот период (как на экране аналитики), без переключателя диапазона.
  final DatePickerPeriod? analyticsPeriod;

  /// Заголовок AppBar; по умолчанию — строка «Транзакции».
  final String? listTitle;

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
    final fixed = widget.analyticsPeriod;
    if (fixed != null) {
      context.read<TransactionsCubit>().loadTransactionsById(
        widget.idType,
        widget.id,
        TransactionPeriod.month,
        startDayKey: fixed.startDayKey,
        endDayKey: fixed.endDayKey,
      );
    } else {
      context.read<TransactionsCubit>().loadTransactionsById(
        widget.idType,
        widget.id,
        _selectedPeriod,
      );
    }
  }

  void _onPeriodChanged(TransactionPeriod period) {
    if (widget.analyticsPeriod != null) return;
    if (period == _selectedPeriod) return;
    setState(() => _selectedPeriod = period);
    _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final showPeriodPicker = widget.analyticsPeriod == null;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listTitle ?? context.l10n.transactions),
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(
            horizontal: AppSizing.defaultPadding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showPeriodPicker) ...[
                SegmentedControl<TransactionPeriod>(
                  segments: TransactionPeriod.values
                      .map((p) => SegmentItem(value: p, label: p.label(context)))
                      .toList(),
                  selectedValue: _selectedPeriod,
                  onChanged: _onPeriodChanged,
                ),
                const SizedBox(height: AppSizing.spaceBtwElements),
              ],
              Flexible(
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
