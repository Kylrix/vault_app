import 'dart:async';
import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../appwrite_config.dart';
import '../models/vault_models.dart';
import 'totp.dart';
import 'vault_crypto.dart';
import 'vault_database.dart';

class VaultStore extends ChangeNotifier {
  VaultStore()
      : _database = VaultDatabase(),
        _crypto = VaultCrypto(const FlutterSecureStorage()),
        _totp = TotpService();

  final VaultDatabase _database;
  final VaultCrypto _crypto;
  final TotpService _totp;
  final _uuid = const Uuid();

  final Client _client = Client();

  bool isBootstrapping = true;
  bool isUnlocked = false;
  bool needsMasterPassword = false;
  bool hasInitializedVault = false;
  String? errorMessage;
  String searchQuery = '';
  String selectedFolderId = 'all';

  List<VaultCredential> credentials = [];
  List<VaultFolder> folders = [];
  List<VaultTotp> totpItems = [];
  VaultSettings settings = VaultSettings.defaults();

  AppwriteUser? user;

  bool get canUseAutofill => isUnlocked && settings.autofillEnabled;
  bool get hasSession => user != null;

  Future<void> bootstrap() async {
    _client
        .setEndpoint(AppwriteConfig.endpoint)
        .setProject(AppwriteConfig.projectId);
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('vault_search_query');
      if (stored != null) {
        searchQuery = stored;
      }
      hasInitializedVault = await _crypto.isInitialized;
      needsMasterPassword = hasInitializedVault;
      await _loadSession();
      await _loadLockedState();
      if (_crypto.isUnlocked) {
        await refreshUnlocked();
      }
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isBootstrapping = false;
      notifyListeners();
    }
  }

  Future<void> _loadSession() async {
    try {
      final account = Account(_client);
      final info = await account.get();
      user = AppwriteUser(
        id: info.$id,
        name: info.name,
        email: info.email,
      );
    } catch (_) {
      user = null;
    }
  }

  Future<void> _loadLockedState() async {
    final payload = await _database.readSettings();
    if (payload != null && _crypto.isUnlocked) {
      settings = VaultSettings.fromJson(
        jsonDecode(await _crypto.decryptString(payload)) as Map<String, dynamic>,
      );
    }
  }

  Future<void> unlock(String masterPassword) async {
    final ok = await _crypto.unlock(masterPassword);
    if (!ok) {
      throw StateError('Unable to unlock vault.');
    }
    isUnlocked = true;
    needsMasterPassword = false;
    await refreshUnlocked();
    notifyListeners();
  }

  Future<void> initializeVault(String masterPassword) async {
    await _crypto.initialize(masterPassword);
    hasInitializedVault = true;
    needsMasterPassword = false;
    isUnlocked = true;
    await refreshUnlocked();
    notifyListeners();
  }

  Future<void> refreshUnlocked() async {
    final credentialRows = await _database.listRecords(kind: 'credential');
    final folderRows = await _database.listRecords(kind: 'folder');
    final totpRows = await _database.listRecords(kind: 'totp');
    credentials = [];
    folders = [];
    totpItems = [];
    for (final row in credentialRows) {
      credentials.add(await _decodeCredentialRecord(row));
    }
    for (final row in folderRows) {
      folders.add(await _decodeFolderRecord(row));
    }
    for (final row in totpRows) {
      totpItems.add(await _decodeTotpRecord(row));
    }
    final payload = await _database.readSettings();
    if (payload != null) {
      settings = VaultSettings.fromJson(
        jsonDecode(await _crypto.decryptString(payload)) as Map<String, dynamic>,
      );
    }
    notifyListeners();
  }

  Future<void> lock() async {
    _crypto.lock();
    isUnlocked = false;
    notifyListeners();
  }

  Future<void> logout() async {
    user = null;
    await lock();
    notifyListeners();
  }

  Future<void> saveSettings(VaultSettings next) async {
    settings = next;
    final payload = await _crypto.encryptString(jsonEncode(next.toJson()));
    await _database.writeSettings(payload);
    notifyListeners();
  }

  Future<void> upsertCredential({
    String? id,
    required String title,
    required String username,
    required String password,
    required String url,
    required String notes,
    required String folderId,
    required bool favorite,
  }) async {
    final credential = VaultCredential(
      id: id ?? _uuid.v4(),
      title: title,
      username: username,
      password: password,
      url: url,
      notes: notes,
      folderId: folderId,
      isFavorite: favorite,
      updatedAt: DateTime.now().toUtc(),
      createdAt: DateTime.now().toUtc(),
    );
    await _database.upsertRecord(
      id: credential.id,
      kind: 'credential',
      folderId: credential.folderId,
      favorite: credential.isFavorite,
      updatedAt: credential.updatedAt.toIso8601String(),
      createdAt: credential.createdAt.toIso8601String(),
      encryptedPayload: await _crypto.encryptString(jsonEncode(credential.toJson())),
    );
    await refreshUnlocked();
  }

  Future<void> removeCredential(String id) async {
    await _database.deleteRecord(id);
    await refreshUnlocked();
  }

  Future<void> upsertFolder({
    String? id,
    required String name,
    required String color,
    required String icon,
  }) async {
    final folder = VaultFolder(
      id: id ?? _uuid.v4(),
      name: name,
      color: color,
      icon: icon,
      updatedAt: DateTime.now().toUtc(),
    );
    await _database.upsertRecord(
      id: folder.id,
      kind: 'folder',
      folderId: folder.id,
      favorite: false,
      updatedAt: folder.updatedAt.toIso8601String(),
      createdAt: folder.updatedAt.toIso8601String(),
      encryptedPayload: await _crypto.encryptString(jsonEncode(folder.toJson())),
    );
    await refreshUnlocked();
  }

  Future<void> upsertTotp({
    String? id,
    required String issuer,
    required String accountName,
    required String secret,
  }) async {
    final item = VaultTotp(
      id: id ?? _uuid.v4(),
      issuer: issuer,
      accountName: accountName,
      secret: secret,
      updatedAt: DateTime.now().toUtc(),
    );
    await _database.upsertRecord(
      id: item.id,
      kind: 'totp',
      folderId: '',
      favorite: false,
      updatedAt: item.updatedAt.toIso8601String(),
      createdAt: item.updatedAt.toIso8601String(),
      encryptedPayload: await _crypto.encryptString(jsonEncode(item.toJson())),
    );
    await refreshUnlocked();
  }

  Future<void> resetVault() async {
    await _crypto.reset();
    isUnlocked = false;
    hasInitializedVault = false;
    needsMasterPassword = false;
    credentials = [];
    folders = [];
    totpItems = [];
    settings = VaultSettings.defaults();
    notifyListeners();
  }

  Future<void> changeMasterPassword(String currentPassword, String nextPassword) async {
    await _crypto.changeMasterPassword(currentPassword, nextPassword);
    notifyListeners();
  }

  Future<void> search(String query) async {
    searchQuery = query;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('vault_search_query', query);
    notifyListeners();
  }

  void selectFolder(String folderId) {
    selectedFolderId = folderId;
    notifyListeners();
  }

  Future<void> toggleFavorite(VaultCredential credential) async {
    await upsertCredential(
      id: credential.id,
      title: credential.title,
      username: credential.username,
      password: credential.password,
      url: credential.url,
      notes: credential.notes,
      folderId: credential.folderId,
      favorite: !credential.isFavorite,
    );
  }

  List<VaultCredential> get filteredCredentials {
    return credentials.where((credential) {
      final matchesFolder = selectedFolderId == 'all' || credential.folderId == selectedFolderId;
      final query = searchQuery.trim().toLowerCase();
      final matchesQuery = query.isEmpty ||
          credential.title.toLowerCase().contains(query) ||
          credential.username.toLowerCase().contains(query) ||
          credential.url.toLowerCase().contains(query);
      return matchesFolder && matchesQuery;
    }).toList();
  }

  Future<VaultCredential> _decodeCredentialRecord(Map<String, Object?> row) async {
    final payload = await _crypto.decryptString(row['encrypted_payload'] as String);
    return VaultCredential.fromJson(jsonDecode(payload) as Map<String, dynamic>);
  }

  Future<VaultFolder> _decodeFolderRecord(Map<String, Object?> row) async {
    final payload = await _crypto.decryptString(row['encrypted_payload'] as String);
    return VaultFolder.fromJson(jsonDecode(payload) as Map<String, dynamic>);
  }

  Future<VaultTotp> _decodeTotpRecord(Map<String, Object?> row) async {
    final payload = await _crypto.decryptString(row['encrypted_payload'] as String);
    return VaultTotp.fromJson(jsonDecode(payload) as Map<String, dynamic>);
  }

  String generateTotpCode(VaultTotp item) => _totp.generate(item.secret);
  int get totpSecondsRemaining => _totp.secondsRemaining();
}

class AppwriteUser {
  AppwriteUser({required this.id, required this.name, required this.email});

  final String id;
  final String name;
  final String email;
}
