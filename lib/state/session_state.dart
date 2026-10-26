import 'package:flutter/foundation.dart';

import '../data/local_db/session_store.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';

/// What the UI listens to: who is logged in and where they are in onboarding.
class SessionState extends ChangeNotifier {
  SessionState(this._auth, this._store);

  final AuthService _auth;
  final SessionStore _store;

  bool isRestoring = true;
  bool isLoggedIn = false;
  bool hasCompletedOnboarding = false;
  UserProfile? currentUser;

  /// True when the user can skip straight to the main app home screen.
  bool get shouldSkipToHome => isLoggedIn && hasCompletedOnboarding;

  /// Call once at startup, before runApp().
  Future<void> restore() async {
    final email = await _store.readEmail();
    if (email != null) {
      final result = await _auth.getSession(email);
      if (result != null && result.ok) {
        _apply(result);
      } else {
        await _store.clear(); // stale session (account was removed)
      }
    }
    isRestoring = false;
    notifyListeners();
  }

  Future<bool> accountExists(String email) => _auth.accountExists(email);

  /// Returns an error message, or null on success.
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
  }) =>
      _finishAuth(_auth.signUp(name: name, email: email, password: password));

  Future<String?> logIn({
    required String email,
    required String password,
  }) =>
      _finishAuth(_auth.logIn(email: email, password: password));

  Future<String?> signInWithProvider({
    required SocialProvider provider,
    required String name,
    required String email,
  }) =>
      _finishAuth(_auth.signInWithProvider(
        provider: provider,
        name: name,
        email: email,
      ));

  Future<String?> resetPassword({
    required String email,
    required String newPassword,
  }) =>
      _auth.resetPassword(email: email, newPassword: newPassword);

  /// State updates immediately; persistence follows, so callers may ignore
  /// the returned Future.
  Future<void> completeOnboarding() async {
    hasCompletedOnboarding = true;
    notifyListeners();
    final user = currentUser;
    if (user != null) await _auth.markOnboardingComplete(user.email);
  }

  Future<void> logOut() async {
    isLoggedIn = false;
    hasCompletedOnboarding = false;
    currentUser = null;
    notifyListeners();
    await _store.clear();
  }

  /// Runs [update] on the current profile, notifies, then saves it.
  Future<void> updateProfile(void Function(UserProfile) update) async {
    final user = currentUser;
    if (user == null) return;
    update(user);
    notifyListeners();
    await _auth.saveProfile(user);
  }

  Future<String?> _finishAuth(Future<AuthResult> pending) async {
    final result = await pending;
    if (!result.ok) return result.error;
    _apply(result);
    await _store.saveEmail(result.profile!.email);
    notifyListeners();
    return null;
  }

  void _apply(AuthResult result) {
    currentUser = result.profile;
    isLoggedIn = true;
    hasCompletedOnboarding = result.hasCompletedOnboarding;
  }
}