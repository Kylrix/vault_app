import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class VaultDatabase {
  Database? _db;

  Future<Database> get database async {
    final existing = _db;
    if (existing != null) {
      return existing;
    }
    final dir = await getApplicationSupportDirectory();
    final dbPath = p.join(dir.path, 'kylrix_vault.db');
    final db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE vault_records (
            id TEXT PRIMARY KEY,
            kind TEXT NOT NULL,
            folder_id TEXT,
            favorite INTEGER NOT NULL DEFAULT 0,
            updated_at TEXT NOT NULL,
            created_at TEXT NOT NULL,
            encrypted_payload TEXT NOT NULL
          )
        ''');
        await database.execute('''
          CREATE TABLE vault_settings (
            id INTEGER PRIMARY KEY CHECK (id = 1),
            encrypted_payload TEXT NOT NULL
          )
        ''');
      },
    );
    _db = db;
    return db;
  }

  Future<List<Map<String, Object?>>> listRecords({String? kind}) async {
    final db = await database;
    return db.query(
      'vault_records',
      where: kind == null ? null : 'kind = ?',
      whereArgs: kind == null ? null : [kind],
      orderBy: 'updated_at DESC',
    );
  }

  Future<void> upsertRecord({
    required String id,
    required String kind,
    required String folderId,
    required bool favorite,
    required String updatedAt,
    required String createdAt,
    required String encryptedPayload,
  }) async {
    final db = await database;
    await db.insert(
      'vault_records',
      {
        'id': id,
        'kind': kind,
        'folder_id': folderId,
        'favorite': favorite ? 1 : 0,
        'updated_at': updatedAt,
        'created_at': createdAt,
        'encrypted_payload': encryptedPayload,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteRecord(String id) async {
    final db = await database;
    await db.delete('vault_records', where: 'id = ?', whereArgs: [id]);
  }

  Future<String?> readSettings() async {
    final db = await database;
    final rows = await db.query('vault_settings', where: 'id = 1', limit: 1);
    if (rows.isEmpty) return null;
    return rows.first['encrypted_payload'] as String;
  }

  Future<void> writeSettings(String payload) async {
    final db = await database;
    await db.insert(
      'vault_settings',
      {'id': 1, 'encrypted_payload': payload},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> wipe() async {
    final db = await database;
    await db.delete('vault_records');
    await db.delete('vault_settings');
  }
}
