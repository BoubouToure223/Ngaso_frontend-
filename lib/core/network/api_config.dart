import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080/api/v1';
    if (Platform.isAndroid) return 'http://10.0.2.2:8080/api/v1';
    return 'http://localhost:8080/api/v1';
  }
  static String get baseOrigin {
    final uri = Uri.parse(baseUrl);
    final port = (uri.hasPort && uri.port != 0) ? ':${uri.port}' : '';
    return '${uri.scheme}://${uri.host}$port';
  }
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
}
