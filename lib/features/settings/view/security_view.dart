import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';

class SecurityView extends StatelessWidget {
  const SecurityView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthCubit>().currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text('Настройки безопасности'),
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizing.defaultPadding,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TabTitleWidget(
                  title: 'Настройте безопасность вашего аккаунта',
                ),
                const SizedBox(height: AppSizing.spaceBtwSections),
                TitledSection(
                  title: 'Данные аккаунта',
                  children: [
                    CategoryCard(
                      title: user?.email ?? '',
                      subtitle: 'Email',
                      radius: CardRadius.first,
                      leading: Icon(Icons.email),
                    ),
                    const SizedBox(height: AppSizing.spaceBtwItemsExtra),
                    CategoryCard(
                      title: user?.displayName ?? 'Не установлено',
                      subtitle: user?.displayName?.isEmpty ?? true
                          ? 'Нажмите для установки имени пользователя'
                          : 'Имя пользователя',
                      radius: CardRadius.middle,
                      leading: Icon(Icons.person),
                      trailing: Icon(Icons.arrow_forward_ios),
                    ),
                    const SizedBox(height: AppSizing.spaceBtwItemsExtra),
                    CategoryCard(
                      title: context.l10n.password,
                      subtitle: context.l10n.changePasswordCardSubtitle,
                      radius: CardRadius.last,
                      leading: Icon(Icons.lock),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        final fbUser = FirebaseAuth.instance.currentUser;
                        final hasEmailPassword = fbUser?.providerData.any(
                              (p) => p.providerId == EmailAuthProvider.PROVIDER_ID,
                            ) ??
                            false;
                        if (!hasEmailPassword) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                context.l10n.passwordChangeEmailOnly,
                              ),
                            ),
                          );
                          return;
                        }
                        Navigator.of(context).pushNamed(
                          AppRouter.changePassword,
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppSizing.spaceBtwSections),
            
                CategoryCard(
                  title: 'Привезать к Google аккаунт',
                  subtitle: 'Привяжите ваш Google аккаунт для доступа в приложение',
                  radius: CardRadius.single,
                  leading: SvgPicture.asset(
                        'assets/icons/google_icon.svg',
                        width: AppSizing.iconSizeM,
                        height: AppSizing.iconSizeM,
                      ),
                ),
                const SizedBox(height: AppSizing.spaceBtwSections),
            
                TitledSection(
                  title: 'Безопасность',
                  children: [
                    CategoryCard(
                      title: 'Задать PIN',
                      subtitle: 'Установите PIN для доступа в приложение',
                      radius: CardRadius.first,
                      leading: Icon(Icons.lock),
                      trailing: Icon(Icons.arrow_forward_ios),
                    ),
                    const SizedBox(height: AppSizing.spaceBtwItemsExtra),
                    CategoryCard(
                      title: 'Биометрия не установлена',
                      subtitle: 'Биометрию для доступа в приложение',
                      radius: CardRadius.last,
                      leading: Icon(Icons.fingerprint),
                      trailing: Icon(Icons.arrow_forward_ios),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
