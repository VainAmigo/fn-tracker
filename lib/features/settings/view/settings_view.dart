import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';

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
                title: context.l10n.settings,
                subtitle: context.l10n.manageYourAccountAndPreferences,
              ),
              const SizedBox(height: AppSizing.spaceBtwSections),

              TitledSection(
                title: context.l10n.appSettings,
                children: [
                  _buildSettingsListTile(
                    context,
                    context.l10n.appTheme,
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
                    context.l10n.language,
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
                    context.l10n.currencyAndFormats,
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
                title: context.l10n.privacy,
                children: [
                  _buildSettingsListTile(
                    context,
                    context.l10n.account,
                    Icons.person,
                    isFirst: true,
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRouter.privacyPolicy);
                    },
                  ),
                  const SizedBox(height: AppSizing.spaceBtwItemsExtra),
                  _buildSettingsListTile(
                    context,
                    context.l10n.security,
                    Icons.security,
                    isLast: true,
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRouter.security);
                    },
                  ),
                ],
              ),

              const SizedBox(height: AppSizing.spaceBtwSections),
              _buildSettingsListTile(
                context,
                context.l10n.signOut,
                Icons.logout,
                isFirst: true,
                isLast: true,
                onTap: () {
                  showSignOutConfirmationDialog(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> showSignOutConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.signOut),
        content: Text(context.l10n.signOutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthCubit>().logout();
              Navigator.of(context).pop(true);
            },
            child: Text(context.l10n.signOut),
          ),
        ],
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
      tileColor: Theme.of(context).colorScheme.secondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: isFirst
              ? Radius.circular(AppSizing.borderRadius12)
              : Radius.circular(AppSizing.borderRadius4),
          bottom: isLast
              ? Radius.circular(AppSizing.borderRadius12)
              : Radius.circular(AppSizing.borderRadius4),
        ),
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
