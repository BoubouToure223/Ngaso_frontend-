import 'dart:convert';
import 'package:dio/dio.dart';
import '../../network/dio_client.dart';
import 'package:http_parser/http_parser.dart';

class AuthApiService {
  final Dio _dio = DioClient.I.dio;

  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    final response = await _dio.post('/auth/login', data: {
      'telephone': email,
      'password': password,
    });
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> registerNovice(Map<String, dynamic> body) async {
    final response = await _dio.post('/auth/register/novice', data: body);
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Response> registerProfessionnel({required Map<String, dynamic> data, MultipartFile? document}) async {
    // Backend Spring: @RequestPart("data") (JSON) et @RequestPart("document") (fichier)
    final formData = FormData();
    final jsonPart = MultipartFile.fromString(
      jsonEncode(data),
      filename: 'data.json',
      contentType: MediaType('application', 'json'),
    );
    formData.files.add(MapEntry('data', jsonPart));
    if (document != null) {
      formData.files.add(MapEntry('document', document));
    }
    return _dio.post('/auth/register/professionnel', data: formData);
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await _dio.post(
      '/auth/change-password',
      data: {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
      },
      options: Options(responseType: ResponseType.plain),
    );
  }
}
