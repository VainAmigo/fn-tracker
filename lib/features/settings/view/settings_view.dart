import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/app_theme.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizing.defaultPadding,
          ),
          child: Column(
            children: [
              TabTitleWidget(
                title: 'Settings',
                subtitle: 'Manage your account and preferences',
              ),
              const SizedBox(height: AppSizing.spaceBtwSections),

              TitledSection(
                title: 'App settings',
                children: [
                  _buildSettingsListTile(
                    context,
                    'App Theme',
                    Icons.palette,
                    isFirst: true,
                    onTap: () {
                      AppBottomSheet.showFittedModalBottomSheet(
                        context,
                        child: const SettingsThemeWidget(),
                      );
                    },
                  ),
                  const SizedBox(height: AppSizing.spaceBtwItemsExtra),
                  _buildSettingsListTile(
                    context,
                    'Language',
                    Icons.language,
                    onTap: () {
                      AppBottomSheet.showFittedModalBottomSheet(
                        context,
                        child: const SettingsLocaleWidget(),
                      );
                    },
                  ),
                  const SizedBox(height: AppSizing.spaceBtwItemsExtra),
                  _buildSettingsListTile(
                    context,
                    'Currency and formats',
                    Icons.attach_money,
                    isLast: true,
                    onTap: () {
                      AppBottomSheet.showFittedModalBottomSheet(
                        context,
                        child: const SettingsCurrencyWidget(),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSizing.spaceBtwElements),

              TitledSection(
                title: 'Privacy',
                children: [
                  _buildSettingsListTile(
                    context,
                    'Privacy Policy',
                    Icons.privacy_tip,
                    isFirst: true,
                  ),
                  const SizedBox(height: AppSizing.spaceBtwItemsExtra),
                  _buildSettingsListTile(
                    context,
                    'Security',
                    Icons.security,
                    isLast: true,
                  ),
                ],
              ),

              const SizedBox(height: AppSizing.spaceBtwSections),
              _buildSettingsListTile(
                context,
                'Sign out',
                Icons.logout,
                isFirst: true,
                isLast: true,
                onTap: () => context.read<AuthCubit>().logout(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsListTile(
    BuildContext context,
    String title,
    IconData icon, {
    bool isLast = false,
    bool isFirst = false,
    Function()? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: isFirst
              ? Radius.circular(AppSizing.borderRadius12)
              : Radius.circular(AppSizing.borderRadius4),
          bottom: isLast
              ? Radius.circular(AppSizing.borderRadius12)
              : Radius.circular(AppSizing.borderRadius4),
        ),
        side: BorderSide(color: Theme.of(context).colorScheme.onSecondary),
      ),
      leading: Icon(icon, color: Theme.of(context).colorScheme.onSecondary),
      title: Text(title, style: AppTextStyles.listTileTitle(context)),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: Theme.of(context).colorScheme.onSecondary,
      ),
    );
  }
}
