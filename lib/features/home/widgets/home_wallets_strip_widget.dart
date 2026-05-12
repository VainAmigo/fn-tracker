import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/features/features.dart';

/// Горизонтальный список кошельков на главной с учётом [HomeWalletsSettingsCubit].
class HomeWalletsStripWidget extends StatelessWidget {
  const HomeWalletsStripWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeWalletsSettingsCubit, HomeWalletsSettingsState>(
      builder: (context, settings) {
        return WalletsListWidget(
          autoLoad: true,
          hiddenFromHomeIds: settings.hiddenFromHomeIds,
          onWalletSelected: (wallet) =>
              WalletSheetFlow.openWalletDetails(context, wallet),
          onHiddenCardsSelected: () =>
              WalletSheetFlow.openHiddenWallets(context),
        );
      },
    );
  }
}
