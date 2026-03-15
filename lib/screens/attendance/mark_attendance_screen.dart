import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/models/worker.dart';
import 'package:construction_erp/controllers/worker/worker_controller.dart';
import 'add_worker.dart'; 
import 'add_staff.dart'; // 🚨 Import the new staff screen

class WorkerAttendanceLocal {
  final String id;
  final String name;
  final String workerType;
  final String designation; // 🚨 Added designation for staff UI
  String status;
  String multiplier;
  double baseRate;

  WorkerAttendanceLocal({
    required this.id,
    required this.name,
    required this.workerType,
    this.designation = 'Worker',
    this.status = 'Present',
    this.multiplier = 'x1.0',
    this.baseRate = 600.0,
  });

  double get currentRate {
    if (status == 'Absent') return 0.0;
    double multValue = double.tryParse(multiplier.replaceAll('x', '')) ?? 1.0;
    return baseRate * multValue;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'workerType': workerType,
    'designation': designation,
    'status': status,
    'multiplier': multiplier,
    'baseRate': baseRate,
  };

  factory WorkerAttendanceLocal.fromJson(Map<String, dynamic> json) {
    return WorkerAttendanceLocal(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      workerType: json['workerType'] ?? 'SITE_STAFF',
      designation: json['designation'] ?? 'Worker',
      status: json['status'] ?? 'Present',
      multiplier: json['multiplier'] ?? 'x1.0',
      baseRate: (json['baseRate'] ?? 500.0).toDouble(),
    );
  }
}

class MarkAttendanceScreen extends ConsumerStatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  ConsumerState<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends ConsumerState<MarkAttendanceScreen> {
  String _selectedRole = 'Workers';
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;
  bool _isLoadingRecords = false;

  final List<WorkerAttendanceLocal> _workers = [];

  final List<String> _statusOptions = ['Present', 'Absent', 'Week Off', 'Paid Leave'];
  // Staff specific options
  final List<String> _staffStatusOptions = ['Present', 'Absent', 'On Leave']; 
  final List<String> _multiplierOptions = ['x1.0', 'x1.5', 'x1.75', 'x2.0'];
  final Map<String, bool> _activeFilters = {
    'Present': false, 'Absent': false, 'Week Off': false, 'Paid Leave': false, 'On Leave': false,
  };

  final String _projectId = "ca0ee39d-f2e9-46d2-8cec-d3a8bb44b755";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingAttendance();
    });
  }

  Future<void> _saveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final dateKey = 'draft_attendance_${_selectedDate.toIso8601String().split('T')[0]}';
    
    final draftJson = jsonEncode(_workers.map((w) => w.toJson()).toList());
    await prefs.setString(dateKey, draftJson);
  }

  Future<void> _loadExistingAttendance() async {
    setState(() {
      _isLoadingRecords = true;
      _workers.clear(); 
    });

    final prefs = await SharedPreferences.getInstance();
    final dateKey = 'draft_attendance_${_selectedDate.toIso8601String().split('T')[0]}';
    final draftString = prefs.getString(dateKey);
    
    if (draftString != null) {
      try {
        final List<dynamic> decoded = jsonDecode(draftString);
        _workers.addAll(decoded.map((e) => WorkerAttendanceLocal.fromJson(e)).toList());
      } catch(e) {
        debugPrint("Error loading draft: $e");
      }
    }

    final savedRecords = await ref.read(workerControllerProvider.notifier)
        .getSavedAttendance(projectId: _projectId, date: _selectedDate);

    setState(() {
      for (var record in savedRecords) {
        String dbStatus = record['status'] ?? 'PRESENT';
        String formattedStatus = _statusOptions.contains(dbStatus) ? dbStatus : 'Present';

        final workerId = record['siteStaffId'] ?? record['subcontractorWorkerId'] ?? '';
        
        _workers.removeWhere((w) => w.id == workerId);

        _workers.add(WorkerAttendanceLocal(
          id: workerId,
          name: record['siteStaff']?['name'] ?? 'Unknown Worker',
          workerType: record['workerType'] ?? 'SITE_STAFF',
          designation: record['siteStaff']?['designation'] ?? 'Worker',
          status: formattedStatus,
          baseRate: (record['wageRate'] ?? 500).toDouble(),
          multiplier: 'x${record['shiftMultiplier'] ?? 1.0}',
        ));
      }
      _isLoadingRecords = false;
    });

    _saveDraft();
  }

  List<WorkerAttendanceLocal> get _filteredList {
    // Filter by role tab first
    var roleFiltered = _workers.where((w) {
      bool isStaff = w.designation.toLowerCase() != 'worker' && w.designation.isNotEmpty;
      return _selectedRole == 'Staff' ? isStaff : !isStaff;
    }).toList();

    bool noFiltersSelected = !_activeFilters.values.contains(true);
    if (noFiltersSelected) return roleFiltered;
    return roleFiltered.where((w) => _activeFilters[w.status] == true).toList();
  }

  // 🚨 Dynamic Navigation based on Tab
  void _navigateToAddWorkers() async {
    final isStaff = _selectedRole == 'Staff';
    
    final result = await Navigator.push(
      context,
      // REMOVED 'const' keywords to fix the expression error
     MaterialPageRoute(builder: (context) => isStaff ?   const AddStaffScreen() :  const AddWorkerScreen()),
    );
    if (result != null) {
      if (result is List<Worker>) {
        setState(() {
          for (var worker in result) {
            if (!_workers.any((w) => w.id == worker.id)) {
              _workers.add(WorkerAttendanceLocal(
                id: worker.id ?? '',
                name: worker.name ?? 'Unknown',
                workerType: 'SITE_STAFF', 
                designation: worker.designation ?? (isStaff ? 'Staff' : 'Worker'),
                baseRate: (worker.dailyWageRate ?? (isStaff ? 600 : 500)).toDouble(), 
              ));
            }
          }
        });
      } 
      else if (result is List) {
        final allAvailableWorkers = await ref.read(workerControllerProvider.future);
        setState(() {
          for (var item in result) {
            String id = item is Worker ? item.id : item.toString();
            if (!_workers.any((w) => w.id == id)) {
              try {
                final workerData = allAvailableWorkers.firstWhere((w) => w.id == id);
                _workers.add(WorkerAttendanceLocal(
                  id: workerData.id ?? '',
                  name: workerData.name ?? 'Unknown',
                  workerType: 'SITE_STAFF', 
                  designation: workerData.designation ?? (isStaff ? 'Staff' : 'Worker'),
                  baseRate: (workerData.dailyWageRate ?? (isStaff ? 600 : 500)).toDouble(), 
                ));
              } catch (e) {
                debugPrint("Worker not found");
              }
            }
          }
        });
      }
      
      _saveDraft();
    }
  }

  Future<void> _submitAttendance() async {
    setState(() => _isSubmitting = true);
    
    try {
      final attendanceData = _workers.map((w) => {
        'workerType': w.workerType,
        'workerId': w.id,
        'status': w.status.toUpperCase().replaceAll(' ', '_'),
        'notes': 'Marked via mobile app',
        'multiplier': double.tryParse(w.multiplier.replaceAll('x', '')) ?? 1.0,
      }).toList();

      await ref.read(workerControllerProvider.notifier).submitBulkAttendance(
        projectId: _projectId,
        date: _selectedDate,
        attendanceData: attendanceData,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Attendance submitted successfully!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalPayroll = _filteredList.fold(0, (sum, item) => sum + item.currentRate);
    int presentCount = _filteredList.where((w) => w.status == 'Present').length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        centerTitle: false, // Match staff screenshot
        title: const Text("Attendance", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildToggle(),
              _buildSummary(totalPayroll),
              _buildFilterRow(),
              _buildListHeader(presentCount),
              
              if (_isLoadingRecords)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else
                _buildList(),
                
              _buildSubmitButton(),
            ],
          ),
          if (_isSubmitting)
            Container(
              color: Colors.black.withOpacity(0.2),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      margin: const EdgeInsets.all(20),
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(25)),
      child: Row(
        children: ['Workers', 'Staff'].map((role) {
          bool isSelected = _selectedRole == role;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedRole = role),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(role, style: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade600, fontWeight: FontWeight.bold)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummary(double total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Total Payroll:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          Text("₹${total.toInt()}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                  _loadExistingAttendance();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(border: Border.all(color: AppColors.primaryBlue.withOpacity(0.5)), borderRadius: BorderRadius.circular(25)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat('MM/dd/yyyy').format(_selectedDate), style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w500)),
                    const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.primaryBlue),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          PopupMenuButton<String>(
            offset: const Offset(0, 45),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: StatefulBuilder(
                  builder: (context, setPopupState) => Column(
                    children: (_selectedRole == 'Staff' ? _staffStatusOptions : _statusOptions).map((status) => CheckboxListTile(
                      title: Text(status, style: const TextStyle(fontSize: 13)),
                      value: _activeFilters[status] ?? false,
                      onChanged: (val) {
                        setPopupState(() => _activeFilters[status] = val!);
                        setState(() {});
                      },
                    )).toList(),
                  ),
                ),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(25)),
              child: const Row(children: [Text("Filter", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)), SizedBox(width: 6), Icon(Icons.tune, size: 16)]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListHeader(int present) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                  children: [
                    TextSpan(text: "$present/${_filteredList.length} ", style: const TextStyle(color: AppColors.primaryBlue)),
                    const TextSpan(text: "Present", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _navigateToAddWorkers,
                child: Text("+ Add ${_selectedRole == 'Staff' ? 'Staff' : 'Workers'}", style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: AppColors.primaryBlue.withOpacity(0.3), thickness: 1),
        ],
      ),
    );
  }

  Widget _buildList() {
    return Expanded(
      child: _filteredList.isEmpty 
      ? Center(child: Text("No ${_selectedRole.toLowerCase()} added yet.", style: TextStyle(color: Colors.grey.shade600)))
      : ListView.builder(
        itemCount: _filteredList.length,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemBuilder: (context, index) {
          final worker = _filteredList[index];
          
          // 🚨 BRANCH UI: Staff styling vs Worker styling
          if (_selectedRole == 'Staff') {
            return _buildStaffCard(worker);
          } else {
            return _buildWorkerCard(worker);
          }
        },
      ),
    );
  }

  // Custom Staff Card (Matches your new screenshot)
  Widget _buildStaffCard(WorkerAttendanceLocal worker) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(16), 
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 4, offset: const Offset(0, 2))]
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(worker.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
                const SizedBox(height: 4),
                Text(worker.designation, style: const TextStyle(color: AppColors.primaryBlue, fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8)
            ),
            child: Text("₹${worker.currentRate.toInt()}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey.shade700)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildStaffStatusPill(worker),
              const SizedBox(height: 6),
              Text("Check-In: 9:05 AM\nCheck-out: 6:20 PM", textAlign: TextAlign.right, style: TextStyle(color: AppColors.primaryBlue.withOpacity(0.7), fontSize: 9, height: 1.2)),
            ],
          ),
        ],
      ),
    );
  }

  // Standard Worker Card (Matches original style)
  Widget _buildWorkerCard(WorkerAttendanceLocal worker) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade100)),
      child: Row(
        children: [
          Expanded(child: Text(worker.name, style: const TextStyle(fontWeight: FontWeight.w500))),
          Text("₹${worker.currentRate.toInt()}", style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          _buildDropdown(
            value: worker.multiplier,
            options: _multiplierOptions,
            color: AppColors.primaryBlue,
            onChanged: (val) {
              setState(() => worker.multiplier = val!);
              _saveDraft();
            },
          ),
          const SizedBox(width: 8),
          _buildDropdown(
            value: worker.status,
            options: _statusOptions,
            isStatus: true,
            onChanged: (val) {
              setState(() => worker.status = val!);
              _saveDraft();
            },
          ),
        ],
      ),
    );
  }

  // Colored Dropdown Pill for Staff
  Widget _buildStaffStatusPill(WorkerAttendanceLocal worker) {
    Color bgColor;
    Color textColor;

    if (worker.status == 'Present') {
      bgColor = const Color(0xFFE8F5E9); 
      textColor = const Color(0xFF2E7D32); 
    } else if (worker.status == 'Absent') {
      bgColor = const Color(0xFFFFEBEE); 
      textColor = const Color(0xFFC62828); 
    } else {
      bgColor = const Color(0xFFE3F2FD); 
      textColor = const Color(0xFF1976D2); 
    }

    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(15)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: ['Present', 'Absent', 'On Leave'].contains(worker.status) ? worker.status : 'Present',
          icon: Icon(Icons.keyboard_arrow_down, size: 16, color: textColor),
          style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
          onChanged: (val) {
            setState(() => worker.status = val!);
            _saveDraft();
          },
          items: _staffStatusOptions.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
        ),
      ),
    );
  }

  Widget _buildDropdown({required String value, required List<String> options, required Function(String?) onChanged, bool isStatus = false, Color? color}) {
    Color displayColor = color ?? _getStatusColor(value);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isStatus ? displayColor.withOpacity(0.1) : Colors.white,
        border: Border.all(color: isStatus ? Colors.transparent : displayColor.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: options.contains(value) ? value : options.first,
          icon: Icon(Icons.keyboard_arrow_down, size: 14, color: displayColor),
          style: TextStyle(color: displayColor, fontSize: 11, fontWeight: FontWeight.bold),
          onChanged: onChanged,
          items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
        ),
      ),
    );
  }

  Color _getStatusColor(String s) {
    if (s == 'Present') return Colors.green;
    if (s == 'Absent') return Colors.red;
    if (s == 'Week Off') return Colors.orange;
    return Colors.blue;
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, -5))]),
      child: ElevatedButton(
        onPressed: _filteredList.isEmpty ? null : () => _showConfirmationDialog(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue, 
          disabledBackgroundColor: Colors.grey.shade300,
          minimumSize: const Size(double.infinity, 54), 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
        ),
        child: const Text("Submit", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Are you sure you want to\nsubmit attendance?", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            const Text("Once you submit you can't edit/update it later", textAlign: TextAlign.center, style: TextStyle(color: Colors.red, fontSize: 12)),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _submitAttendance();
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D6EFD), minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text("Yes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
          ],
        ),
      ),
    );
  }
}