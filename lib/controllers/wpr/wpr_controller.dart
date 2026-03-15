import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_erp/core/dio_client.dart';
import 'package:construction_erp/controllers/core_providers.dart';
import 'package:construction_erp/models/wpr.dart';

final wprControllerProvider = AsyncNotifierProvider<WPRController, List<WeeklyProgressReport>>(() {
  return WPRController();
});

class WPRController extends AsyncNotifier<List<WeeklyProgressReport>> {
  DioClient get _dioClient => ref.read(dioClientProvider);
  static const String _basePath = '/wpr';

  @override
  Future<List<WeeklyProgressReport>> build() async {
    return _fetchWPRs();
  }

  Future<List<WeeklyProgressReport>> _fetchWPRs() async {
    final response = await _dioClient.dio.get(_basePath);
    final List<dynamic> data = response.data['data'] ?? [];
    return data.map((json) => WeeklyProgressReport.fromJson(json)).toList();
  }

  /// Fetches the summary of the last 7 days to pre-fill the Create WPR screen
  Future<Map<String, dynamic>> getWeeklyPreview(String projectId, DateTime date) async {
    final response = await _dioClient.dio.get(
      '$_basePath/preview',
      queryParameters: {
        'projectId': projectId,
        'date': date.toIso8601String(),
      },
    );
    return response.data['data'];
  }

  Future<void> createWPR(Map<String, dynamic> payload) async {
    state = const AsyncValue.loading();
    await _dioClient.dio.post(_basePath, data: payload);
    state = await AsyncValue.guard(() => _fetchWPRs());
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchWPRs());
  }
}