import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

class AnalyticsView extends StatefulWidget {
  const AnalyticsView({super.key});

  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> {
  int _selectedChartTabIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<AnalyticsCubit>().loadAnalytics();
  }

  Future<void> _onRefresh() async {
    await context.read<AnalyticsCubit>().loadAnalytics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizing.defaultPadding,
          ),
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Text(
                    'Analytics chart',
                    style: AppTextStyles.tabTitle(context),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _AnalyticsBody(
                    selectedChartTabIndex: _selectedChartTabIndex,
                    onChartTabChanged: (index) =>
                        setState(() => _selectedChartTabIndex = index),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnalyticsBody extends StatelessWidget {
  const _AnalyticsBody({
    required this.selectedChartTabIndex,
    required this.onChartTabChanged,
  });

  final int selectedChartTabIndex;
  final ValueChanged<int> onChartTabChanged;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnalyticsCubit, AnalyticsState>(
      buildWhen: (prev, curr) =>
          curr is AnalyticsLoaded ||
          curr is AnalyticsLoading ||
          curr is AnalyticsError ||
          curr is AnalyticsInitial,
      builder: (context, state) {
        final cubit = context.read<AnalyticsCubit>();
        return MonthPickerScrollWidget(
          initialYear: cubit.selectedYear,
          initialMonth: cubit.selectedMonth,
          onPeriodChange: (period) => cubit.loadAnalyticsByPeriod(period),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSizing.spaceBtwSections),
              if (state is AnalyticsLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSizing.spaceBtwSections),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (state is AnalyticsError)
                AnalyticsErrorPlaceholderWidget(
                  message: state.message,
                  onRetry: () => cubit.loadAnalytics(),
                )
              else if (state is AnalyticsLoaded)
                AnalyticsContentWidget(
                  data: state.data,
                  period: state.period,
                  initialTabIndex: selectedChartTabIndex,
                  onTabChanged: onChartTabChanged,
                ),
              const SizedBox(height: AppSizing.bottomPadding),
            ],
          ),
        );
      },
    );
  }
}
