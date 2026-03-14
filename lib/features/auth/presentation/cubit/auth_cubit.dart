import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/auth/auth.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'auth_state.dart';

class AuthCubit extends HydratedCubit<AuthState> {
  final AuthRepoImpl authRepo;
  final DefaultDataSeeder? dataSeeder;
  AppUser? _currentUser;

  AuthCubit({required this.authRepo, this.dataSeeder}) : super(AuthInitial());

  @override
  String get storagePrefix => 'AuthCubit';

  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    final type = json['_type'] as String?;
    return switch (type) {
      'authenticated' => Authenticated(
          AppUser.fromJson(json['user'] as Map<String, dynamic>),
        ),
      'unauthenticated' => Unauthenticated(),
      _ => null,
    };
  }

  @override
  Map<String, dynamic>? toJson(AuthState state) {
    if (state is AuthLoading ||
        state is AuthInitial ||
        state is AuthError ||
        state is AuthPasswordChanged) {
      return null; // Do not persist — keep previous cached state
    }
    if (state is Authenticated) {
      return {'_type': 'authenticated', 'user': state.user.toJson()};
    }
    if (state is Unauthenticated) return {'_type': 'unauthenticated'};
    return null;
  }

  // check if user is already authenticated
  void checkAuth() async {
    final AppUser? user = await authRepo.getCurrentUser();

    if (user != null) {
      _currentUser = user;
      emit(Authenticated(user));
    } else {
      emit(Unauthenticated());
    }
  }

  // get current user (from state when Authenticated, supports cache restore)
  AppUser? get currentUser =>
      state is Authenticated ? (state as Authenticated).user : _currentUser;

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

  Future<void> register(String email, String password) async {
    try {
      emit(AuthLoading());
      final user = await authRepo.registerWithEmailPassword(email, password);

      if (user != null) {
        _currentUser = user;
        await dataSeeder?.seed();
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
    await authRepo.logout();
    _currentUser = null;
    emit(Unauthenticated());
  }

  // change password
  void reauthenticateAndChangePassword(
    String currentPassword,
    String newPassword,
  ) async {
    emit(AuthLoading());
    try {
      await authRepo.reauthenticateAndChangePassword(
        currentPassword,
        newPassword,
      );
      emit(AuthPasswordChanged());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
