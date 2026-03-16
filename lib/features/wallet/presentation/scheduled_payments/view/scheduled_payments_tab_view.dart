import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/theme/themes.dart';
import 'package:fn_tracker/features/wallet/data/models/scheduled_payment_model.dart';
import 'package:fn_tracker/features/wallet/presentation/scheduled_payments/scheduled_payments.dart';
import '../widgets/scheduled_payment_card.dart';
import '../widgets/scheduled_payment_details_sheet.dart';
import '../widgets/scheduled_payments_calendar_view.dart';

enum _ScheduledPaymentsTab { subscriptions, regular, regularIncome }

extension on _ScheduledPaymentsTab {
  String get label => switch (this) {
    _ScheduledPaymentsTab.subscriptions => 'Подписки',
    _ScheduledPaymentsTab.regular => 'Регулярные платежи',
    _ScheduledPaymentsTab.regularIncome => 'Регулярный доход',
  };
}

class ScheduledPaymentsTabView extends StatefulWidget {
  const ScheduledPaymentsTabView({super.key});

  @override
  State<ScheduledPaymentsTabView> createState() =>
      _ScheduledPaymentsTabViewState();
}

class _ScheduledPaymentsTabViewState extends State<ScheduledPaymentsTabView> {
  _ScheduledPaymentsTab _selectedTab = _ScheduledPaymentsTab.subscriptions;
  int _calendarYear = DateTime.now().year;
  int _calendarMonth = DateTime.now().month;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScheduledPaymentsCubit, ScheduledPaymentsState>(
      builder: (context, state) {
        if (state is ScheduledPaymentsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ScheduledPaymentsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.message),
                const SizedBox(height: 16),
                PrimaryButton(
                  text: 'Повторить',
                  onPressed: () =>
                      context.read<ScheduledPaymentsCubit>().loadPayments(),
                ),
              ],
            ),
          );
        }

        final payments = state is ScheduledPaymentsLoaded
            ? state.payments
            : <ScheduledPaymentModel>[];
        final subscriptions =
            payments
                .where((p) => p.type == ScheduledPaymentType.subscription)
                .toList()
              ..sort((a, b) => a.nextDate.compareTo(b.nextDate));
        final regularPayments =
            payments
                .where((p) => p.type == ScheduledPaymentType.regular)
                .toList()
              ..sort((a, b) => a.nextDate.compareTo(b.nextDate));
        final regularIncomePayments =
            payments
                .where((p) => p.type == ScheduledPaymentType.regularIncome)
                .toList()
              ..sort((a, b) => a.nextDate.compareTo(b.nextDate));

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              MonthPickerScrollWidget(
                initialYear: _calendarYear,
                initialMonth: _calendarMonth,
                onDateChange: _onCalendarDateChange,
                child: ScheduledPaymentsCalendarView(
                  payments: payments,
                  selectedYear: _calendarYear,
                  selectedMonth: _calendarMonth,
                  onDayTap: _showDayPayments,
                ),
              ),
              const SizedBox(height: AppSizing.spaceBtwSections),
              CustomTabWidget<_ScheduledPaymentsTab>(
                items: _ScheduledPaymentsTab.values,
                selectedValue: _selectedTab,
                onChanged: (v) => setState(() => _selectedTab = v),
                labelBuilder: (t) => t.label,
              ),
              const SizedBox(height: AppSizing.spaceBtwElements),
              _buildTabContent(
                _selectedTab,
                _selectedTab == _ScheduledPaymentsTab.subscriptions
                    ? subscriptions
                    : _selectedTab == _ScheduledPaymentsTab.regular
                        ? regularPayments
                        : regularIncomePayments,
              ),
              const SizedBox(height: AppSizing.spaceBtwSections),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabContent(
    _ScheduledPaymentsTab tab,
    List<ScheduledPaymentModel> list,
  ) {
    final total = list.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ...list.asMap().entries.map(
          (entry) => Padding(
            padding: EdgeInsets.only(
              bottom: entry.key < total - 1 ? AppSizing.spaceBtwItemsExtra : 0,
            ),
            child: ScheduledPaymentCard(
              payment: entry.value,
              onTap: () => _showDetails(entry.value),
              radius: radiusForIndex(entry.key, total),
            ),
          ),
        ),
        PrimaryButton(
          onPressed: () => _openForm(),
          text: 'Добавить',
          size: PrimaryButtonSize.xSmall,
          rounded: true,
          fullWidth: false,
        ),
      ],
    );
  }

  void _openForm({ScheduledPaymentModel? payment}) async {
    await Navigator.of(context).pushNamed(
      payment != null
          ? AppRouter.updateScheduledPayment
          : AppRouter.createScheduledPayment,
      arguments: payment,
    );
    if (!mounted) return;
    context.read<ScheduledPaymentsCubit>().loadPayments();
  }

  void _showDayPayments(int day, List<ScheduledPaymentModel> dayPayments) {
    AppBottomSheet.showFittedModalBottomSheet(
      context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: AppSizing.bottomPadding,
          left: AppSizing.defaultPadding,
          right: AppSizing.defaultPadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ModalSheetTitleWidget(
              title: 'Платежи на $day',
              subtitle:
                  '${_calendarMonth.toString().padLeft(2, '0')}.$_calendarYear',
            ),
            const SizedBox(height: AppSizing.spaceBtwSections),
            ...dayPayments.map(
              (p) => Padding(
                padding: const EdgeInsets.only(
                  bottom: AppSizing.spaceBtwItemsExtra,
                ),
                child: ScheduledPaymentCard(
                  payment: p,
                  onTap: () {
                    Navigator.of(context).pop();
                    _showDetails(p);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetails(ScheduledPaymentModel payment) {
    final cubit = context.read<ScheduledPaymentsCubit>();
    AppBottomSheet.showFittedModalBottomSheet(
      context,
      child: ScheduledPaymentDetailsSheet(
        payment: payment,
        onEdit: () {
          Navigator.of(context).pop();
          _openForm(payment: payment);
        },
        onPause: () {
          Navigator.of(context).pop();
          cubit.togglePause(payment.id);
        },
        onDelete: () async {
          Navigator.of(context).pop();
          await cubit.deletePayment(payment.id);
          await NotificationService.cancelReminder(payment.id);
        },
        onCreatePaymentNow: () {
          Navigator.of(context).pop();
          Navigator.of(
            context,
          ).pushNamed(AppRouter.addTransaction, arguments: payment);
        },
      ),
    );
  }

  void _onCalendarDateChange(Month month, int year) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_calendarYear == year && _calendarMonth == month.value) return;
      setState(() {
        _calendarYear = year;
        _calendarMonth = month.value;
      });
    });
  }
}
