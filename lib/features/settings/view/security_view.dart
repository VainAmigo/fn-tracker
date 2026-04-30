import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SecurityView extends StatelessWidget {
  const SecurityView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthCubit>().currentUser;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizing.defaultPadding,
          ),
          child: Column(
            children: [
              TabTitleWidget(
                title: 'Настройки безопасности',
                subtitle: 'Управление вашей безопасностью',
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
                    title: 'Пароль',
                    subtitle: 'Нажмите для смены пароля',
                    radius: CardRadius.last,
                    leading: Icon(Icons.lock),
                    trailing: Icon(Icons.arrow_forward_ios),
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
    );
  }
}
