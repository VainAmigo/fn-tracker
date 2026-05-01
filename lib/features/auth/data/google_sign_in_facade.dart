import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Получение [OAuthCredential] для Firebase через Google Sign-In 7.x ([authenticate]).
final class GoogleSignInFacade {
  /// Возвращает учётные данные для Firebase, либо `null` при отмене пользователем.
  Future<OAuthCredential?> obtainCredential() async {
    try {
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw StateError(
          'Google Sign-In: нет idToken. '
          'Добавьте OAuth client в Firebase Console (SHA-1 для Android, URL scheme для iOS).',
        );
      }
      return GoogleAuthProvider.credential(
        accessToken: null,
        idToken: idToken,
      );
    } on GoogleSignInException catch (e) {
      switch (e.code) {
        case GoogleSignInExceptionCode.canceled:
        case GoogleSignInExceptionCode.interrupted:
        case GoogleSignInExceptionCode.uiUnavailable:
          return null;
        case GoogleSignInExceptionCode.unknownError:
        case GoogleSignInExceptionCode.clientConfigurationError:
        case GoogleSignInExceptionCode.providerConfigurationError:
        case GoogleSignInExceptionCode.userMismatch:
          rethrow;
      }
    }
  }

  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
  }
}
