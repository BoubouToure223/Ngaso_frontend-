import 'package:dio/dio.dart';
import '../../network/dio_client.dart';

class UserApiService {
  final Dio _dio = DioClient.I.dio;

  Future<Map<String, dynamic>> getMe() async {
    final res = await _dio.get('/users/me');
    return Map<String, dynamic>.from(res.data as Map);
  }
}
