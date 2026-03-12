import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_erp/core/dio_client.dart';
import 'package:construction_erp/models/timeline.dart';
import 'package:construction_erp/models/enums.dart';
import 'package:construction_erp/controllers/core_providers.dart';

// --- WRAPPER CLASS ---
// This ensures Base Timelines and Timeline Versions get SEPARATE cards in the UI
class TimelineApprovalItem {
  final Timeline timeline;
  final TimelineVersion? version; // If null, it's a Base Timeline. If provided, it's a Version.

  TimelineApprovalItem({required this.timeline, this.version});
}

// ==========================================================================
// 1. FETCH PROVIDERS (For displaying lists in the UI)
// ==========================================================================

final pendingTimelinesProvider = FutureProvider.autoDispose<List<TimelineApprovalItem>>((ref) async {
  final dioClient = ref.read(dioClientProvider);
  
  final response = await dioClient.dio.get('/timelines'); 
  final List<dynamic> listJson = response.data['data'];
  final allTimelines = listJson.map((json) => Timeline.fromJson(json)).toList();
  
  List<TimelineApprovalItem> pendingList = [];
  
  for (var timeline in allTimelines) {
    // 1. Is the Base Timeline pending?
    if (timeline.status == TimelineStatus.pendingApproval) {
      pendingList.add(TimelineApprovalItem(timeline: timeline));
    }
    
    // 2. Fetch versions and check if ANY version is pending
    try {
      final vRes = await dioClient.dio.get('/timelines/${timeline.id}/versions');
      final versions = (vRes.data['data'] as List).map((v) => TimelineVersion.fromJson(v)).toList();
      
      for (var version in versions) {
        if (version.status == TimelineVersionStatus.pendingReview) {
          // Add a SEPARATE item for every single pending version!
          pendingList.add(TimelineApprovalItem(timeline: timeline, version: version));
        }
      }
    } catch (e) {
      // Skip if error fetching versions
    }
  }
  return pendingList;
});

final historyTimelinesProvider = FutureProvider.autoDispose<List<TimelineApprovalItem>>((ref) async {
  final dioClient = ref.read(dioClientProvider);
  
  final response = await dioClient.dio.get('/timelines');
  final List<dynamic> listJson = response.data['data'];
  final allTimelines = listJson.map((json) => Timeline.fromJson(json)).toList();
  
  List<TimelineApprovalItem> historyList = [];
  
  for (var timeline in allTimelines) {
    // 1. Check Base Timeline history
    if (timeline.status == TimelineStatus.approved || timeline.status == TimelineStatus.rejected) {
      historyList.add(TimelineApprovalItem(timeline: timeline));
    } 
    
    // 2. Check Version history
    try {
      final vRes = await dioClient.dio.get('/timelines/${timeline.id}/versions');
      final versions = (vRes.data['data'] as List).map((v) => TimelineVersion.fromJson(v)).toList();
      
      for (var version in versions) {
        if (version.status == TimelineVersionStatus.approved || version.status == TimelineVersionStatus.rejected) {
          historyList.add(TimelineApprovalItem(timeline: timeline, version: version));
        }
      }
    } catch (e) {}
  }
  return historyList;
});

// --- BUDGET PROVIDERS (Placeholders) ---
final pendingBudgetsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async => []);
final historyBudgetsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async => []);

// ==========================================================================
// 2. ACTION CONTROLLER
// ==========================================================================

final approvalControllerProvider = AsyncNotifierProvider<ApprovalController, void>(() {
  return ApprovalController();
});

class ApprovalController extends AsyncNotifier<void> {
  DioClient get _dioClient => ref.read(dioClientProvider);

  @override
  FutureOr<void> build() {}

  // Action for BASE Timelines
  Future<void> approveRejectTimeline({
    required String timelineId, 
    required bool isApproved, 
    String? reason
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _dioClient.dio.post(
        '/timelines/$timelineId/approve-reject',
        data: {'action': isApproved ? 'approve' : 'reject', 'rejectionReason': reason},
      );
      _invalidateCaches(timelineId);
    });
  }

  // Action for TIMELINE VERSIONS
  Future<void> approveRejectVersion({
    required String timelineId,
    required int versionNumber,
    required bool isApproved,
    String? reason,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _dioClient.dio.post(
        '/timelines/$timelineId/versions/$versionNumber/approve-reject',
        data: {'action': isApproved ? 'approve' : 'reject', 'rejectionReason': reason},
      );
      _invalidateCaches(timelineId);
    });
  }

  // Helper to clear ONLY approval caches
  void _invalidateCaches(String timelineId) {
    ref.invalidate(pendingTimelinesProvider);
    ref.invalidate(historyTimelinesProvider);
    // REMOVED the timelineControllerProvider invalidations from here!
  }
}