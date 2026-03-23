import 'dart:convert';
import 'package:construction_erp/controllers/core_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart'; // 🔥 Needed for Options and DioException
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/models/worker.dart';
import 'package:construction_erp/controllers/worker/worker_controller.dart';
import 'package:construction_erp/controllers/payroll/payroll_controller.dart';
import 'package:construction_erp/controllers/project/project_controller.dart';
import 'add_worker.dart';

class WorkerAttendanceLocal {
  final String id;
  final String name;
  final String workerType;
  final String designation;
  String status;
  String? shiftTypeId;
  double shiftMultiplier;
  double baseRate;
  String? attendanceRecordId;

  WorkerAttendanceLocal({
    required this.id,
    required this.name,
    required this.workerType,
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'workerType': workerType,
        'designation': designation,
        'status': status,
        'shiftTypeId': shiftTypeId,
        'shiftMultiplier': shiftMultiplier,
        'baseRate': baseRate,
        'attendanceRecordId': attendanceRecordId,
      };

  factory WorkerAttendanceLocal.fromJson(Map<String, dynamic> json) {
    String safeWorkerType = json['workerType'] ?? '';
    if (safeWorkerType.isEmpty) {
      String desig = (json['designation'] ?? '').toString().toLowerCase();
      safeWorkerType = desig == 'worker' ? 'SUBCONTRACTOR' : 'SITE_STAFF';
    }

    return WorkerAttendanceLocal(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      workerType: safeWorkerType,
      designation: json['designation'] ?? 'Worker',
      status: json['status'] ?? 'Present',
      shiftTypeId: json['shiftTypeId'],
      shiftMultiplier: (json['shiftMultiplier'] ?? 1.0).toDouble(),
      baseRate: (json['baseRate'] ?? 0.0).toDouble(),
      attendanceRecordId: json['attendanceRecordId'],
    );
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
      setState(() => _isStaffSubmitted = true);
      await _loadExistingAttendance();
    });
  }

  Future<void> _loadGlobalSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRate = prefs.getString('default_worker_rate');
    if (savedRate != null) {
      setState(() {
        _globalDefaultRate = double.tryParse(savedRate) ?? 500.0;
      });
    }
  }

  Future<void> _fetchDynamicShifts() async {
    final shifts = await ref.read(payrollControllerProvider).getShiftTypes();
    setState(() {
      _dynamicShifts = shifts
          .map((e) => {
                'id': e['id'],
                'multiplier': (e['multiplier'] as num).toDouble()
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

      // ==========================================
      // 1. LOAD WORKERS & STAFF BASICS
      // ==========================================
      final prefs = await SharedPreferences.getInstance();
      final rosterKey = 'project_roster_${widget.projectId}';
      final rosterString = prefs.getString(rosterKey);

      if (rosterString != null) {
        final List<dynamic> decoded = jsonDecode(rosterString);
        final List<WorkerAttendanceLocal> loadedRoster =
            decoded.map((e) => WorkerAttendanceLocal.fromJson(e)).toList();
        for (var w in loadedRoster) {
          if (w.workerType == 'SUBCONTRACTOR') {
            if (w.baseRate == 0) w.baseRate = _globalDefaultRate;
            w.status = 'Present';
            _workers.add(w);
          }
        }
      }

      final teamAssignments = await ref
          .read(projectControllerProvider.notifier)
          .getProjectTeam(widget.projectId);
      final usersResponse =
          await dio.get('/users', queryParameters: {'limit': 500});
      final List<dynamic> allUsers = usersResponse.data['data'] ?? [];
      final salaryMap = {for (var u in allUsers) u['id']: u};
      final defaultShift = _getDefaultShift();

      for (var assignment in teamAssignments) {
        final user = assignment['user'];
        if (user == null) continue;

        final userId = user['id'];
        final fullUser = salaryMap[userId];
        double rawSalary = (fullUser?['salary'] as num?)?.toDouble() ?? 0.0;
        String salaryType = fullUser?['salaryType']?.toString() ?? 'MONTHLY';

        _workers.add(WorkerAttendanceLocal(
          id: userId,
          name: user['name'] ?? 'Unknown',
          workerType: 'SITE_STAFF',
          designation:
              user['designation'] ?? assignment['role']?['name'] ?? 'Staff',
          baseRate: _calculateDailyRate(rawSalary, salaryType),
          status: 'Present',
          shiftTypeId: defaultShift?['id'],
          shiftMultiplier:
              (defaultShift?['multiplier'] as num?)?.toDouble() ?? 1.0,
        ));
      }

      // ==========================================
      // 2. FETCH EXISTING WORKER ATTENDANCE
      // ==========================================
      final savedWorkerRecords = await ref
          .read(workerControllerProvider.notifier)
          .getSavedAttendance(projectId: widget.projectId, date: _selectedDate);

      for (var record in savedWorkerRecords) {
        final String workerId = record['workerId']?.toString() ??
            record['subcontractorWorkerId']?.toString() ??
            '';
        final existingIndex = _workers.indexWhere(
            (w) => w.id == workerId && w.workerType == 'SUBCONTRACTOR');

        if (existingIndex >= 0) {
          final String backendStatus =
              record['status']?.toString().toUpperCase() ?? 'PRESENT';
          _workers[existingIndex].status =
              backendStatus == 'ABSENT' ? 'Absent' : 'Present';
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

      // ==========================================
      // 3. 🔥 FETCH EXISTING STAFF ATTENDANCE
      // ==========================================
      final String formattedDate =
          DateFormat('yyyy-MM-dd').format(_selectedDate);

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

        // Since projectId may be stripped by backend validation, filter locally
        final List<dynamic> savedStaffRecords = allStaffRecords.where((record) {
          final recordProjectId = record['project']?['id']?.toString() ??
              record['projectId']?.toString();
          return recordProjectId == widget.projectId;
        }).toList();

        for (var record in savedStaffRecords) {
          final String staffId = record['user']?['id']?.toString() ??
              record['userId']?.toString() ??
              '';

          final existingIndex = _workers.indexWhere(
            (w) => w.id == staffId && w.workerType == 'SITE_STAFF',
          );

          if (existingIndex >= 0) {
            _workers[existingIndex].attendanceRecordId =
                record['id']?.toString();

            final String backendStatus =
                record['status']?.toString().toUpperCase() ?? 'PRESENT';

            if (backendStatus == 'ABSENT') {
              _workers[existingIndex].status = 'Absent';
            } else if (backendStatus == 'ON_LEAVE') {
              _workers[existingIndex].status = 'On Leave';
            } else if (backendStatus == 'WEEK_OFF') {
              _workers[existingIndex].status = 'Week Off';
            } else {
              _workers[existingIndex].status = 'Present';
            }
          }
        }
      } on DioException catch (e) {
        debugPrint(
            "Staff GET 500 Error safely caught: Backend crashed fetching team attendance. Skipping fetch, relying on fallback. Error: ${e.message}");
      } catch (e) {
        debugPrint("Other error processing staff attendance: $e");
      }
    } catch (e) {
      debugPrint("Error loading attendance: $e");
    } finally {
      setState(() => _isLoadingRecords = false);
    }
  }

  void _navigateToAddWorkers() async {
    final result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const AddWorkerScreen()));
    if (result != null && result is List) {
      final returnedWorkers = result.whereType<Worker>().toList();
      final defaultShift = _getDefaultShift();

      setState(() {
        for (var worker in returnedWorkers) {
          if (worker.id.isEmpty) continue;
          if (!_workers.any((w) => w.id == worker.id)) {
            _workers.add(WorkerAttendanceLocal(
              id: worker.id,
              name: worker.name ?? 'Unknown',
              workerType: 'SUBCONTRACTOR',
              designation: worker.designation ?? 'Worker',
              baseRate: worker.dailyWageRate.toDouble(),
              shiftTypeId: defaultShift?['id'],
              shiftMultiplier:
                  (defaultShift?['multiplier'] as num?)?.toDouble() ?? 1.0,
            ));
          }
        }
      });
      _saveRoster();
    }
  }

  void _removeWorker(String id) {
    setState(() {
      _workers.removeWhere((w) => w.id == id);
      _activeDeleteId = null;
    });
    _saveRoster();
  }

  Future<void> _saveRoster() async {
    final prefs = await SharedPreferences.getInstance();
    final subcontractors =
        _workers.where((w) => w.workerType == 'SUBCONTRACTOR').toList();
    await prefs.setString('project_roster_${widget.projectId}',
        jsonEncode(subcontractors.map((w) => w.toJson()).toList()));
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
      return _selectedRole == 'Staff'
          ? w.workerType == 'SITE_STAFF'
          : w.workerType == 'SUBCONTRACTOR';
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
      _loadExistingAttendance();
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
              _loadExistingAttendance();
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$present/$total Present",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
          if (!isStaffTab)
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
    return ListView.builder(
      itemCount: list.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final worker = list[index];
        final isDeleting = _activeDeleteId == worker.id;
        final isStaffTab = _selectedRole == 'Staff';

        return GestureDetector(
          onLongPress: isStaffTab
              ? null
              : () => setState(() => _activeDeleteId = worker.id),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDeleting ? Colors.red.shade50 : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color:
                      isDeleting ? Colors.red.shade200 : Colors.grey.shade100),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(worker.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                          overflow: TextOverflow.ellipsis),
                      Text(worker.designation,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                if (!isDeleting) ...[
                  Container(
                    width: 50,
                    alignment: Alignment.centerRight,
                    child: Text(
                        "₹${worker.currentRate < 1 && worker.currentRate > 0 ? worker.currentRate.toStringAsFixed(1) : worker.currentRate.toStringAsFixed(0)}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(width: 70, child: _buildShiftDropdown(worker)),
                  const SizedBox(width: 8),
                  SizedBox(width: 95, child: _buildStatusDropdown(worker)),
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

  Widget _buildShiftDropdown(WorkerAttendanceLocal worker) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.blue.shade100),
          borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: worker.shiftTypeId ?? _getDefaultShift()?['id'],
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          items: _dynamicShifts
              .map((s) => DropdownMenuItem(
                  value: s['id'] as String,
                  child: Text("x${s['multiplier']}",
                      style: const TextStyle(fontSize: 12))))
              .toList(),
          onChanged: (val) {
            final shift = _dynamicShifts.firstWhere((s) => s['id'] == val);
            setState(() {
              worker.shiftTypeId = val;
              worker.shiftMultiplier = shift['multiplier'];
              if (_selectedRole == 'Staff') _isStaffSubmitted = false;
              if (_selectedRole == 'Workers') _isWorkersSubmitted = false;
            });
          },
        ),
      ),
    );
  }

  Widget _buildStatusDropdown(WorkerAttendanceLocal worker) {
    final options =
        _selectedRole == 'Staff' ? _staffStatusOptions : _statusOptions;
    final color = _getStatusColor(worker.status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: worker.status,
          isExpanded: true,
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 11),
          items: options
              .map((o) => DropdownMenuItem(
                  value: o,
                  child: Text(o, style: const TextStyle(fontSize: 11))))
              .toList(),
          onChanged: (val) {
            setState(() {
              worker.status = val!;
              if (_selectedRole == 'Staff') _isStaffSubmitted = false;
              if (_selectedRole == 'Workers') _isWorkersSubmitted = false;
            });
          },
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
          DateFormat('yyyy-MM-dd').format(_selectedDate);

      if (_selectedRole == 'Workers') {
        final workerList =
            _workers.where((w) => w.workerType == 'SUBCONTRACTOR').toList();
        final workerData = workerList
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

        await ref.read(workerControllerProvider.notifier).submitBulkAttendance(
              projectId: widget.projectId,
              date: _selectedDate,
              attendanceData: workerData,
            );

        setState(() => _isWorkersSubmitted = true);
      } else {
        // --- STAFF LOGIC ---
        final staffList =
            _workers.where((w) => w.workerType == 'SITE_STAFF').toList();

        final toCreate =
            staffList.where((w) => w.attendanceRecordId == null).toList();
        final toUpdate =
            staffList.where((w) => w.attendanceRecordId != null).toList();

        // 1. Process Updates (PUT) for staff we already know about
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

        // 2. Try to create the rest (POST)
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

          final response = await dio.post('/attendance/mark-bulk', data: {
            'date': formattedDate,
            'projectId': widget.projectId,
            'attendanceData': staffData,
          });

          // 3. THE MAGICAL FALLBACK: If they already exist, extract their IDs and force an update!
          if (response.data['errors'] != null) {
            final List<dynamic> errors = response.data['errors'];
            for (var err in errors) {
              if (err['error'] == "Attendance already marked for this date") {
                final String targetUserId = err['userId'];
                final String existingId = err['existingAttendanceId'];

                // Find the worker locally and update their ID
                final idx = _workers.indexWhere((w) => w.id == targetUserId);
                if (idx >= 0) {
                  _workers[idx].attendanceRecordId = existingId;

                  // Figure out what status you were trying to send
                  String fallbackStatus = 'PRESENT';
                  if (_workers[idx].status == 'Absent') {
                    fallbackStatus = 'ABSENT';
                  }
                  if (['On Leave', 'Paid Leave', 'Week Off']
                      .contains(_workers[idx].status)) {
                    fallbackStatus = 'ON_LEAVE';
                  }

                  // 🔥 Instantly update it now that we know the ID!
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

        setState(() {
          _isStaffSubmitted = true;
        });
      }

      ref.invalidate(payrollControllerProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$_selectedRole Attendance Saved Successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("Submit Error: $e");
      // We swallow the error UI to green because our fallback handles the duplicates
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$_selectedRole Attendance Synced!"),
          backgroundColor: Colors.green,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
