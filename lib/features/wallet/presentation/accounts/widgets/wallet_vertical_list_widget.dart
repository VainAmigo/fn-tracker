import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

class WalletVerticalListWidget extends StatefulWidget {
  const WalletVerticalListWidget({
    super.key,
    this.onWalletSelected,
    this.cardStyle = CategoryCardStyle.filled,
    this.shrinkWrap = false,
    this.autoLoad = false,
  });

  final ValueChanged<WalletModel>? onWalletSelected;
  final CategoryCardStyle cardStyle;
  final bool shrinkWrap;
  final bool autoLoad;

  @override
  State<WalletVerticalListWidget> createState() =>
      _WalletVerticalListWidgetState();
}

class _WalletVerticalListWidgetState extends State<WalletVerticalListWidget> {
  @override
  void initState() {
    super.initState();
    if (widget.autoLoad) {
      context.read<WalletCubit>().loadWallets();
    }
  }

  CategoryCardRadius _radiusForIndex(int index, int total) {
    if (total == 1) return CategoryCardRadius.single;
    if (index == 0) return CategoryCardRadius.first;
    if (index == total - 1) return CategoryCardRadius.last;
    return CategoryCardRadius.middle;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletCubit, WalletsState>(
      builder: (context, state) {
        if (state is WalletsLoading || state is WalletsInitial) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is WalletsError) {
          return Center(
            child: Text(state.message, textAlign: TextAlign.center),
          );
        }

        final wallets = switch (state) {
          WalletsLoaded s => s.wallets,
          WalletsEmpty() => const <WalletModel>[],
          _ => const <WalletModel>[],
        };

        if (wallets.isEmpty) {
          return const Center(child: Text('Кошельков пока нет'));
        }

        final total = wallets.length + 1;

        return ListView.separated(
          shrinkWrap: widget.shrinkWrap,
          physics:
              widget.shrinkWrap ? const NeverScrollableScrollPhysics() : null,
          itemCount: total,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppSizing.spaceBtwItemsExtra),
          itemBuilder: (context, index) {
            if (index == wallets.length) {
              final colorScheme = Theme.of(context).colorScheme;
              return CategoryCard(
                title: 'New wallet',
                leading: Container(
                  height: AppSizing.heightS,
                  decoration: BoxDecoration(
                    color: colorScheme.onSecondary.withValues(alpha: 0.15),
                    borderRadius:
                        BorderRadius.circular(AppSizing.borderRadius8),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Icon(
                      Icons.add_rounded,
                      size: AppSizing.iconSizeM,
                      color: colorScheme.onSecondary,
                    ),
                  ),
                ),
                style: widget.cardStyle,
                radius: _radiusForIndex(index, total),
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRouter.createWallet),
              );
            }

            final wallet = wallets[index];
            final shade = findShadeById(wallet.colorId);
            final icon = findIconById(wallet.iconId);
            final color = shade?.color ?? Colors.grey;

            return CategoryCard(
              title: wallet.name,
              subtitle: wallet.balance?.toString(),
              leading: Container(
                height: AppSizing.heightS,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius:
                      BorderRadius.circular(AppSizing.borderRadius8),
                ),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Icon(
                    icon?.icon ?? Icons.account_balance_wallet,
                    size: AppSizing.iconSizeM,
                    color: color,
                  ),
                ),
              ),
              style: widget.cardStyle,
              radius: _radiusForIndex(index, total),
              onTap: widget.onWalletSelected != null
                  ? () => widget.onWalletSelected!(wallet)
                  : null,
            );
          },
        );
      },
    );
  }
}
