import 'package:fn_tracker/features/wallet/wallet.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'wallet_state.dart';

class WalletCubit extends HydratedCubit<WalletsState> {
  final WalletRepoImpl walletRepo;

  WalletCubit({required this.walletRepo}) : super(WalletsInitial());

  @override
  String get storagePrefix => 'WalletCubit';

  @override
  WalletsState? fromJson(Map<String, dynamic> json) {
    final type = json['_type'] as String?;
    return switch (type) {
      'loaded' => WalletsLoaded(
          wallets: (json['wallets'] as List)
              .map((e) => WalletModel.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      'empty' => WalletsEmpty(),
      _ => null,
    };
  }

  @override
  Map<String, dynamic>? toJson(WalletsState state) {
    if (state is WalletsLoading ||
        state is WalletsInitial ||
        state is WalletsError) {
      return null; // Do not persist — keep previous cached state
    }
    if (state is WalletsEmpty) return {'_type': 'empty'};
    if (state is WalletsLoaded) {
      return {
        '_type': 'loaded',
        'wallets': state.wallets.map((w) => w.toJson()).toList(),
      };
    }
    return null;
  }

  void clearForLogout() => emit(WalletsInitial());

  Future<void> loadWallets() async {
    emit(WalletsLoading());
    final wallets = await walletRepo.getWallets();
    if (wallets.isEmpty) {
      emit(WalletsEmpty());
    } else {
      emit(WalletsLoaded(wallets: wallets));
    }
  }

  List<WalletModel> get currentWallets =>
      state is WalletsLoaded ? (state as WalletsLoaded).wallets : [];

  List<WalletModel> get _currentWallets => currentWallets;

  Future<void> addWallet({required WalletModel wallet}) async {
    final previous = _currentWallets;
    emit(WalletsLoading());
    final newWallet = await walletRepo.addWallet(wallet: wallet);
    emit(WalletsLoaded(wallets: [newWallet, ...previous]));
  }

  Future<void> updateWallet({required WalletModel wallet}) async {
    final previous = _currentWallets;
    final wasDefaultAndNowHidden = wallet.isHidden &&
        previous.any((w) => w.id == wallet.id && w.isDefault);
    emit(WalletsLoading());
    var updatedWallet = await walletRepo.updateWallet(wallet: wallet);
    var updatedList = previous.map((w) {
      if (w.id == updatedWallet.id) return updatedWallet;
      if (wallet.isDefault) return w.copyWith(isDefault: false);
      return w;
    }).toList();

    if (wasDefaultAndNowHidden) {
      final firstVisible = updatedList
          .where((w) => !w.isHidden && w.id != updatedWallet.id)
          .firstOrNull;
      if (firstVisible != null) {
        updatedWallet = updatedWallet.copyWith(isDefault: false);
        updatedList = updatedList.map((w) {
          if (w.id == updatedWallet.id) return updatedWallet;
          if (w.id == firstVisible.id) return w.copyWith(isDefault: true);
          return w.copyWith(isDefault: false);
        }).toList();
        await walletRepo.updateWallet(wallet: firstVisible.copyWith(isDefault: true));
      }
    }

    emit(WalletsLoaded(wallets: updatedList));
  }

  Future<void> deleteWallet({required String walletId}) async {
    final previous = _currentWallets;
    final wasDefault = previous.any((w) => w.id == walletId && w.isDefault);
    emit(WalletsLoading());
    await walletRepo.deleteWallet(walletId);
    var updatedList = previous.where((w) => w.id != walletId).toList();
    if (wasDefault && updatedList.isNotEmpty) {
      updatedList = [
        updatedList.first.copyWith(isDefault: true),
        ...updatedList.skip(1),
      ];
    }
    if (updatedList.isEmpty) {
      emit(WalletsEmpty());
    } else {
      emit(WalletsLoaded(wallets: updatedList));
    }
  }
}
