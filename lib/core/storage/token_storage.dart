import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage._();
  static final TokenStorage instance = TokenStorage._();
  final _storage = const FlutterSecureStorage();
  static const _kTokenKey = 'auth_token';

  Future<void> saveToken(String token) => _storage.write(key: _kTokenKey, value: token);
  Future<String?> readToken() => _storage.read(key: _kTokenKey);
  Future<void> deleteToken() => _storage.delete(key: _kTokenKey);
}
