import 'package:flutter/material.dart';
import 'package:fn_tracker/features/features.dart';

@immutable
final class AppRouter {
  const AppRouter._();

  static const main = '/';
  static const auth = '/auth';
  static const register = '/register';
  static const login = '/login';
  static const addTransaction = '/add-transaction';
  static const createCategory = '/create-category';

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
        settings: const RouteSettings(name: addTransaction),
        builder: (_) => const AddTransactionView(),
      ),
      createCategory => MaterialPageRoute(
        settings: const RouteSettings(name: createCategory),
        builder: (_) => const CreateCategoryView(),
      ),
      _ => throw Exception(
        'No builder specified for route named: [${settings.name}]',
      ),
    };
  }
}
