import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/auth/auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthRepo implements AuthRepoImpl {
  FirebaseAuthRepo({GoogleSignInFacade? googleSignIn})
      : _googleSignIn = googleSignIn ?? GoogleSignInFacade();

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final GoogleSignInFacade _googleSignIn;

  @override
  Future<AppUser?> loginWithEmailPassword(String email, String password) async {
    return FirebaseLogger.mutation<AppUser?>(
      operation: 'Auth.login',
      collection: 'auth',
      data: {'email': email},
      fn: () async {
        final userCredential = await firebaseAuth
            .signInWithEmailAndPassword(email: email, password: password);
        final uid = userCredential.user!.uid;
        final ref = firebaseFirestore.collection('users').doc(uid);
        final snap = await ref.get();
        final authName = userCredential.user!.displayName;
        if (snap.exists) {
          final data = snap.data()!;
          return AppUser(
            uid: uid,
            email: email,
            displayName: data['displayName'] as String? ?? authName,
          );
        }
        return AppUser(uid: uid, email: email, displayName: authName);
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
      fn: () async {
        await _googleSignIn.signOut();
        await firebaseAuth.signOut();
      },
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
        final ref = firebaseFirestore.collection('users').doc(firebaseUser.uid);
        var userDoc = await ref.get();
        final email = firebaseUser.email;
        if (!userDoc.exists) {
          if (email == null || email.isEmpty) return null;
          final created = AppUser(
            uid: firebaseUser.uid,
            email: email,
            displayName: firebaseUser.displayName,
          );
          await ref.set(created.toJson());
          return created;
        }
        final data = userDoc.data()!;
        return AppUser(
          uid: firebaseUser.uid,
          email: data['email'] as String? ?? email ?? '',
          displayName:
              data['displayName'] as String? ?? firebaseUser.displayName,
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

  @override
  Future<GoogleSignInOutcome> signInWithGoogle() async {
    return FirebaseLogger.mutation<GoogleSignInOutcome>(
      operation: 'Auth.signInGoogle',
      collection: 'auth',
      fn: () async {
        try {
          final credential = await _googleSignIn.obtainCredential();
          if (credential == null) {
            return const GoogleSignInCancelled();
          }
          try {
            final userCredential =
                await firebaseAuth.signInWithCredential(credential);
            final fu = userCredential.user!;
            final synced = await _syncFirestoreUser(fu);
            return GoogleSignInSuccess(
              user: synced.user,
              isNewProfile: synced.isNew,
            );
          } on FirebaseAuthException catch (e) {
            return GoogleSignInFailure(
              firebaseCode: e.code,
              debugMessage: e.message,
            );
          }
        } on GoogleSignInException catch (e) {
          return GoogleSignInFailure(
            firebaseCode: 'google-sign-in',
            debugMessage: e.description ?? e.toString(),
          );
        } on StateError catch (e) {
          return GoogleSignInFailure(debugMessage: e.message);
        } catch (e) {
          return GoogleSignInFailure(debugMessage: e.toString());
        }
      },
      serialize: (o) => switch (o) {
        GoogleSignInSuccess(:final user) => {'uid': user.uid},
        GoogleSignInFailure(:final firebaseCode) => {
            'code': firebaseCode ?? 'unknown',
          },
        GoogleSignInCancelled() => {'cancelled': true},
      },
    );
  }

  @override
  Future<GoogleLinkOutcome> linkGoogleAccount() async {
    return FirebaseLogger.mutation<GoogleLinkOutcome>(
      operation: 'Auth.linkGoogle',
      collection: 'auth',
      fn: () async {
        try {
          final user = firebaseAuth.currentUser;
          if (user == null) {
            return const GoogleLinkFailure(firebaseCode: 'no-current-user');
          }
          final credential = await _googleSignIn.obtainCredential();
          if (credential == null) {
            return const GoogleLinkCancelled();
          }
          try {
            await user.linkWithCredential(credential);
            await user.reload();
            final synced = firebaseAuth.currentUser;
            if (synced != null) {
              await _mergeAuthDisplayNameIntoFirestoreIfEmpty(synced);
            }
            return const GoogleLinkSuccess();
          } on FirebaseAuthException catch (e) {
            return GoogleLinkFailure(
              firebaseCode: e.code,
              debugMessage: e.message,
            );
          }
        } on GoogleSignInException catch (e) {
          return GoogleLinkFailure(
            firebaseCode: 'google-sign-in',
            debugMessage: e.description ?? e.toString(),
          );
        } on StateError catch (e) {
          return GoogleLinkFailure(debugMessage: e.message);
        } catch (e) {
          return GoogleLinkFailure(debugMessage: e.toString());
        }
      },
      serialize: (o) => switch (o) {
        GoogleLinkSuccess() => {'linked': true},
        GoogleLinkFailure(:final firebaseCode) => {
            'code': firebaseCode ?? 'unknown',
          },
        GoogleLinkCancelled() => {'cancelled': true},
      },
    );
  }

  Future<({AppUser user, bool isNew})> _syncFirestoreUser(User u) async {
    final ref = firebaseFirestore.collection('users').doc(u.uid);
    final snap = await ref.get();
    final email = u.email;
    if (email == null || email.isEmpty) {
      throw FirebaseAuthException(
        code: 'invalid-email',
        message: 'Google account has no email',
      );
    }
    if (!snap.exists) {
      final created = AppUser(
        uid: u.uid,
        email: email,
        displayName: u.displayName,
      );
      await ref.set(created.toJson());
      return (user: created, isNew: true);
    }
    final data = snap.data()!;
    final storedName = data['displayName'] as String?;
    final authName = u.displayName;
    if ((storedName == null || storedName.trim().isEmpty) &&
        authName != null &&
        authName.trim().isNotEmpty) {
      await ref.update({'displayName': authName.trim()});
      final merged = AppUser(
        uid: u.uid,
        email: data['email'] as String? ?? email,
        displayName: authName.trim(),
      );
      return (user: merged, isNew: false);
    }
    final existing = AppUser(
      uid: u.uid,
      email: data['email'] as String? ?? email,
      displayName: (storedName != null && storedName.trim().isNotEmpty)
          ? storedName.trim()
          : authName?.trim(),
    );
    return (user: existing, isNew: false);
  }

  Future<void> _mergeAuthDisplayNameIntoFirestoreIfEmpty(User u) async {
    final authName = u.displayName?.trim();
    if (authName == null || authName.isEmpty) return;
    final ref = firebaseFirestore.collection('users').doc(u.uid);
    final snap = await ref.get();
    if (!snap.exists) return;
    final stored = snap.data()!['displayName'] as String?;
    if (stored != null && stored.trim().isNotEmpty) return;
    await ref.update({'displayName': authName});
  }

  @override
  Future<AppUser> updateDisplayName(String displayName) async {
    return FirebaseLogger.mutation<AppUser>(
      operation: 'Auth.updateDisplayName',
      collection: 'users',
      fn: () async {
        final user = firebaseAuth.currentUser;
        if (user == null) {
          throw Exception('User not logged in');
        }
        final trimmed = displayName.trim();
        await user.updateDisplayName(trimmed.isEmpty ? null : trimmed);
        await user.reload();
        final email = user.email;
        if (email == null || email.isEmpty) {
          throw Exception('User email missing');
        }
        final ref = firebaseFirestore.collection('users').doc(user.uid);
        final appUser = AppUser(
          uid: user.uid,
          email: email,
          displayName: trimmed.isEmpty ? null : trimmed,
        );
        await ref.set(appUser.toJson(), SetOptions(merge: true));
        return appUser;
      },
      serialize: (u) => {'uid': u.uid, 'displayName': u.displayName},
    );
  }

  @override
  Future<void> deleteAllUserData() async {
    return FirebaseLogger.mutation<void>(
      operation: 'Auth.deleteAllUserData',
      collection: 'users',
      fn: () async {
        final user = firebaseAuth.currentUser;
        if (user == null) {
          throw StateError('User not logged in');
        }
        final uid = user.uid;
        final ref = firebaseFirestore.collection('users').doc(uid);
        final prev = await ref.get();
        final email = prev.data()?['email'] as String? ?? user.email ?? '';
        final displayName =
            prev.data()?['displayName'] as String? ?? user.displayName;

        await UserFirestoreCleanup(firebaseFirestore).wipeAllSubcollections(
          uid,
        );

        await ref.set(
          {
            'uid': uid,
            'email': email,
            if (displayName != null && displayName.trim().isNotEmpty)
              'displayName': displayName.trim(),
          },
          SetOptions(merge: false),
        );
      },
    );
  }

  @override
  Future<void> deleteAccount({
    String? emailPassword,
    OAuthCredential? googleCredential,
  }) async {
    return FirebaseLogger.mutation<void>(
      operation: 'Auth.deleteAccount',
      collection: 'auth',
      fn: () async {
        final user = firebaseAuth.currentUser;
        if (user == null) {
          throw StateError('User not logged in');
        }
        final email = user.email;
        final hasPassword = user.providerData.any(
          (p) => p.providerId == EmailAuthProvider.PROVIDER_ID,
        );

        late AuthCredential credential;
        if (hasPassword) {
          if (email == null ||
              emailPassword == null ||
              emailPassword.isEmpty) {
            throw ArgumentError('Password required');
          }
          credential = EmailAuthProvider.credential(
            email: email,
            password: emailPassword,
          );
        } else {
          if (googleCredential == null) {
            throw ArgumentError('Google credential required');
          }
          credential = googleCredential;
        }

        await user.reauthenticateWithCredential(credential);
        final uid = user.uid;
        await UserFirestoreCleanup(firebaseFirestore).wipeAllSubcollections(
          uid,
        );
        await firebaseFirestore.collection('users').doc(uid).delete();
        await _googleSignIn.signOut();
        await user.delete();
      },
    );
  }

  @override
  Future<OAuthCredential?> obtainGoogleReauthCredential() async {
    return _googleSignIn.obtainCredential();
  }
}
