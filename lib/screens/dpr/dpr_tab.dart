import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/controllers/core_providers.dart';
import 'package:construction_erp/controllers/dpr/dpr_controller.dart';
import 'package:construction_erp/controllers/wpr/wpr_controller.dart'; // 🚨 Added WPR Controller
import 'package:construction_erp/models/dpr.dart';
import 'package:construction_erp/models/wpr.dart'; // 🚨 Added WPR Model
import 'package:construction_erp/models/enums.dart';

import 'package:construction_erp/screens/dpr/edit_dpr_screen.dart';
import 'dpr_details.dart';
// import 'wpr_details.dart'; // Uncomment once you create the WPR details screen

// --- DATA PROVIDER ---
// Changed to .family to accept projectId
final dprListProvider = FutureProvider.family<List<dynamic>, String>((ref, projectId) async {
  final dioClient = ref.watch(dioClientProvider);
  // Added projectId to the query parameters
  final response = await dioClient.dio.get('/dpr', queryParameters: {
    'projectId': projectId,
    'page': 1,
    'limit': 20,
  });
  return response.data['data'] as List<dynamic>;
});

// 🚨 Updated Provider logic to handle nested data objects
final wprListProvider = FutureProvider.family<List<WeeklyProgressReport>, String>((ref, projectId) async {
  final dioClient = ref.watch(dioClientProvider);
  
  final response = await dioClient.dio.get('/wpr', queryParameters: {
    'projectId': projectId,
  });

  // Extract the raw response data
  final rawData = response.data['data'];

  // Check if rawData is a List (Direct Array) or a Map (contains meta/pagination)
  List<dynamic> listToParse = [];
  
  if (rawData is List) {
    listToParse = rawData;
  } else if (rawData is Map && rawData['wprs'] is List) {
    // Some backends nest the list inside another key like 'wprs' or 'reports'
    listToParse = rawData['wprs'];
  } else if (rawData is Map && rawData['data'] is List) {
    // Handle double-nesting if it exists
    listToParse = rawData['data'];
  }

  return listToParse.map((json) => WeeklyProgressReport.fromJson(json)).toList();
});

class ProjectDPRTab extends ConsumerStatefulWidget {
  final ValueChanged<int>? onTypeChanged;
  final String projectId; // 🚨 Add this field

  const ProjectDPRTab({
    super.key, 
    this.onTypeChanged, 
    required this.projectId // 🚨 Make it required
  });

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
      if (_selectedType == 0) {
        final controller = ref.read(dprControllerProvider.notifier);
        for (String id in _selectedIds) {
          await controller.deleteDPR(id);
        }
        ref.invalidate(dprListProvider);
      } else {
        // Add WPR delete logic here if backend supports it
      }
      _toggleSelectionMode();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reports deleted successfully')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  Future<void> _editSelected(List<dynamic> allDprs) async {
    if (_selectedIds.length != 1) return;
    final String id = _selectedIds.first;

    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));

    try {
      final fullDpr = await ref.read(dprControllerProvider.notifier).getDPRById(id);
      if (!mounted) return;
      Navigator.pop(context);

      Navigator.of(context).push(MaterialPageRoute(builder: (_) => EditDPRScreen(dpr: fullDpr))).then((_) {
        _toggleSelectionMode();
        ref.invalidate(dprListProvider); 
      });
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load for editing: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dprAsyncValue = ref.watch(dprListProvider(widget.projectId));

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_isSelectionMode) _buildTopToggle(),
          const SizedBox(height: 14),
          _buildHeaderRow(dprAsyncValue),
          const SizedBox(height: 10),
          _selectedType == 0 
            ? _buildDPRList(dprAsyncValue) 
            : _buildWPRList(), // 🚨 Now updated for dynamic data
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildWPRList() {
  // 🚨 Use the projectId from your widget/model
  final wprAsync = ref.watch(wprListProvider(widget.projectId ?? "")); 

  return Column(
    children: [
      Row(children: [_wprFilter("FEB"), const SizedBox(width: 12), _wprFilter("Week 1")]),
      const SizedBox(height: 20),
      wprAsync.when(
        data: (wprs) {
          if (wprs.isEmpty) return const Center(child: Text("No Weekly Reports found."));
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: wprs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _wprCard(wprs[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) => Center(
          child: Text("Error: $e", style: const TextStyle(color: Colors.red, fontSize: 12))
        ),
      ),
    ],
  );
}

  Widget _wprCard(WeeklyProgressReport wpr) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        // Navigator.push(context, MaterialPageRoute(builder: (_) => WPRDetailsScreen(wpr: wpr)));
      },
      child: Container(
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
            Text(wpr.reportNo.isEmpty ? "Week Report" : wpr.reportNo, 
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey)
          ]
        ),
      ),
    );
  }

  // --- EXISTING DPR HELPERS ---
  Widget _buildDPRList(AsyncValue<List<dynamic>> asyncVal) {
    return asyncVal.when(
      data: (dprs) {
        if (dprs.isEmpty) return const Center(child: Text("No reports found."));
        return ListView.separated(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          itemCount: dprs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) => _dprCard(dprs[index], dprs[index]['id'], DateTime.tryParse(dprs[index]['date'] ?? '') ?? DateTime.now()),
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
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(DateFormat("dd MMM yyyy").format(date), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text("Prepared by: ${item['preparedBy']?['name'] ?? 'User'}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ]),
            _statusBadge(item['status'] ?? 'TODO'),
          ],
        ),
      ),
    );
  }

  // --- COMMON UI WIDGETS ---
  Widget _buildTopToggle() => Container(height: 42, padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.grey.withOpacity(0.12), borderRadius: BorderRadius.circular(22)), child: Row(children: [_toggleButton("Daily", 0), _toggleButton("Weekly", 1)]));
  Widget _toggleButton(String label, int type) {
    bool isSelected = _selectedType == type;
    return Expanded(child: GestureDetector(onTap: () { setState(() => _selectedType = type); if (widget.onTypeChanged != null) widget.onTypeChanged!(type); }, child: Container(alignment: Alignment.center, decoration: BoxDecoration(color: isSelected ? AppColors.primaryBlue : Colors.transparent, borderRadius: BorderRadius.circular(18)), child: Text(label, style: TextStyle(color: isSelected ? Colors.white : AppColors.textDark, fontWeight: FontWeight.w600)))));
  }
  Widget _buildHeaderRow(AsyncValue<List<dynamic>> asyncVal) => Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: _isSelectionMode ? Row(children: [Text("${_selectedIds.length} Selected", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)), const Spacer(), IconButton(icon: Icon(Icons.edit, color: _selectedIds.length == 1 ? AppColors.primaryBlue : Colors.grey.shade400), onPressed: _selectedIds.length == 1 ? () => asyncVal.whenData((dprs) => _editSelected(dprs)) : null), _isDeleting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : IconButton(icon: Icon(Icons.delete, color: _selectedIds.isNotEmpty ? Colors.red : Colors.grey.shade400), onPressed: _selectedIds.isNotEmpty ? _deleteSelected : null), IconButton(icon: const Icon(Icons.close), onPressed: _toggleSelectionMode)]) : Row(children: [Text(_selectedType == 0 ? "DPR list" : "WPR list", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const Spacer(), _quickActionButton(Icons.edit, Colors.grey, _toggleSelectionMode), const SizedBox(width: 8), _quickActionButton(Icons.delete, Colors.red, _toggleSelectionMode)]));
  Widget _quickActionButton(IconData icon, Color color, VoidCallback onTap) => InkWell(onTap: onTap, child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 20)));
  Widget _statusBadge(String status) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: (status.toLowerCase() == 'approved' || status.toLowerCase() == 'completed') ? Colors.green : AppColors.primaryBlue, borderRadius: BorderRadius.circular(20)), child: Text(status.toUpperCase() == 'TODO' ? 'Submitted' : status, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)));
  Widget _wprFilter(String label) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.primaryBlue)), child: Row(children: [Text(label, style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)), const Icon(Icons.keyboard_arrow_down, color: AppColors.primaryBlue)]));

  List<DPREquipment> _parseEquipments(dynamic data) {
    if (data == null) return [];
    if (data is List) return data.map((e) => DPREquipment.fromUsageJson(Map<String, dynamic>.from(e))).toList();
    if (data is String && data.startsWith('[')) { try { final List parsed = jsonDecode(data); return parsed.map((e) => DPREquipment.fromUsageJson(Map<String, dynamic>.from(e))).toList(); } catch (_) { return []; } }
    return [];
  }
}