import 'package:dio/dio.dart';
import '../../network/dio_client.dart';

class ProjectApiService {
  final Dio _dio = DioClient.I.dio;

  Future<Map<String, dynamic>> createMyProject({
    required String titre,
    required String dimensionsTerrain,
    required double budget,
    required String localisation,
  }) async {
    final res = await _dio.post(
      '/projets/me',
      data: {
        'titre': titre,
        'dimensionsTerrain': dimensionsTerrain,
        'budget': budget,
        'localisation': localisation,
      },
    );
    final data = res.data;
    if (data is Map<String, dynamic>) return data;
    return Map<String, dynamic>.from(data as Map);
  }

  Future<List<Map<String, dynamic>>> listMyProjects() async {
    final res = await _dio.get('/projets/me');
    final data = res.data;
    if (data is List) {
      return data.map<Map<String, dynamic>>((e) => e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map)).toList();
    }
    if (data is Map && data['content'] is List) {
      final list = data['content'] as List;
      return list.map<Map<String, dynamic>>((e) => e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map)).toList();
    }
    return const [];
  }

  Future<List<Map<String, dynamic>>> getProjectSteps({required int projectId}) async {
    final res = await _dio.get('/projets/$projectId/etapes');
    final data = res.data;
    if (data is List) {
      return data
          .map<Map<String, dynamic>>((e) => e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map))
          .toList(growable: false);
    }
    if (data is Map && data['content'] is List) {
      final list = data['content'] as List;
      return list
          .map<Map<String, dynamic>>((e) => e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map))
          .toList(growable: false);
    }
    return const [];
  }

  Future<Map<String, dynamic>> validateEtape({required int etapeId}) async {
    final res = await _dio.post('/projets/etapes/$etapeId/valider');
    final data = res.data;
    if (data is Map<String, dynamic>) return data;
    return Map<String, dynamic>.from(data as Map);
  }

  Future<List<Map<String, dynamic>>> getProjectDemandes({required int projectId}) async {
    final res = await _dio.get('/projets/$projectId/demandes');
    final data = res.data;
    if (data == null) return const [];
    if (data is List) {
      return data
          .map<Map<String, dynamic>>((e) => e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map))
          .toList(growable: false);
    }
    if (data is Map && data['content'] is List) {
      final list = data['content'] as List;
      return list
          .map<Map<String, dynamic>>((e) => e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map))
          .toList(growable: false);
    }
    return const [];
  }

  Future<void> cancelDemande({required int demandeId}) async {
    await _dio.post('/projets/demandes/$demandeId/annuler');
  }
  Future<void> deleteMyProject({required int projectId}) async {
    await _dio.delete('/projets/$projectId');
  }
}

