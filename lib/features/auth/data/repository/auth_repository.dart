import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/auth/auth.dart';

class FirebaseAuthRepo implements AuthRepoImpl {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<AppUser?> loginWithEmailPassword(String email, String password) async {
    return FirebaseLogger.withLogging<AppUser?>(
      'Auth.loginWithEmailPassword',
      {'email': email},
      () async {
        final userCredential = await firebaseAuth
            .signInWithEmailAndPassword(email: email, password: password);
        final user =
            AppUser(uid: userCredential.user!.uid, email: email);
        return user;
      },
      serializeResponse: (u) => u != null
          ? {'uid': u.uid, 'email': u.email}
          : {'result': 'null'},
    ).catchError((e) => throw Exception('Login failed: $e'));
  }

  @override
  Future<AppUser?> registerWithEmailPassword(
    String email,
    String password,
  ) async {
    return FirebaseLogger.withLogging<AppUser?>(
      'Auth.registerWithEmailPassword',
      {'email': email},
      () async {
        final userCredential = await firebaseAuth
            .createUserWithEmailAndPassword(email: email, password: password);
        final user =
            AppUser(uid: userCredential.user!.uid, email: email);
        await firebaseFirestore
            .collection('users')
            .doc(user.uid)
            .set(user.toJson());
        return user;
      },
      serializeResponse: (u) => u != null
          ? {'uid': u.uid, 'email': u.email}
          : {'result': 'null'},
    ).catchError((e) => throw Exception('Register failed: $e'));
  }

  @override
  Future<void> logout() async {
    return FirebaseLogger.withLogging<void>(
      'Auth.logout',
      {},
      () => firebaseAuth.signOut(),
      serializeResponse: (_) => {'ok': true},
    );
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    return FirebaseLogger.withLogging<AppUser?>(
      'Auth.getCurrentUser',
      {},
      () async {
        final firebaseUser = firebaseAuth.currentUser;
        if (firebaseUser == null) return null;

        final userDoc = await firebaseFirestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        if (!userDoc.exists) return null;
        return AppUser(
          uid: firebaseUser.uid,
          email: firebaseUser.email!,
        );
      },
      serializeResponse: (u) =>
          u != null ? {'uid': u.uid, 'email': u.email} : {'result': 'null'},
    );
  }

  @override
  Future<void> reauthenticateAndChangePassword(
    String currentPassword,
    String newPassword,
  ) async {
    return FirebaseLogger.withLogging<void>(
      'Auth.reauthenticateAndChangePassword',
      {},
      () async {
        final user = firebaseAuth.currentUser;
        if (user == null || user.email == null) {
          throw Exception('User not logged in or email is null');
        }
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPassword);
      },
      serializeResponse: (_) => {'ok': true},
    );
  }
}
