import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:construction_erp/controllers/core_providers.dart';
import 'package:construction_erp/models/worker.dart';
import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:intl/intl.dart';

final workerControllerProvider =
    AsyncNotifierProvider<WorkerController, List<Worker>>(() {
  return WorkerController();
});

class WorkerController extends AsyncNotifier<List<Worker>> {
  static const String _basePath = '/workers';
  final _storage = const FlutterSecureStorage();

  // 🔍 Extract Auth Data from Token & SharedPreferences
  Future<Map<String, String?>> _getAuthData() async {
    String? userId;
    String? companyId;

    // 1. Get userId from Token
    final token = await _storage.read(key: 'access_token');
    if (token != null && !JwtDecoder.isExpired(token)) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      userId = decodedToken['userId']?.toString();
    }

    // 2. Many apps save the user object in SharedPreferences instead of SecureStorage
    final prefs = await SharedPreferences.getInstance();

    // Attempt to read from common SharedPreferences keys
    final companyIdFromPrefs =
        prefs.getString('companyId') ?? prefs.getString('company_id');

    if (companyIdFromPrefs != null) {
      companyId = companyIdFromPrefs;
    } else {
      // 🚨 TEMPORARY FALLBACK 🚨
      print(
          "⚠️ WARNING: USING HARDCODED COMPANY ID. PLEASE LOCATE YOUR AUTH PROVIDER.");
      companyId = "72ad085f-2d70-41a9-ba58-2529a13a5798";
    }

    return {
      'userId': userId,
      'companyId': companyId,
    };
  }

  @override
  Future<List<Worker>> build() async {
    return fetchWorkersForAttendance();
  }

  // ==========================================================================
  // 1. FETCH WORKERS
  // ==========================================================================
  Future<List<Worker>> fetchWorkersForAttendance({
    String? projectId,
    String? search,
  }) async {
    try {
      final dio = ref.read(dioClientProvider).dio;
      final auth = await _getAuthData();

      final response = await dio.get(
        '$_basePath/site-staff',
        queryParameters: {
          'companyId': auth['companyId'],
          if (projectId != null) 'projectId': projectId,
          if (search != null && search.isNotEmpty) 'search': search,
        },
        options: Options(
          headers: {
            'x-company-id': auth['companyId'],
            if (auth['userId'] != null) 'x-user-id': auth['userId'],
          },
        ),
      );

      final List<dynamic> data = response.data['data'] ?? [];
      final workers = data.map((json) => Worker.fromJson(json)).toList();

      state = AsyncValue.data(workers);
      return workers;
    } catch (e, stack) {
      print("FETCH ERROR: $e");
      state = AsyncValue.error(e, stack);
      return [];
    }
  }

  // ==========================================================================
  // 2. SUBMIT BULK ATTENDANCE
  // ==========================================================================
  Future<void> submitBulkAttendance({
    required String projectId,
    required DateTime date,
    required List<Map<String, dynamic>> attendanceData,
  }) async {
    final dio = ref.read(dioClientProvider).dio;
    final auth = await _getAuthData();

    // 🚨 FIX: Convert the date to a plain YYYY-MM-DD string.
    // This prevents the backend from shifting the date due to timezone offsets.
    String dateOnly = DateFormat('yyyy-MM-dd').format(date);

    final response = await dio.post(
      '$_basePath/attendance/bulk',
      data: {
        'projectId': projectId,
        'date': dateOnly, // ✅ Sent as "2026-03-14"
        'attendanceData': attendanceData,
        'companyId': auth['companyId'],
      },
      options: Options(
        headers: {
          'x-company-id': auth['companyId'],
          if (auth['userId'] != null) 'x-user-id': auth['userId'],
        },
      ),
    );

    final responseData = response.data;
    // Handle partial success
    if (responseData['summary'] != null &&
        responseData['summary']['successful'] == 0) {
      throw Exception(responseData['errors']?[0]?['error'] ?? 'Failed to save');
    }

    ref.invalidateSelf();
  }

  // ==========================================================================
  // 3. CREATE WORKER (With Zod Sanitization)
  // ==========================================================================
  Future<void> createWorker({
    required Map<String, dynamic> fields,
    String? profilePath,
    String? aadharPath,
  }) async {
    final dio = ref.read(dioClientProvider).dio;
    final auth = await _getAuthData();

    // Sanitize to prevent Zod/Prisma Unique Constraint crashes
    final Map<String, dynamic> cleanFields = {};
    fields.forEach((key, value) {
      if (value != null && value.toString().trim().isNotEmpty) {
        cleanFields[key] = value;
      }
    });

    final formData = FormData.fromMap({
      ...cleanFields,
      'status': 'ACTIVE',
      'companyId': auth['companyId'],
      if (auth['userId'] != null) 'userId': auth['userId'],
    });

    if (profilePath != null) {
      formData.files.add(MapEntry('profilePicture',
          await MultipartFile.fromFile(profilePath, filename: 'profile.jpg')));
    }
    if (aadharPath != null) {
      formData.files.add(MapEntry('aadharCopy',
          await MultipartFile.fromFile(aadharPath, filename: 'aadhar.jpg')));
    }

    await dio.post(
      '$_basePath/site-staff',
      data: formData,
      options: Options(
        headers: {
          'x-company-id': auth['companyId'],
          if (auth['userId'] != null) 'x-user-id': auth['userId'],
        },
      ),
    );

    ref.invalidateSelf();
  }

  // ==========================================================================
  // 4. DELETE WORKER
  // ==========================================================================
  Future<void> deleteWorker(String id) async {
    final dio = ref.read(dioClientProvider).dio;
    final auth = await _getAuthData();

    await dio.delete(
      '$_basePath/site-staff/$id',
      options: Options(
        headers: {
          'x-company-id': auth['companyId'],
          if (auth['userId'] != null) 'x-user-id': auth['userId'],
        },
      ),
    );
    ref.invalidateSelf();
  }

  // ==========================================================================
  // 5. GET SAVED ATTENDANCE
  // ==========================================================================
  Future<List<dynamic>> getSavedAttendance({
    required String projectId,
    required DateTime date,
  }) async {
    try {
      final dio = ref.read(dioClientProvider).dio;
      final auth = await _getAuthData();

      // Format date to YYYY-MM-DD
      final dateString = date.toIso8601String().split('T')[0];

      final response = await dio.get(
        '$_basePath/attendance',
        queryParameters: {
          'projectId': projectId,
          'startDate': dateString,
          'endDate': dateString,
          // 🚨 ADDED THIS LINE: The backend crashes if this isn't in the URL 🚨
          if (auth['companyId'] != null) 'companyId': auth['companyId'],
        },
        options: Options(
          headers: {
            if (auth['companyId'] != null) 'x-company-id': auth['companyId'],
            if (auth['userId'] != null) 'x-user-id': auth['userId'],
          },
        ),
      );

      return response.data['data'] ?? [];
    } catch (e) {
      print("FETCH ATTENDANCE ERROR: $e");
      return [];
    }
  }

  // ==========================================================================
  // 6. FETCH SYSTEM STAFF (From User / Employee Table)
  // ==========================================================================
  Future<List<Worker>> fetchSystemStaff() async {
    try {
      final dio = ref.read(dioClientProvider).dio;
      final auth = await _getAuthData();

      // Hit the user/employee endpoint
      // 🚨 NOTE: Check your Node.js routes file. This might be '/users' or '/employees'
      final response = await dio.get(
        '/users',
        queryParameters: {
          'limit':
              100, // Fetch up to 100 people so the dropdown is fully populated
          'status': 'active' // Only get active employees
        },
        options: Options(
          headers: {
            if (auth['companyId'] != null) 'x-company-id': auth['companyId'],
            if (auth['userId'] != null) 'x-user-id': auth['userId'],
          },
        ),
      );

      final List<dynamic> data = response.data['data'] ?? [];

// Change the mapping logic to be null-safe
      return data.map<Worker>((json) {
        // Ensure the ID is never null
        final String safeId = json['id']?.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString();

        return Worker(
          id: safeId,
          name: json['name']?.toString() ?? 'Unknown',
          workerId: json['employeeId']?.toString() ?? safeId.substring(0, 8),
          designation: json['designation']?.toString() ??
              json['role']?['name'] ??
              'Staff',
          dailyWageRate: (json['salary'] as num?)?.toDouble() ?? 0.0,
        );
      }).toList();
    } catch (e) {
      print("FETCH STAFF ERROR: $e");
      return [];
    }
  }
}
