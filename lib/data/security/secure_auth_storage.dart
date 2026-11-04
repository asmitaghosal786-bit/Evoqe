import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SecureAuthStorage extends LocalStorage implements GotrueAsyncStorage {
  const SecureAuthStorage();

  static const _sessionKey = 'supabase_auth_session_v1';
  static const _storage = FlutterSecureStorage();

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> hasAccessToken() async =>
      await _storage.read(key: _sessionKey) != null;

  @override
  Future<String?> accessToken() => _storage.read(key: _sessionKey);

  @override
  Future<void> removePersistedSession() => _storage.delete(key: _sessionKey);

  @override
  Future<void> persistSession(String persistSessionString) =>
      _storage.write(key: _sessionKey, value: persistSessionString);

  @override
  Future<String?> getItem({required String key}) =>
      _storage.read(key: 'supabase_pkce_$key');

  @override
  Future<void> setItem({required String key, required String value}) =>
      _storage.write(key: 'supabase_pkce_$key', value: value);

  @override
  Future<void> removeItem({required String key}) =>
      _storage.delete(key: 'supabase_pkce_$key');
}
