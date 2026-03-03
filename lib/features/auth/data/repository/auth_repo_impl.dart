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
}
