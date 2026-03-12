import 'dart:async'; // Required for Completer
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

// Import your SecureStorageService
import 'package:construction_erp/core/services/secure_storage_service.dart';

class DioClient {
  // 1. Singleton pattern
  static final DioClient _instance = DioClient._internal();
  static final Dio _dio = Dio();

  // --- REFRESH TOKEN STATE ---
  bool _isRefreshing = false;
  Completer<void>? _refreshCompleter;

  factory DioClient() {
    return _instance;
  }

  DioClient._internal() {
    _configureDio();
  }

  String getBaseUrl() {
    if (Platform.isAndroid) {
      // Do not change the URL, comment it out if needed.
      // return "http://172.16.2.21:5000/api/v1";
      // return "http://192.168.1.7:5000/api/v1";
      return "http://10.0.2.2:5000/api/v1";
    }
    if (Platform.isIOS) {
      return "http://172.16.30.217:5001/api/v1";
    }
    return "http://localhost:5001/api/v1";
  }

  // 2. Configuration
  void _configureDio() {
    _dio.options = BaseOptions(
      baseUrl: getBaseUrl(),
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 90,
    ));

    // 3. Auth Interceptor with Refresh Logic
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final storage = SecureStorageService();
        final token = await storage.getAccessToken();

        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        // A. Handle 401 Unauthorized
        if (e.response?.statusCode == 401) {
          // 1. SAFETY CHECK: If the failing request IS the refresh token request,
          // we are in a loop or the refresh token is expired. Fail immediately.
          if (e.requestOptions.path.contains('/auth/refresh-token')) {
            return handler.next(e);
          }

          // 2. LOCKING: If a refresh is already in progress, wait for it to finish.
          if (_isRefreshing) {
            if (_refreshCompleter != null) {
              await _refreshCompleter!.future;
            }
            // After the other request refreshed the token, retry this one
            return _retryRequest(e, handler);
          }

          // 3. START REFRESH
          _isRefreshing = true;
          _refreshCompleter = Completer<void>();

          try {
            final newAccessToken = await _performRefreshToken();

            if (newAccessToken != null) {
              // Refresh Successful: Complete the lock
              _refreshCompleter?.complete();
              _isRefreshing = false;

              // Retry the original failed request
              return _retryRequest(e, handler);
            } else {
              // Refresh returned no token
              _refreshCompleter?.completeError("No token returned");
              _isRefreshing = false;
              return handler.next(e);
            }
          } catch (refreshError) {
            // Refresh Failed (Network error or Expired Refresh Token)
            _refreshCompleter?.completeError(refreshError);
            _isRefreshing = false;
            // Propagate the error so the UI (AuthController) can logout
            return handler.next(e);
          }
        }

        return handler.next(e);
      },
    ));
  }

  /// Helper: Calls API to refresh token
  Future<String?> _performRefreshToken() async {
    final storage = SecureStorageService();
    final refreshToken =
        await storage.getRefreshToken(); // Ensure this method exists

    if (refreshToken == null) {
      throw DioException(
        requestOptions: RequestOptions(path: '/auth/refresh-token'),
        error: "No refresh token available",
      );
    }

    // Use a separate, clean Dio instance to avoid interceptor recursion
    final tokenDio = Dio(BaseOptions(baseUrl: getBaseUrl()));

    // Call your refresh endpoint
    final response = await tokenDio.post('/auth/refresh-token', data: {
      'refreshToken': refreshToken,
    });

    // Parse the new Access Token
    // Adjust json path: response.data['data']['accessToken'] or similar
    final newAccessToken = response.data['data']['tokens']['accessToken'];
    final newRefreshToken = response.data['data']['tokens']
        ['refreshToken']; // Optional: if API rotates refresh tokens

    // Save tokens
    await storage.saveTokens(
      accessToken: newAccessToken,
      refreshToken:
          newRefreshToken ?? refreshToken, // Keep old if new one not provided
    );

    return newAccessToken;
  }

  /// Helper: Retries the original request with the new token
  Future<void> _retryRequest(
      DioException e, ErrorInterceptorHandler handler) async {
    final storage = SecureStorageService();
    final newToken = await storage.getAccessToken();

    // Update header
    final options = e.requestOptions;
    options.headers['Authorization'] = 'Bearer $newToken';

    try {
      // Retry request
      final response = await _dio.fetch(options);
      return handler.resolve(response);
    } on DioException catch (retryError) {
      return handler.next(retryError);
    }
  }

  // 4. Expose the Dio instance
  Dio get dio => _dio;
}
