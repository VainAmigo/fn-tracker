import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';

class WalletsListWidget extends StatefulWidget {
  const WalletsListWidget({
    super.key,
    this.autoLoad = false,
    required this.onWalletSelected,
    this.onHiddenCardsSelected,
    this.hiddenFromHomeIds,
  });

  final bool autoLoad;
  final ValueChanged<WalletModel> onWalletSelected;
  final VoidCallback? onHiddenCardsSelected;

  /// Скрыть эти кошельки только в этом списке (например настройки главной).
  final Set<String>? hiddenFromHomeIds;

  @override
  State<WalletsListWidget> createState() => _WalletsListWidgetState();
}

class _WalletsListWidgetState extends State<WalletsListWidget> {
  @override
  void initState() {
    super.initState();
    if (widget.autoLoad) {
      context.read<WalletCubit>().loadWallets();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletCubit, WalletsState>(
      builder: (context, state) {
        return switch (state) {
          WalletsInitial() => const SizedBox.shrink(),
          WalletsLoading() => const Center(child: CircularProgressIndicator()),
          WalletsEmpty() => EmptyCardWidget(
            title: context.l10n.noWallets,
            subtitle: context.l10n.createYourFirstWallet,
          ),
          WalletsLoaded() => _Body(
            wallets: state.wallets,
            onWalletSelected: widget.onWalletSelected,
            onHiddenCardsSelected: widget.onHiddenCardsSelected,
            hiddenFromHomeIds: widget.hiddenFromHomeIds,
          ),
          WalletsError() => Center(child: Text(state.message)),
        };
      },
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.wallets,
    required this.onWalletSelected,
    this.onHiddenCardsSelected,
    this.hiddenFromHomeIds,
  });

  final List<WalletModel> wallets;
  final ValueChanged<WalletModel> onWalletSelected;
  final VoidCallback? onHiddenCardsSelected;
  final Set<String>? hiddenFromHomeIds;

  @override
  Widget build(BuildContext context) {
    final hiddenHome = hiddenFromHomeIds;
    final visibleWallets = wallets.where((w) {
      if (w.isHidden) return false;
      final id = w.id;
      if (hiddenHome != null && id != null && hiddenHome.contains(id)) {
        return false;
      }
      return true;
    }).toList();
    final hiddenWallets = wallets.where((w) => w.isHidden).toList();
    final hasHidden = hiddenWallets.isNotEmpty;
    final showHiddenTile = hasHidden && onHiddenCardsSelected != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final narrowW = MediaQuery.sizeOf(context).width * 0.7;
        final singleWalletFullWidth =
            visibleWallets.length == 1 && !showHiddenTile;
        final itemWidth = singleWalletFullWidth ? maxW : narrowW;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: singleWalletFullWidth
              ? const NeverScrollableScrollPhysics()
              : null,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int i = 0; i < visibleWallets.length; i++) ...[
                  if (i > 0) const SizedBox(width: AppSizing.spaceBtwItems),
                  SizedBox(
                    width: itemWidth,
                    child: GestureDetector(
                      onTap: () => onWalletSelected(visibleWallets[i]),
                      child: WalletCardWidget(
                        wallet: visibleWallets[i],
                        isEnabled: false,
                      ),
                    ),
                  ),
                ],
                if (showHiddenTile) ...[
                  if (visibleWallets.isNotEmpty)
                    const SizedBox(width: AppSizing.spaceBtwItems),
                  SizedBox(
                    width: narrowW,
                    child: GestureDetector(
                      onTap: onHiddenCardsSelected,
                      child: _HiddenCardsPlaceholder(
                        count: hiddenWallets.length,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HiddenCardsPlaceholder extends StatelessWidget {
  const _HiddenCardsPlaceholder({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSizing.defaultPadding),
      decoration: BoxDecoration(
        color: colorScheme.secondary,
        borderRadius: BorderRadius.circular(AppSizing.borderRadius16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.visibility_off,
            size: AppSizing.iconSizeS,
            color: colorScheme.onSecondary,
          ),
          const SizedBox(height: AppSizing.spaceBtwItems),
          Text(
            context.l10n.hiddenCards,
            style: AppTextStyles.text20w600(context),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSizing.spaceBtwElements),
          Text(
            '$count ${_pluralize(count, context)}',
            style: AppTextStyles.text16w400(context),
          ),
        ],
      ),
    );
  }

  String _pluralize(int n, BuildContext context) {
    if (n % 10 == 1 && n % 100 != 11) return context.l10n.card;
    if (n % 10 >= 2 && n % 10 <= 4 && (n % 100 < 10 || n % 100 >= 20)) {
      return context.l10n.cards;
    }
    return context.l10n.cards;
  }
}
