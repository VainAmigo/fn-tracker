import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

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
    final width = MediaQuery.of(context).size.width * 0.7;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = 0; i < wallets.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSizing.spaceBtwItems),
              SizedBox(
                width: width,
                child: GestureDetector(
                  onTap: () => Navigator.of(
                    context,
                  ).pushNamed(AppRouter.updateWallet, arguments: wallets[i]),
                  child: WalletCardWidget(wallet: wallets[i]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
