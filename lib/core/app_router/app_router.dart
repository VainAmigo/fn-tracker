import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/features/features.dart';

@immutable
final class AppRouter {
  const AppRouter._();

  static const main = '/';
  static const auth = '/auth';
  static const authInit = '/auth-init';
  static const register = '/register';
  static const login = '/login';

  static const transactions = '/transactions';
  static const addTransaction = '/add-transaction';
  static const aiLogic = '/ai-logic';
  static const transactionsById = '/transactions-by-id';

  static const createCategory = '/create-category';
  static const updateCategory = '/update-category';

  static const createWallet = '/create-wallet';
  static const updateWallet = '/update-wallet';

  static const createGoal = '/create-goal';
  static const updateGoal = '/update-goal';

  static const createScheduledPayment = '/create-scheduled-payment';
  static const updateScheduledPayment = '/update-scheduled-payment';
  static const analyticsExportSettings = '/analytics-export-settings';

  static const privacyPolicy = '/privacy-policy';
  static const security = '/security';

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
      authInit => MaterialPageRoute(
        settings: const RouteSettings(name: authInit),
        builder: (_) => const AuthInitView(),
      ),
      aiLogic => MaterialPageRoute(
        settings: RouteSettings(name: aiLogic, arguments: settings.arguments),
        builder: (context) {
          final args = settings.arguments as AiLogicEntryArgs?;
          final mode = args?.mode ?? AiLogicEntryMode.voice;
          return BlocProvider(
            create: (context) => AiLogicCubit(
              entryMode: mode,
              categoryRepo: CategoryRepository(),
              financeRepo: FinanceRepository(
                transactionsRepo: context
                    .read<TransactionsCubit>()
                    .transactionsRepo,
              ),
              parseRepo: AiExpenseParseRepositoryImpl(),
              transactionsRepo: context
                  .read<TransactionsCubit>()
                  .transactionsRepo,
            ),
            child: const AiLogicView(),
          );
        },
      ),
      addTransaction => MaterialPageRoute(
        settings: RouteSettings(
          name: addTransaction,
          arguments: settings.arguments,
        ),
        builder: (context) {
          final args = settings.arguments;
          CategoryModel? categoryById;
          if (args is Map<String, dynamic> && args['categoryId'] is String) {
            final categoriesState = context.read<CategoriesCubit>().state;
            if (categoriesState is CategoriesLoaded) {
              final categoryId = args['categoryId'] as String;
              for (final category in categoriesState.categories) {
                if (category.categoryId == categoryId) {
                  categoryById = category;
                  break;
                }
              }
            }
          }
          return AddTransactionView(
            initialType: args is WalletModel || args is GoalModel
                ? TransactionType.income
                : args is Map<String, dynamic>
                ? TransactionType.expense
                : null,
            initialWallet: args is WalletModel ? args : null,
            initialGoal: args is GoalModel ? args : null,
            initialCategory: args is CategoryModel ? args : categoryById,
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
          return TransactionsListByIdView(
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
      createScheduledPayment => MaterialPageRoute(
        settings: const RouteSettings(name: createScheduledPayment),
        builder: (_) => const ScheduledPaymentFormView(),
      ),
      updateScheduledPayment => MaterialPageRoute(
        settings: RouteSettings(
          name: updateScheduledPayment,
          arguments: settings.arguments,
        ),
        builder: (_) => ScheduledPaymentFormView(
          payment: settings.arguments as ScheduledPaymentModel?,
        ),
      ),
      analyticsExportSettings => MaterialPageRoute(
        settings: const RouteSettings(name: analyticsExportSettings),
        builder: (_) => const ExportSettingsView(),
      ),
      privacyPolicy => MaterialPageRoute(
        settings: const RouteSettings(name: privacyPolicy),
        builder: (_) => const PrivacyPolicyView(),
      ),
      security => MaterialPageRoute(
        settings: const RouteSettings(name: security),
        builder: (_) => const SecurityView(),
      ),
      _ => throw Exception(
        'No builder specified for route named: [${settings.name}]',
      ),
    };
  }
}
