import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:construction_erp/controllers/core_providers.dart';
import 'package:flutter/foundation.dart';

final payrollControllerProvider = Provider<PayrollController>((ref) {
  return PayrollController(ref);
});

class PayrollController {
  final Ref ref;
  static const String _basePath = '/payroll';
  final _storage = const FlutterSecureStorage();

  PayrollController(this.ref);

  // 🔍 Extract Auth Data (Ensures headers match backend requirements)
  Future<Map<String, String?>> _getAuthData() async {
    String? userId;
    String? companyId;

    final token = await _storage.read(key: 'access_token');
    if (token != null && !JwtDecoder.isExpired(token)) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      userId = decodedToken['userId']?.toString();
    }

    final prefs = await SharedPreferences.getInstance();
    companyId = prefs.getString('companyId') ?? prefs.getString('company_id');

    // Fallback for development if needed
    companyId ??= "72ad085f-2d70-41a9-ba58-2529a13a5798";

    return {'userId': userId, 'companyId': companyId};
  }

  // ==========================================================================
  // 1. SHIFT TYPES
  // ==========================================================================

  Future<List<dynamic>> getShiftTypes() async {
    try {
      final dio = ref.read(dioClientProvider).dio;
      final auth = await _getAuthData();

      final response = await dio.get(
        '$_basePath/shift-types',
        options: Options(headers: {
          'x-company-id': auth['companyId'],
          if (auth['userId'] != null) 'x-user-id': auth['userId'],
        }),
      );
      return response.data['data'] ?? [];
    } catch (e) {
      debugPrint("Error fetching shift types: $e");
      return [];
    }
  }

  Future<void> createShiftType(
      {required String name, required double multiplier}) async {
    final dio = ref.read(dioClientProvider).dio;
    final auth = await _getAuthData();

    await dio.post(
      '$_basePath/shift-types',
      data: {'name': name, 'multiplier': multiplier},
      options: Options(headers: {
        'x-company-id': auth['companyId'],
        if (auth['userId'] != null) 'x-user-id': auth['userId'],
      }),
    );
  }

  // ==========================================================================
  // 2. PAYROLL HISTORY (Fetches saved records for the Details Screen)
  // ==========================================================================

  Future<List<dynamic>> getSavedPayrolls({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final dio = ref.read(dioClientProvider).dio;
      final auth = await _getAuthData();

      final response = await dio.get(
        '$_basePath/', // Matches your router.get('/') in payroll.routes.js
        queryParameters: {
          if (fromDate != null) 'fromDate': fromDate.toIso8601String(),
          if (toDate != null) 'toDate': toDate.toIso8601String(),
        },
        options: Options(
          headers: {
            'x-company-id': auth['companyId'],
            if (auth['userId'] != null) 'x-user-id': auth['userId'],
          },
        ),
      );

      return response.data['data'] ?? [];
    } catch (e) {
      debugPrint("Error fetching payroll history: $e");
      return [];
    }
  }

  // ==========================================================================
  // 3. LABOUR RATES
  // ==========================================================================

  Future<void> createLabourRate({
    required String workerType,
    required String workerId,
    required double rate,
    required DateTime effectiveFrom,
  }) async {
    final dio = ref.read(dioClientProvider).dio;
    final auth = await _getAuthData();

    await dio.post(
      '$_basePath/labour-rates',
      data: {
        'workerType': workerType,
        'workerId': workerId,
        'rate': rate,
        'effectiveFrom': effectiveFrom.toIso8601String(),
      },
      options: Options(headers: {
        'x-company-id': auth['companyId'],
        if (auth['userId'] != null) 'x-user-id': auth['userId'],
      }),
    );
  }

  Future<void> bulkUpdateLabourRates({
    required List<Map<String, dynamic>> rates,
    required DateTime effectiveFrom,
    String? reason,
  }) async {
    final dio = ref.read(dioClientProvider).dio;
    final auth = await _getAuthData();

    await dio.post(
      '$_basePath/labour-rates/bulk',
      data: {
        'rates': rates,
        'effectiveFrom': effectiveFrom.toIso8601String(),
        'reason': reason,
      },
      options: Options(headers: {
        'x-company-id': auth['companyId'],
        if (auth['userId'] != null) 'x-user-id': auth['userId'],
      }),
    );
  }

  Future<List<dynamic>> getLabourRates({String? workerType, String? workerId, bool? isCurrent}) async {
    try {
      final dio = ref.read(dioClientProvider).dio;
      final auth = await _getAuthData();

      final response = await dio.get(
        '$_basePath/labour-rates',
        queryParameters: {
          if (workerType != null) 'workerType': workerType,
          if (workerId != null) 'workerId': workerId,
          if (isCurrent != null) 'isCurrent': isCurrent.toString(),
        },
        options: Options(headers: {
          'x-company-id': auth['companyId'],
          if (auth['userId'] != null) 'x-user-id': auth['userId'],
        }),
      );
      return response.data['data'] ?? [];
    } catch (e) {
      debugPrint("Error fetching labour rates: $e");
      return [];
    }
  }

  Future<void> deleteLabourRate(String id) async {
    final dio = ref.read(dioClientProvider).dio;
    final auth = await _getAuthData();

    await dio.delete(
      '$_basePath/labour-rates/$id',
      options: Options(headers: {
        'x-company-id': auth['companyId'],
        if (auth['userId'] != null) 'x-user-id': auth['userId'],
      }),
    );
  }

  Future<void> bulkDeleteLabourRates(List<String> ids) async {
    final dio = ref.read(dioClientProvider).dio;
    final auth = await _getAuthData();

    await dio.post(
      '$_basePath/labour-rates/bulk-delete',
      data: {'ids': ids},
      options: Options(headers: {
        'x-company-id': auth['companyId'],
        if (auth['userId'] != null) 'x-user-id': auth['userId'],
      }),
    );
  }

  Future<void> bulkDeleteShiftTypes(List<String> ids) async {
    final dio = ref.read(dioClientProvider).dio;
    final auth = await _getAuthData();

    await dio.post(
      '$_basePath/shift-types/bulk-delete',
      data: {'ids': ids},
      options: Options(headers: {
        'x-company-id': auth['companyId'],
        if (auth['userId'] != null) 'x-user-id': auth['userId'],
      }),
    );
  }

  // ==========================================================================
  // 4. CALCULATION & CREATION
  // ==========================================================================

  Future<Map<String, dynamic>?> calculatePayroll({
    required DateTime periodFrom,
    required DateTime periodTo,
    String? projectId,
  }) async {
    try {
      final dio = ref.read(dioClientProvider).dio;
      final auth = await _getAuthData();

      final response = await dio.post(
        '$_basePath/calculate',
        data: {
          'periodFrom': periodFrom.toIso8601String(),
          'periodTo': periodTo.toIso8601String(),
          if (projectId != null) 'projectId': projectId,
        },
        options: Options(headers: {
          'x-company-id': auth['companyId'],
          if (auth['userId'] != null) 'x-user-id': auth['userId'],
        }),
      );
      return response.data['data'];
    } catch (e) {
      debugPrint("Error calculating payroll: $e");
      return null;
    }
  }

  Future<void> createPayroll(Map<String, dynamic> payload) async {
    final dio = ref.read(dioClientProvider).dio;
    final auth = await _getAuthData();

    await dio.post(
      '$_basePath/',
      data: payload,
      options: Options(headers: {
        'x-company-id': auth['companyId'],
        if (auth['userId'] != null) 'x-user-id': auth['userId'],
      }),
    );
  }

  Future<void> deleteShiftType(String id) async {
    try {
      final dio = ref.read(dioClientProvider).dio;
      final auth = await _getAuthData();

      await dio.delete(
        '$_basePath/shift-types/$id',
        options: Options(
          headers: {
            'x-company-id': auth['companyId'],
            if (auth['userId'] != null) 'x-user-id': auth['userId'],
          },
        ),
      );
    } catch (e) {
      debugPrint("Error deleting shift type: $e");
      // Rethrow so the UI can catch it and show an error SnackBar
      rethrow;
    }
  }
}
