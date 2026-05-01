import 'package:firebase_auth/firebase_auth.dart';
import 'package:fn_tracker/features/auth/auth.dart';

abstract class AuthRepoImpl {
  Future<AppUser?> loginWithEmailPassword(String email, String password);

  Future<AppUser?> registerWithEmailPassword(String email, String password);

  Future<void> logout();

  Future<AppUser?> getCurrentUser();

  Future<void> reauthenticateAndChangePassword(
    String currentPassword,
    String newPassword,
  );

  Future<GoogleSignInOutcome> signInWithGoogle();

  Future<GoogleLinkOutcome> linkGoogleAccount();

  /// Обновляет отображаемое имя в Firebase Auth и в `users/{uid}`.
  Future<AppUser> updateDisplayName(String displayName);

  /// Удаляет все данные пользователя в Firestore, профиль `users/{uid}` сохраняется.
  Future<void> deleteAllUserData();

  /// Удаляет аккаунт и данные. Требуется пароль [emailPassword] или [googleCredential].
  Future<void> deleteAccount({
    String? emailPassword,
    OAuthCredential? googleCredential,
  });

  /// Для повторной аутентификации перед удалением аккаунта (Google).
  Future<OAuthCredential?> obtainGoogleReauthCredential();
}
