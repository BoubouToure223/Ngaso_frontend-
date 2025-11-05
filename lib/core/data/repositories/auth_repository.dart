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
      final role = data['role'] as String?;
      final userId = data['userId'];
      if (token == null || token.isEmpty) {
        throw Exception('Token manquant');
      }
      await TokenStorage.instance.saveToken(token);
      return AuthResult(token: token, role: role, userId: userId);
    } on DioException catch (e) {
      final msg = e.response?.data is Map && (e.response?.data['message'] != null)
          ? e.response?.data['message'].toString()
          : e.message ?? 'Erreur réseau';
      throw Exception(msg);
    }
  }

  Future<AuthResult> registerNovice(Map<String, dynamic> body) async {
    try {
      final data = await _api.registerNovice(body);
      final token = data['token'] as String?;
      final role = data['role'] as String?;
      final userId = data['userId'];
      if (token == null || token.isEmpty) {
        throw Exception('Token manquant');
      }
      await TokenStorage.instance.saveToken(token);
      return AuthResult(token: token, role: role, userId: userId);
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
        final role = body['role'] as String?;
        final userId = body['userId'];
        if (token != null && token.isNotEmpty) {
          await TokenStorage.instance.saveToken(token);
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
}

class AuthResult {
  final String token;
  final String? role;
  final dynamic userId;
  AuthResult({required this.token, required this.role, required this.userId});
}
