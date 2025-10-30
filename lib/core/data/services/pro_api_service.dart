import 'package:dio/dio.dart';
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
    if (data is Map && data['content'] is List) return List.from(data['content']);
    return const [];
  }

  Future<List<dynamic>> getMyRealisationsItems() async {
    final res = await _dio.get('/professionnels/me/realisations/items');
    final data = res.data;
    if (data is List) return data;
    if (data is Map && data['content'] is List) return List.from(data['content']);
    return const [];
  }
}
