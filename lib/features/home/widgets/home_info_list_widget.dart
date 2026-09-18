import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';

class HomeInfoListWidget extends StatelessWidget {
  const HomeInfoListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizing.defaultPadding),
      child: BlocBuilder<HomeLayoutSettingsCubit, HomeLayoutSettingsState>(
        builder: (context, layout) {
          final children = <Widget>[];

          for (final index in layout.sectionOrder) {
            final section = HomeSection.values[index];
            if (!layout.isSectionVisible(section)) continue;
            children.add(_buildSection(context, section));
          }
          children.add(const SizedBox(height: AppSizing.spaceBtwElements));
          children.add(
            PrimaryButton(
              text: context.l10n.edit,
              size: PrimaryButtonSize.xSmall,
              onPressed: () => HomeLayoutSettingsSheet.show(context),
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Theme.of(context).colorScheme.onSecondary,
            ),
          );
          children.add(const SizedBox(height: AppSizing.bottomPadding));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          );
        },
      ),
    );
  }

  Widget _buildSection(BuildContext context, HomeSection section) {
    return switch (section) {
      HomeSection.wallets => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TitledSection(
            title: context.l10n.wallets,
            action: PrimaryButton(
              text: context.l10n.settings,
              onPressed: () => HomeWalletsSettingsSheet.show(context),
              size: PrimaryButtonSize.xSmall,
              fullWidth: false,
              rounded: true,
            ),
            children: [
              const HomeWalletsStripWidget(),
              const SizedBox(height: AppSizing.spaceBtwElements),
            ],
          ),
        ],
      ),
      HomeSection.quickCategories => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TitledSection(
            title: context.l10n.quickCategories,
            action: PrimaryButton(
              text: context.l10n.settings,
              onPressed: () => QuickCategoriesSettingsSheet.show(context),
              size: PrimaryButtonSize.xSmall,
              fullWidth: false,
              rounded: true,
            ),
            children: const [QuickCategoriesWidget()],
          ),
        ],
      ),
      HomeSection.lastTransactions => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TitledSection(
            title: context.l10n.lastTransactions,
            action: PrimaryButton(
              text: context.l10n.viewAll,
              onPressed: () =>
                  Navigator.pushNamed(context, AppRouter.transactions),
              size: PrimaryButtonSize.xSmall,
              fullWidth: false,
              rounded: true,
            ),
            children: [
              LastTransactionsListWidget(),
              const SizedBox(height: AppSizing.spaceBtwElements),
            ],
          ),
        ],
      ),
    };
  }
}
