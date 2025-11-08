import 'package:dio/dio.dart';
import '../services/project_api_service.dart';

class ProjectRepository {
  ProjectRepository({ProjectApiService? api}) : _api = api ?? ProjectApiService();
  final ProjectApiService _api;

  Future<Map<String, dynamic>> createMyProject({
    required String titre,
    required String dimensionsTerrain,
    required double budget,
    required String localisation,
  }) async {
    try {
      return await _api.createMyProject(
        titre: titre,
        dimensionsTerrain: dimensionsTerrain,
        budget: budget,
        localisation: localisation,
      );
    } on DioException catch (e) {
      // Statuts attendus côté auth/protection
      final status = e.response?.statusCode;
      if (status == 400) {
        // Erreurs de validation côté backend
        final data = e.response?.data;
        if (data is Map && data['message'] != null) {
          throw Exception(data['message'].toString());
        }
        throw Exception('Données invalides');
      }
      if (status == 401 || status == 403) {
        throw Exception('Session expirée ou non autorisée');
      }
      // Fallback générique
      final data = e.response?.data;
      final msg = data is Map && (data['message'] != null)
          ? data['message'].toString()
          : e.message ?? 'Erreur réseau';
      throw Exception(msg);
    }
  }

  Future<List<Map<String, dynamic>>> listMyProjects() async {
    try {
      return await _api.listMyProjects();
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401 || status == 403) {
        throw Exception('Session expirée ou non autorisée');
      }
      final data = e.response?.data;
      final msg = data is Map && (data['message'] != null)
          ? data['message'].toString()
          : e.message ?? 'Erreur réseau';
      throw Exception(msg);
    }
  }
}
