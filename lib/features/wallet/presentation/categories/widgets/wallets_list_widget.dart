import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

const _cardWidth = 160.0;
const _cardHeight = 100.0;

class WalletsListWidget extends StatefulWidget {
  const WalletsListWidget({super.key, this.autoLoad = false});

  final bool autoLoad;

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
          WalletsEmpty() => _Body(wallets: const []),
          WalletsLoaded() => _Body(wallets: state.wallets),
          WalletsError() => Center(child: Text(state.message)),
        };
      },
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.wallets});

  final List<WalletModel> wallets;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final totalCount = wallets.length + 1;

    return SizedBox(
      height: _cardHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: totalCount,
        separatorBuilder: (_, _) =>
            const SizedBox(width: AppSizing.spaceBtwItems),
        itemBuilder: (context, index) {
          if (index < wallets.length) {
            return SizedBox(
              width: _cardWidth,
              child: WalletCardWidget(wallet: wallets[index]),
            );
          }
          return SizedBox(
            width: _cardWidth,
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.secondary,
                borderRadius: BorderRadius.circular(AppSizing.borderRadius16),
                border: Border.all(
                  color: colorScheme.onSecondary.withValues(alpha: 0.3),
                ),
              ),
              child: Icon(
                Icons.add_rounded,
                size: AppSizing.iconSizeL,
                color: colorScheme.onSecondary,
              ),
            ),
          );
        },
      ),
    );
  }
}
