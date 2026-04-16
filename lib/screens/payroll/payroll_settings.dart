import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/controllers/payroll/payroll_controller.dart';
// Needed for the direct dio call

class PayrollSettingsScreen extends ConsumerStatefulWidget {
  final String projectId; // 🔥 1. Accept projectId from the parent screen

  // 🔥 2. Require projectId in the constructor
  const PayrollSettingsScreen({super.key, required this.projectId});

  @override
  ConsumerState<PayrollSettingsScreen> createState() =>
      _PayrollSettingsScreenState();
}

class _PayrollSettingsScreenState extends ConsumerState<PayrollSettingsScreen> {
  bool _isLoading = true;
  final bool _isSaving = false;

  List<dynamic> _shifts = [];
  List<dynamic> _labourRates = [];
  
  final Set<String> _selectedRateIds = {};
  final Set<String> _selectedShiftIds = {};

  final TextEditingController _globalWorkerRateController =
      TextEditingController(text: "500");

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSettingsData());
  }

  @override
  void dispose() {
    _globalWorkerRateController.dispose();
    super.dispose();
  }

  Future<void> _loadSettingsData() async {
    setState(() => _isLoading = true);
    try {
      final payrollCtrl = ref.read(payrollControllerProvider);

      // Load available shifts
      final shifts = await payrollCtrl.getShiftTypes();
      
      // Load available labour rate presets (workerId null implies global preset)
      final rateHistory = await payrollCtrl.getLabourRates(isCurrent: true);
      final presets = rateHistory.where((r) => r['siteStaffId'] == null && r['subcontractorWorkerId'] == null).toList();

      if (!mounted) return;

      setState(() {
        _shifts = shifts;
        _labourRates = presets;
        _isLoading = false;
        _selectedRateIds.clear();
        _selectedShiftIds.clear();
      });
    } catch (e) {
      debugPrint("Error loading settings: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveWorkerSettings() async {
    // This button now just pops back as we save rates/shifts individually in the new UI flow
    Navigator.pop(context, true);
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
                Expanded(
                  child: _buildWorkersContent(),
                ),
                _buildSaveButton(),
              ],
            ),
    );
  }

  Widget _buildWorkersContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Row(
            children: [
              const Text("Project Specific Labour Rate",
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold)),
              const Spacer(),
              if (_selectedRateIds.isNotEmpty)
                TextButton.icon(
                  onPressed: _confirmBulkDeleteRates,
                  icon: const Icon(Icons.delete_sweep, color: Colors.red, size: 20),
                  label: Text("Delete (${_selectedRateIds.length})", 
                      style: const TextStyle(color: Colors.red, fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 10),
          _buildLabourRateInput(),
          const SizedBox(height: 40),
          Row(
            children: [
              const Text("Global Available Shifts",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Spacer(),
              if (_selectedShiftIds.isNotEmpty)
                TextButton.icon(
                  onPressed: _confirmBulkDeleteShifts,
                  icon: const Icon(Icons.delete_sweep, color: Colors.red, size: 20),
                  label: Text("Delete (${_selectedShiftIds.length})", 
                      style: const TextStyle(color: Colors.red, fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 15),
          _buildShiftList(),
        ],
      ),
    );
  }

  Widget _buildLabourRateInput() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ..._labourRates.map((rate) {
          final isSelected = _selectedRateIds.contains(rate['id']);
          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedRateIds.remove(rate['id']);
                } else {
                  _selectedRateIds.add(rate['id']);
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF00B69B).withOpacity(0.1) : Colors.transparent,
                  border: Border.all(color: isSelected ? const Color(0xFF00B69B) : Colors.grey.withOpacity(0.3), width: isSelected ? 2 : 1),
                  borderRadius: BorderRadius.circular(10)),
              child: Text("₹${rate['rate']}",
                  style: TextStyle(
                      color: const Color(0xFF00B69B),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            ),
          );
        }),
        GestureDetector(
            onTap: _showCreateLabourRateDialog,
            child: const Icon(Icons.add_circle,
                color: Color(0xFF00B69B), size: 36)),
      ],
    );
  }

  void _confirmBulkDeleteRates() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Labour Rates"),
        content: Text("Are you sure you want to delete ${_selectedRateIds.length} labour rates?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              try {
                await ref.read(payrollControllerProvider).bulkDeleteLabourRates(_selectedRateIds.toList());
                await _loadSettingsData();
              } catch (e) {
                debugPrint("Error bulk deleting labour rates: $e");
                if (mounted) {
                  setState(() => _isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCreateLabourRateDialog() {
    final rateController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Labour Rate"),
        content: TextField(
          controller: rateController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(hintText: "e.g. 600"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (rateController.text.isNotEmpty) {
                final rate = double.tryParse(rateController.text);
                if (rate == null) return;

                Navigator.pop(context);
                setState(() => _isLoading = true);
                
                try {
                  // For a global preset, siteStaffId and subcontractorWorkerId are left null
                  // We use SITE_STAFF as a placeholder workerType, but with null IDs it's a global preset
                  await ref.read(payrollControllerProvider).createLabourRate(
                      workerType: 'SITE_STAFF', 
                      workerId: '', // Setting to empty string indicates preset in our new backend logic
                      rate: rate,
                      effectiveFrom: DateTime.now());
                  await _loadSettingsData();
                } catch (e) {
                  debugPrint("Error creating labour rate: $e");
                  if (mounted) {
                    setState(() => _isLoading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                    );
                  }
                }
              }
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftList() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ..._shifts.map((shift) {
          final isSelected = _selectedShiftIds.contains(shift['id']);
          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedShiftIds.remove(shift['id']);
                } else {
                  _selectedShiftIds.add(shift['id']);
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryBlue.withOpacity(0.1) : Colors.blue.withOpacity(0.05),
                  border: Border.all(color: isSelected ? AppColors.primaryBlue : AppColors.primaryBlue.withOpacity(0.5), width: isSelected ? 2 : 1),
                  borderRadius: BorderRadius.circular(10)),
              child: Text("x${shift['multiplier']}",
                  style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            ),
          );
        }),
        GestureDetector(
            onTap: _showCreateShiftDialog,
            child: const Icon(Icons.add_circle,
                color: AppColors.primaryBlue, size: 36)),
      ],
    );
  }

  void _confirmBulkDeleteShifts() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Shifts"),
        content: Text("Are you sure you want to delete ${_selectedShiftIds.length} shift types?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              try {
                await ref.read(payrollControllerProvider).bulkDeleteShiftTypes(_selectedShiftIds.toList());
                await _loadSettingsData();
              } catch (e) {
                debugPrint("Error bulk deleting shift types: $e");
                if (mounted) {
                  setState(() => _isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                  );
                }
              }
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
                final mult = double.tryParse(multiplierController.text);
                if (mult == null) return;

                Navigator.pop(context);
                setState(() => _isLoading = true);
                try {
                  await ref.read(payrollControllerProvider).createShiftType(
                      name: "x${multiplierController.text}",
                      multiplier: mult);
                  await _loadSettingsData();
                } catch (e) {
                  debugPrint("Error creating shift: $e");
                  if (mounted) {
                    setState(() => _isLoading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                    );
                  }
                }
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
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : const Text("Save Worker Settings",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
