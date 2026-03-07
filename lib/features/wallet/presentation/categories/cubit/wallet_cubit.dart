import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/features/wallet/wallet.dart';

part 'wallet_state.dart';

class WalletCubit extends Cubit<WalletsState> {
  final WalletRepoImpl walletRepo;

  WalletCubit({required this.walletRepo}) : super(WalletsInitial());

  Future<void> loadWallets() async {
    emit(WalletsLoading());
    final wallets = await walletRepo.getWallets();
    if (wallets.isEmpty) {
      emit(WalletsEmpty());
    } else {
      emit(WalletsLoaded(wallets: wallets));
    }
  }

  Future<void> addWallet({required WalletModel wallet}) async {
    emit(WalletsLoading());
    final newWallet = await walletRepo.addWallet(wallet: wallet);
    emit(
      WalletsLoaded(
        wallets: [
          newWallet,
          ...(state is WalletsLoaded ? (state as WalletsLoaded).wallets : []),
        ],
      ),
    );
  }

  Future<void> updateWallet({required WalletModel wallet}) async {
    emit(WalletsLoading());
    final updatedWallet = await walletRepo.updateWallet(wallet: wallet);
    emit(
      WalletsLoaded(
        wallets: [
          updatedWallet,
          ...(state is WalletsLoaded ? (state as WalletsLoaded).wallets : []),
        ],
      ),
    );
  }

  Future<void> deleteWallet({required String walletId}) async {
    emit(WalletsLoading());
    await walletRepo.deleteWallet(walletId);
    emit(
      WalletsLoaded(
        wallets:
            (state is WalletsLoaded
                    ? (state as WalletsLoaded).wallets
                    : <WalletModel>[])
                .where((wallet) => wallet.id != walletId)
                .toList(),
      ),
    );
  }
}
