import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/app_theme.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final PasswordVisibilityNotifier _passwordVisibilityNotifier =
      PasswordVisibilityNotifier();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _passwordVisibilityNotifier.dispose();
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: AppSizing.spaceBtwSections),
                Text(
                  'Finance Tracker',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizing.spaceBtwItems),
                Text(
                  'Войдите, чтобы продолжить',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizing.spaceBtwSections),

                CustomTextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  label: 'Email',
                  validator: AuthValidationUtils.email,
                ),

                PasswordTextField(
                  controller: passwordController,
                  validator: AuthValidationUtils.password,
                  label: 'Password',
                  passwordVisibilityNotifier: _passwordVisibilityNotifier,
                ),

                const SizedBox(height: AppSizing.spaceBtwSections),

                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;

                    return PrimaryButton(
                      onPressed: isLoading ? null : _login,
                      text: 'Login',
                    );
                  },
                ),

                const SizedBox(height: AppSizing.spaceBtwItems),

                PrimaryButton(
                  text: 'Нет аккаунта? Регистрация',
                  onPressed: () =>
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRouter.register,
                        (route) => false,
                      ),
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  size: PrimaryButtonSize.xSmall,
                  rounded: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthCubit>().login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );
  }
}
