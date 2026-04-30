import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final ValueNotifier<bool> _isCollapsedNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    final (:start, :end) = MonthRangeUtils.currentMonth();
    context.read<HomeCubit>().getHomePageStats(
      startDayKey: start.dayKey,
      endDayKey: end.dayKey,
    );
  }

  Future<void> _onRefresh() async {
    final (:start, :end) = MonthRangeUtils.currentMonth();
    await Future.wait([
      context.read<HomeCubit>().getHomePageStats(
        startDayKey: start.dayKey,
        endDayKey: end.dayKey,
      ),
      context.read<TransactionsCubit>().loadTransactionsByPeriod(
        TransactionPeriod.month,
      ),
      context.read<AnalyticsCubit>().loadAnalytics(),
      context.read<WalletCubit>().loadWallets(),
      context.read<GoalsCubit>().loadGoals(),
      context.read<BudgetCubit>().loadBudgetStats(
        startDayKey: start.dayKey,
        endDayKey: end.dayKey,
      ),
    ]);
  }

  @override
  void dispose() {
    _isCollapsedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final homePageStat = state is HomeLoaded
            ? state.homePageStat
            : HomePageStatModel(totalExpense: 0.0, homeChartStat: const []);

        final rawValues = homePageStat.homeChartStat;
        final merged = mergeChartBuckets(rawValues);
        final values = merged.length == 1
            ? <double>[merged.first, merged.first]
            : merged;

        return Scaffold(
          body: Stack(
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: _isCollapsedNotifier,
                builder: (context, isCollapsed, child) {
                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: isCollapsed ? 0.0 : 1.0,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        height: height * 0.6,
                        width: double.infinity,
                        child: CustomPaint(
                          painter: StaticLineChartPainter(
                            values: values,
                            minYFactor: 0.3,
                            gradientColor: colorScheme.tertiary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              RefreshIndicator(
                onRefresh: _onRefresh,
                child: CustomScrollView(
                  clipBehavior: Clip.none,
                  slivers: [
                    SliverAppBar(
                      pinned: true,
                      automaticallyImplyLeading: false,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      scrolledUnderElevation: 0,
                      surfaceTintColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      expandedHeight: height * 0.6,
                      collapsedHeight: height * 0.15,
                      flexibleSpace: LayoutBuilder(
                        builder: (context, constraints) {
                          final isCollapsed =
                              constraints.biggest.height <= height * 0.30;
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (_isCollapsedNotifier.value != isCollapsed) {
                              _isCollapsedNotifier.value = isCollapsed;
                            }
                          });

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            color: isCollapsed
                                ? colorScheme.surface
                                : Colors.transparent,
                            child: FlexibleSpaceBar(
                              title: HomeTopActionWidget(
                                totalExpense: homePageStat.totalExpense,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: AppSizing.spaceBtwElements,
                        ),
                        child: const HomeInfoListWidget(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
