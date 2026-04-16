import 'dart:async';
import 'package:flutter/material.dart';
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

  Future<Map<String, String?>> getAuthData() async {
    String? userId;
    String? companyId;

    final token = await _storage.read(key: 'access_token');
    if (token != null && !JwtDecoder.isExpired(token)) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      userId = decodedToken['userId']?.toString();
    }

    final prefs = await SharedPreferences.getInstance();
    companyId = prefs.getString('companyId') ?? prefs.getString('company_id');

    companyId ??= "72ad085f-2d70-41a9-ba58-2529a13a5798";

    return {
      'userId': userId,
      'companyId': companyId,
    };
  }

  @override
  Future<List<Worker>> build() async {
    return fetchWorkersForAttendance();
  }

  Future<List<Worker>> fetchWorkersForAttendance({
    String? projectId,
    String? search,
    DateTime? date,
  }) async {
    try {
      final dio = ref.read(dioClientProvider).dio;
      final auth = await getAuthData();

      final response = await dio.get(
        '$_basePath/site-staff',
        queryParameters: {
          'companyId': auth['companyId'],
          if (projectId != null) 'projectId': projectId,
          if (search != null && search.isNotEmpty) 'search': search,
          if (date != null) 'atDate': date.toIso8601String(),
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
      debugPrint("FETCH ERROR: $e");
      state = AsyncValue.error(e, stack);
      return [];
    }
  }

// Add this inside WorkerController class
// 2. PERMANENTLY ASSIGN WORKER TO DB
  Future<void> assignWorkerToProject(String workerId, String projectId) async {
    if (projectId.isEmpty || workerId.isEmpty) {
      throw Exception("Project ID or Worker ID is missing");
    }

    final dio = ref.read(dioClientProvider).dio;
    final auth = await getAuthData();
    try {
      // 🔥 UPDATED ROUTE TO MATCH BACKEND EXACTLY
      await dio.post(
        '$_basePath/site-staff/$workerId/projects/$projectId/assign',
        data: {
          'startDate': DateTime.now().toIso8601String(),
          'companyId': auth['companyId'],
        },
        options: Options(headers: {
          'x-company-id': auth['companyId'],
          if (auth['userId'] != null) 'x-user-id': auth['userId'],
        }),
      );
    } on DioException catch (e) {
      // If already assigned, backend sends 400. Safely ignore it so flow continues.
      if (e.response?.statusCode == 400 &&
          e.response?.data['message']?.contains('already assigned') == true) {
        debugPrint("Worker already assigned, skipping.");
        return;
      }
      throw Exception(e.response?.data['message'] ?? "Assignment failed");
    }
  }

  Future<void> submitBulkAttendance({
    required String projectId,
    required DateTime date,
    required List<Map<String, dynamic>> attendanceData,
  }) async {
    final dio = ref.read(dioClientProvider).dio;
    final auth = await getAuthData();
    String dateOnly = DateFormat("yyyy-MM-dd'T'00:00:00").format(date);

    final response = await dio.post(
      '$_basePath/attendance/bulk',
      data: {
        'projectId': projectId,
        'date': dateOnly,
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
    if (responseData['summary'] != null &&
        responseData['summary']['successful'] == 0) {
      throw Exception(responseData['errors']?[0]?['error'] ?? 'Failed to save');
    }
    ref.invalidateSelf();
  }

  Future<void> createWorker({
    required Map<String, dynamic> fields,
    String? profilePath,
    String? aadharPath,
  }) async {
    final dio = ref.read(dioClientProvider).dio;
    final auth = await getAuthData();

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

  Future<void> deleteWorker(String id) async {
    final dio = ref.read(dioClientProvider).dio;
    final auth = await getAuthData();

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

  Future<List<dynamic>> getSavedAttendance({
    required String projectId,
    required DateTime date,
  }) async {
    try {
      final dio = ref.read(dioClientProvider).dio;
      final auth = await getAuthData();
      final dateString = date.toIso8601String().split('T')[0];

      final response = await dio.get(
        '$_basePath/attendance',
        queryParameters: {
          'projectId': projectId,
          'startDate': dateString,
          'endDate': dateString,
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
      return [];
    }
  }

  Future<List<Worker>> fetchSystemStaff() async {
    try {
      final dio = ref.read(dioClientProvider).dio;
      final auth = await getAuthData();

      final response = await dio.get(
        '/users',
        queryParameters: {'limit': 100, 'status': 'active'},
        options: Options(
          headers: {
            if (auth['companyId'] != null) 'x-company-id': auth['companyId'],
            if (auth['userId'] != null) 'x-user-id': auth['userId'],
          },
        ),
      );

      final List<dynamic> data = response.data['data'] ?? [];
      return data.map<Worker>((json) {
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
      return [];
    }
  }
}
