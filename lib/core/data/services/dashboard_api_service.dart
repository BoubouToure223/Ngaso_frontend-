import 'package:dio/dio.dart';
import '../../network/dio_client.dart';

class DashboardApiService {
  final Dio _dio = DioClient.I.dio;

  Future<Map<String, dynamic>> getNoviceDashboard() async {
    // Backend endpoint (prefixed by ApiConfig.baseUrl e.g. /api/v1)
    final res = await _dio.get('/novices/me/dashboard');
    return Map<String, dynamic>.from(res.data as Map);
  }
}
