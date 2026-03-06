import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/features/features.dart';

part 'budget_state.dart';

class BudgetCubit extends Cubit<BudgetState> {
  final WalletRepoImpl walletRepo;

  BudgetCubit({required this.walletRepo}) : super(BudgetInitial());

  Future<void> getBudget() async {
    emit(BudgetLoading());
    try {
      final budget = await walletRepo.getBudget();
      if (budget == null) {
        emit(BudgetNotFound());
      } else {
        emit(BudgetLoaded(budget));
      }
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> createBudget({required BudgetModel budget}) async {
    emit(BudgetLoading());
    try {
      final newBudget = await walletRepo.createBudget(budget: budget);
      emit(BudgetLoaded(newBudget));
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> updateBudget({required BudgetModel budget}) async {
    emit(BudgetLoading());
    try {
      final updatedBudget = await walletRepo.updateBudget(budget: budget);
      emit(BudgetLoaded(updatedBudget));
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> deleteBudget(String id) async {
    emit(BudgetLoading());
    try {
      await walletRepo.deleteBudget(id);
      emit(BudgetInitial());
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }
}
