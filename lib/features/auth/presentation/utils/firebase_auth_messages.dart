import 'package:firebase_auth/firebase_auth.dart';
import 'package:fn_tracker/l10n/generated/app_localizations.dart';

/// Сообщение для SnackBar по коду Firebase и необязательному тексту от SDK.
String firebaseAuthMessage(
  AppLocalizations l10n,
  String? code,
  String? details,
) {
  final extra = details?.trim();

  return switch (code) {
    'account-exists-with-different-credential' =>
      l10n.authErrorAccountExistsWithDifferentCredential,
    'credential-already-in-use' => l10n.authErrorCredentialAlreadyInUse,
    'provider-already-linked' => l10n.authErrorProviderAlreadyLinked,
    'requires-recent-login' => l10n.authErrorRequiresRecentLogin,
    'invalid-credential' => l10n.authErrorInvalidCredential,
    'user-disabled' => l10n.authErrorUserDisabled,
    'network-request-failed' => l10n.authErrorNetwork,
    'no-current-user' => l10n.authErrorNotSignedIn,
    'google-sign-in' => extra ?? l10n.authErrorGoogleSignIn,
    null || '' => l10n.authErrorGeneric,
    _ => extra ?? l10n.authErrorGeneric,
  };
}

String firebaseAuthMessageFromError(AppLocalizations l10n, Object error) {
  if (error is FirebaseAuthException) {
    return firebaseAuthMessage(l10n, error.code, error.message);
  }
  return error.toString();
}
