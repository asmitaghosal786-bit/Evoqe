import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../security/crypto_service.dart';

class LocalProfile {
  const LocalProfile({
    required this.userId,
    required this.profile,
    required this.hasCompletedOnboarding,
  });

  final String userId;
  final Map<String, dynamic> profile;
  final bool hasCompletedOnboarding;
}

class ProfileStore {
  ProfileStore._(this._db, this._crypto);

  final Database _db;
  final CryptoService _crypto;

  static const _table = 'profiles';

  static Future<ProfileStore> open(CryptoService crypto) async {
    final dir = await getDatabasesPath();
    final db = await openDatabase(
      p.join(dir, 'evoqe.db'),
      version: 2,
      onCreate: (db, version) async {
        await _createProfileTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('DROP TABLE IF EXISTS accounts');
          await _createProfileTable(db);
        }
      },
    );
    return ProfileStore._(db, crypto);
  }

  static Future<void> _createProfileTable(DatabaseExecutor db) => db.execute('''
    CREATE TABLE $_table (
      user_id TEXT PRIMARY KEY,
      has_completed_onboarding INTEGER NOT NULL DEFAULT 0,
      profile_enc TEXT NOT NULL
    )
  ''');

  Future<String> _seal(Map<String, dynamic> profile) =>
      _crypto.encryptString(jsonEncode(profile));

  Future<LocalProfile?> find(String userId) async {
    final rows = await _db.query(
      _table,
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final row = rows.first;

    try {
      final profile = jsonDecode(
        await _crypto.decryptString(row['profile_enc'] as String),
      ) as Map<String, dynamic>;
      return LocalProfile(
        userId: row['user_id'] as String,
        profile: profile,
        hasCompletedOnboarding: (row['has_completed_onboarding'] as int) == 1,
      );
    } on FormatException {
      return null;
    }
  }

  Future<LocalProfile> save({
    required String userId,
    required Map<String, dynamic> profile,
    required bool hasCompletedOnboarding,
  }) async {
    await _db.insert(_table, {
      'user_id': userId,
      'has_completed_onboarding': hasCompletedOnboarding ? 1 : 0,
      'profile_enc': await _seal(profile),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    return LocalProfile(
      userId: userId,
      profile: profile,
      hasCompletedOnboarding: hasCompletedOnboarding,
    );
  }
}
