import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/controllers/payroll/payroll_controller.dart';
import 'package:construction_erp/controllers/worker/worker_controller.dart';
import 'package:construction_erp/models/worker.dart';

class PayrollSettingsScreen extends ConsumerStatefulWidget {
  const PayrollSettingsScreen({super.key});

  @override
  ConsumerState<PayrollSettingsScreen> createState() =>
      _PayrollSettingsScreenState();
}

class _PayrollSettingsScreenState extends ConsumerState<PayrollSettingsScreen> {
  String _selectedRole = 'Workers';
  bool _isEditingStaff = false;
  bool _isLoading = true;
  bool _isSaving = false;

  List<dynamic> _shifts = [];
  List<Worker> _staffList = [];

  final TextEditingController _globalWorkerRateController =
      TextEditingController(text: "500");
  final Map<String, TextEditingController> _staffSalaryControllers = {};

  final String _projectId = "ca0ee39d-f2e9-46d2-8cec-d3a8bb44b755";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSettingsData());
  }

  @override
  void dispose() {
    _globalWorkerRateController.dispose();
    for (var controller in _staffSalaryControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadSettingsData() async {
    setState(() => _isLoading = true);
    try {
      final payrollCtrl = ref.read(payrollControllerProvider);
      final workerCtrl = ref.read(workerControllerProvider.notifier);

      final prefs = await SharedPreferences.getInstance();
      final savedRate = prefs.getString('default_worker_rate');
      if (savedRate != null) {
        _globalWorkerRateController.text = savedRate;
      }

      final shifts = await payrollCtrl.getShiftTypes();
      final staff = await workerCtrl.fetchSystemStaff();

      _staffSalaryControllers.clear();
      for (var s in staff) {
        _staffSalaryControllers[s.id] = TextEditingController(
            text: (s.dailyWageRate ?? 0).toInt().toString());
      }

      if (mounted) {
        setState(() {
          _shifts = shifts;
          _staffList = staff;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading settings: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveWorkerSettings() async {
    setState(() => _isSaving = true);
    try {
      final rateText = _globalWorkerRateController.text;
      final rate = double.tryParse(rateText) ?? 500.0;

      final allWorkers = await ref
          .read(workerControllerProvider.notifier)
          .fetchWorkersForAttendance();

      final laborWorkers = allWorkers.where((w) {
        final d = w.designation?.toLowerCase() ?? '';
        return d == 'worker' || d == '';
      }).toList();

      for (var w in laborWorkers) {
        await ref.read(payrollControllerProvider).createLabourRate(
              workerType: 'SITE_STAFF',
              workerId: w.id!,
              rate: rate,
              effectiveFrom: DateTime.now(),
            );
        await Future.delayed(const Duration(milliseconds: 50));
            }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('default_worker_rate', rateText);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Worker rates updated successfully!"),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _saveStaffSettings() async {
    setState(() => _isSaving = true);
    try {
      final payrollCtrl = ref.read(payrollControllerProvider);
      final prefs = await SharedPreferences.getInstance();

      // 1. Update Backend
      for (var staff in _staffList) {
        final controller = _staffSalaryControllers[staff.id];
        double newRate = double.tryParse(controller?.text ?? '0') ??
            (staff.dailyWageRate ?? 0).toDouble();

        await payrollCtrl.createLabourRate(
          workerType: 'SITE_STAFF',
          workerId: staff.id,
          rate: newRate,
          effectiveFrom: DateTime.now(),
        );
      }

      // 2. Update Local Project Roster to ensure Attendance screen sees it immediately
      final rosterKey = 'project_roster_$_projectId';
      final rosterString = prefs.getString(rosterKey);
      if (rosterString != null) {
        List<dynamic> roster = jsonDecode(rosterString);
        for (var item in roster) {
          if (_staffSalaryControllers.containsKey(item['id'])) {
            item['baseRate'] =
                double.tryParse(_staffSalaryControllers[item['id']]!.text) ??
                    0.0;
          }
        }
        await prefs.setString(rosterKey, jsonEncode(roster));
      }

      if (mounted) {
        setState(() => _isEditingStaff = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Staff monthly salaries updated!"),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // --- UI BUILDING ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text("Payroll Settings",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildRoleToggle(),
                Expanded(
                  child: _selectedRole == 'Workers'
                      ? _buildWorkersContent()
                      : _buildStaffContent(),
                ),
                if (_selectedRole == 'Workers') _buildSaveButton(),
              ],
            ),
    );
  }

  Widget _buildRoleToggle() {
    return Container(
      margin: const EdgeInsets.all(20),
      height: 48,
      decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(25)),
      child: Row(
        children: ['Workers', 'Staff'].map((role) {
          bool isSelected = _selectedRole == role;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _selectedRole = role;
                _isEditingStaff = false;
              }),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color:
                        isSelected ? AppColors.primaryBlue : Colors.transparent,
                    borderRadius: BorderRadius.circular(20)),
                child: Text(role,
                    style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWorkersContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabourRateInput(),
          const SizedBox(height: 30),
          const Text("Available shifts",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 15),
          _buildShiftList(),
        ],
      ),
    );
  }

  Widget _buildLabourRateInput() {
    return Row(
      children: [
        const Text("Default Rate  ",
            style: TextStyle(fontWeight: FontWeight.w500)),
        Container(
          width: 120,
          height: 40,
          decoration: BoxDecoration(
              border: Border.all(color: AppColors.primaryBlue),
              borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Text("₹",
                    style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: TextField(
                  controller: _globalWorkerRateController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Text("  per Day", style: TextStyle(color: AppColors.primaryBlue)),
      ],
    );
  }

  Widget _buildShiftList() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ..._shifts.map((shift) => GestureDetector(
              onLongPress: () =>
                  _confirmDeleteShift(shift['id'], "x${shift['multiplier']}"),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.05),
                    border: Border.all(color: AppColors.primaryBlue),
                    borderRadius: BorderRadius.circular(10)),
                child: Text("x${shift['multiplier']}",
                    style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold)),
              ),
            )),
        GestureDetector(
            onTap: _showCreateShiftDialog,
            child: const Icon(Icons.add_circle,
                color: AppColors.primaryBlue, size: 36)),
      ],
    );
  }

  Widget _buildStaffContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Staff Monthly Salaries",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              _isEditingStaff
                  ? IconButton(
                      icon: const Icon(Icons.check_circle,
                          color: Colors.green, size: 28),
                      onPressed: _isSaving ? null : _saveStaffSettings)
                  : IconButton(
                      icon:
                          const Icon(Icons.edit, color: Colors.blue, size: 24),
                      onPressed: () => setState(() => _isEditingStaff = true)),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _staffList.length,
              itemBuilder: (context, index) {
                final staff = _staffList[index];
                final controller = _staffSalaryControllers[staff.id];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(staff.name ?? '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text(staff.designation ?? '',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      _isEditingStaff
                          ? SizedBox(
                              width: 110,
                              child: TextField(
                                  controller: controller,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.right,
                                  decoration: const InputDecoration(
                                    prefixText: "₹ ",
                                    suffixText: "/mo",
                                    isDense: true,
                                  )))
                          : Text("₹${controller?.text ?? '0'}/mo",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBlue)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteShift(String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Shift"),
        content: Text("Are you sure you want to delete '$name'?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              await ref.read(payrollControllerProvider).deleteShiftType(id);
              await _loadSettingsData();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCreateShiftDialog() {
    final multiplierController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Multiplier"),
        content: TextField(
          controller: multiplierController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(hintText: "e.g. 1.5"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (multiplierController.text.isNotEmpty) {
                Navigator.pop(context);
                setState(() => _isLoading = true);
                await ref.read(payrollControllerProvider).createShiftType(
                    name: "x${multiplierController.text}",
                    multiplier: double.parse(multiplierController.text));
                _loadSettingsData();
              }
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveWorkerSettings,
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00B69B),
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30))),
        child: _isSaving
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("Save Worker Settings",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
