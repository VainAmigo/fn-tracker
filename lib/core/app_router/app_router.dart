import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/features/features.dart';

class AppRouter {
  static const login = '/login';
  static const register = '/register';
  static const app = '/app';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) {
            final state = context.read<AuthCubit>().state;
            if (state is Authenticated) return const AppMainView();
            return const LoginView();
          },
        );
      case register:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) {
            final state = context.read<AuthCubit>().state;
            if (state is Authenticated) return const AppMainView();
            return const RegisterView();
          },
        );
      case app:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) {
            final state = context.read<AuthCubit>().state;
            if (state is Unauthenticated) return const LoginView();
            return const AppMainView();
          },
        );
      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Страница не найдена')),
            body: Center(child: Text('Маршрут: ${settings.name}')),
          ),
        );
    }
  }
}
