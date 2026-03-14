import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/features/features.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final TransactionsRepository transactionsRepo;

  HomeCubit({required this.transactionsRepo}) : super(HomeInitial());

  Future<void> getHomePageStats({
    required String startDayKey,
    required String endDayKey,
  }) async {
    try {
      emit(HomeLoading());
      final homePageStat = await transactionsRepo.getHomePageStats(
        startDayKey: startDayKey,
        endDayKey: endDayKey,
      );
      emit(HomeLoaded(homePageStat: homePageStat));
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }
}
