import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/auth/auth.dart';

class FirebaseAuthRepo implements AuthRepoImpl {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<AppUser?> loginWithEmailPassword(String email, String password) async {
    return FirebaseLogger.mutation<AppUser?>(
      operation: 'Auth.login',
      collection: 'auth',
      data: {'email': email},
      fn: () async {
        final userCredential = await firebaseAuth
            .signInWithEmailAndPassword(email: email, password: password);
        return AppUser(uid: userCredential.user!.uid, email: email);
      },
      serialize: (u) => u != null
          ? {'uid': u.uid, 'email': u.email}
          : {'result': 'null'},
    );
  }

  @override
  Future<AppUser?> registerWithEmailPassword(
    String email,
    String password,
  ) async {
    return FirebaseLogger.mutation<AppUser?>(
      operation: 'Auth.register',
      collection: 'auth + users',
      data: {'email': email},
      fn: () async {
        final userCredential = await firebaseAuth
            .createUserWithEmailAndPassword(email: email, password: password);
        final user = AppUser(uid: userCredential.user!.uid, email: email);
        await firebaseFirestore
            .collection('users')
            .doc(user.uid)
            .set(user.toJson());
        return user;
      },
      serialize: (u) => u != null
          ? {'uid': u.uid, 'email': u.email}
          : {'result': 'null'},
    );
  }

  @override
  Future<void> logout() async {
    return FirebaseLogger.mutation<void>(
      operation: 'Auth.logout',
      collection: 'auth',
      fn: () => firebaseAuth.signOut(),
    );
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    return FirebaseLogger.query<AppUser?>(
      operation: 'Auth.getCurrentUser',
      collection: 'users',
      fn: () async {
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
      serialize: (u) => u != null
          ? {'uid': u.uid, 'email': u.email}
          : {'result': 'null'},
    );
  }

  @override
  Future<void> reauthenticateAndChangePassword(
    String currentPassword,
    String newPassword,
  ) async {
    return FirebaseLogger.mutation<void>(
      operation: 'Auth.changePassword',
      collection: 'auth',
      fn: () async {
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
    );
  }
}
