import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Remembers who is logged in across app restarts.
/// When you add a backend, store the auth token here instead of the email.
abstract class SessionStore {
  Future<String?> readEmail();
  Future<void> saveEmail(String email);
  Future<void> clear();
}

class SecureSessionStore implements SessionStore {
  SecureSessionStore([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _key = 'session_email';

  @override
  Future<String?> readEmail() => _storage.read(key: _key);

  @override
  Future<void> saveEmail(String email) =>
      _storage.write(key: _key, value: email);

  @override
  Future<void> clear() => _storage.delete(key: _key);
}