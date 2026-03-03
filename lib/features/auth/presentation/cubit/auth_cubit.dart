import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/features/auth/auth.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepoImpl authRepo;
  AppUser? _currentUser;

  AuthCubit({required this.authRepo}): super(AuthInitial());

  // check if user is already authenticated
  void checkAuth() async {
    final AppUser? user = await authRepo.getCurrentUser();

    if(user != null) {
      _currentUser = user;
      emit(Authenticated(user));
    } else {
      emit(Unauthenticated());
    }
  }

  // get current user
  AppUser? get currentUser => _currentUser;

  // login with email an password
  Future<void> login(String email, String password) async {
    try {
      emit(AuthLoading());
      final user = await authRepo.loginWithEmailPassword(email, password);

      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  //   register with email and password
  Future<void> register(String email, String password) async {
    try {
      emit(AuthLoading());
      final user = await authRepo.registerWithEmailPassword(email, password);

      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  //   logout
  Future<void> logout() async {
    authRepo.logout();
    emit(Unauthenticated());
  }


  // change password
  void reauthenticateAndChangePassword(String currentPassword, String newPassword) async {
    emit(AuthLoading());
    try {
      await authRepo.reauthenticateAndChangePassword(currentPassword, newPassword);
      emit(AuthPasswordChanged());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

}