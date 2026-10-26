import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'crypto_service.dart';

/// Saves photos encrypted in the app's private folder.
/// The profile stores only the returned file NAME, never a full path
/// (full paths can change between app updates on iOS).
class SecureMediaStore {
  SecureMediaStore(this._crypto);

  final CryptoService _crypto;

  Future<Directory> _dir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'secure_media'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Encrypts [bytes], writes them to disk, returns the file name to store.
  Future<String> save(List<int> bytes) async {
    final name = '${DateTime.now().microsecondsSinceEpoch}.enc';
    final file = File(p.join((await _dir()).path, name));
    await file.writeAsBytes(await _crypto.encryptBytes(bytes), flush: true);
    return name;
  }

  /// Returns the decrypted image bytes, or null if missing/unreadable.
  Future<Uint8List?> load(String name) async {
    try {
      final file = File(p.join((await _dir()).path, name));
      if (!await file.exists()) return null;
      return await _crypto.decryptBytes(await file.readAsBytes());
    } catch (_) {
      return null;
    }
  }

  Future<void> delete(String name) async {
    final file = File(p.join((await _dir()).path, name));
    if (await file.exists()) await file.delete();
  }
}