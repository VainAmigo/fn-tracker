import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';

class HomeWalletsSettingsSheet extends StatefulWidget {
  const HomeWalletsSettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return AppBottomSheet.showFittedModalBottomSheet<void>(
      context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      showDragHandle: false,
      child: const HomeWalletsSettingsSheet(),
    );
  }

  @override
  State<HomeWalletsSettingsSheet> createState() =>
      _HomeWalletsSettingsSheetState();
}

class _HomeWalletsSettingsSheetState extends State<HomeWalletsSettingsSheet> {
  @override
  void initState() {
    super.initState();
    context.read<WalletCubit>().loadWallets();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(
        top: AppSizing.defaultPadding,
        bottom: AppSizing.bottomPadding,
        left: AppSizing.defaultPadding,
        right: AppSizing.defaultPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outline.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSizing.spaceBtwElements),
          ModalSheetTitleWidget(
            title: context.l10n.wallets,
            subtitle: context.l10n.homeWalletsSettingsSubtitle,
          ),
          const SizedBox(height: AppSizing.spaceBtwElements),
          BlocBuilder<WalletCubit, WalletsState>(
            builder: (context, walletState) {
              return switch (walletState) {
                WalletsInitial() => const SizedBox.shrink(),
                WalletsLoading() => Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSizing.spaceBtwSections,
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                WalletsEmpty() => EmptyCardWidget(
                    title: context.l10n.noWallets,
                    subtitle: context.l10n.createYourFirstWallet,
                  ),
                WalletsLoaded(:final wallets) => BlocBuilder<
                    HomeWalletsSettingsCubit,
                    HomeWalletsSettingsState>(
                  builder: (context, settingsState) {
                    final configurable = wallets
                        .where((w) => !w.isHidden && w.id != null)
                        .toList();
                    if (configurable.isEmpty) {
                      return EmptyCardWidget(
                        title: context.l10n.noWallets,
                        subtitle: context.l10n.createYourFirstWallet,
                      );
                    }
                    return TitledSection(
                      title: context.l10n.showOnHome,
                      children: [
                        for (var i = 0; i < configurable.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSizing.spaceBtwItemsExtra,
                            ),
                            child: _WalletVisibilityCard(
                              wallet: configurable[i],
                              isVisibleOnHome: !settingsState.hiddenFromHomeIds
                                  .contains(configurable[i].id!),
                              radius: radiusForIndex(i, configurable.length),
                              onTap: () {
                                final id = configurable[i].id!;
                                final hiddenFromHome = settingsState
                                    .hiddenFromHomeIds
                                    .contains(id);
                                context
                                    .read<HomeWalletsSettingsCubit>()
                                    .setWalletVisibleOnHome(
                                      id,
                                      hiddenFromHome,
                                    );
                              },
                            ),
                          ),
                      ],
                    );
                  },
                ),
                WalletsError(:final message) => EmptyCardWidget(
                    title: context.l10n.somethingWentWrong,
                    subtitle: message,
                  ),
              };
            },
          ),
        ],
      ),
    );
  }
}

class _WalletVisibilityCard extends StatelessWidget {
  const _WalletVisibilityCard({
    required this.wallet,
    required this.isVisibleOnHome,
    required this.radius,
    required this.onTap,
  });

  final WalletModel wallet;
  final bool isVisibleOnHome;
  final CardRadius radius;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final shade = findShadeById(wallet.colorId);
    final iconEntry = findIconById(wallet.iconId);
    final accent = shade?.color ?? colorScheme.primary;

    return CategoryCard(
      title: wallet.name,
      leading: Container(
        padding: const EdgeInsets.all(AppSizing.spaceBtwItems),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: isVisibleOnHome ? 0.28 : 0.12),
          borderRadius: BorderRadius.circular(AppSizing.borderRadius8),
        ),
        child: Icon(
          iconEntry?.icon ?? Icons.account_balance_wallet_outlined,
          size: AppSizing.iconSizeM,
          color: isVisibleOnHome ? accent : colorScheme.onSecondary,
        ),
      ),
      trailing: isVisibleOnHome
          ? Icon(
              Icons.check_circle_rounded,
              color: colorScheme.primary,
              size: AppSizing.iconSizeM,
            )
          : Icon(
              Icons.radio_button_unchecked_rounded,
              color: colorScheme.onSecondary.withValues(alpha: 0.7),
              size: AppSizing.iconSizeM,
            ),
      onTap: onTap,
      radius: radius,
    );
  }
}
