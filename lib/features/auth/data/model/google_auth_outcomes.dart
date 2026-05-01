import 'package:flutter/foundation.dart';
import 'package:fn_tracker/features/auth/data/model/auth_model.dart';

@immutable
sealed class GoogleSignInOutcome {
  const GoogleSignInOutcome();
}

/// Пользователь закрыл окно выбора аккаунта Google.
class GoogleSignInCancelled extends GoogleSignInOutcome {
  const GoogleSignInCancelled();
}

class GoogleSignInFailure extends GoogleSignInOutcome {
  const GoogleSignInFailure({this.firebaseCode, this.debugMessage});

  final String? firebaseCode;
  final String? debugMessage;
}

class GoogleSignInSuccess extends GoogleSignInOutcome {
  const GoogleSignInSuccess({
    required this.user,
    required this.isNewProfile,
  });

  final AppUser user;
  final bool isNewProfile;
}

@immutable
sealed class GoogleLinkOutcome {
  const GoogleLinkOutcome();
}

class GoogleLinkCancelled extends GoogleLinkOutcome {
  const GoogleLinkCancelled();
}

class GoogleLinkFailure extends GoogleLinkOutcome {
  const GoogleLinkFailure({this.firebaseCode, this.debugMessage});

  final String? firebaseCode;
  final String? debugMessage;
}

class GoogleLinkSuccess extends GoogleLinkOutcome {
  const GoogleLinkSuccess();
}
