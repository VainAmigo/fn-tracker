import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
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

  Future<void> _openExportSettings() async {
    await Navigator.of(context).pushNamed(AppRouter.analyticsExportSettings);
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
                  child: Row(
                    children: [
                      Text(context.l10n.analytics, style: AppTextStyles.tabTitle(context)),
                      const Spacer(),
                      BlocBuilder<ExportCubit, ExportState>(
                        builder: (context, exportState) {
                          return PrimaryButton(
                            text: context.l10n.export,
                            onPressed: _openExportSettings,
                            size: PrimaryButtonSize.small,
                            fullWidth: false,
                            icon: Icons.file_download_outlined,
                          );
                        },
                      ),
                    ],
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
