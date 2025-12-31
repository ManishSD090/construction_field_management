import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

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

  // 2. Configuration
  void _configureDio() {
    // Base options for all requests
    _dio.options = BaseOptions(
      baseUrl: 'https://api.yourbackend.com/v1', // Replace with your URL
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
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

    // Optional: Add an interceptor for Auth Tokens
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // e.g., String token = await Storage.getToken();
        // options.headers['Authorization'] = 'Bearer $token';
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        if (e.response?.statusCode == 401) {
          // Handle token expiry (e.g., logout user)
        }
        return handler.next(e);
      },
    ));
  }

  // 4. Expose the Dio instance
  Dio get dio => _dio;
}
