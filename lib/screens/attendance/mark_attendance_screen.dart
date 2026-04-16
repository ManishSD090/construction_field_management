import 'package:construction_erp/controllers/core_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Only kept to pull the global base rate
import 'package:dio/dio.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/controllers/worker/worker_controller.dart';
import 'package:construction_erp/controllers/payroll/payroll_controller.dart';
import 'package:construction_erp/controllers/project/project_controller.dart';
import 'add_worker.dart';
import 'package:construction_erp/screens/payroll/payroll_details_screen.dart';

class WorkerAttendanceLocal {
  final String id;
  final String name;
  final String workerType;
  final String designation;
  final bool isManagement;
  String status;
  String? shiftTypeId;
  double shiftMultiplier;
  double baseRate;
  String? attendanceRecordId;

  WorkerAttendanceLocal({
    required this.id,
    required this.name,
    required this.workerType,
    required this.isManagement,
    this.designation = 'Worker',
    this.status = 'Present',
    this.shiftTypeId,
    this.shiftMultiplier = 1.0,
    this.baseRate = 0.0,
    this.attendanceRecordId,
  });

  double get currentRate {
    if (['Absent', 'Week Off', 'Paid Leave', 'On Leave'].contains(status)) {
      return 0.0;
    }
    return baseRate * shiftMultiplier;
  }
}

class MarkAttendanceScreen extends ConsumerStatefulWidget {
  final String projectId;

  const MarkAttendanceScreen({super.key, required this.projectId});

  @override
  ConsumerState<MarkAttendanceScreen> createState() =>
      _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends ConsumerState<MarkAttendanceScreen> {
  String _selectedRole = 'Workers';
  DateTime _selectedDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  bool _isSubmitting = false;
  bool _isLoadingRecords = false;
  String? _activeDeleteId;
  bool _isStaffSubmitted = false;
  bool _isWorkersSubmitted = false;

  double _globalDefaultRate = 500.0;
  final List<WorkerAttendanceLocal> _workers = [];
  List<Map<String, dynamic>> _dynamicShifts = [];
  List<dynamic> _labourRatePresets = [];

  final List<String> _statusOptions = [
    'Present',
    'Absent',
    'Week Off',
    'Paid Leave'
  ];
  final List<String> _staffStatusOptions = ['Present', 'Absent', 'On Leave'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadGlobalSettings();
      await _fetchDynamicShifts();
      await _loadExistingAttendance();
    });
  }

  Future<void> _loadGlobalSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // 🔥 THE FIX: Make the local storage key strictly project-specific!
    final savedRate =
        prefs.getString('default_worker_rate_${widget.projectId}');

    if (savedRate != null) {
      setState(() {
        _globalDefaultRate = double.tryParse(savedRate) ?? 500.0;
      });
    } else {
      // Fallback if this specific project hasn't had a rate set yet
      setState(() {
        _globalDefaultRate = 500.0;
      });
    }
  }

  Future<void> _fetchDynamicShifts() async {
    final payrollCtrl = ref.read(payrollControllerProvider);
    final shifts = await payrollCtrl.getShiftTypes();
    
    // Load available labour rate presets
    final rateHistory = await payrollCtrl.getLabourRates(isCurrent: true);
    final presets = rateHistory.where((r) => r['siteStaffId'] == null && r['subcontractorWorkerId'] == null).toList();

    setState(() {
      _labourRatePresets = presets;
      if (presets.isNotEmpty) {
        // 🔥 Update the global default rate to the latest preset found
        _globalDefaultRate = (presets.first['rate'] as num).toDouble();
      }
      _dynamicShifts = shifts
          .map((e) => {
                'id': e['id'],
                'multiplier': (e['multiplier'] as num).toDouble(),
                'name':
                    'x${e['multiplier']}', // 🔥 FORCED CLEAN FORMATTING (e.g., x1.0, x0.5)
              })
          .toList();
    });
  }

  Map<String, dynamic>? _getDefaultShift() {
    if (_dynamicShifts.isEmpty) return null;
    try {
      return _dynamicShifts
          .firstWhere((s) => s['multiplier'] == 1.0 || s['multiplier'] == 1);
    } catch (e) {
      return _dynamicShifts.first;
    }
  }

  double _calculateDailyRate(double salary, String salaryType) {
    if (salary <= 0) return 0.0;
    switch (salaryType.toUpperCase()) {
      case 'DAILY':
        return salary;
      case 'WEEKLY':
        return salary / 7;
      case 'HOURLY':
        return salary * 8;
      case 'MONTHLY':
      default:
        int daysInMonth =
            DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
        return salary / daysInMonth;
    }
  }

  Future<void> _loadExistingAttendance() async {
    setState(() {
      _isLoadingRecords = true;
      _workers.clear();
      _isStaffSubmitted = false;
      _isWorkersSubmitted = false;
    });

    try {
      final dio = ref.read(dioClientProvider).dio;
      // Fixed Date Formatting
      final String formattedDate =
          DateFormat("yyyy-MM-dd'T'00:00:00").format(_selectedDate);

      // 1. LOAD ASSIGNED WORKERS FROM DB
      // ==========================================
      final assignedWorkers = await ref
          .read(workerControllerProvider.notifier)
          .fetchWorkersForAttendance(
              projectId: widget.projectId, date: _selectedDate);
      final defaultShift = _getDefaultShift();

      for (var worker in assignedWorkers) {
        _workers.add(WorkerAttendanceLocal(
          id: worker.id,
          name: worker.name ?? 'Unknown',
          workerType: worker.workerType,
          isManagement: false,
          designation: worker.designation ?? 'Worker',
          baseRate: worker.dailyWageRate > 0
              ? worker.dailyWageRate
              : _globalDefaultRate,
          status: 'Present',
          shiftTypeId: defaultShift?['id'],
          shiftMultiplier:
              (defaultShift?['multiplier'] as num?)?.toDouble() ?? 1.0,
        ));
      }

      // ==========================================
      // 2. LOAD STAFF FROM DB
      // ==========================================
      final teamAssignments = await ref
          .read(projectControllerProvider.notifier)
          .getProjectTeam(widget.projectId, date: _selectedDate);
      final usersResponse =
          await dio.get('/users', queryParameters: {'limit': 500});
      final List<dynamic> allUsers = usersResponse.data['data'] ?? [];
      final salaryMap = {for (var u in allUsers) u['id']: u};

      for (var assignment in teamAssignments) {
        final user = assignment['user'];
        if (user == null) continue;

        final userId = user['id'];
        final fullUser = salaryMap[userId];
        double rawSalary = (fullUser?['salary'] as num?)?.toDouble() ?? 0.0;
        String salaryType = fullUser?['salaryType']?.toString() ?? 'MONTHLY';

        final designation =
            user['designation'] ?? assignment['role']?['name'] ?? 'Staff';
        if (designation.toString().toLowerCase().contains('company admin')) {
          continue;
        }

        _workers.add(WorkerAttendanceLocal(
          id: userId,
          name: user['name'] ?? 'Unknown',
          workerType: 'SITE_STAFF',
          isManagement: true, // Management staff
          designation: designation,
          baseRate: _calculateDailyRate(rawSalary, salaryType),
          status: 'Present',
          shiftTypeId: defaultShift?['id'],
          shiftMultiplier:
              (defaultShift?['multiplier'] as num?)?.toDouble() ?? 1.0,
        ));
      }

      // ==========================================
      // 3. APPLY EXISTING WORKER ATTENDANCE FROM DB
      // ==========================================
      final savedWorkerRecords = await ref
          .read(workerControllerProvider.notifier)
          .getSavedAttendance(projectId: widget.projectId, date: _selectedDate);

      int workersMarkedCount = 0;
      int totalSubcontractors =
          _workers.where((w) => !w.isManagement).length;

      for (var record in savedWorkerRecords) {
        // 🔥 THE FIX: Extract all possible IDs from the backend record
        final String siteStaffId = record['siteStaffId']?.toString() ?? '';
        final String subId = record['subcontractorWorkerId']?.toString() ?? '';
        final String recordId = record['id']?.toString() ?? '';

        // Match against SUBCONTRACTOR role using either ID
        final existingIndex = _workers.indexWhere((w) =>
            !w.isManagement &&
            (w.id == siteStaffId || w.id == subId));

        if (existingIndex >= 0) {
          workersMarkedCount++;
          final String backendStatus =
              record['status']?.toString().toUpperCase() ?? 'PRESENT';
          _workers[existingIndex].status =
              backendStatus == 'ABSENT' ? 'Absent' : 'Present';
          _workers[existingIndex].attendanceRecordId = recordId;

          if (record['wageRate'] != null) {
            _workers[existingIndex].baseRate =
                (record['wageRate'] as num).toDouble();
          }
          if (record['shiftTypeId'] != null) {
            _workers[existingIndex].shiftTypeId =
                record['shiftTypeId'].toString();
          }
          if (record['shiftMultiplier'] != null) {
            _workers[existingIndex].shiftMultiplier =
                (record['shiftMultiplier'] as num).toDouble();
          }
        }
      }

      // Hide Worker submit button if DB says all are marked
      if (totalSubcontractors > 0 &&
          workersMarkedCount == totalSubcontractors) {
        _isWorkersSubmitted = true;
      }

      // ==========================================
      // 4. APPLY EXISTING STAFF ATTENDANCE FROM DB
      // ==========================================
      try {
        final staffAttResponse = await dio.get(
          '/attendance/team',
          queryParameters: {
            'startDate': formattedDate,
            'endDate': formattedDate,
          },
        );

        final List<dynamic> allStaffRecords =
            staffAttResponse.data['data'] ?? [];
        final List<dynamic> savedStaffRecords = allStaffRecords.where((record) {
          final recordProjectId = record['project']?['id']?.toString() ??
              record['projectId']?.toString();
          return recordProjectId == widget.projectId;
        }).toList();

        int staffMarkedCount = 0;
        int totalStaff =
            _workers.where((w) => w.isManagement).length;

        for (var record in savedStaffRecords) {
          final String staffId = record['user']?['id']?.toString() ??
              record['userId']?.toString() ??
              '';
          final existingIndex = _workers.indexWhere(
              (w) => w.id == staffId && w.isManagement);

          if (existingIndex >= 0) {
            staffMarkedCount++;
            _workers[existingIndex].attendanceRecordId =
                record['id']?.toString();

            final String backendStatus =
                record['status']?.toString().toUpperCase() ?? 'PRESENT';
            if (backendStatus == 'ABSENT') {
              _workers[existingIndex].status = 'Absent';
            } else if (['ON_LEAVE', 'PAID_LEAVE', 'WEEK_OFF']
                .contains(backendStatus)) {
              _workers[existingIndex].status = 'On Leave';
            } else {
              _workers[existingIndex].status = 'Present';
            }
          }
        }

        // Hide Staff submit button if DB says all are marked
        if (totalStaff > 0 && staffMarkedCount == totalStaff) {
          _isStaffSubmitted = true;
        }
      } on DioException catch (e) {
        debugPrint("Staff GET error safely caught: ${e.message}");
      }
    } catch (e) {
      debugPrint("Error loading attendance: $e");
    } finally {
      setState(() => _isLoadingRecords = false);
    }
  }

  void _navigateToAddWorkers() async {
    // 🔥 Grab the IDs of everyone currently assigned
    final assignedWorkerIds = _workers.map((w) => w.id).toList();

    final didAdd = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddWorkerScreen(
                  projectId: widget.projectId,
                  assignedWorkerIds:
                      assignedWorkerIds, // 🔥 Pass them to the screen
                )));
    // If a worker was successfully assigned in the DB, fetch the fresh DB list
    if (didAdd == true) {
      _loadExistingAttendance();
    }
  }

  void _removeWorker(String id) {
    setState(() {
      _workers.removeWhere((w) => w.id == id);
      _activeDeleteId = null;
    });
  }

  Color _getStatusColor(String s) {
    if (s == 'Present') return Colors.green;
    if (s == 'Absent') return Colors.red;
    if (s == 'Week Off') return Colors.orange;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _workers.where((w) {
      if (_selectedRole == 'Staff') {
        return w.isManagement;
      } else {
        return !w.isManagement;
      }
    }).toList();

    double totalPayroll =
        filtered.fold(0, (sum, item) => sum + item.currentRate);
    int presentCount = filtered.where((w) => w.status == 'Present').length;

    bool hideButton = (_selectedRole == 'Staff' && _isStaffSubmitted) ||
        (_selectedRole == 'Workers' && _isWorkersSubmitted);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        title: const Text("Attendance",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context)),
      ),
      body: GestureDetector(
        onTap: () => setState(() => _activeDeleteId = null),
        child: Column(
          children: [
            _buildToggle(),
            _buildSummary(totalPayroll),
            _buildFilterRow(),
            _buildListHeader(presentCount, filtered.length),
            Expanded(
              child: _isLoadingRecords
                  ? const Center(child: CircularProgressIndicator())
                  : _buildList(filtered),
            ),
            if (!hideButton) _buildSubmitButton(filtered),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      margin: const EdgeInsets.all(20),
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: Colors.grey.shade100, borderRadius: BorderRadius.circular(25)),
      child: Row(
        children: ['Workers', 'Staff'].map((role) {
          bool isSelected = _selectedRole == role;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _selectedRole = role;
                _activeDeleteId = null;
              }),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color:
                        isSelected ? AppColors.primaryBlue : Colors.transparent,
                    borderRadius: BorderRadius.circular(20)),
                child: Text(role,
                    style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                        fontWeight: FontWeight.bold)),
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
          const Text("Total Payroll:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text("₹${total.toStringAsFixed(0)}",
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue)),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
            data: Theme.of(context).copyWith(
                colorScheme:
                    const ColorScheme.light(primary: AppColors.primaryBlue)),
            child: child!);
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, picked.day);
      });
      _loadExistingAttendance(); // 🔥 FETCh DB IMMEDIATELY
    }
  }

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue.shade100),
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.white),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat('MM/dd/yyyy').format(_selectedDate),
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    const Icon(Icons.calendar_today_outlined,
                        size: 16, color: AppColors.primaryBlue),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              setState(() {
                final now = DateTime.now();
                _selectedDate = DateTime(now.year, now.month, now.day);
              });
              _loadExistingAttendance(); // 🔥 FETCH DB IMMEDIATELY
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(25),
                  color: Colors.white),
              child: const Row(
                children: [
                  Text("Today", style: TextStyle(fontSize: 13)),
                  SizedBox(width: 5),
                  Icon(Icons.tune, size: 16, color: Colors.grey)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildListHeader(int present, int total) {
    bool isStaffTab = _selectedRole == 'Staff';
    bool hideButton = (_selectedRole == 'Staff' && _isStaffSubmitted) ||
        (_selectedRole == 'Workers' && _isWorkersSubmitted);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$present/$total Present",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
          // 🔥 Hide the "Add Workers" button if the UI is frozen!
          if (!isStaffTab && !hideButton)
            GestureDetector(
              onTap: _navigateToAddWorkers,
              child: const Text("+ Add Workers",
                  style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _buildList(List<WorkerAttendanceLocal> list) {
    if (list.isEmpty) {
      return Center(
          child: Text(
              "No assigned ${_selectedRole.toLowerCase()} found for this date."));
    }

    // 🔥 Calculate the frozen state right here
    bool isFrozen = (_selectedRole == 'Staff' && _isStaffSubmitted) ||
        (_selectedRole == 'Workers' && _isWorkersSubmitted);

    return ListView.builder(
      itemCount: list.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final worker = list[index];
        final isDeleting = _activeDeleteId == worker.id;
        final isStaffTab = _selectedRole == 'Staff';

        return GestureDetector(
          // UI FREEZE: Disable Long Press delete if already submitted
          onLongPress: (isStaffTab || isFrozen)
              ? null
              : () => setState(() => _activeDeleteId = worker.id),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDeleting
                  ? Colors.red.shade50
                  : (isFrozen ? Colors.grey.shade50 : Colors.white),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color:
                      isDeleting ? Colors.red.shade200 : Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(worker.name,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isFrozen
                                  ? Colors.grey.shade700
                                  : Colors.black),
                          overflow: TextOverflow.ellipsis),
                      Text(worker.designation,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                if (!isDeleting) ...[
                  if (!isStaffTab) ...[
                    SizedBox(
                      width: 65,
                      child: _buildRateDropdown(worker, isFrozen),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _buildShiftDropdown(
                            worker, isFrozen)), // Passing isFrozen instead
                    const SizedBox(width: 8),
                  ],
                  SizedBox(
                      width: 85,
                      child: _buildStatusDropdown(
                          worker, isFrozen)), // Passing isFrozen instead
                ] else
                  IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeWorker(worker.id)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRateDropdown(WorkerAttendanceLocal worker, bool isFrozen) {
    final isNonPresent =
        ['Absent', 'Week Off', 'Paid Leave', 'On Leave'].contains(worker.status);
    final effectiveIsFrozen = isFrozen || isNonPresent;

    return IgnorePointer(
      ignoring: effectiveIsFrozen,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
            color: effectiveIsFrozen ? Colors.grey.shade100 : Colors.white,
            border: Border.all(
                color: effectiveIsFrozen
                    ? Colors.grey.shade300
                    : Colors.blue.shade100),
            borderRadius: BorderRadius.circular(8)),
        child: isNonPresent
            ? Center(
                child: Text("₹0",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600)))
            : DropdownButtonHideUnderline(
                child: DropdownButton<double>(
                  value: _labourRatePresets.any((r) =>
                          (r['rate'] as num).toDouble() == worker.baseRate)
                      ? worker.baseRate
                      : (_labourRatePresets.isNotEmpty
                          ? (_labourRatePresets.first['rate'] as num).toDouble()
                          : null),
                  isExpanded: true,
                  icon: Icon(Icons.arrow_drop_down,
                      size: 20,
                      color: effectiveIsFrozen
                          ? Colors.transparent
                          : Colors.grey),
                  items: _labourRatePresets
                      .map((r) => DropdownMenuItem<double>(
                          value: (r['rate'] as num).toDouble(),
                          child: Text("₹${(r['rate'] as num).toInt()}",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: effectiveIsFrozen
                                      ? Colors.grey.shade700
                                      : Colors.black))))
                      .toList(),
                  selectedItemBuilder: (context) {
                    return _labourRatePresets.map((r) {
                      return Center(
                        child: Text(
                          "₹${((r['rate'] as num).toDouble() * worker.shiftMultiplier).toInt()}",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: effectiveIsFrozen
                                  ? Colors.grey.shade700
                                  : Colors.black),
                        ),
                      );
                    }).toList();
                  },
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        worker.baseRate = val;
                      });
                    }
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildShiftDropdown(WorkerAttendanceLocal worker, bool isFrozen) {
    return IgnorePointer(
      ignoring: isFrozen, // 🛡️ Glass shield blocks taps
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
            color: isFrozen ? Colors.grey.shade100 : Colors.white,
            border: Border.all(
                color: isFrozen ? Colors.grey.shade300 : Colors.blue.shade100),
            borderRadius: BorderRadius.circular(8)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: worker.shiftTypeId ?? _getDefaultShift()?['id'],
            isExpanded: true,
            icon: Icon(Icons.arrow_drop_down,
                size: 20, color: isFrozen ? Colors.transparent : Colors.grey),
            items: _dynamicShifts
                .map((s) => DropdownMenuItem(
                    value: s['id'] as String,
                    child: Text(s['name'] as String,
                        style: TextStyle(
                            fontSize: 12,
                            color:
                                isFrozen ? Colors.grey.shade700 : Colors.black),
                        overflow: TextOverflow.ellipsis)))
                .toList(),
            onChanged: (val) {
              final shift = _dynamicShifts.firstWhere((s) => s['id'] == val);
              setState(() {
                worker.shiftTypeId = val;
                worker.shiftMultiplier = shift['multiplier'];
              });
            },
          ),
        ),
      ),
    );
  }

  // 🔥 UI FREEZE: Accepts isFrozen flag and uses IgnorePointer to preserve text visibility
  Widget _buildStatusDropdown(WorkerAttendanceLocal worker, bool isFrozen) {
    final options =
        _selectedRole == 'Staff' ? _staffStatusOptions : _statusOptions;
    final color = isFrozen ? Colors.grey : _getStatusColor(worker.status);

    return IgnorePointer(
      ignoring: isFrozen, // 🛡️ Glass shield blocks taps
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
            color: isFrozen ? Colors.grey.shade100 : color.withOpacity(0.1),
            border: Border.all(
                color: isFrozen ? Colors.grey.shade300 : Colors.transparent),
            borderRadius: BorderRadius.circular(8)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: worker.status,
            isExpanded: true,
            icon: Icon(Icons.arrow_drop_down,
                size: 20, color: isFrozen ? Colors.transparent : color),
            style: TextStyle(
                color: isFrozen ? Colors.grey.shade700 : color,
                fontWeight: FontWeight.bold,
                fontSize: 11),
            items: options
                .map((o) => DropdownMenuItem(
                    value: o,
                    child: Text(o, style: const TextStyle(fontSize: 11))))
                .toList(),
            onChanged: (val) {
              setState(() {
                worker.status = val!;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(List list) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: list.isEmpty ? null : _submitAttendance,
        style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30))),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : Text("Submit $_selectedRole Attendance",
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _submitAttendance() async {
    setState(() => _isSubmitting = true);
    try {
      final dio = ref.read(dioClientProvider).dio;
      final String formattedDate =
          DateFormat("yyyy-MM-dd'T'00:00:00").format(_selectedDate);

      if (_selectedRole == 'Workers') {
        final workerList =
            _workers.where((w) => !w.isManagement).toList();
        final toCreate =
            workerList.where((w) => w.attendanceRecordId == null).toList();
        final toUpdate =
            workerList.where((w) => w.attendanceRecordId != null).toList();

        // 1. UPDATE Workers (PUT)
        for (var w in toUpdate) {
          String backendStatus = w.status == 'Present' ? 'PRESENT' : 'ABSENT';
          await dio.put('/workers/attendance/${w.attendanceRecordId}', data: {
            'status': backendStatus,
            'date': formattedDate,
            'projectId': widget.projectId,
            'shiftTypeId': w.shiftTypeId,
            'shiftMultiplier': w.shiftMultiplier,
            'wageRate': w.baseRate,
          });
        }

        // 2. CREATE Workers (POST)
        if (toCreate.isNotEmpty) {
          final workerData = toCreate
              .map((w) => {
                    'workerType': w.workerType,
                    'workerId': w.id,
                    'status': (w.status == 'Present') ? 'PRESENT' : 'ABSENT',
                    'shiftMultiplier': w.shiftMultiplier,
                    'wageRate': w.baseRate,
                    'shiftTypeId': w.shiftTypeId,
                    'notes': 'Daily Worker Attendance',
                  })
              .toList();

          final response = await dio.post('/workers/attendance/bulk', data: {
            'projectId': widget.projectId,
            'date': formattedDate,
            'attendanceData': workerData,
          });

          // Fallback logic
          if (response.data['errors'] != null) {
            for (var err in response.data['errors']) {
              if (err['error'] == "Attendance already marked for this date") {
                final String existingId = err['existingAttendanceId'];
                final String targetUserId = err['workerId'];
                final idx = _workers.indexWhere((w) => w.id == targetUserId);
                if (idx >= 0) {
                  _workers[idx].attendanceRecordId = existingId;
                  String fallbackStatus =
                      _workers[idx].status == 'Present' ? 'PRESENT' : 'ABSENT';
                  await dio.put('/workers/attendance/$existingId', data: {
                    'status': fallbackStatus,
                    'date': formattedDate,
                    'projectId': widget.projectId,
                    'shiftTypeId': _workers[idx].shiftTypeId,
                    'shiftMultiplier': _workers[idx].shiftMultiplier,
                  });
                }
              }
            }
          }
        }

        setState(() => _isWorkersSubmitted = true);
        await _loadExistingAttendance(); // 🔥 DB REFRESH

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Workers Attendance Saved!"),
                backgroundColor: Colors.green),
          );
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => PayrollDetailsScreen(
                        projectId: widget.projectId,
                      )));
        }
      } else {
        // --- STAFF LOGIC ---
        final staffList =
            _workers.where((w) => w.isManagement).toList();
        final toCreate =
            staffList.where((w) => w.attendanceRecordId == null).toList();
        final toUpdate =
            staffList.where((w) => w.attendanceRecordId != null).toList();

        // 1. UPDATE Staff
        for (var w in toUpdate) {
          String backendStatus = 'PRESENT';
          if (w.status == 'Absent') backendStatus = 'ABSENT';
          if (['On Leave', 'Paid Leave', 'Week Off'].contains(w.status)) {
            backendStatus = 'ON_LEAVE';
          }

          await dio.put('/attendance/${w.attendanceRecordId}', data: {
            'status': backendStatus,
            'date': formattedDate,
            'projectId': widget.projectId,
          });
        }

        // 2. CREATE Staff
        if (toCreate.isNotEmpty) {
          final staffData = toCreate.map((w) {
            String backendStatus = 'PRESENT';
            if (w.status == 'Absent') backendStatus = 'ABSENT';
            if (['On Leave', 'Paid Leave', 'Week Off'].contains(w.status)) {
              backendStatus = 'ON_LEAVE';
            }
            return {
              'userId': w.id,
              'status': backendStatus,
              'notes': 'Marked from Mobile App',
            };
          }).toList();

          final response = await dio.post('/attendance/mark', data: {
            'date': formattedDate,
            'projectId': widget.projectId,
            'attendanceRecords': staffData,
          });

          // Fallback logic
          if (response.data['errors'] != null) {
            for (var err in response.data['errors']) {
              if (err['error'] == "Attendance already marked for this date") {
                final String targetUserId = err['userId'];
                final String existingId = err['existingAttendanceId'];

                final idx = _workers.indexWhere((w) => w.id == targetUserId);
                if (idx >= 0) {
                  _workers[idx].attendanceRecordId = existingId;
                  String fallbackStatus = 'PRESENT';
                  if (_workers[idx].status == 'Absent') {
                    fallbackStatus = 'ABSENT';
                  }
                  if ([
                    'On Leave',
                    'Paid Leave',
                    'Week Off'
                  ].contains(_workers[idx].status)) {
                    fallbackStatus = 'ON_LEAVE';
                  }

                  await dio.put('/attendance/$existingId', data: {
                    'status': fallbackStatus,
                    'date': formattedDate,
                    'projectId': widget.projectId,
                  });
                }
              }
            }
          }
        }

        setState(() => _isStaffSubmitted = true);
        await _loadExistingAttendance(); // 🔥 DB REFRESH

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Staff Attendance Saved Successfully!"),
                backgroundColor: Colors.green),
          );
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => PayrollDetailsScreen(
                        projectId: widget.projectId,
                      )));
        }
      }

      ref.invalidate(payrollControllerProvider);
    } catch (e) {
      debugPrint("Submit Error: $e");
      if (mounted) {
        String errMsg = e.toString();
        if (e is DioException) {
          errMsg = e.response?.data['message'] ?? e.message ?? e.toString();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Submission Error: $errMsg"),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
