import 'dart:convert'; // 🚨 Added to fix jsonDecode error
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/controllers/core_providers.dart';
import 'package:construction_erp/controllers/dpr/dpr_controller.dart';
import 'package:construction_erp/models/dpr.dart';
import 'package:construction_erp/models/enums.dart';

import 'package:construction_erp/screens/dpr/create_wpr_screen.dart';
import 'package:construction_erp/screens/dpr/create_dpr_screen.dart';
import 'package:construction_erp/screens/dpr/edit_dpr_screen.dart';
import 'dpr_details.dart';

// --- DATA PROVIDER ---
final dprListProvider = FutureProvider<List<dynamic>>((ref) async {
  final dioClient = ref.watch(dioClientProvider);
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
  bool _isSelectionMode = false;
  final Set<String> _selectedIds = {};
  bool _isDeleting = false;

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _selectedIds.clear();
    });
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) return;
    setState(() => _isDeleting = true);
    try {
      final controller = ref.read(dprControllerProvider.notifier);
      for (String id in _selectedIds) {
        await controller.deleteDPR(id);
      }
      ref.invalidate(dprListProvider);
      _toggleSelectionMode();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reports deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  Future<void> _editSelected(List<dynamic> allDprs) async {
    if (_selectedIds.length != 1) return;
    final String id = _selectedIds.first;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final fullDpr = await ref.read(dprControllerProvider.notifier).getDPRById(id);
      if (!mounted) return;
      Navigator.pop(context);

      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => EditDPRScreen(dpr: fullDpr)),
      ).then((_) {
        _toggleSelectionMode();
        ref.invalidate(dprListProvider); 
      });
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load for editing: $e')),
      );
    }
  }

  DailyProgressReport _mapToDprModel(Map<String, dynamic> item) {
    DateTime parsedDate = DateTime.now();
    try { parsedDate = DateTime.parse(item['date']); } catch (_) {}

    final String statusStr = (item['status'] ?? 'TODO').toString().toUpperCase();
    TaskStatus status = TaskStatus.todo;
    try { status = TaskStatus.values.byName(statusStr.toLowerCase()); } catch (_) {
      if (statusStr == 'COMPLETED' || statusStr == 'APPROVED') status = TaskStatus.completed;
      if (statusStr == 'IN_PROGRESS') status = TaskStatus.inProgress;
    }

    return DailyProgressReport(
      id: item['id'] ?? "",
      reportNo: item['reportNo'] ?? "N/A",
      projectId: item['projectId'] ?? "-",
      projectName: item['project']?['name'] ?? "Unknown Project",
      preparedById: item['preparedBy']?['name'] ?? item['preparedById'] ?? "-",
      date: parsedDate,
      weather: item['weather'] ?? "Sunny",
      workDescription: item['workDescription'] ?? "-",
      completedWork: item['completedWork'] ?? "-",
      totalWorkers: item['totalWorkers'] ?? item['attendanceCount'] ?? 0,
      supervisorPresent: item['supervisorPresent'] ?? false,
      status: status,
      createdAt: item['createdAt'] != null ? DateTime.parse(item['createdAt']) : DateTime.now(),
      updatedAt: item['updatedAt'] != null ? DateTime.parse(item['updatedAt']) : DateTime.now(),
      materialConsumptions: (item['materialConsumptions'] as List?)
        ?.map((e) => MaterialConsumption.fromJson(Map<String, dynamic>.from(e)))
        .toList() ?? [],
      subContractorName: item['subcontractorDetails']?['name'] ?? item['subContractorName'],
      equipments: _parseEquipments(item['equipmentUsage'] ?? item['equipmentUsed']),
      siteVisitors: (item['siteVisitors'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ?? const [],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dprAsyncValue = ref.watch(dprListProvider);

    return SingleChildScrollView( // 🚨 Added to prevent ListView height errors
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_isSelectionMode) _buildTopToggle(),
          const SizedBox(height: 14),
          _buildHeaderRow(dprAsyncValue),
          const SizedBox(height: 10),
          _selectedType == 0 
            ? _buildDPRList(dprAsyncValue) 
            : _buildWPRList(),
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildTopToggle() {
    return Container(
      height: 42,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.12),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          _toggleButton("Daily", 0),
          _toggleButton("Weekly", 1),
        ],
      ),
    );
  }

  Widget _toggleButton(String label, int type) {
    bool isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedType = type);
          // This notifies the parent screen IMMEDIATELY
          if (widget.onTypeChanged != null) {
            widget.onTypeChanged!(type);
          }
        },
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(label, style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textDark, 
            fontWeight: FontWeight.w600
          )),
        ),
      ),
    );
  }

  Widget _buildHeaderRow(AsyncValue<List<dynamic>> asyncVal) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: _isSelectionMode 
      ? Row(
          children: [
            Text("${_selectedIds.length} Selected", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
            const Spacer(),
            IconButton(
              icon: Icon(Icons.edit, color: _selectedIds.length == 1 ? AppColors.primaryBlue : Colors.grey.shade400),
              onPressed: _selectedIds.length == 1 ? () => asyncVal.whenData((dprs) => _editSelected(dprs)) : null,
            ),
            _isDeleting 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : IconButton(
                  icon: Icon(Icons.delete, color: _selectedIds.isNotEmpty ? Colors.red : Colors.grey.shade400),
                  onPressed: _selectedIds.isNotEmpty ? _deleteSelected : null,
                ),
            IconButton(icon: const Icon(Icons.close), onPressed: _toggleSelectionMode),
          ],
        )
      : Row(
          children: [
            Text(_selectedType == 0 ? "DPR list" : "WPR list", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const Spacer(),
            _quickActionButton(Icons.edit, Colors.grey, _toggleSelectionMode),
            const SizedBox(width: 8),
            _quickActionButton(Icons.delete, Colors.red, _toggleSelectionMode),
          ],
        ),
    );
  }

  Widget _quickActionButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8), 
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), 
        child: Icon(icon, color: color, size: 20)
      ),
    );
  }

  Widget _buildDPRList(AsyncValue<List<dynamic>> asyncVal) {
    return asyncVal.when(
      data: (dprs) {
        if (dprs.isEmpty) return const Center(child: Text("No reports found."));
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: dprs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final item = dprs[index];
            final id = item['id'];
            DateTime date = DateTime.tryParse(item['date'] ?? '') ?? DateTime.now();
            return _dprCard(item, id, date);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Text("Error: $err"),
    );
  }

  Widget _dprCard(Map<String, dynamic> item, String id, DateTime date) {
    bool isSelected = _selectedIds.contains(id);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        if (_isSelectionMode) {
          _toggleSelection(id);
        } else {
          showDialog(context: context, builder: (_) => const Center(child: CircularProgressIndicator()));
          final fullDpr = await ref.read(dprControllerProvider.notifier).getDPRById(id);
          if (!mounted) return;
          Navigator.pop(context);
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => DPRDetailsScreen(dpr: fullDpr)));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primaryBlue : Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat("dd MMM yyyy").format(date), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text("Prepared by: ${item['preparedBy']?['name'] ?? 'User'}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            _statusBadge(item['status'] ?? 'TODO'),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    bool isDone = status.toLowerCase() == 'approved' || status.toLowerCase() == 'completed';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isDone ? Colors.green : AppColors.primaryBlue, 
        borderRadius: BorderRadius.circular(20)
      ),
      child: Text(status.toUpperCase() == 'TODO' ? 'Submitted' : status, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildWPRList() {
    return Column(
      children: [
        Row(
          children: [
            _wprFilter("FEB"),
            const SizedBox(width: 12),
            _wprFilter("Week 1"),
          ],
        ),
        const SizedBox(height: 20),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final weeks = ["Sep 2025 - Week 4", "Sep 2025 - Week 3", "Sep 2025 - Week 2", "Sep 2025 - Week 1"];
            return _wprCard(weeks[index]);
          },
        ),
      ],
    );
  }

  Widget _wprFilter(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.primaryBlue)),
      child: Row(children: [
        Text(label, style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
        const Icon(Icons.keyboard_arrow_down, color: AppColors.primaryBlue)
      ]),
    );
  }

  Widget _wprCard(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, 
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey)
        ]
      ),
    );
  }

  List<DPREquipment> _parseEquipments(dynamic data) {
    if (data == null) return [];
    if (data is List) return data.map((e) => DPREquipment.fromUsageJson(Map<String, dynamic>.from(e))).toList();
    if (data is String && data.startsWith('[')) {
      try {
        final List parsed = jsonDecode(data);
        return parsed.map((e) => DPREquipment.fromUsageJson(Map<String, dynamic>.from(e))).toList();
      } catch (_) { return []; }
    }
    return [];
  }
}