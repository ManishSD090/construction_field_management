import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/controllers/core_providers.dart';
import 'package:construction_erp/controllers/dpr/dpr_controller.dart';
import 'package:construction_erp/models/dpr.dart';
import 'package:construction_erp/models/wpr.dart';
import 'package:construction_erp/screens/dpr/wpr_details.dart';
import 'package:construction_erp/screens/dpr/edit_dpr_screen.dart';
import 'dpr_details.dart';
import 'edit_wpr_screen.dart';

// --- DATA PROVIDERS ---
final dprListProvider = FutureProvider.family<List<dynamic>, String>((ref, projectId) async {
  final dioClient = ref.watch(dioClientProvider);
  final response = await dioClient.dio.get('/dpr', queryParameters: {
    'projectId': projectId,
    'page': 1,
    'limit': 100, // Fetch a large chunk so we can filter locally by month
  });
  return response.data['data'] as List<dynamic>;
});

final wprListProvider = FutureProvider.family<List<WeeklyProgressReport>, String>((ref, projectId) async {
  final dioClient = ref.watch(dioClientProvider);
  final response = await dioClient.dio.get('/wpr/list', queryParameters: {
    'projectId': projectId,
  });

  final rawData = response.data['data'];
  List<dynamic> listToParse = [];
  
  if (rawData is List) {
    listToParse = rawData;
  } else if (rawData is Map && rawData['wprs'] is List) {
    listToParse = rawData['wprs'];
  } else if (rawData is Map && rawData['data'] is List) {
    listToParse = rawData['data'];
  }

  return listToParse.map((json) => WeeklyProgressReport.fromJson(json)).toList();
});

class ProjectDPRTab extends ConsumerStatefulWidget {
  final ValueChanged<int>? onTypeChanged;
  final String projectId; 

  const ProjectDPRTab({
    super.key, 
    this.onTypeChanged, 
    required this.projectId 
  });

  @override
  ConsumerState<ProjectDPRTab> createState() => _ProjectDPRTabState();
}

class _ProjectDPRTabState extends ConsumerState<ProjectDPRTab> {
  int _selectedType = 0; // 0 = Daily, 1 = Weekly
  bool _isSelectionMode = false;
  final Set<String> _selectedIds = {};
  bool _isDeleting = false;

  // --- FILTER STATES ---
  late String _selectedMonth;
  late String _selectedYear;
  String _selectedWeek = "Week 1"; // Only used in WPR

  final List<String> _months = [
    "JAN", "FEB", "MAR", "APR", "MAY", "JUN", 
    "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"
  ];
  final List<String> _weeks = ["Week 1", "Week 2", "Week 3", "Week 4", "Week 5"];
  late List<String> _years;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateFormat('MMM').format(now).toUpperCase();
    _selectedYear = now.year.toString();
    
    // Generate years dynamically (e.g., from 5 years ago to 2 years in future)
    _years = List.generate(8, (index) => (now.year - 5 + index).toString());
  }

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

  Future<void> _editSelected(List<dynamic> allReports) async {
  if (_selectedIds.length != 1) return;
  final String id = _selectedIds.first;

  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()));

  try {
    if (_selectedType == 0) {
      // --- DAILY DPR LOGIC ---
      final fullDpr = await ref.read(dprControllerProvider.notifier).getDPRById(id);
      if (!mounted) return;
      Navigator.pop(context);
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => EditDPRScreen(dpr: fullDpr)));
    } else {
      // --- WEEKLY WPR LOGIC ---
      // Find the selected WPR from the current list
      final selectedWpr = (allReports as List<WeeklyProgressReport>).firstWhere((w) => w.id == id);
      if (!mounted) return;
      Navigator.pop(context);
      
      // Navigate to your new EditWPRScreen
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => EditWPRScreen(wpr: selectedWpr)
      ));
    }
    
    // Cleanup after returning
    _toggleSelectionMode();
    if (_selectedType == 0) {
      ref.invalidate(dprListProvider);
    } else {
      ref.invalidate(wprListProvider(widget.projectId));
    }
  } catch (e) {
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load: $e')));
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
          
          // 🚨 SHARED FILTERS ACROSS BOTH TABS
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _dropdownFilter(
                    value: _selectedMonth,
                    items: _months,
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedMonth = val);
                    },
                  ),
                  const SizedBox(width: 10),
                  _dropdownFilter(
                    value: _selectedYear,
                    items: _years,
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedYear = val);
                    },
                  ),
                  if (_selectedType == 1) ...[ // Only show Week filter on WPR tab
                    const SizedBox(width: 10),
                    _dropdownFilter(
                      value: _selectedWeek,
                      items: _weeks,
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedWeek = val);
                      },
                    ),
                  ]
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          
          _selectedType == 0 
            ? _buildDPRList(dprAsyncValue) 
            : _buildWPRList(), 
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // --- REUSABLE DROPDOWN FILTER ---
  Widget _dropdownFilter({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryBlue),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Icon(Icons.keyboard_arrow_down, color: AppColors.primaryBlue, size: 18),
          ),
          style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 13),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // --- DPR TAB ---
  Widget _buildDPRList(AsyncValue<List<dynamic>> asyncVal) {
    return asyncVal.when(
      data: (dprs) {
        // 🚨 LIVE FILTERING LOGIC 🚨
        final filteredDprs = dprs.where((d) {
          final dateStr = d['date'];
          if (dateStr == null) return false;
          
          final date = DateTime.tryParse(dateStr);
          if (date == null) return false;

          final monthStr = DateFormat('MMM').format(date).toUpperCase();
          final yearStr = date.year.toString();

          return monthStr == _selectedMonth && yearStr == _selectedYear;
        }).toList();
        
        if (filteredDprs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Text("No reports found for $_selectedMonth $_selectedYear.", style: const TextStyle(color: Colors.grey)),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredDprs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) => _dprCard(
            filteredDprs[index], 
            filteredDprs[index]['id'], 
            DateTime.tryParse(filteredDprs[index]['date'] ?? '') ?? DateTime.now()
          ),
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

  // --- WPR TAB ---
  Widget _buildWPRList() {
    final wprAsync = ref.watch(wprListProvider(widget.projectId)); 

    return wprAsync.when(
      data: (wprs) {
        // 🚨 WPR FILTERING LOGIC (Using createdAt or weekInfo) 🚨
        // Note: Make sure your WeeklyProgressReport model has a date/createdAt field 
        // to filter properly. Assuming w.createdAt exists for now.
        final filteredWprs = wprs.where((w) {
          // Use whatever date field is available on your WPR model (createdAt, reportDate, weekStartDate, etc.)
        final DateTime? date = w.weekStartDate ?? w.createdAt;

        if (date == null) return false;
          
        final monthStr = DateFormat('MMM').format(date).toUpperCase();
        final yearStr = date.year.toString();

          return monthStr == _selectedMonth && yearStr == _selectedYear;
        }).toList();

        if (filteredWprs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(30.0), 
              child: Text("No WPRs found for $_selectedMonth $_selectedYear.", style: const TextStyle(color: Colors.grey))
            )
          );
        }
        
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredWprs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _wprCard(filteredWprs[index]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, stack) => Center(
        child: Text("Error: $e", style: const TextStyle(color: Colors.red, fontSize: 12))
      ),
    );
  }

 Widget _wprCard(WeeklyProgressReport wpr) {
  bool isSelected = _selectedIds.contains(wpr.id); // 🚨 Added selection check
  final String startDay = DateFormat("dd").format(wpr.weekStartDate);
  final String endDay = DateFormat("dd").format(wpr.weekEndDate);
  final String month = DateFormat("MMM").format(wpr.weekEndDate);

  return InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: () {
      if (_isSelectionMode) {
        _toggleSelection(wpr.id); // 🚨 Toggle selection if in edit mode
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => WPRDetailsScreen(wpr: wpr)),
        );
      }
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        // 🚨 Highlight color when selected
        color: isSelected ? AppColors.primaryBlue.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        // 🚨 Blue border when selected
        border: Border.all(color: isSelected ? AppColors.primaryBlue : Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$startDay - $endDay $month",
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                wpr.reportNo,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          // 🚨 Show checkbox icon if selected, otherwise arrow
          Icon(
            isSelected ? Icons.check_circle : Icons.arrow_forward_ios,
            size: isSelected ? 22 : 14,
            color: isSelected ? AppColors.primaryBlue : Colors.grey,
          ),
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
  Widget _buildHeaderRow(AsyncValue<List<dynamic>> asyncVal) => Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: _isSelectionMode ? Row(children: [Text("${_selectedIds.length} Selected", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)), const Spacer(), 
  IconButton(
    icon: Icon(Icons.edit, color: _selectedIds.length == 1 ? AppColors.primaryBlue : Colors.grey.shade400),
    onPressed: _selectedIds.length == 1 
      ? () {
          if (_selectedType == 0) {
            asyncVal.whenData((dprs) => _editSelected(dprs));
          } else {
            // 🚨 Pass the WPR list to the edit function
            ref.read(wprListProvider(widget.projectId)).whenData((wprs) => _editSelected(wprs));
          }
        }
      : null,
  ),
   _isDeleting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : IconButton(icon: Icon(Icons.delete, color: _selectedIds.isNotEmpty ? Colors.red : Colors.grey.shade400), onPressed: _selectedIds.isNotEmpty ? _deleteSelected : null), IconButton(icon: const Icon(Icons.close), onPressed: _toggleSelectionMode)]) : Row(children: [Text(_selectedType == 0 ? "DPR list" : "WPR list", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const Spacer(), _quickActionButton(Icons.edit, Colors.grey, _toggleSelectionMode), const SizedBox(width: 8), _quickActionButton(Icons.delete, Colors.red, _toggleSelectionMode)]));
  Widget _quickActionButton(IconData icon, Color color, VoidCallback onTap) => InkWell(onTap: onTap, child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 20)));
  Widget _statusBadge(String status) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: (status.toLowerCase() == 'approved' || status.toLowerCase() == 'completed') ? Colors.green : AppColors.primaryBlue, borderRadius: BorderRadius.circular(20)), child: Text(status.toUpperCase() == 'TODO' ? 'Submitted' : status, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)));
  
  List<DPREquipment> _parseEquipments(dynamic data) {
    if (data == null) return [];
    if (data is List) return data.map((e) => DPREquipment.fromUsageJson(Map<String, dynamic>.from(e))).toList();
    if (data is String && data.startsWith('[')) { try { final List parsed = jsonDecode(data); return parsed.map((e) => DPREquipment.fromUsageJson(Map<String, dynamic>.from(e))).toList(); } catch (_) { return []; } }
    return [];
  }
}