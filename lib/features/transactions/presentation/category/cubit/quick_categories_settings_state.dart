import 'package:fn_tracker/features/transactions/presentation/category/data/quick_categories_display_mode.dart';
import 'package:fn_tracker/features/transactions/presentation/category/data/widget_categories_source.dart';

class QuickCategoriesSettingsState {
  const QuickCategoriesSettingsState({
    required this.displayMode,
    this.pinnedOrder = const [],
    this.widgetSource = WidgetCategoriesSource.system,
    this.customWidgetOrder = const [],
  });

  final QuickCategoriesDisplayMode displayMode;
  final List<String> pinnedOrder;
  final WidgetCategoriesSource widgetSource;
  final List<String> customWidgetOrder;
}
