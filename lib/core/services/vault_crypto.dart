import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class VaultCrypto {
  VaultCrypto(this._storage);

  static const _saltKey = 'vault_master_salt';
  static const _wrappedKey = 'vault_wrapped_mek';
  static const _initializedKey = 'vault_initialized';

  final FlutterSecureStorage _storage;
  final _pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 120000,
    bits: 256,
  );
  final _aes = AesGcm.with256bits();
  final _random = Random.secure();

  List<int>? _mek;

  bool get isUnlocked => _mek != null;

  Future<bool> get isInitialized async =>
      (await _storage.read(key: _initializedKey)) == 'true';

  Future<void> initialize(String masterPassword) async {
    final salt = _randomBytes(16);
    final mek = _randomBytes(32);
    final derived = await _pbkdf2.deriveKeyFromPassword(
      password: masterPassword,
      nonce: salt,
    );
    final wrapped = await _aes.encrypt(
      mek,
      secretKey: derived,
      nonce: _randomBytes(12),
    );
    await _storage.write(key: _saltKey, value: base64Encode(salt));
    await _storage.write(key: _wrappedKey, value: _encodeSecretBox(wrapped));
    await _storage.write(key: _initializedKey, value: 'true');
    _mek = mek;
  }

  Future<bool> unlock(String masterPassword) async {
    final saltRaw = await _storage.read(key: _saltKey);
    final wrappedRaw = await _storage.read(key: _wrappedKey);
    if (saltRaw == null || wrappedRaw == null) {
      return false;
    }
    final salt = base64Decode(saltRaw);
    final wrapped = _decodeSecretBox(wrappedRaw);
    final derived = await _pbkdf2.deriveKeyFromPassword(
      password: masterPassword,
      nonce: salt,
    );
    final mek = await _aes.decrypt(wrapped, secretKey: derived);
    _mek = mek;
    return true;
  }

  Future<void> changeMasterPassword(
    String currentPassword,
    String nextPassword,
  ) async {
    final saltRaw = await _storage.read(key: _saltKey);
    final wrappedRaw = await _storage.read(key: _wrappedKey);
    if (saltRaw == null || wrappedRaw == null) {
      throw StateError('Vault is not initialized.');
    }
    final salt = base64Decode(saltRaw);
    final wrapped = _decodeSecretBox(wrappedRaw);
    final currentDerived = await _pbkdf2.deriveKeyFromPassword(
      password: currentPassword,
      nonce: salt,
    );
    final mek = await _aes.decrypt(wrapped, secretKey: currentDerived);
    final nextSalt = _randomBytes(16);
    final nextDerived = await _pbkdf2.deriveKeyFromPassword(
      password: nextPassword,
      nonce: nextSalt,
    );
    final nextWrapped = await _aes.encrypt(
      mek,
      secretKey: nextDerived,
      nonce: _randomBytes(12),
    );
    await _storage.write(key: _saltKey, value: base64Encode(nextSalt));
    await _storage.write(key: _wrappedKey, value: _encodeSecretBox(nextWrapped));
    _mek = mek;
  }

  Future<void> reset() async {
    await _storage.delete(key: _saltKey);
    await _storage.delete(key: _wrappedKey);
    await _storage.delete(key: _initializedKey);
    _mek = null;
  }

  void lock() {
    _mek = null;
  }

  Future<String> encryptString(String value) async {
    final mek = _mek;
    if (mek == null) {
      throw StateError('Vault is locked.');
    }
    final box = await _encryptBytes(utf8.encode(value), mek);
    return _encodeSecretBox(box);
  }

  Future<String> decryptString(String value) async {
    final mek = _mek;
    if (mek == null) {
      throw StateError('Vault is locked.');
    }
    final box = _decodeSecretBox(value);
    final bytes = await _decryptBytes(box, mek);
    return utf8.decode(bytes);
  }

  Future<SecretBox> _encryptBytes(List<int> plaintext, List<int> mek) async {
    final key = SecretKey(mek);
    return _aes.encrypt(
      plaintext,
      secretKey: key,
      nonce: _randomBytes(12),
    );
  }

  Future<List<int>> _decryptBytes(SecretBox box, List<int> mek) async {
    final key = SecretKey(mek);
    return _aes.decrypt(box, secretKey: key);
  }

  List<int> _randomBytes(int length) =>
      List<int>.generate(length, (_) => _random.nextInt(256));

  String _encodeSecretBox(SecretBox box) {
    return base64Encode([
      ...box.nonce,
      ...box.cipherText,
      ...box.mac.bytes,
    ]);
  }

  SecretBox _decodeSecretBox(String encoded) {
    final bytes = base64Decode(encoded);
    const nonceLength = 12;
    const macLength = 16;
    final nonce = bytes.sublist(0, nonceLength);
    final mac = Mac(bytes.sublist(bytes.length - macLength));
    final cipherText = bytes.sublist(nonceLength, bytes.length - macLength);
    return SecretBox(cipherText, nonce: nonce, mac: mac);
  }
}
