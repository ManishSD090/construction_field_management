import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:construction_erp/controllers/core_providers.dart';
import 'package:construction_erp/core/dio_client.dart';
import 'package:construction_erp/models/dpr.dart';

final dprControllerProvider =
    AsyncNotifierProvider<DPRController, DPRState>(() {
  return DPRController();
});

class DPRController extends AsyncNotifier<DPRState> {
  DioClient get _dioClient => ref.read(dioClientProvider);
  static const String _basePath = '/dpr';
  static const String _photoPath = '/dpr-photos';

  String _search = '';
  String? _status;
  String? _projectId;

  @override
  Future<DPRState> build() async {
    return _fetchPage(page: 1, isRefresh: true);
  }

  Future<DPRState> _fetchPage({
    required int page,
    required bool isRefresh,
  }) async {
    final response = await _dioClient.dio.get(
      _basePath,
      queryParameters: {
        'page': page,
        'limit': 10,
        if (_search.isNotEmpty) 'search': _search,
        if (_status != null) 'status': _status,
        if (_projectId != null) 'projectId': _projectId,
      },
    );

    final data = response.data;
    final List<dynamic> listJson = data['data'] ?? [];
    final pagination = data['pagination'] ?? {};

    final newDprs =
        listJson.map((json) => DailyProgressReport.fromJson(json)).toList();

    final currentPage = pagination['page'] ?? 1;
    final totalPages = pagination['pages'] ?? 1;
    final hasMore = currentPage < totalPages;

    if (isRefresh) {
      return DPRState(
        dprs: newDprs,
        currentPage: currentPage,
        hasMore: hasMore,
      );
    } else {
      final currentState = state.value;
      if (currentState == null) return build();
      return currentState.copyWith(
        dprs: [...currentState.dprs, ...newDprs],
        currentPage: currentPage,
        hasMore: hasMore,
        isLoadingMore: false,
      );
    }
  }

  Future<void> refresh({
    String? search,
    String? status,
    String? projectId,
  }) async {
    if (search != null) _search = search;
    if (status != null) _status = status;
    if (projectId != null) _projectId = projectId;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPage(page: 1, isRefresh: true));
  }

  Future<void> loadNextPage() async {
    final currentState = state.value;
    if (currentState == null || !currentState.hasMore || currentState.isLoadingMore) return;

    state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));
    state = await AsyncValue.guard(() => _fetchPage(
          page: currentState.currentPage + 1,
          isRefresh: false,
        ));
  }

  Future<DailyProgressReport> getDPRById(String id) async {
    final response = await _dioClient.dio.get('$_basePath/$id');
    return DailyProgressReport.fromJson(response.data['data']);
  }

  Future<DailyProgressReport> createDPR(Map<String, dynamic> payload) async {
    final response = await _dioClient.dio.post(_basePath, data: payload);
    final newDpr = DailyProgressReport.fromJson(response.data['data']);
    await refresh();
    return newDpr;
  }

  Future<DailyProgressReport> updateDPR(String id, Map<String, dynamic> payload) async {
    final wrappedPayload = {
      ...payload,
      'params': { 'id': id },
      'body': payload,
    };

    final response = await _dioClient.dio.put('$_basePath/$id', data: wrappedPayload);
    final updatedDpr = DailyProgressReport.fromJson(response.data['data']);
    
    await refresh();
    return updatedDpr;
  }

  Future<void> deleteDPR(String id) async {
    await _dioClient.dio.delete('$_basePath/$id');
    await refresh();
  }

  Future<DailyProgressReport> approveDPR(String id, {String status = 'COMPLETED', String? comments}) async {
    final payload = {
      'status': status,
      if (comments != null) 'comments': comments,
      
      'params': { 'id': id },
      'body': {
        'status': status,
        if (comments != null) 'comments': comments,
      }
    };

    final response = await _dioClient.dio.patch(
      '$_basePath/$id/approve',
      data: payload,
    );
    final result = DailyProgressReport.fromJson(response.data['data']);
    await refresh();
    return result;
  }

  Future<DPRPhoto> uploadDPRPhoto({
    required String dprId,
    required File file,
    String? title,
    String? description,
  }) async {
    final fileName = file.path.split('/').last;
    final formData = FormData.fromMap({
      'dprId': dprId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });
    
    final response = await _dioClient.dio.post(
      '$_photoPath/upload',
      data: formData,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
    );
    return DPRPhoto.fromJson(response.data['data']);
  }

  Future<void> uploadMultiplePhotos(String dprId, List<File> files) async {
    for (var file in files) {
      await uploadDPRPhoto(
        dprId: dprId, 
        file: file, 
        title: "Site Photo",
        description: "Uploaded from Mobile App",
      );
    }
    await refresh();
  }
}

class DPRState {
  final List<DailyProgressReport> dprs;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  const DPRState({
    required this.dprs,
    required this.currentPage,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  DPRState copyWith({
    List<DailyProgressReport>? dprs,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return DPRState(
      dprs: dprs ?? this.dprs,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

final projectsProvider = FutureProvider<List<dynamic>>((ref) async {
  final dioClient = ref.watch(dioClientProvider);
  final response = await dioClient.dio.get('/projects');
  return response.data['data'] as List<dynamic>;
});

final materialsProvider = FutureProvider<List<dynamic>>((ref) async {
  final dioClient = ref.watch(dioClientProvider);
  final response = await dioClient.dio.get('/inventory');
  return response.data['data'] as List<dynamic>;
});