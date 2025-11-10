import 'package:dio/dio.dart';
import 'package:myapp/core/network/dio_client.dart';

class NotificationApiService {
  final Dio _dio = DioClient.I.dio;

  Future<List<Map<String, dynamic>>> listMy() async {
    final res = await _dio.get('/notifications/me');
    final data = res.data;
    if (data == null) return const [];
    if (data is List) {
      return data
          .where((e) => e is Map)
          .map<Map<String, dynamic>>((e) => e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map))
          .toList(growable: false);
    }
    if (data is Map && data['content'] is List) {
      final list = data['content'] as List;
      return list
          .where((e) => e is Map)
          .map<Map<String, dynamic>>((e) => e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map))
          .toList(growable: false);
    }
    return const [];
  }

  Future<int> countUnread() async {
    final res = await _dio.get('/notifications/me/count');
    final data = res.data;
    if (data is Map && data['unread'] != null) {
      final v = data['unread'];
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
    }
    return 0;
  }

  Future<void> markAllRead() async {
    await _dio.post('/notifications/me/read');
  }
}
