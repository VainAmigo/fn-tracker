import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/theme/themes.dart';
import 'package:fn_tracker/features/wallet/data/models/scheduled_payment_model.dart';
import '../widgets/scheduled_payment_card.dart';
import '../widgets/scheduled_payment_details_sheet.dart';
import '../widgets/scheduled_payments_calendar_view.dart';

enum _ScheduledPaymentsTab { subscriptions, regular }

extension on _ScheduledPaymentsTab {
  String get label => switch (this) {
    _ScheduledPaymentsTab.subscriptions => 'Подписки',
    _ScheduledPaymentsTab.regular => 'Регулярные платежи',
  };
}

class ScheduledPaymentsTabView extends StatefulWidget {
  const ScheduledPaymentsTabView({super.key});

  @override
  State<ScheduledPaymentsTabView> createState() =>
      _ScheduledPaymentsTabViewState();
}

class _ScheduledPaymentsTabViewState extends State<ScheduledPaymentsTabView> {
  late List<ScheduledPaymentModel> _subscriptions;
  late List<ScheduledPaymentModel> _regularPayments;
  _ScheduledPaymentsTab _selectedTab = _ScheduledPaymentsTab.subscriptions;
  int _calendarYear = DateTime.now().year;
  int _calendarMonth = DateTime.now().month;

  @override
  void initState() {
    super.initState();
    _subscriptions = _createMockSubscriptions();
    _regularPayments = _createMockRegularPayments();
  }

  List<ScheduledPaymentModel> _createMockSubscriptions() {
    return [
      ScheduledPaymentModel(
        id: '1',
        name: 'Netflix',
        amount: 999,
        nextDate: DateTime(2025, 3, 15),
        iconId: 'fun_movie',
        colorId: 'red_500',
        frequency: ScheduledPaymentFrequency.monthly,
        autoCreateTransaction: true,
      ),
      ScheduledPaymentModel(
        id: '2',
        name: 'Spotify',
        amount: 299,
        nextDate: DateTime(2025, 3, 20),
        iconId: 'fun_music',
        colorId: 'green_500',
        frequency: ScheduledPaymentFrequency.monthly,
        autoCreateTransaction: false,
      ),
      ScheduledPaymentModel(
        id: '3',
        name: 'YouTube Premium',
        amount: 449,
        nextDate: DateTime(2025, 3, 25),
        iconId: 'fun_headset',
        colorId: 'red_400',
        frequency: ScheduledPaymentFrequency.monthly,
        autoCreateTransaction: true,
      ),
    ];
  }

  List<ScheduledPaymentModel> _createMockRegularPayments() {
    return [
      ScheduledPaymentModel(
        id: '4',
        name: 'Коммунальные услуги',
        amount: 3500,
        nextDate: DateTime(2025, 3, 10),
        iconId: 'home_water',
        colorId: 'blue_500',
        frequency: ScheduledPaymentFrequency.monthly,
        autoCreateTransaction: false,
      ),
      ScheduledPaymentModel(
        id: '5',
        name: 'Интернет',
        amount: 599,
        nextDate: DateTime(2025, 3, 12),
        iconId: 'home_wifi',
        colorId: 'indigo_500',
        frequency: ScheduledPaymentFrequency.monthly,
        autoCreateTransaction: false,
      ),
      ScheduledPaymentModel(
        id: '6',
        name: 'Электричество',
        amount: 1200,
        nextDate: DateTime(2025, 3, 18),
        iconId: 'home_electric',
        colorId: 'yellow_600',
        frequency: ScheduledPaymentFrequency.monthly,
        autoCreateTransaction: true,
      ),
    ];
  }

  List<ScheduledPaymentModel> get _allPayments => [
    ..._subscriptions,
    ..._regularPayments,
  ];
  @override
  Widget build(BuildContext context) {
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
              payments: _allPayments,
              selectedYear: _calendarYear,
              selectedMonth: _calendarMonth,
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
          _buildTabContent(_selectedTab),
          const SizedBox(height: AppSizing.spaceBtwSections),
        ],
      ),
    );
  }

  Widget _buildTabContent(_ScheduledPaymentsTab tab) {
    final list = tab == _ScheduledPaymentsTab.subscriptions
        ? _subscriptions
        : _regularPayments;
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

  void _openForm({ScheduledPaymentModel? payment}) {
    Navigator.of(context).pushNamed(
      payment != null
          ? AppRouter.updateScheduledPayment
          : AppRouter.createScheduledPayment,
      arguments: payment,
    );
  }

  void _showDetails(ScheduledPaymentModel payment) {
    AppBottomSheet.showFittedModalBottomSheet(
      context,
      child: ScheduledPaymentDetailsSheet(
        payment: payment,
        onEdit: () => _openForm(payment: payment),
        onPause: () {},
        onDelete: () {},
        onCreatePaymentNow: () {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed(AppRouter.addTransaction);
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
