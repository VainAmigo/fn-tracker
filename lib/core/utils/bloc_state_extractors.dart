import 'package:fn_tracker/features/transactions/transactions.dart';
import 'package:fn_tracker/features/wallet/wallet.dart';

/// Утилиты для извлечения данных из состояний BLoC/Cubit.
/// Устраняет дублирование _extractGoals, _extractWallets, _extractCategories.
abstract final class BlocStateExtractors {
  static List<CategoryModel> extractCategories(CategoriesState state) {
    return switch (state) {
      CategoriesLoaded s => s.categories,
      _ => const [],
    };
  }

  static List<GoalModel> extractGoals(GoalsState state) {
    return switch (state) {
      GoalsLoaded s => s.goalsModel.goals,
      _ => const [],
    };
  }

  static List<WalletModel> extractWallets(WalletsState state) {
    return switch (state) {
      WalletsLoaded s => s.wallets,
      _ => const [],
    };
  }
}
