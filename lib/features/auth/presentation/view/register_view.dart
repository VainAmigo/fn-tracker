import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/auth/auth.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(hintText: 'Email'),
                  validator: AuthValidationUtils.email,
                ),

                const SizedBox(height: 10),

                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(hintText: 'Password'),
                  validator: AuthValidationUtils.password,
                ),

                const SizedBox(height: 10),

                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(hintText: 'Confirm Password'),
                  validator: (value) => AuthValidationUtils.confirmPassword(value, passwordController.text),
                ),

                const SizedBox(height: 20),

                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;

                    final isValid = isLoading && passwordController == confirmPasswordController;

                    return SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: isValid ? null : _register,
                        child: isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Register'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _register() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthCubit>().register(emailController.text.trim(), passwordController.text.trim());
  }
}
