import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/local_db/profile_store.dart';
import '../models/user_profile.dart';

class Validators {
  static final _emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$');

  static bool isValidEmail(String email) =>
      email.trim().isNotEmpty && _emailRegex.hasMatch(email.trim());

  static String? newPassword(String password) {
    if (password.length < 8 || !password.contains(RegExp(r'\d'))) {
      return 'Password must be at least 8 characters and include a number';
    }
    return null;
  }
}

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

class AuthService {
  AuthService(this._client, this._profiles);

  static const authCallbackUrl = 'com.example.evoqe://auth-callback';

  final SupabaseClient _client;
  final ProfileStore _profiles;

  String? get currentUserId => _client.auth.currentUser?.id;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResult?> getSession() async {
    final user = _client.auth.currentUser;
    if (user == null || _client.auth.currentSession == null) return null;
    return _toResult(user);
  }

  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final passwordError = Validators.newPassword(password);
    if (passwordError != null) return AuthResult.failure(passwordError);

    try {
      final response = await _client.auth.signUp(
        email: email.trim().toLowerCase(),
        password: password,
        data: {'full_name': name.trim()},
      );
      final user = response.user;
      if (user == null || response.session == null) {
        return const AuthResult.failure(
          'Sign-up did not start a session. Disable email confirmation in '
          'Supabase Auth settings to allow immediate sign-in.',
        );
      }
      return await _toResult(user, fallbackName: name.trim());
    } on AuthException catch (error) {
      return AuthResult.failure(error.message);
    }
  }

  Future<AuthResult> logIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      final user = response.user;
      if (user == null || response.session == null) {
        return const AuthResult.failure('Invalid email or password.');
      }
      return await _toResult(user);
    } on AuthException catch (error) {
      return AuthResult.failure(error.message);
    }
  }

  Future<String?> resetPassword({required String email}) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email.trim().toLowerCase(),
        redirectTo: authCallbackUrl,
      );
      return null;
    } on AuthException catch (error) {
      return error.message;
    }
  }

  Future<String?> updatePassword(String password) async {
    final passwordError = Validators.newPassword(password);
    if (passwordError != null) return passwordError;
    try {
      await _client.auth.updateUser(UserAttributes(password: password));
      return null;
    } on AuthException catch (error) {
      return error.message;
    }
  }

  Future<void> signOut() => _client.auth.signOut();

  Future<void> markOnboardingComplete(String userId) async {
    final existing = await _profiles.find(userId);
    if (existing == null) return;
    await _profiles.save(
      userId: userId,
      profile: existing.profile,
      hasCompletedOnboarding: true,
    );
  }

  Future<void> saveProfile(UserProfile profile) async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    final existing = await _profiles.find(user.id);
    await _profiles.save(
      userId: user.id,
      profile: profile.toJson(),
      hasCompletedOnboarding: existing?.hasCompletedOnboarding ?? false,
    );
  }

  Future<AuthResult> _toResult(User user, {String? fallbackName}) async {
    final stored = await _profiles.find(user.id);
    if (stored != null) {
      return AuthResult.success(
        profile: UserProfile.fromJson(stored.profile),
        hasCompletedOnboarding: stored.hasCompletedOnboarding,
      );
    }

    final email = user.email ?? '';
    final name = (user.userMetadata?['full_name'] as String?)?.trim();
    final profile = UserProfile(
      name: (name?.isNotEmpty == true)
          ? name!
          : (fallbackName?.isNotEmpty == true
                ? fallbackName!
                : email.split('@').first),
      email: email,
    );
    await _profiles.save(
      userId: user.id,
      profile: profile.toJson(),
      hasCompletedOnboarding: false,
    );
    return AuthResult.success(profile: profile, hasCompletedOnboarding: false);
  }
}
