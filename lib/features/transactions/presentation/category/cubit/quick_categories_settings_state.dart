import 'package:fn_tracker/features/transactions/presentation/category/data/quick_categories_display_mode.dart';

class QuickCategoriesSettingsState {
  const QuickCategoriesSettingsState({
    required this.displayMode,
    this.pinnedOrder = const [],
  });

  final QuickCategoriesDisplayMode displayMode;
  final List<String> pinnedOrder;
}
