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

  List<WalletModel> get _currentWallets =>
      state is WalletsLoaded ? (state as WalletsLoaded).wallets : [];

  Future<void> addWallet({required WalletModel wallet}) async {
    final previous = _currentWallets;
    emit(WalletsLoading());
    final newWallet = await walletRepo.addWallet(wallet: wallet);
    emit(WalletsLoaded(wallets: [newWallet, ...previous]));
  }

  Future<void> updateWallet({required WalletModel wallet}) async {
    final previous = _currentWallets;
    emit(WalletsLoading());
    final updatedWallet = await walletRepo.updateWallet(wallet: wallet);
    final updatedList = previous
        .map((w) => w.id == updatedWallet.id ? updatedWallet : w)
        .toList();
    emit(WalletsLoaded(wallets: updatedList));
  }

  Future<void> deleteWallet({required String walletId}) async {
    final previous = _currentWallets;
    emit(WalletsLoading());
    await walletRepo.deleteWallet(walletId);
    final updatedList = previous.where((w) => w.id != walletId).toList();
    if (updatedList.isEmpty) {
      emit(WalletsEmpty());
    } else {
      emit(WalletsLoaded(wallets: updatedList));
    }
  }
}
