import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'api_config.dart';
import '../storage/token_storage.dart';

class DioClient {
  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await TokenStorage.instance.readToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (e, handler) {
        // Log plus détaillé pour diagnostiquer les erreurs réseau
        // (status, data de la réponse et erreur sous-jacente si présente)
        // Ces logs seront visibles via PrettyDioLogger déjà activé.
        // ignore: avoid_print
        print('[DioError] status=${e.response?.statusCode} data=${e.response?.data} error=${e.error}');
        handler.next(e);
      },
    ));

    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: true,
    ));
  }

  static final DioClient I = DioClient._internal();
  late final Dio _dio;
  Dio get dio => _dio;
}
