import 'package:dio/dio.dart';
import '../services/auth_api_service.dart';
import '../../../core/storage/token_storage.dart';

class AuthRepository {
  AuthRepository({AuthApiService? api}) : _api = api ?? AuthApiService();
  final AuthApiService _api;

  Future<AuthResult> login(String email, String password) async {
    try {
      final data = await _api.login(email: email, password: password);
      final token = data['token'] as String?;
      final refreshToken = data['refreshToken'] as String?;
      final role = data['role'] as String?;
      final userId = data['userId'];
      if (token == null || token.isEmpty) {
        throw Exception('Token manquant');
      }
      await TokenStorage.instance.saveTokens(accessToken: token, refreshToken: refreshToken);
      return AuthResult(token: token, role: role, userId: userId);
    } on DioException catch (e) {
      // 1) Erreurs réseau franches → message réseau
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception('Erreur réseau');
      }

      // 2) Si c'est bien l'appel login, on privilégie un message UX clair
      final isLogin = e.requestOptions.path.endsWith('/auth/login');
      if (isLogin) {
        final status = e.response?.statusCode;
        if (status == null || status == 400 || status == 401 || status == 403) {
          throw Exception('Identifiants incorrects');
        }
      }

      // 3) Statuts d'auth incorrecte → message UX clair
      final status = e.response?.statusCode;
      if (status == 400 || status == 401 || status == 403) {
        throw Exception('Identifiants incorrects');
      }

      // 4) Autres cas: on tente de lire le message backend, sinon défaut login
      final data = e.response?.data;
      final msg = data is Map && (data['message'] != null)
          ? data['message'].toString()
          : 'Identifiants incorrects';
      throw Exception(msg);
    }
  }

  Future<AuthResult> registerNovice(Map<String, dynamic> body) async {
    try {
      final data = await _api.registerNovice(body);
      final token = data['token'] as String?;
      final refreshToken = data['refreshToken'] as String?;
      final role = data['role'] as String?;
      final userId = data['userId'];
      if (token != null && token.isNotEmpty) {
        await TokenStorage.instance.saveTokens(accessToken: token, refreshToken: refreshToken);
        return AuthResult(token: token, role: role, userId: userId);
      }
      // Pas de token: considérer l'inscription comme réussie sans connexion automatique
      return AuthResult(token: '', role: role, userId: userId);
    } on DioException catch (e) {
      final msg = e.response?.data is Map && (e.response?.data['message'] != null)
          ? e.response?.data['message'].toString()
          : e.message ?? 'Erreur réseau';
      throw Exception(msg);
    }
  }

  Future<AuthResult> registerProfessionnel({
    required Map<String, dynamic> data,
    MultipartFile? document,
  }) async {
    try {
      final res = await _api.registerProfessionnel(data: data, document: document);
      final body = res.data;
      if (body is Map) {
        final token = body['token'] as String?;
        final refreshToken = body['refreshToken'] as String?;
        final role = body['role'] as String?;
        final userId = body['userId'];
        if (token != null && token.isNotEmpty) {
          await TokenStorage.instance.saveTokens(accessToken: token, refreshToken: refreshToken);
          return AuthResult(token: token, role: role, userId: userId);
        }
        // Pas de token: retour sans connexion automatique
        return AuthResult(token: '', role: role, userId: userId);
      }
      // Corps non JSON: considérer comme succès sans token
      return AuthResult(token: '', role: null, userId: null);
    } on DioException catch (e) {
      final msg = e.response?.data is Map && (e.response?.data['message'] != null)
          ? e.response?.data['message'].toString()
          : e.message ?? 'Erreur réseau';
      throw Exception(msg);
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await _api.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = data is Map && data['message'] != null
          ? data['message'].toString()
          : e.response?.data?.toString() ?? e.message ?? 'Erreur réseau';
      throw Exception(msg);
    }
  }
}

class AuthResult {
  final String token;
  final String? role;
  final dynamic userId;
  AuthResult({required this.token, required this.role, required this.userId});
}
