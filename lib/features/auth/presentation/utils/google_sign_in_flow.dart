import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/features/auth/auth.dart';
import 'package:fn_tracker/l10n/l10.dart';

/// Вход через Google с экранов [AuthInitView] / Login / Register.
Future<void> runGoogleSignInFlow(BuildContext context) async {
  final outcome = await context.read<AuthCubit>().signInWithGoogle();
  if (!context.mounted) return;

  if (outcome is GoogleSignInFailure) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          firebaseAuthMessage(
            context.l10n,
            outcome.firebaseCode,
            outcome.debugMessage,
          ),
        ),
      ),
    );
  }
}
