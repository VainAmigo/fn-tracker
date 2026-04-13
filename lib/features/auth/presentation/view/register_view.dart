import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final PasswordVisibilityNotifier _passwordVisibilityNotifier =
      PasswordVisibilityNotifier();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    _passwordVisibilityNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: AppSizing.spaceBtwSections),
                  Text(
                    'Регистрация',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizing.spaceBtwItems),
                  Text(
                    'Создайте аккаунт для отслеживания финансов',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
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
          
                  PasswordTextField(
                    controller: confirmPasswordController,
                    validator: (value) => AuthValidationUtils.confirmPassword(
                      value,
                      passwordController.text,
                    ),
                    label: 'Confirm Password',
                    passwordVisibilityNotifier: _passwordVisibilityNotifier,
                  ),
          
                  const SizedBox(height: AppSizing.spaceBtwSections),
          
                  BlocConsumer<AuthCubit, AuthState>(
                    listener: (context, state) {
                      if (state is Authenticated) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRouter.main,
                          (route) => false,
                        );
                      } else if (state is AuthError) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(state.message)));
                      }
                    },
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
          
                      return PrimaryButton(
                        onPressed: isLoading ? null : _register,
                        text: 'Register',
                      );
                    },
                  ),
          
                  const SizedBox(height: AppSizing.spaceBtwItems),
          
                  PrimaryButton(
                    text: 'Уже есть аккаунт? Войти',
                    onPressed: () => Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil(AppRouter.login, (route) => false),
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
      ),
    );
  }

  void _register() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthCubit>().register(
      emailController.text.trim(),
      passwordController.text.trim(),
    );
  }
}
