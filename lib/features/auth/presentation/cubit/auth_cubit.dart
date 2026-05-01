import 'package:firebase_auth/firebase_auth.dart';
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
        state is AuthError) {
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

  /// Смена пароля (email/password). Не эмитит [AuthLoading], чтобы не закрывать главный экран.
  /// При успехе возвращает `null`. При ошибке — текст ошибки (состояние снова [Authenticated]).
  Future<GoogleSignInOutcome> signInWithGoogle() async {
    emit(AuthLoading());
    try {
      final outcome = await authRepo.signInWithGoogle();
      switch (outcome) {
        case GoogleSignInSuccess(:final user, :final isNewProfile):
          _currentUser = user;
          if (isNewProfile) {
            await dataSeeder?.seed();
          }
          emit(Authenticated(user));
        case GoogleSignInCancelled():
          emit(Unauthenticated());
        case GoogleSignInFailure():
          emit(Unauthenticated());
      }
      return outcome;
    } catch (e) {
      emit(Unauthenticated());
      return GoogleSignInFailure(debugMessage: e.toString());
    }
  }

  Future<GoogleLinkOutcome> linkGoogleAccount() async {
    try {
      return await authRepo.linkGoogleAccount();
    } catch (e) {
      return GoogleLinkFailure(debugMessage: e.toString());
    }
  }

  /// Подтянуть профиль из Firestore / Auth (например, после привязки Google).
  Future<void> refreshProfile() async {
    final u = await authRepo.getCurrentUser();
    if (u != null) {
      _currentUser = u;
      emit(Authenticated(u));
    }
  }

  Future<String?> deleteAllUserData() async {
    try {
      await authRepo.deleteAllUserData();
      final u = await authRepo.getCurrentUser();
      if (u != null) {
        _currentUser = u;
        emit(Authenticated(u));
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<OAuthCredential?> obtainGoogleReauthCredential() async {
    try {
      return await authRepo.obtainGoogleReauthCredential();
    } catch (_) {
      return null;
    }
  }

  Future<String?> deleteAccount({
    String? emailPassword,
    OAuthCredential? googleCredential,
  }) async {
    try {
      await authRepo.deleteAccount(
        emailPassword: emailPassword,
        googleCredential: googleCredential,
      );
      _currentUser = null;
      emit(Unauthenticated());
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Обновляет имя профиля. При успехе — `null`, иначе текст ошибки.
  Future<String?> updateDisplayName(String displayName) async {
    try {
      final updated = await authRepo.updateDisplayName(displayName);
      _currentUser = updated;
      emit(Authenticated(updated));
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> reauthenticateAndChangePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final userBefore = _currentUser;
    if (userBefore == null) return 'User not authenticated';
    try {
      await authRepo.reauthenticateAndChangePassword(
        currentPassword,
        newPassword,
      );
      emit(Authenticated(userBefore));
      return null;
    } catch (e) {
      final message = e.toString();
      emit(AuthError(message));
      emit(Authenticated(userBefore));
      return message;
    }
  }
}
