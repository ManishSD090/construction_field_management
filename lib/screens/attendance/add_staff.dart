import 'dart:convert'; // 🚨 Added for JSON encoding
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/models/worker.dart';
import 'package:construction_erp/controllers/worker/worker_controller.dart';

class AddStaffScreen extends ConsumerStatefulWidget {
  const AddStaffScreen({super.key});

  @override
  ConsumerState<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends ConsumerState<AddStaffScreen> {
  bool _isSelectionEnabled = false;
  final Set<String> _selectedStaffIds = {};

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _salaryController =
      TextEditingController(); // 🚨 NEW
  String? _aadharPath;
  final ImagePicker _picker = ImagePicker();

  final List<Worker> _localStaffList = [];

  bool get _hasSelection => _selectedStaffIds.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadLocalStaff();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _salaryController.dispose(); // 🚨 NEW
    super.dispose();
  }

  Future<void> _loadLocalStaff() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString('saved_project_staff');

    if (encodedData != null) {
      try {
        final List<dynamic> decodedData = jsonDecode(encodedData);
        setState(() {
          _localStaffList.clear();
          _localStaffList.addAll(decodedData.map((data) => Worker(
                id: data['id'],
                name: data['name'],
                workerId: data['workerId'],
                designation: data['designation'],
                dailyWageRate: (data['dailyWageRate'] ?? 0).toDouble(),
              )));
        });
      } catch (e) {
        debugPrint("Error loading local staff: $e");
      }
    }
  }

// ... inside _AddStaffScreenState ...

  Future<void> _saveLocalStaff() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(
      _localStaffList
          .map((w) => {
                'id': w.id,
                'name': w.name,
                'workerId': w.workerId,
                'designation': w.designation,
                'dailyWageRate':
                    w.dailyWageRate, // Store the raw monthly salary here
                'workerType': 'SITE_STAFF' // Ensure Type is explicitly saved
              })
          .toList(),
    );
    await prefs.setString('saved_project_staff', encodedData);
  }

  void _showAddStaffDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    final staffFromDB =
        await ref.read(workerControllerProvider.notifier).fetchSystemStaff();

    if (mounted) Navigator.pop(context);

    Worker? localSelectedWorker;
    String? localSelectedRole;

    final List<String> roleOptions = [
      'Site Engineer',
      'Supervisor',
      'Project Manager',
      'Architect',
      'Company Administrator',
      'Staff'
    ];

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Center(
                child: Text("Add Staff",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Name",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.black87)),
                  const SizedBox(height: 6),
// 1. WORKER DROPDOWN
                  DropdownButtonFormField<Worker>(
                    initialValue: localSelectedWorker,
                    decoration: InputDecoration(
                      hintText: staffFromDB.isEmpty
                          ? "No staff found in DB"
                          : "Select staff member",
                      hintStyle: TextStyle(
                          color: AppColors.primaryBlue.withOpacity(0.5),
                          fontSize: 13),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AppColors.primaryBlue)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AppColors.primaryBlue)),
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: AppColors.primaryBlue),
                    items: staffFromDB
                        .map((w) => DropdownMenuItem(
                            value: w, child: Text(w.name ?? 'Unknown')))
                        .toList(),
                    onChanged: (Worker? val) {
                      if (val != null) {
                        setDialogState(() {
                          localSelectedWorker = val;

                          // 🔥 FIX 1: If the DB role isn't in the list, add it dynamically!
                          if (val.designation != null &&
                              val.designation!.isNotEmpty) {
                            if (!roleOptions.contains(val.designation)) {
                              roleOptions
                                  .add(val.designation!); // Add missing role
                            }
                            localSelectedRole = val.designation;
                          } else {
                            localSelectedRole = null;
                          }

                          _salaryController.text =
                              (val.dailyWageRate ?? 0).toInt().toString();
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text("Role Name",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.black87)),
                  const SizedBox(height: 6),

                  // 2. ROLE DROPDOWN
                  DropdownButtonFormField<String>(
                    initialValue: localSelectedRole, 
                    decoration: InputDecoration(
                      hintText: "Select Role",
                      hintStyle: TextStyle(
                          color: AppColors.primaryBlue.withOpacity(0.5),
                          fontSize: 13),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AppColors.primaryBlue)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AppColors.primaryBlue)),
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: AppColors.primaryBlue),
                    items: roleOptions
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (val) =>
                        setDialogState(() => localSelectedRole = val),
                  ),

                  const SizedBox(height: 16),
                  const Text("Monthly Salary",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.black87)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _salaryController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Enter salary per month",
                      hintStyle: TextStyle(
                          color: AppColors.primaryBlue.withOpacity(0.5),
                          fontSize: 13),
                      prefixText: "₹ ",
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AppColors.primaryBlue)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AppColors.primaryBlue)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text("Aadhar card",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.black87)),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final XFile? image = await _picker.pickImage(
                            source: ImageSource.gallery);
                        if (image != null) {
                          setDialogState(() => _aadharPath = image.path);
                        }
                      },
                      icon: Icon(
                          _aadharPath == null
                              ? Icons.description_outlined
                              : Icons.check_circle,
                          color: AppColors.primaryBlue,
                          size: 18),
                      label: Text(
                          _aadharPath == null ? "Select file" : "File Selected",
                          style: const TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryBlue),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text("Upload a jpeg, jpg, png, pdf no larger than 10 MB",
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 10)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (localSelectedWorker != null &&
                          localSelectedRole != null) {
                        final salary =
                            double.tryParse(_salaryController.text) ?? 0.0;
                        setState(() {
                          if (!_localStaffList
                              .any((w) => w.id == localSelectedWorker!.id)) {
                            _localStaffList.add(Worker(
                              id: localSelectedWorker!.id,
                              name: localSelectedWorker!.name,
                              workerId: localSelectedWorker!.workerId,
                              designation: localSelectedRole,
                              dailyWageRate: salary, // Storing monthly salary
                            ));
                          }
                        });
                        _saveLocalStaff();
                        _salaryController.clear();
                        _aadharPath = null;
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text("Please select a name and role")));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                    ),
                    child: const Text("Create",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Remove Staff"),
        content: Text(
            "Are you sure you want to remove ${_selectedStaffIds.length} selected person(s)?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _localStaffList.removeWhere(
                    (local) => _selectedStaffIds.contains(local.id));
                _selectedStaffIds.clear();
                _isSelectionEnabled = false;
              });
              _saveLocalStaff();
            },
            child: const Text("Remove",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workersAsync = ref.watch(workerControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        title: const Text("Staff Details",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildSearchField(),
          _buildListTitleRow(),
          const Divider(height: 1),
          Expanded(
            child: workersAsync.when(
              data: (workers) {
                var dbStaff = workers.where((w) {
                  final d = w.designation?.toLowerCase() ?? '';
                  return d != 'worker' && d != '';
                }).toList();

                List<Worker> combinedStaff = [...dbStaff, ..._localStaffList];

                if (combinedStaff.isEmpty) {
                  return const Center(
                      child: Text("No staff assigned yet. Add one!",
                          style: TextStyle(color: Colors.grey)));
                }

                return _buildStaffList(combinedStaff);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) =>
                  const Center(child: Text("Error loading data")),
            ),
          ),
          if (_isSelectionEnabled && _hasSelection)
            workersAsync.maybeWhen(
              data: (workers) {
                var dbStaff = workers
                    .where((w) =>
                        w.designation != null &&
                        w.designation!.toLowerCase() != 'worker')
                    .toList();
                final combined = [...dbStaff, ..._localStaffList];
                return _buildBottomActions(combined);
              },
              orElse: () => const SizedBox.shrink(),
            ),
        ],
      ),
      floatingActionButton: !_isSelectionEnabled
          ? FloatingActionButton(
              onPressed: _showAddStaffDialog,
              backgroundColor: AppColors.primaryBlue,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => ref
            .read(workerControllerProvider.notifier)
            .fetchWorkersForAttendance(search: val),
        decoration: InputDecoration(
          hintText: "Search People",
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildListTitleRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Staff List/ Payroll",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          IconButton(
            icon: Icon(
                _isSelectionEnabled
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                color: _isSelectionEnabled
                    ? AppColors.primaryBlue
                    : Colors.grey.shade600),
            onPressed: () => setState(() {
              _isSelectionEnabled = !_isSelectionEnabled;
              if (!_isSelectionEnabled) _selectedStaffIds.clear();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffList(List<Worker> staffList) {
    return ListView.builder(
      itemCount: staffList.length,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemBuilder: (context, index) {
        final staff = staffList[index];
        final isSelected = _selectedStaffIds.contains(staff.id);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.shade100,
                  blurRadius: 4,
                  offset: const Offset(0, 2))
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: _isSelectionEnabled ? Checkbox(
              value: isSelected,
              activeColor: AppColors.primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              onChanged: (val) => setState(() => val! ? _selectedStaffIds.add(staff.id) : _selectedStaffIds.remove(staff.id)),
            ) : null,
            title: Text(staff.name ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(staff.designation ?? 'Staff', style: const TextStyle(color: AppColors.primaryBlue, fontSize: 12, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text("Created on: 12 FEB 2026", style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
                ],
              ),
            ),
            trailing: Text("₹${staff.dailyWageRate.toInt()}",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            onTap: () {
              if (_isSelectionEnabled) {
                setState(() => isSelected ? _selectedStaffIds.remove(staff.id) : _selectedStaffIds.add(staff.id));
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildBottomActions(List<Worker> allStaff) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -5))
      ]),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30))),
        onPressed: () {
          final selectedStaff =
              allStaff.where((w) => _selectedStaffIds.contains(w.id)).toList();
          Navigator.pop(context, selectedStaff);
        },
        child: const Text("Add to the Project",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
      ),
    );
  }
}
