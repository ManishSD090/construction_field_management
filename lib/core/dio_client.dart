import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

// Import your SecureStorageService
import 'package:construction_erp/core/services/secure_storage_service.dart';

class DioClient {
  // 1. Singleton pattern
  static final DioClient _instance = DioClient._internal();
  static final Dio _dio = Dio();

  factory DioClient() {
    return _instance;
  }

  DioClient._internal() {
    _configureDio();
  }

  String getBaseUrl() {
    if (Platform.isAndroid) {
      return "http://10.0.2.2:5000/api/v1";
    }

    if (Platform.isIOS) {
      return "http://localhost:5000/api/v1";
    }

    // Fallback
    return "http://localhost:5000/api/v1";
  }

  // 2. Configuration
  void _configureDio() {
    // Base options for all requests
    _dio.options = BaseOptions(
      baseUrl: getBaseUrl(),
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    // 3. Interceptors (Logging & Auth)
    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 90,
    ));

    // Auth Interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // A. Instantiate Storage Service
        // Since DioClient is a singleton, we create the storage instance here
        // to ensure we get the latest state/reference.
        final storage = SecureStorageService();

        // B. Get Token
        final token = await storage.getAccessToken();

        // C. Attach to Header if token exists
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        return handler.next(options);
      },
      onError: (DioException e, handler) {
        if (e.response?.statusCode == 401) {
          // TODO: Handle 401 (Token Expired)
          // Usually trigger a refresh token flow or force logout here
        }
        return handler.next(e);
      },
    ));
  }

  // 4. Expose the Dio instance
  Dio get dio => _dio;
}
