import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/app_sizing/app_sizing.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final ValueNotifier<bool> _isCollapsedNotifier = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _isCollapsedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const values = [10.0, 25.0, 18.0, 30.0, 10.0, 40.0, 80.0, 10.0];
    final height = MediaQuery.of(context).size.height;
    final colorScheme = Theme.of(context).colorScheme;

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
          CustomScrollView(
            clipBehavior: Clip.none,
            scrollBehavior: ScrollBehavior().copyWith(overscroll: false),
            slivers: [
              SliverAppBar(
                pinned: true,
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                surfaceTintColor: Colors.transparent,
                shadowColor: Colors.transparent,
                expandedHeight: height * 0.7,
                collapsedHeight: height * 0.15,
                flexibleSpace: LayoutBuilder(
                  builder: (context, constraints) {
                    final isCollapsed =
                        constraints.biggest.height <= height * 0.40;
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
                      child: const FlexibleSpaceBar(
                        title: HomeTopActionWidget(),
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
        ],
      ),
    );
  }
}
