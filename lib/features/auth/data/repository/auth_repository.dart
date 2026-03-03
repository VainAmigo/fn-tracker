import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fn_tracker/features/auth/auth.dart';

class FirebaseAuthRepo implements AuthRepoImpl {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<AppUser?> loginWithEmailPassword(String email, String password) async {
    try {
      //   attempt sign in
      UserCredential userCredential = await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);

      // fetch user document from firestore
      DocumentSnapshot userDoc = await firebaseFirestore.collection('users').doc(userCredential.user!.uid).get();

      //   create user
      AppUser user = AppUser(uid: userCredential.user!.uid, email: email);

      //   return user
      return user;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<AppUser?> registerWithEmailPassword(String email, String password) async {
    try {
      //   attempt sign up
      UserCredential userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      //   create user
      AppUser user = AppUser(uid: userCredential.user!.uid, email: email);

      //save user data in firestore
      await firebaseFirestore.collection("users").doc(user.uid).set(user.toJson());

      //   return user
      return user;
    } catch (e) {
      throw Exception('Register failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    //   get current user
    final firebaseUser = firebaseAuth.currentUser;

    if (firebaseUser == null) {
      return null;
    }

    // fetch user document from firestore
    DocumentSnapshot userDoc = await firebaseFirestore.collection('users').doc(firebaseUser.uid).get();

    // check if user doc exists
    if (!userDoc.exists) {
      return null;
    }

    return AppUser(uid: firebaseUser.uid, email: firebaseUser.email!);
  }

  // change password
  @override
  Future<void> reauthenticateAndChangePassword(String currentPassword, String newPassword) async {
    final user = firebaseAuth.currentUser;
    if (user == null || user.email == null) {
      throw Exception("User not logged in or email is null");
    }

    final credential = EmailAuthProvider.credential(email: user.email!, password: currentPassword);

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }
}
