import 'dart:convert';
import 'package:dio/dio.dart';
import '../../network/dio_client.dart';
import '../models/specialite.dart';


class PublicApiService {
  final Dio _dio = DioClient.I.dio;
  static List<Specialite>? _cachedSpecialites;
  static DateTime? _cachedAt;
  static const Duration _cacheTtl = Duration(minutes: 10);

  Future<List<Specialite>> getSpecialites({bool forceRefresh = false}) async {
    // Retourne le cache si valide
    if (!forceRefresh && _cachedSpecialites != null) {
      final isFresh = _cachedAt != null && DateTime.now().difference(_cachedAt!) < _cacheTtl;
      if (isFresh) return _cachedSpecialites!;
    }
    final res = await _dio.get('/admin/specialites');
    dynamic data = res.data;
    if (data == null) return <Specialite>[];
    if (data is String) {
      if (data.trim().isEmpty) return <Specialite>[];
      try {
        data = json.decode(data);
      } catch (_) {
        throw Exception('Réponse non JSON pour les spécialités');
      }
    }
    if (data is List) {
      final list = data.map((e) => Specialite.fromJson(e)).toList();
      _cachedSpecialites = list;
      _cachedAt = DateTime.now();
      return list;
    }
    if (data is Map && data['content'] is List) {
      final list = (data['content'] as List).map((e) => Specialite.fromJson(e)).toList();
      _cachedSpecialites = list;
      _cachedAt = DateTime.now();
      return list;
    }
    return <Specialite>[];
  }
}
