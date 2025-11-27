import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage._();
  static final TokenStorage instance = TokenStorage._();
  final _storage = const FlutterSecureStorage();

  static const _kAccessTokenKey = 'auth_token';
  static const _kRefreshTokenKey = 'refresh_token';

  /// Sauvegarde uniquement l'access token (API historique)
  Future<void> saveToken(String token) => saveTokens(accessToken: token);

  /// Lit uniquement l'access token (API historique)
  Future<String?> readToken() => readAccessToken();

  /// Supprime uniquement l'access token (API historique)
  Future<void> deleteToken() => deleteAccessToken();

  Future<void> saveTokens({required String accessToken, String? refreshToken}) async {
    await _storage.write(key: _kAccessTokenKey, value: accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _storage.write(key: _kRefreshTokenKey, value: refreshToken);
    }
  }

  Future<String?> readAccessToken() => _storage.read(key: _kAccessTokenKey);

  Future<String?> readRefreshToken() => _storage.read(key: _kRefreshTokenKey);

  Future<void> deleteAccessToken() => _storage.delete(key: _kAccessTokenKey);

  Future<void> deleteRefreshToken() => _storage.delete(key: _kRefreshTokenKey);

  Future<void> clearAll() async {
    await _storage.delete(key: _kAccessTokenKey);
    await _storage.delete(key: _kRefreshTokenKey);
  }
}
