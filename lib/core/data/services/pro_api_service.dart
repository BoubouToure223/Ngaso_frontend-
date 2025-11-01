import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import '../../network/dio_client.dart';
import '../models/pro_dashboard.dart';

class ProApiService {
  final Dio _dio = DioClient.I.dio;

  Future<ProDashboard> getDashboard({required int professionnelId}) async {
    final res = await _dio.get('/professionnels/$professionnelId/dashboard');
    final data = res.data;
    if (data is Map<String, dynamic>) {
      return ProDashboard.fromJson(data);
    }
    // Tolérer data dynamique provenant de Dio
    return ProDashboard.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<List<dynamic>> getProjectsEnCours() async {
    final res = await _dio.get('/projets/en-cours');
    final data = res.data;
    if (data is List) return data;
    if (data is Map) {
      if (data['content'] is List) return List.from(data['content']);
      if (data['items'] is List) return List.from(data['items']);
    }
    return const [];
  }

  Future<List<dynamic>> getMyRealisationsItems() async {
    final res = await _dio.get('/professionnels/me/realisations/items');
    final data = res.data;
    if (data is List) return data;
    if (data is Map && data['content'] is List) return List.from(data['content']);
    return const [];
  }

  Future<List<dynamic>> uploadMyRealisationImage({
    required String filePath,
    String? fileName,
    String? mimeType,
  }) async {
    final form = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        filePath,
        filename: fileName,
        contentType: mimeType != null ? MediaType.parse(mimeType) : null,
      ),
    });
    final res = await _dio.post('/professionnels/me/realisations/upload', data: form);
    final data = res.data;
    if (data is List) return data;
    if (data is Map && data['content'] is List) return List.from(data['content']);
    return const [];
  }

  Future<Map<String, dynamic>> getMyProfile() async {
    final res = await _dio.get('/professionnels/me');
    final data = res.data;
    if (data is Map<String, dynamic>) return data;
    return Map<String, dynamic>.from(data as Map);
  }

  Future<Map<String, dynamic>> submitProposition({
    required int projectId,
    required String titre,
    required String details,
  }) async {
    final res = await _dio.post('/professionnels/me/projets/$projectId/propositions', data: {
      'titre': titre,
      'details': details,
    });
    final data = res.data;
    if (data is Map<String, dynamic>) return data;
    return Map<String, dynamic>.from(data as Map);
  }

  Future<Map<String, dynamic>> getProjetById(int id) async {
    final res = await _dio.get('/projets/$id');
    final data = res.data;
    if (data is Map<String, dynamic>) return data;
    return Map<String, dynamic>.from(data as Map);
  }

  Future<Map<String, dynamic>> submitPropositionMultipart({
    required int professionnelId,
    required int projetId,
    required double montant,
    required String description,
    int? specialiteId,
    String? devisFilePath,
  }) async {
    final Map<String, dynamic> dataPart = {
      'montant': montant,
      'description': description,
    };
    if (specialiteId != null) dataPart['specialiteId'] = specialiteId;

    final form = FormData.fromMap({
      'data': MultipartFile.fromString(
        jsonEncode(dataPart),
        contentType: MediaType.parse('application/json'),
      ),
      if (devisFilePath != null && devisFilePath.isNotEmpty)
        'devis': await MultipartFile.fromFile(devisFilePath),
    });

    final res = await _dio.post('/professionnels/$professionnelId/projets/$projetId/propositions', data: form);
    final resp = res.data;
    if (resp is Map<String, dynamic>) return resp;
    return Map<String, dynamic>.from(resp as Map);
  }

  Future<List<dynamic>> getMyPropositions({String? statut}) async {
    final res = await _dio.get(
      '/professionnels/me/propositions',
      queryParameters: {
        if (statut != null) 'statut': statut,
      },
    );
    final data = res.data;
    if (data is List) return data;
    if (data is Map && data['content'] is List) return List.from(data['content']);
    return const [];
  }
}
