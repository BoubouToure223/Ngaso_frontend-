import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:myapp/core/data/models/user_me_response.dart';
import '../../network/dio_client.dart';
import '../models/pro_dashboard.dart';
import '../models/app_notification.dart';

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

  Future<List<dynamic>> deleteMyRealisationById(String realisationId) async {
    final res = await _dio.delete('/professionnels/me/realisations/$realisationId');
    final data = res.data;
    if (data is List) return data;
    if (data is Map && data['content'] is List) return List.from(data['content']);
    return const [];
  }

  Future<UserMeResponse> getUserMe() async {
    final res = await _dio.get('/users/me');
    final data = res.data;
    if (data is Map<String, dynamic>) return UserMeResponse.fromJson(data);
    if (data is Map) return UserMeResponse.fromJson(Map<String, dynamic>.from(data));
    return const UserMeResponse();
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

  Future<Map<String, dynamic>> getProfessionnelProfil(int id) async {
    final res = await _dio.get('/professionnels/$id/profil');
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

  Future<List<dynamic>> getMyDemandes({String? statut}) async {
    final res = await _dio.get(
      '/professionnels/me/demandes',
      queryParameters: {
        if (statut != null) 'statut': statut,
      },
    );
    final data = res.data;
    if (data is List) return data;
    if (data is Map && data['content'] is List) return List.from(data['content']);
    return const [];
  }

  Future<void> validateDemande(int demandeId) async {
    await _dio.post('/professionnels/me/demandes/$demandeId/validate');
  }

  Future<void> refuseDemande(int demandeId) async {
    await _dio.post('/professionnels/me/demandes/$demandeId/refuse');
  }

  Future<List<dynamic>> getMyConversations() async {
    final res = await _dio.get('/conversations/me');
    final data = res.data;
    if (data is List) return data;
    if (data is Map && data['content'] is List) return List.from(data['content']);
    return const [];
  }

  Future<List<dynamic>> getMyNovicePropositions() async {
    final res = await _dio.get('/novices/me/propositions');
    final data = res.data;
    if (data is List) return data;
    if (data is Map && data['content'] is List) return List.from(data['content']);
    return const [];
  }

  Future<Map<String, dynamic>> acceptMyNoviceProposition(int propositionId) async {
    final res = await _dio.post('/novices/me/propositions/$propositionId/accepter');
    final data = res.data;
    if (data is Map<String, dynamic>) return data;
    return Map<String, dynamic>.from(data as Map);
  }

  Future<Map<String, dynamic>> refuseMyNoviceProposition(int propositionId) async {
    final res = await _dio.post('/novices/me/propositions/$propositionId/refuser');
    final data = res.data;
    if (data is Map<String, dynamic>) return data;
    return Map<String, dynamic>.from(data as Map);
  }

  Future<List<AppNotification>> getMyNotifications() async {
    final res = await _dio.get('/notifications/me');
    final data = res.data;
    if (data is List) {
      return data
          .map((e) => AppNotification.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(growable: false);
    }
    if (data is Map && data['content'] is List) {
      return List.from(data['content'])
          .map((e) => AppNotification.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(growable: false);
    }
    return const [];
  }

  Future<int> getMyNotificationsCount() async {
    final res = await _dio.get('/notifications/me/count');
    final data = res.data;
    int? parseDynamic(dynamic v) {
      if (v is int) return v;
      if (v is String) return int.tryParse(v);
      if (v is Map) {
        for (final k in ['count', 'unread', 'unreadCount', 'nonLu', 'nonLus', 'nonLues', 'value']) {
          if (v.containsKey(k)) {
            final r = parseDynamic(v[k]);
            if (r != null) return r;
          }
        }
        if (v.containsKey('data')) {
          final r = parseDynamic(v['data']);
          if (r != null) return r;
        }
      }
      if (v is List) return v.length;
      return null;
    }
    return parseDynamic(data) ?? 0;
  }

  Future<void> markAllNotificationsRead() async {
    await _dio.post('/notifications/me/read');
  }

  Future<List<dynamic>> getConversationMessages({
    required int conversationId,
    int page = 0,
    int size = 20,
  }) async {
    final res = await _dio.get(
      '/conversations/$conversationId/messages',
      queryParameters: {'page': page, 'size': size},
    );
    final data = res.data;
    if (data is List) return data;
    if (data is Map && data['content'] is List) return List.from(data['content']);
    return const [];
  }

  Future<Map<String, dynamic>> sendConversationMessage({
    required int conversationId,
    required String content,
  }) async {
    final res = await _dio.post(
      '/conversations/$conversationId/messages',
      data: {'content': content},
    );
    final data = res.data;
    if (data is Map<String, dynamic>) return data;
    return Map<String, dynamic>.from(data as Map);
  }

  Future<Map<String, dynamic>> sendConversationAttachment({
    required int conversationId,
    required String filePath,
    String? fileName,
    String? mimeType,
    String? content,
  }) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: fileName,
        contentType: mimeType != null ? MediaType.parse(mimeType) : null,
      ),
      if (content != null) 'content': content,
    });
    final res = await _dio.post('/conversations/$conversationId/messages/upload', data: form);
    final data = res.data;
    if (data is Map<String, dynamic>) return data;
    return Map<String, dynamic>.from(data as Map);
  }
}
