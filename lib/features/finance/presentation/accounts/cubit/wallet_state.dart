part of 'wallet_cubit.dart';

sealed class WalletsState {}

class WalletsInitial extends WalletsState {}

class WalletsLoading extends WalletsState {}

class WalletsEmpty extends WalletsState {}

class WalletsLoaded extends WalletsState {
  final List<WalletModel> wallets;

  WalletsLoaded({required this.wallets});
}

class WalletsError extends WalletsState {
  final String message;

  WalletsError({required this.message});
}