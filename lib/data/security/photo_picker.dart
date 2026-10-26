import 'dart:io';

import 'package:image_picker/image_picker.dart';

import 'secure_media_store.dart';

class PhotoPicker {
  PhotoPicker(this._store);

  final SecureMediaStore _store;
  final ImagePicker _picker = ImagePicker();

  /// Returns the stored (encrypted) file name, or null if the user cancelled.
  /// If [replacing] is given, that old encrypted file is deleted.
  Future<String?> pick({
    required ImageSource source,
    CameraDevice camera = CameraDevice.rear,
    String? replacing,
  }) async {
    final picked = await _picker.pickImage(
      source: source,
      preferredCameraDevice: camera,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (picked == null) return null;

    final bytes = await picked.readAsBytes();
    final name = await _store.save(bytes);

    // Remove the unencrypted temporary copy.
    try {
      await File(picked.path).delete();
    } catch (_) {}

    if (replacing != null) await _store.delete(replacing);
    return name;
  }
}