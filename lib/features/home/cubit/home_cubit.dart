import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/features/features.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final TransactionsRepoImpl transactionsRepo;

  HomeCubit({required this.transactionsRepo}) : super(HomeInitial());

  Future<void> getHomePageStats({
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      emit(HomeLoading());
      final homePageStat = await transactionsRepo.getHomePageStats(
        start: start,
        end: end,
      );
      emit(HomeLoaded(homePageStat: homePageStat));
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }
}
