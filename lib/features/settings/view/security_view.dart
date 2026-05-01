import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/theme/themes.dart';

class SecurityView extends StatefulWidget {
  const SecurityView({super.key});

  @override
  State<SecurityView> createState() => _SecurityViewState();
}

class _SecurityViewState extends State<SecurityView> {
  @override
  Widget build(BuildContext context) {
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
                TabTitleWidget(title: 'Настройте безопасность вашего аккаунта'),
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
