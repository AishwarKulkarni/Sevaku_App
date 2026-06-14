import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../utils/token_storage.dart';

class ApiClient {
  static String get baseUrl {
    if (kIsWeb) {
      return 'https://sevakubackend-production.up.railway.app/api/v1';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'https://sevakubackend-production.up.railway.app/api/v1';
    }
    return 'https://sevakubackend-production.up.railway.app/api/v1';
  }

  final Dio _dio;

  ApiClient() : _dio = Dio(BaseOptions(baseUrl: baseUrl)) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Skip token for auth endpoints
          if (!options.path.startsWith('/auth/login') &&
              !options.path.startsWith('/auth/register')) {
            final token = await TokenStorage.getAccessToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401 &&
              !e.requestOptions.path.startsWith('/auth/refresh')) {
            // Attempt to refresh token
            final refreshToken = await TokenStorage.getRefreshToken();
            if (refreshToken != null) {
              try {
                final refreshDio = Dio(BaseOptions(baseUrl: baseUrl));
                final response = await refreshDio.post(
                  '/auth/refresh',
                  data: {'refresh_token': refreshToken},
                );

                if (response.statusCode == 200) {
                  final newAccessToken = response.data['access_token'];
                  final newRefreshToken = response.data['refresh_token'];

                  await TokenStorage.saveTokens(
                    accessToken: newAccessToken,
                    refreshToken: newRefreshToken,
                  );

                  // Retry the original request
                  final retryOptions = e.requestOptions;
                  retryOptions.headers['Authorization'] =
                      'Bearer $newAccessToken';

                  final retryResponse = await _dio.fetch(retryOptions);
                  return handler.resolve(retryResponse);
                }
              } catch (refreshError) {
                // Refresh failed, clear tokens
                await TokenStorage.clearTokens();
              }
            }
          }
          return handler.next(e);
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(responseBody: true, requestBody: true),
      );
    }
  }

  Dio get dio => _dio;
}
