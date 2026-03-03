import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/features/features.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is Unauthenticated) return const LoginView();
        if (state is Authenticated) return const AppMainView();
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
    );
  }
}
