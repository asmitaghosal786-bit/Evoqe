import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// AES-256-GCM encryption. The key lives in the platform secure store.
/// GCM also authenticates, so tampered data fails to decrypt.
class CryptoService {
  CryptoService._(this._key);

  final SecretKey _key;
  static final _algo = AesGcm.with256bits();
  static const _keyName = 'data_encryption_key_v1';

  static Future<CryptoService> init([FlutterSecureStorage? storage]) async {
    final secure = storage ?? const FlutterSecureStorage();
    final existing = await secure.read(key: _keyName);
    if (existing != null) {
      return CryptoService._(SecretKey(base64Decode(existing)));
    }
    final key = await _algo.newSecretKey();
    final bytes = await key.extractBytes();
    await secure.write(key: _keyName, value: base64Encode(bytes));
    return CryptoService._(SecretKey(bytes));
  }

  /// Output layout: nonce | ciphertext | mac (a fresh random nonce each time).
  Future<Uint8List> encryptBytes(List<int> plain) async {
    final box = await _algo.encrypt(plain, secretKey: _key);
    return Uint8List.fromList(box.concatenation());
  }

  Future<Uint8List> decryptBytes(List<int> data) async {
    final box = SecretBox.fromConcatenation(
      data,
      nonceLength: _algo.nonceLength,
      macLength: _algo.macAlgorithm.macLength,
    );
    final clear = await _algo.decrypt(box, secretKey: _key);
    return Uint8List.fromList(clear);
  }

  Future<String> encryptString(String text) async =>
      base64Encode(await encryptBytes(utf8.encode(text)));

  Future<String> decryptString(String encoded) async =>
      utf8.decode(await decryptBytes(base64Decode(encoded)));
}