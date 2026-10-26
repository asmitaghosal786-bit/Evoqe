import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/foundation.dart';

import '../data/local_db/account_store.dart';
import '../models/user_profile.dart';

/// Supported social authentication providers.
enum SocialProvider { google, apple }

/// Shared validation rules so screens and services never drift apart.
class Validators {
  static final _emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');

  static bool isValidEmail(String email) =>
      email.trim().isNotEmpty && _emailRegex.hasMatch(email.trim());

  /// Returns an error message, or null if the password is acceptable.
  static String? newPassword(String password) {
    if (password.length < 8 || !password.contains(RegExp(r'\d'))) {
      return 'Password must be at least 8 characters and include a number';
    }
    return null;
  }
}

/// Result of an auth action. [error] == null means success.
class AuthResult {
  final String? error;
  final UserProfile? profile;
  final bool hasCompletedOnboarding;

  const AuthResult.failure(String message)
      : error = message,
        profile = null,
        hasCompletedOnboarding = false;

  const AuthResult.success({
    required UserProfile this.profile,
    required this.hasCompletedOnboarding,
  }) : error = null;

  bool get ok => error == null;
}

// Top-level so they can run in a background isolate via compute().
String _hashPassword(String password) =>
    BCrypt.hashpw(password, BCrypt.gensalt());
bool _checkPassword(List<String> args) => BCrypt.checkpw(args[0], args[1]);

/// Auth actions only. Holds no UI state. Swap the AccountStore calls for
/// API calls when a backend exists.
class AuthService {
  AuthService(this._accounts);

  final AccountStore _accounts;

  static String _normalize(String email) => email.trim().toLowerCase();

  /// Debug-only demo account. Never ships in release builds.
  Future<void> seedDemoAccount() async {
    if (!kDebugMode) return;
    const email = 'demo@evoqe.com';
    if (await _accounts.find(email) != null) return;
    final profile = UserProfile(name: 'Demo User', email: email);
    await _accounts.insert(AccountRecord(
      email: email,
      passwordHash: await compute(_hashPassword, 'Demo1234'),
      profile: profile.toJson(),
      hasCompletedOnboarding: true,
    ));
  }

  Future<bool> accountExists(String email) async =>
      await _accounts.find(_normalize(email)) != null;

  /// Used to restore a session on app start.
  Future<AuthResult?> getSession(String email) async {
    final record = await _accounts.find(_normalize(email));
    return record == null ? null : _toResult(record);
  }

  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final passwordError = Validators.newPassword(password);
    if (passwordError != null) return AuthResult.failure(passwordError);

    final key = _normalize(email);
    final profile = UserProfile(name: name.trim(), email: email.trim());
    final record = AccountRecord(
      email: key,
      passwordHash: await compute(_hashPassword, password),
      profile: profile.toJson(),
    );

    final inserted = await _accounts.insert(record);
    if (!inserted) {
      return const AuthResult.failure(
          'An account with this email already exists.');
    }
    return _toResult(record);
  }

  Future<AuthResult> logIn({
    required String email,
    required String password,
  }) async {
    const generic = 'Invalid email or password';
    final record = await _accounts.find(_normalize(email));
    final hash = record?.passwordHash;
    if (record == null || hash == null) {
      return const AuthResult.failure(generic);
    }
    final matches = await compute(_checkPassword, [password, hash]);
    if (!matches) return const AuthResult.failure(generic);
    return _toResult(record);
  }

  // TODO(auth): replace with google_sign_in / sign_in_with_apple + backend
  // token exchange. Right now this trusts the name/email it is given.
  Future<AuthResult> signInWithProvider({
    required SocialProvider provider,
    required String name,
    required String email,
  }) async {
    final key = _normalize(email);
    final existing = await _accounts.find(key);
    if (existing != null) return _toResult(existing);

    final profile = UserProfile(name: name.trim(), email: email.trim());
    final record = AccountRecord(
      email: key,
      profile: profile.toJson(),
      socialProvider: provider.name,
    );
    await _accounts.insert(record);
    return _toResult(record);
  }

  // TODO(auth): real flow = backend emails a reset link/code.
  /// Returns an error message, or null on success.
  Future<String?> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    final key = _normalize(email);
    if (await _accounts.find(key) == null) {
      return 'No account found for this email';
    }
    final error = Validators.newPassword(newPassword);
    if (error != null) return error;

    await _accounts.updatePasswordHash(
      key,
      await compute(_hashPassword, newPassword),
    );
    return null;
  }

  Future<void> markOnboardingComplete(String email) =>
      _accounts.setOnboardingCompleted(_normalize(email));

  Future<void> saveProfile(UserProfile profile) =>
      _accounts.updateProfile(_normalize(profile.email), profile.toJson());

  AuthResult _toResult(AccountRecord record) => AuthResult.success(
    profile: UserProfile.fromJson(record.profile),
    hasCompletedOnboarding: record.hasCompletedOnboarding,
  );
}