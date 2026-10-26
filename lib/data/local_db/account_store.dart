import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../security/crypto_service.dart';

class AccountRecord {
  final String email;
  final String? passwordHash; // bcrypt hash; null for social-only accounts
  final String? socialProvider; // 'google' | 'apple' | null
  final bool hasCompletedOnboarding;
  final Map<String, dynamic> profile;

  const AccountRecord({
    required this.email,
    required this.profile,
    this.passwordHash,
    this.socialProvider,
    this.hasCompletedOnboarding = false,
  });
}

class AccountStore {
  AccountStore._(this._db, this._crypto);

  final Database _db;
  final CryptoService _crypto;
  static const _table = 'accounts';

  static Future<AccountStore> open(CryptoService crypto) async {
    final dir = await getDatabasesPath();
    final db = await openDatabase(
      p.join(dir, 'evoqe.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_table (
            email TEXT PRIMARY KEY,
            password_hash TEXT,
            social_provider TEXT,
            has_completed_onboarding INTEGER NOT NULL DEFAULT 0,
            profile_enc TEXT NOT NULL,
            created_at INTEGER NOT NULL
          )
        ''');
      },
    );
    return AccountStore._(db, crypto);
  }

  Future<String> _seal(Map<String, dynamic> profile) =>
      _crypto.encryptString(jsonEncode(profile));

  /// Checks whether a record exists for [normalizedEmail] without attempting
  /// to decrypt its profile payload.
  Future<bool> existsRaw(String normalizedEmail) async {
    final count = Sqflite.firstIntValue(await _db.rawQuery(
      'SELECT COUNT(*) FROM $_table WHERE email = ?',
      [normalizedEmail],
    ));
    return (count ?? 0) > 0;
  }

  /// Deletes the account record for [normalizedEmail].
  Future<void> delete(String normalizedEmail) async {
    await _db.delete(
      _table,
      where: 'email = ?',
      whereArgs: [normalizedEmail],
    );
  }

  Future<AccountRecord?> find(String normalizedEmail) async {
    final rows = await _db.query(
      _table,
      where: 'email = ?',
      whereArgs: [normalizedEmail],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final row = rows.first;

    try {
      final profile = jsonDecode(
        await _crypto.decryptString(row['profile_enc'] as String),
      ) as Map<String, dynamic>;
      return AccountRecord(
        email: row['email'] as String,
        passwordHash: row['password_hash'] as String?,
        socialProvider: row['social_provider'] as String?,
        hasCompletedOnboarding: (row['has_completed_onboarding'] as int) == 1,
        profile: profile,
      );
    } catch (_) {
      // Key lost or data corrupted: treat as unreadable.
      return null;
    }
  }

  /// Returns false if an account with this email already exists.
  Future<bool> insert(AccountRecord record) async {
    try {
      await _db.insert(
        _table,
        {
          'email': record.email,
          'password_hash': record.passwordHash,
          'social_provider': record.socialProvider,
          'has_completed_onboarding': record.hasCompletedOnboarding ? 1 : 0,
          'profile_enc': await _seal(record.profile),
          'created_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return true;
    } on DatabaseException {
      return false;
    }
  }

  Future<void> updatePasswordHash(String normalizedEmail, String hash) =>
      _db.update(
        _table,
        {'password_hash': hash},
        where: 'email = ?',
        whereArgs: [normalizedEmail],
      );

  Future<void> setOnboardingCompleted(String normalizedEmail) => _db.update(
    _table,
    {'has_completed_onboarding': 1},
    where: 'email = ?',
    whereArgs: [normalizedEmail],
  );

  Future<void> updateProfile(
      String normalizedEmail,
      Map<String, dynamic> profileJson,
      ) async {
    await _db.update(
      _table,
      {'profile_enc': await _seal(profileJson)},
      where: 'email = ?',
      whereArgs: [normalizedEmail],
    );
  }
}
