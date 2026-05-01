import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
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
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRouter.authInit, (route) => false),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
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

                  CustomTextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    label: context.l10n.email,
                    validator: (value) =>
                        AuthValidationUtils.email(value, context),
                  ),

                  PasswordTextField(
                    controller: passwordController,
                    validator: (value) =>
                        AuthValidationUtils.password(value, context),
                    label: context.l10n.password,
                    passwordVisibilityNotifier: _passwordVisibilityNotifier,
                  ),

                  PasswordTextField(
                    controller: confirmPasswordController,
                    validator: (value) => AuthValidationUtils.confirmPassword(
                      value,
                      context,
                      passwordController.text,
                    ),
                    label: context.l10n.confirmPassword,
                    passwordVisibilityNotifier: _passwordVisibilityNotifier,
                  ),
                  const SizedBox(height: AppSizing.spaceBtwItems),

                  PrimaryButton(
                    text: context.l10n.alreadyHaveAccount,
                    onPressed: () =>
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRouter.login,
                          (route) => false,
                        ),
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    size: PrimaryButtonSize.xSmall,
                    rounded: true,
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
                        text: context.l10n.register,
                        rounded: true,
                      );
                    },
                  ),
                  const SizedBox(height: AppSizing.spaceBtwSections),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      final busy = state is AuthLoading;
                      return PrimaryButton(
                        text: context.l10n.continueWithGoogle,
                        size: PrimaryButtonSize.large,
                        leading: SvgPicture.asset(
                          'assets/icons/google_icon.svg',
                          width: AppSizing.iconSizeM,
                          height: AppSizing.iconSizeM,
                        ),
                        onPressed: busy
                            ? null
                            : () => runGoogleSignInFlow(context),
                      );
                    },
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
