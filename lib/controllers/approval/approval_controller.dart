import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_erp/core/dio_client.dart';
import 'package:construction_erp/models/timeline.dart';
import 'package:construction_erp/controllers/core_providers.dart';
import 'package:construction_erp/models/budget.dart';

// ==========================================================================
// WRAPPER CLASSES
// ==========================================================================

class TimelineApprovalItem {
  final Timeline timeline;
  final TimelineVersion? version;

  TimelineApprovalItem({required this.timeline, this.version});

  // Helper to easily get the correct date for sorting
  DateTime get date => version != null ? version!.createdAt : timeline.createdAt;
}

class BudgetApprovalItem {
  final Budget budget;
  final BudgetRevision? revision;

  BudgetApprovalItem({required this.budget, this.revision});

  // Helper to easily get the correct date for sorting
  DateTime get date => (revision != null && revision!.createdAt != null) 
      ? revision!.createdAt! 
      : budget.createdAt;
}

// ==========================================================================
// 1. TIMELINE FETCH PROVIDERS
// ==========================================================================

final pendingTimelinesProvider = FutureProvider.autoDispose<List<TimelineApprovalItem>>((ref) async {
  final dioClient = ref.read(dioClientProvider);
  
  final response = await dioClient.dio.get('/timelines'); 
  final List<dynamic> listJson = response.data['data'];
  
  List<TimelineApprovalItem> pendingList = [];
  
  for (var json in listJson) {
    final statusStr = json['status'].toString().toUpperCase();
    final timeline = Timeline.fromJson(json);

    if (statusStr == 'PENDING_APPROVAL' || statusStr == 'PENDING_REVIEW') {
      pendingList.add(TimelineApprovalItem(timeline: timeline));
    }
    
    try {
      final vRes = await dioClient.dio.get('/timelines/${timeline.id}/versions');
      final versionsData = vRes.data['data'] as List;
      
      for (var vJson in versionsData) {
        final vStatus = vJson['status'].toString().toUpperCase();
        if (vStatus == 'PENDING_APPROVAL' || vStatus == 'PENDING_REVIEW') {
          pendingList.add(TimelineApprovalItem(timeline: timeline, version: TimelineVersion.fromJson(vJson)));
        }
      }
    } catch (e) {}
  }
  
  // Sort Latest to Oldest
  pendingList.sort((a, b) => b.date.compareTo(a.date));
  return pendingList;
});

final historyTimelinesProvider = FutureProvider.autoDispose<List<TimelineApprovalItem>>((ref) async {
  final dioClient = ref.read(dioClientProvider);
  
  final response = await dioClient.dio.get('/timelines');
  final List<dynamic> listJson = response.data['data'];
  
  List<TimelineApprovalItem> historyList = [];
  
  for (var json in listJson) {
    final statusStr = json['status'].toString().toUpperCase();
    final timeline = Timeline.fromJson(json);

    final bool isAppr = statusStr == 'APPROVED' || statusStr == 'ACTIVE';
    final bool isRej = statusStr == 'REJECTED' || json['rejectionReason'] != null;

    if (isAppr || isRej) {
      historyList.add(TimelineApprovalItem(timeline: timeline));
    } 
    
    try {
      final vRes = await dioClient.dio.get('/timelines/${timeline.id}/versions');
      final versionsData = vRes.data['data'] as List;
      
      for (var vJson in versionsData) {
        final vStatus = vJson['status'].toString().toUpperCase();
        final vIsAppr = vStatus == 'APPROVED' || vStatus == 'ACTIVE';
        final vIsRej = vStatus == 'REJECTED' || vJson['rejectionReason'] != null;

        if (vIsAppr || vIsRej) {
          historyList.add(TimelineApprovalItem(timeline: timeline, version: TimelineVersion.fromJson(vJson)));
        }
      }
    } catch (e) {}
  }
  
  // Sort Latest to Oldest
  historyList.sort((a, b) => b.date.compareTo(a.date));
  return historyList;
});

// ==========================================================================
// 2. BUDGET FETCH PROVIDERS
// ==========================================================================

final pendingBudgetsProvider = FutureProvider.autoDispose<List<BudgetApprovalItem>>((ref) async {
  final dioClient = ref.read(dioClientProvider);
  
  final response = await dioClient.dio.get('/budgets/approvals/pending'); 
  final data = response.data['data'];
  
  List<BudgetApprovalItem> pendingList = [];
  
  final List<dynamic> budgetsJson = data['budgets'] ?? [];
  for (var b in budgetsJson) {
    pendingList.add(BudgetApprovalItem(budget: Budget.fromJson(b)));
  }
  
  final List<dynamic> revisionsJson = data['revisions'] ?? [];
  for (var r in revisionsJson) {
    if (r['budget'] != null) {
      pendingList.add(BudgetApprovalItem(budget: Budget.fromJson(r['budget']), revision: BudgetRevision.fromJson(r)));
    }
  }
  
  // Sort Latest to Oldest
  pendingList.sort((a, b) => b.date.compareTo(a.date));
  return pendingList;
});

final historyBudgetsProvider = FutureProvider.autoDispose<List<BudgetApprovalItem>>((ref) async {
  final dioClient = ref.read(dioClientProvider);
  
  final response = await dioClient.dio.get('/budgets');
  final List<dynamic> listJson = response.data['data'];
  
  List<BudgetApprovalItem> historyList = [];
  
  for (var json in listJson) {
    final statusString = json['status'].toString().toUpperCase();
    final budgetObj = Budget.fromJson(json);

    if (statusString == 'APPROVED' || statusString == 'REJECTED' || statusString == 'ACTIVE') {
      historyList.add(BudgetApprovalItem(budget: budgetObj));
    } 
    
    try {
      final rRes = await dioClient.dio.get('/budgets/${budgetObj.id}/revisions');
      final revisionsData = rRes.data['data'] as List;
      
      for (var revJson in revisionsData) {
        final revStatus = revJson['status'].toString().toUpperCase();
        if (revStatus == 'APPROVED' || revStatus == 'REJECTED' || revStatus == 'APPLIED') {
          historyList.add(BudgetApprovalItem(budget: budgetObj, revision: BudgetRevision.fromJson(revJson)));
        }
      }
    } catch (e) {}
  }
  
  // Sort Latest to Oldest
  historyList.sort((a, b) => b.date.compareTo(a.date));
  return historyList;
});

// ==========================================================================
// 3. ACTION CONTROLLER
// ==========================================================================

final approvalControllerProvider = AsyncNotifierProvider<ApprovalController, void>(() {
  return ApprovalController();
});

class ApprovalController extends AsyncNotifier<void> {
  DioClient get _dioClient => ref.read(dioClientProvider);

  @override
  FutureOr<void> build() {}

  // --- TIMELINE ACTIONS ---

  Future<void> approveRejectTimeline({required String timelineId, required bool isApproved, String? reason}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _dioClient.dio.post('/timelines/$timelineId/approve-reject', data: {'action': isApproved ? 'approve' : 'reject', 'rejectionReason': reason});
      _invalidateCaches();
    });
  }

  Future<void> approveRejectVersion({required String timelineId, required int versionNumber, required bool isApproved, String? reason}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _dioClient.dio.post('/timelines/$timelineId/versions/$versionNumber/approve-reject', data: {'action': isApproved ? 'approve' : 'reject', 'rejectionReason': reason});
      _invalidateCaches();
    });
  }

  // --- BUDGET ACTIONS ---

  Future<void> approveRejectBudget({required String budgetId, required bool isApproved, String? reason}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final endpoint = isApproved ? 'approve' : 'reject';
      
      // ✅ BULLETPROOF PAYLOAD FOR BASE BUDGET: Removes nulls
      final payload = <String, dynamic>{};
      if (reason != null && reason.isNotEmpty) {
        if (isApproved) {
          payload['approvalNotes'] = reason;
        } else {
          payload['rejectionReason'] = reason;
        }
      }

      await _dioClient.dio.post('/budgets/approvals/$budgetId/$endpoint', data: payload);
      _invalidateCaches();
    });
  }

  Future<void> approveRejectBudgetRevision({required String revisionId, required bool isApproved, String? reason}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      
      // ✅ BULLETPROOF PAYLOAD FOR REVISIONS: Passes your backend Joi schema perfectly
      final payload = <String, dynamic>{
        'approved': isApproved,
      };
      
      if (reason != null && reason.isNotEmpty) {
        if (isApproved) {
          payload['approvalNotes'] = reason;
        } else {
          payload['rejectionReason'] = reason;
        }
      }

      await _dioClient.dio.post('/budgets/revisions/$revisionId/approve-reject', data: payload);
      _invalidateCaches();
    });
  }

  void _invalidateCaches() {
    ref.invalidate(pendingTimelinesProvider);
    ref.invalidate(historyTimelinesProvider);
    ref.invalidate(pendingBudgetsProvider);
    ref.invalidate(historyBudgetsProvider);
  }
}