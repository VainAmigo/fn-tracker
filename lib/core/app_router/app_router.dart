import 'package:flutter/material.dart';
import 'package:fn_tracker/features/features.dart';

@immutable
final class AppRouter {
  const AppRouter._();

  static const main = '/';
  static const auth = '/auth';
  static const register = '/register';
  static const login = '/login';

  static const transactions = '/transactions';
  static const addTransaction = '/add-transaction';
  static const transactionsById = '/transactions-by-id';

  static const createCategory = '/create-category';
  static const updateCategory = '/update-category';

  static const createWallet = '/create-wallet';
  static const updateWallet = '/update-wallet';

  static const createGoal = '/create-goal';
  static const updateGoal = '/update-goal';

  static Route<void> onGenerateRoute(RouteSettings settings) {
    return switch (settings.name) {
      main => MaterialPageRoute(
        settings: const RouteSettings(name: main),
        builder: (_) => const AuthGateView(),
      ),
      auth => MaterialPageRoute(
        settings: const RouteSettings(name: auth),
        builder: (_) => const AuthView(),
      ),
      register => MaterialPageRoute(
        settings: const RouteSettings(name: register),
        builder: (_) => const RegisterView(),
      ),
      login => MaterialPageRoute(
        settings: const RouteSettings(name: login),
        builder: (_) => const LoginView(),
      ),
      addTransaction => MaterialPageRoute(
        settings: RouteSettings(
          name: addTransaction,
          arguments: settings.arguments,
        ),
        builder: (_) {
          final args = settings.arguments;
          return AddTransactionView(
            initialType: args is WalletModel || args is GoalModel
                ? TransactionType.income
                : null,
            initialWallet: args is WalletModel ? args : null,
            initialGoal: args is GoalModel ? args : null,
          );
        },
      ),
      createCategory => MaterialPageRoute(
        settings: const RouteSettings(name: createCategory),
        builder: (_) => const CategoryFormView(),
      ),
      transactions => MaterialPageRoute(
        settings: const RouteSettings(name: transactions),
        builder: (_) => const TransactionsListView(),
      ),
      transactionsById => MaterialPageRoute(
        settings: const RouteSettings(name: transactionsById),
        builder: (_) {
          final args = settings.arguments as Map<String, dynamic>;
          return TransactionsListByidView(
            idType: args['idType'] as TransactionIdType,
            id: args['id'] as String,
          );
        },
      ),
      updateCategory => MaterialPageRoute(
        settings: const RouteSettings(name: updateCategory),
        builder: (_) =>
            CategoryFormView(category: settings.arguments as CategoryModel),
      ),
      createWallet => MaterialPageRoute(
        settings: const RouteSettings(name: createWallet),
        builder: (_) => const WalletFormView(),
      ),
      updateWallet => MaterialPageRoute(
        settings: const RouteSettings(name: updateWallet),
        builder: (_) =>
            WalletFormView(wallet: settings.arguments as WalletModel),
      ),
      createGoal => MaterialPageRoute(
        settings: const RouteSettings(name: createGoal),
        builder: (_) => const GoalFormView(),
      ),
      updateGoal => MaterialPageRoute(
        settings: const RouteSettings(name: updateGoal),
        builder: (_) => GoalFormView(goal: settings.arguments as GoalModel),
      ),
      _ => throw Exception(
        'No builder specified for route named: [${settings.name}]',
      ),
    };
  }
}
