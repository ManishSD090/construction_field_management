import 'package:construction_erp/controllers/core_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/models/dpr.dart';
import 'package:construction_erp/models/enums.dart';
import 'package:construction_erp/screens/dpr/create_wpr_screen.dart';
import 'package:construction_erp/screens/dpr/create_dpr_screen.dart';
import 'dpr_details.dart';

// --- DATA PROVIDER ---
final dprListProvider = FutureProvider<List<dynamic>>((ref) async {
  final dioClient = ref.watch(dioClientProvider);
  // Fetching real DPR data from your backend
  final response = await dioClient.dio.get('/dpr?page=1&limit=20');
  return response.data['data'] as List<dynamic>;
});

class ProjectDPRTab extends ConsumerStatefulWidget {
  final ValueChanged<int>? onTypeChanged;

  const ProjectDPRTab({super.key, this.onTypeChanged});

  @override
  ConsumerState<ProjectDPRTab> createState() => _ProjectDPRTabState();
}

class _ProjectDPRTabState extends ConsumerState<ProjectDPRTab> {
  int _selectedType = 0; // 0 = Daily, 1 = Weekly

  void _openCreateReport(BuildContext context) {
    if (_selectedType == 0) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CreateDPRScreen(
            scrollController: ScrollController(),
          ),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CreateWPRScreen(
            scrollController: ScrollController(),
          ),
        ),
      );
    }
  }

  // Parses raw API JSON into the DailyProgressReport model required by the details screen
  DailyProgressReport _mapToDprModel(Map<String, dynamic> item) {
    DateTime parsedDate = DateTime.now();
    try {
      parsedDate = DateTime.parse(item['date']);
    } catch (_) {}

    final String statusStr = (item['status'] ?? 'TODO').toString().toUpperCase();
    TaskStatus status = TaskStatus.todo;
    
    try {
      status = TaskStatus.values.byName(statusStr.toLowerCase());
    } catch (_) {
      if (statusStr == 'COMPLETED' || statusStr == 'APPROVED') status = TaskStatus.completed;
      if (statusStr == 'IN_PROGRESS') status = TaskStatus.inProgress;
    }

    return DailyProgressReport(
      id: item['id'] ?? "temp_${DateTime.now().millisecondsSinceEpoch}",
      reportNo: item['reportNo'] ?? "N/A",
      projectId: item['projectId'] ?? "-",
      projectName: item['project']?['name'] ?? "Unknown Project",
      
      // FIX 1: Pass the name into the ID field as a fallback since preparedBy is null, 
      // the details screen uses `dpr.preparedBy?.name ?? dpr.preparedById`
      preparedById: item['preparedBy']?['name'] ?? item['preparedById'] ?? "-",
      preparedBy: null, // Fixed: Reverted to null as per your original model
      
      date: parsedDate,
      weather: item['weather'] ?? "Sunny",
      workDescription: item['workDescription'] ?? "-",
      completedWork: item['completedWork'] ?? "-",
      totalWorkers: item['totalWorkers'] ?? item['attendanceCount'] ?? 0,
      supervisorPresent: item['supervisorPresent'] ?? false,
      status: status,
      createdAt: item['createdAt'] != null ? DateTime.parse(item['createdAt']) : DateTime.now(),
      updatedAt: item['updatedAt'] != null ? DateTime.parse(item['updatedAt']) : DateTime.now(),
      
      materialsUsed: item['materialsUsed'],
      equipmentUsed: item['equipmentUsed'],
      issuesFound: item['issuesFound'],
      nextDayTaskName: item['nextDayPlan'],
      notes: item['notes'],
      
      photos: const [],
      documents: const [],
      
      // FIX 2: Safely cast the list of dynamics to a List of Maps
      siteVisitors: (item['siteVisitors'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          const [],
    );
  }

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s == 'approved' || s == 'completed') return const Color(0xFF4CAF50); // Green
    if (s == 'submitted' || s == 'todo') return const Color(0xFF1976D2); // Blue
    if (s == 'review' || s == 'in_progress') return const Color(0xFFF39C12); // Orange
    return Colors.grey;
  }

  String _formatStatus(String status) {
    if (status.toUpperCase() == 'TODO') return 'Submitted';
    if (status.toUpperCase() == 'COMPLETED') return 'Approved';
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final dprAsyncValue = ref.watch(dprListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Daily / Weekly Toggle ---
        Container(
          height: 42,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.12),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedType = 0);
                    widget.onTypeChanged?.call(_selectedType);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _selectedType == 0 ? AppColors.primaryBlue : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text("Daily", style: TextStyle(color: _selectedType == 0 ? Colors.white : AppColors.textDark, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedType = 1);
                    widget.onTypeChanged?.call(_selectedType);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _selectedType == 1 ? AppColors.primaryBlue : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text("Weekly", style: TextStyle(color: _selectedType == 1 ? Colors.white : AppColors.textDark, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // --- Header Row ---
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              const Text("DPR list", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const Spacer(),
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.edit, color: Colors.grey, size: 20)),
              const SizedBox(width: 8),
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.alertRed.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.delete, color: AppColors.alertRed, size: 20)),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () {}, // Future filter logic
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  side: const BorderSide(color: AppColors.primaryBlue),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                icon: const Icon(Icons.tune, size: 16, color: AppColors.textDark),
                label: const Text("Filter", style: TextStyle(color: AppColors.textDark, fontSize: 13)),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // --- Dynamic DPR List ---
        _selectedType == 0 
        ? dprAsyncValue.when(
            data: (dprs) {
              if (dprs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: Text("No DPRs found.", style: TextStyle(color: Colors.grey))),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dprs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final item = dprs[index];
                  
                  // Format Data for UI
                  DateTime date = DateTime.tryParse(item['date'] ?? '') ?? DateTime.now();
                  String displayDate = DateFormat("dd MMM yyyy").format(date);
                  String preparerName = item['preparedBy']?['name'] ?? "Unknown User";
                  String displayStatus = _formatStatus(item['status'] ?? 'TODO');
                  Color statusColor = _getStatusColor(item['status'] ?? 'TODO');

                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      final dprModel = _mapToDprModel(item);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => DPRDetailsScreen(dpr: dprModel)),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(displayDate, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                              const SizedBox(height: 6),
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  children: [
                                    const TextSpan(text: "Prepared by: "),
                                    TextSpan(text: preparerName, style: const TextStyle(color: AppColors.primaryBlue)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(20)),
                            child: Text(displayStatus, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())),
            error: (err, stack) => Center(child: Padding(padding: const EdgeInsets.all(20), child: Text("Error loading DPRs: $err", style: const TextStyle(color: Colors.red)))),
          )
        : const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: Text("Weekly Reports feature coming soon.", style: TextStyle(color: Colors.grey))),
          ),
      ],
    );
  }
}