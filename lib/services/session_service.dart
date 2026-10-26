// TODO(persistence): later, load/save session to shared_preferences or a DB in this file only.

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';

/// Supported social authentication providers.
enum SocialProvider { google, apple }

/// Manages user authentication state, session info, and in-memory account data.
class SessionService extends ChangeNotifier {
  bool isLoggedIn = false;
  bool hasCompletedOnboarding = false;
  UserProfile? currentUser;

  final Map<String, _Account> _accounts = {};

  SessionService() {
    const demoEmail = 'demo@evoqe.com';
    final demoProfile = UserProfile(
      name: 'Demo User',
      email: demoEmail,
    );
    _accounts[demoEmail.toLowerCase()] = _Account(
      email: demoEmail,
      password: 'Demo1234',
      profile: demoProfile,
      hasCompletedOnboarding: true,
    );
  }

  /// Getter indicating whether the user can skip straight to the main app home screen.
  bool get shouldSkipToHome => isLoggedIn && hasCompletedOnboarding;

  /// Returns true if an account is registered for the given email address.
  bool accountExists(String email) {
    return _accounts.containsKey(email.trim().toLowerCase());
  }

  /// Registers a new user account.
  ///
  /// Returns an error message String if sign up fails, or null on success.
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final normalizedEmail = email.trim().toLowerCase();
    if (_accounts.containsKey(normalizedEmail)) {
      return 'An account with this email already exists.';
    }

    final newProfile = UserProfile(
      name: name.trim(),
      email: email.trim(),
    );

    final newAccount = _Account(
      email: email.trim(),
      password: password,
      profile: newProfile,
      hasCompletedOnboarding: false,
    );

    _accounts[normalizedEmail] = newAccount;

    currentUser = newProfile;
    isLoggedIn = true;
    hasCompletedOnboarding = false;

    notifyListeners();
    return null;
  }

  /// Logs in an existing user account.
  ///
  /// Returns an error message String if login fails, or null on success.
  Future<String?> logIn({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final normalizedEmail = email.trim().toLowerCase();
    final account = _accounts[normalizedEmail];

    if (account == null) {
      return 'No account found';
    }

    if (account.password != password) {
      return 'Incorrect password';
    }

    currentUser = account.profile;
    isLoggedIn = true;
    hasCompletedOnboarding = account.hasCompletedOnboarding;

    notifyListeners();
    return null;
  }

  /// Signs in or signs up a user via a social provider ([SocialProvider.google] or [SocialProvider.apple]).
  ///
  /// Returns null on success, or an error message String if failure occurs.
  Future<String?> signInWithProvider({
    required SocialProvider provider,
    required String name,
    required String email,
  }) async {
    // TODO(auth): replace with real google_sign_in / sign_in_with_apple + backend token exchange.
    await Future.delayed(const Duration(milliseconds: 600));

    final normalizedEmail = email.trim().toLowerCase();
    final account = _accounts[normalizedEmail];

    if (account == null) {
      final newProfile = UserProfile(
        name: name.trim(),
        email: email.trim(),
      );
      final newAccount = _Account(
        email: email.trim(),
        profile: newProfile,
        hasCompletedOnboarding: false,
        socialProvider: provider,
      );
      _accounts[normalizedEmail] = newAccount;

      currentUser = newProfile;
      isLoggedIn = true;
      hasCompletedOnboarding = false;
    } else {
      currentUser = account.profile;
      isLoggedIn = true;
      hasCompletedOnboarding = account.hasCompletedOnboarding;
    }

    notifyListeners();
    return null;
  }

  /// Resets the password for the account associated with [email].
  ///
  /// Returns an error message String if reset fails, or null on success.
  Future<String?> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    // TODO(auth): real flow = backend emails a reset link/code; this demo resets directly.
    await Future.delayed(const Duration(milliseconds: 600));

    final normalizedEmail = email.trim().toLowerCase();
    final account = _accounts[normalizedEmail];

    if (account == null) {
      return 'No account found for this email';
    }

    if (newPassword.length < 8 || !newPassword.contains(RegExp(r'\d'))) {
      return 'Password must be at least 8 characters and include a number';
    }

    account.password = newPassword;
    notifyListeners();
    return null;
  }

  /// Marks onboarding as completed for the current user and session.
  void completeOnboarding() {
    hasCompletedOnboarding = true;
    if (currentUser != null) {
      final normalizedEmail = currentUser!.email.trim().toLowerCase();
      if (_accounts.containsKey(normalizedEmail)) {
        _accounts[normalizedEmail]!.hasCompletedOnboarding = true;
      }
    }
    notifyListeners();
  }

  /// Logs out the current user and clears session state.
  void logOut() {
    isLoggedIn = false;
    hasCompletedOnboarding = false;
    currentUser = null;
    notifyListeners();
  }

  /// Runs an update function on the [currentUser] profile and notifies listeners.
  void updateProfile(void Function(UserProfile) update) {
    if (currentUser != null) {
      update(currentUser!);
      notifyListeners();
    }
  }
}

class _Account {
  final String email;
  String? password;
  final UserProfile profile;
  bool hasCompletedOnboarding;
  SocialProvider? socialProvider;

  _Account({
    required this.email,
    this.password,
    required this.profile,
    this.hasCompletedOnboarding = false,
    this.socialProvider,
  });
}
