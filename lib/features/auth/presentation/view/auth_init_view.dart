import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';
import 'package:provider/provider.dart';

class AuthInitView extends StatelessWidget {
  const AuthInitView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(actions: const [_LocaleCycleButton()]),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: SvgPicture.asset(
                    'assets/icons/app_logo.svg',
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      colorScheme.secondary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(height: AppSizing.spaceBtwElements),
                FullWithLogoTextWidget(),
                Text(
                  context.l10n.startTakingControlOfYourFinances,
                  style: AppTextStyles.tabSubTitle(context),
                ),
                const SizedBox(height: AppSizing.spaceBtwSections),
                PrimaryButton(
                  text: context.l10n.continueWithEmail,
                  rounded: true,
                  size: PrimaryButtonSize.medium,
                  icon: Icons.mail_outline,
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRouter.login);
                  },
                ),
                const SizedBox(height: AppSizing.spaceBtwItems),
                PrimaryButton(
                  text: context.l10n.continueWithGoogle,
                  size: PrimaryButtonSize.large,
                  leading: SvgPicture.asset(
                    'assets/icons/google_icon.svg',
                    width: AppSizing.iconSizeM,
                    height: AppSizing.iconSizeM,
                  ),
                  onPressed: () => runGoogleSignInFlow(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Круглая кнопка: каждое нажатие переключает язык по кругу (en → ky → ru).
class _LocaleCycleButton extends StatelessWidget {
  const _LocaleCycleButton();

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final code = localeProvider.currentLanguageCode.toUpperCase();

    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: PrimaryButton(
        text: code,
        fullWidth: false,
        size: PrimaryButtonSize.small,
        onPressed: () {
          final locales = AppLocalizationHelper.locales;
          var i = locales.indexWhere(
            (l) => l.languageCode == localeProvider.currentLanguageCode,
          );
          if (i < 0) i = 0;
          final next = locales[(i + 1) % locales.length];
          localeProvider.setLocale(next);
        },
      ),
    );
  }
}
