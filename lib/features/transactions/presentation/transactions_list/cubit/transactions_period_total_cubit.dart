import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/features/features.dart';

part 'transactions_period_total_state.dart';

class TransactionsPeriodTotalCubit extends Cubit<TransactionsPeriodTotalState> {
  final TransactionsRepoImpl transactionsRepo;

  TransactionsPeriodTotalCubit({required this.transactionsRepo})
    : super(TransactionsPeriodTotalInitial());

  Future<void> getTotalForPeriod(DateTime start, DateTime end) async {
    emit(TransactionsPeriodTotalLoading());
    try {
      final total = await transactionsRepo.getTotalForPeriod(start, end);
      emit(TransactionsPeriodTotalLoaded(total: total));
    } catch (e) {
      emit(TransactionsPeriodTotalError(message: e.toString()));
    }
  }
}
