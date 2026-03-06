part of 'home_cubit.dart';

sealed class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final HomePageStatModel homePageStat;

  HomeLoaded({required this.homePageStat});
}

class HomeError extends HomeState {
  final String message;

  HomeError({required this.message});
}
