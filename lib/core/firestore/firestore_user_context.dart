import 'package:firebase_auth/firebase_auth.dart';

/// Mixin для репозиториев, работающих с Firestore.
/// Предоставляет единый метод получения UID аутентифицированного пользователя.
mixin FirestoreUserContext {
  FirebaseAuth get firebaseAuth;

  /// Возвращает UID текущего пользователя.
  /// Бросает [Exception] если пользователь не аутентифицирован.
  String requireUid() {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('User is not authenticated');
    }
    return user.uid;
  }
}
