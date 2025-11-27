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
        final token = await TokenStorage.instance.readAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (e, handler) async {
        // Log plus détaillé pour diagnostiquer les erreurs réseau
        // (status, data de la réponse et erreur sous-jacente si présente)
        // Ces logs seront visibles via PrettyDioLogger déjà activé.
        // ignore: avoid_print
        print('[DioError] status=${e.response?.statusCode} data=${e.response?.data} error=${e.error}');

        final statusCode = e.response?.statusCode;
        final requestPath = e.requestOptions.path;
        final isAuthEndpoint = requestPath.endsWith('/auth/login') || requestPath.endsWith('/auth/refresh');
        final alreadyRetried = e.requestOptions.extra['__retried__'] == true;

        // Tentative de refresh uniquement pour les 401 sur endpoints protégés, une seule fois
        if (statusCode == 401 && !isAuthEndpoint && !alreadyRetried) {
          try {
            final refreshToken = await TokenStorage.instance.readRefreshToken();
            if (refreshToken == null || refreshToken.isEmpty) {
              return handler.next(e);
            }

            final refreshResponse = await _dio.post(
              '/auth/refresh',
              data: {'refreshToken': refreshToken},
            );

            if (refreshResponse.data is Map) {
              final body = refreshResponse.data as Map;
              final newAccess = body['token'] as String?;
              final newRefresh = body['refreshToken'] as String?;
              if (newAccess != null && newAccess.isNotEmpty) {
                await TokenStorage.instance.saveTokens(accessToken: newAccess, refreshToken: newRefresh);

                // Rejouer la requête initiale avec le nouveau token
                final opts = e.requestOptions;
                opts.headers['Authorization'] = 'Bearer $newAccess';
                opts.extra['__retried__'] = true;
                final cloneResponse = await _dio.fetch(opts);
                return handler.resolve(cloneResponse);
              }
            }
          } catch (_) {
            // En cas d'échec du refresh, on laisse passer l'erreur originale
          }
        }

        handler.next(e);
      },
    ));

    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: false,
      responseBody: false,
      responseHeader: false,
      compact: true,
      logPrint: (obj) {
        final s = obj.toString();
        if (s.length > 1000) return; // skip very long lines (e.g., binary)
        // ignore: avoid_print
        print(s);
      },
    ));
  }

  static final DioClient I = DioClient._internal();
  late final Dio _dio;
  Dio get dio => _dio;
}
