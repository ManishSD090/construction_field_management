import 'package:construction_erp/core/services/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_erp/controllers/admin/role_controller.dart';
import 'package:construction_erp/models/role.dart';

class RoleInfoScreen extends ConsumerStatefulWidget {
  final String roleId;

  const RoleInfoScreen({super.key, required this.roleId});

  @override
  ConsumerState<RoleInfoScreen> createState() => _RoleInfoScreenState();
}

class _RoleInfoScreenState extends ConsumerState<RoleInfoScreen> {
  bool _isEditing = false;
  late TextEditingController _roleNameController;
  late TextEditingController _roleDescController;

  Set<String> _selectedPermissionCodes = {};
  bool _isInitialized = false;

  final List<String> _modules = [
    'USER_MANAGEMENT',
    'PROJECT_MANAGEMENT',
    'TASK_MANAGEMENT',
    'ATTENDANCE_MANAGEMENT',
    'DPR_MANAGEMENT',
    'MATERIAL_MANAGEMENT',
    'EQUIPMENT_MANAGEMENT',
    'EXPENSE_MANAGEMENT',
    'CLIENT_MANAGEMENT',
    'CONTRACTOR_MANAGEMENT',
    'INVOICE_MANAGEMENT',
    'PAYROLL_MANAGEMENT',
    'REPORTS',
    'SETTINGS_MANAGEMENT',
  ];

  @override
  void initState() {
    super.initState();
    _roleNameController = TextEditingController();
    _roleDescController = TextEditingController();
  }

  @override
  void dispose() {
    _roleNameController.dispose();
    _roleDescController.dispose();
    super.dispose();
  }

  void _initializeLocalState(Role role) {
    if (_isInitialized) return;
    _roleNameController.text = role.name;
    _roleDescController.text = role.description ?? "";
    _selectedPermissionCodes =
        Set.from(role.permissions.map((p) => p.code).whereType<String>());
    _isInitialized = true;
  }

  List<String> _getCodesForModule(String module, String type) {
    final Map<String, String> prefixMap = {
      'USER_MANAGEMENT': 'USER',
      'PROJECT_MANAGEMENT': 'PROJECT',
      'TASK_MANAGEMENT': 'TASK',
      'ATTENDANCE_MANAGEMENT': 'ATTENDANCE',
      'EXPENSE_MANAGEMENT': 'EXPENSE',
      'MATERIAL_MANAGEMENT': 'MATERIAL',
      'EQUIPMENT_MANAGEMENT': 'EQUIPMENT',
      'CLIENT_MANAGEMENT': 'CLIENT',
      'DPR_MANAGEMENT': 'DPR',
      'CONTRACTOR_MANAGEMENT': 'CONTRACTOR',
      'INVOICE_MANAGEMENT': 'INVOICE',
      'PAYROLL_MANAGEMENT': 'PAYROLL',
      'REPORTS': 'REPORTS',
      'SETTINGS_MANAGEMENT': 'SETTINGS',
    };

    final prefix = prefixMap[module] ?? module;
    final List<String> codes = [];

    if (type == 'VIEW') {
      // Standard view codes
      codes.addAll([
        '${prefix}_READ',
        'VIEW_ALL_$prefix',
        '${prefix}_VIEW',
        'VIEW_ALL_${prefix}S'
      ]);

      // Module-specific view variations
      if (module == 'MATERIAL_MANAGEMENT') codes.add('MATERIAL_STOCK_VIEW');
      if (module == 'REPORTS') codes.add('REPORTS_VIEW');
      if (module == 'CONTRACTOR_MANAGEMENT') {
        codes.addAll([
          'CONTRACTOR_WORKER_READ',
          'CONTRACTOR_PROJECT_READ',
          'CONTRACTOR_ASSIGNMENT_READ',
          'CONTRACTOR_PAYMENT_READ',
          'CONTRACTOR_REVIEW_READ',
          'CONTRACTOR_DOCUMENT_READ',
        ]);
      }
    } else {
      // Standard write/action codes
      codes.addAll([
        '${prefix}_CREATE',
        '${prefix}_UPDATE',
        '${prefix}_DELETE',
        '${prefix}_APPROVE',
        '${prefix}_MANAGE'
      ]);

      // Module-specific action variations from your list
      switch (module) {
        case 'USER_MANAGEMENT':
          codes.add('USER_ACTIVATE');
          break;
        case 'PROJECT_MANAGEMENT':
          codes.add('PROJECT_SETTINGS_UPDATE');
          break;
        case 'ATTENDANCE_MANAGEMENT':
          codes.add('ATTENDANCE_VERIFY');
          break;
        case 'DPR_MANAGEMENT':
          codes.add('DPR_PHOTO_UPLOAD');
          break;
        case 'MATERIAL_MANAGEMENT':
          codes.addAll([
            'MATERIAL_REQUEST',
            'MATERIAL_STOCK_MANAGE',
            'MATERIAL_STOCK_ADJUST',
            'MATERIAL_CONSUME',
            'MATERIAL_REPORT'
          ]);
          break;
        case 'EQUIPMENT_MANAGEMENT':
          codes.add('EQUIPMENT_ASSIGN');
          break;
        case 'SETTINGS_MANAGEMENT':
          codes.addAll(['ROLE_MANAGE', 'PERMISSION_MANAGE']);
          break;
        case 'CONTRACTOR_MANAGEMENT':
          codes.addAll([
            'CONTRACTOR_VERIFY',
            'CONTRACTOR_BLACKLIST',
            'CONTRACTOR_WORKER_CREATE',
            'CONTRACTOR_WORKER_UPDATE',
            'CONTRACTOR_WORKER_DELETE',
            'CONTRACTOR_PROJECT_CREATE',
            'CONTRACTOR_PROJECT_UPDATE',
            'CONTRACTOR_PROJECT_DELETE',
            'CONTRACTOR_ASSIGNMENT_CREATE',
            'CONTRACTOR_ASSIGNMENT_UPDATE',
            'CONTRACTOR_ASSIGNMENT_VERIFY',
            'CONTRACTOR_PAYMENT_CREATE',
            'CONTRACTOR_PAYMENT_UPDATE',
            'CONTRACTOR_PAYMENT_PROCESS',
            'CONTRACTOR_REVIEW_CREATE',
            'CONTRACTOR_REVIEW_UPDATE',
            'CONTRACTOR_DOCUMENT_UPLOAD',
            'CONTRACTOR_DOCUMENT_DELETE'
          ]);
          break;
      }
    }
    return codes.toSet().toList(); // Ensure uniqueness
  }

  bool _isModuleChecked(String module, String type) {
    final codes = _getCodesForModule(module, type);
    return codes.any((code) => _selectedPermissionCodes.contains(code));
  }

  void _toggleModulePermissions(String module, String type, bool? value) {
    if (!_isEditing) return;
    setState(() {
      final relevantCodes = _getCodesForModule(module, type);
      if (value == true) {
        _selectedPermissionCodes.addAll(relevantCodes);
      } else {
        _selectedPermissionCodes.removeAll(relevantCodes);
      }
    });
  }

  Future<void> _saveChanges() async {
    final notifier = ref.read(roleControllerProvider.notifier);
    try {
      // 1. Perform the updates
      await notifier.updateRole(
          widget.roleId, _roleNameController.text, _roleDescController.text);
      await notifier.updatePermissions(
          widget.roleId, _selectedPermissionCodes.toList());

      // 2. CRITICAL FIX: Invalidate the specific detail provider cache
      ref.invalidate(roleDetailProvider(widget.roleId));

      // 3. Optional: Invalidate the list provider so the main table is also fresh
      ref.invalidate(roleControllerProvider);

      setState(() => _isEditing = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Role updated successfully!")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to update: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleAsync = ref.watch(roleDetailProvider(widget.roleId));
    const scaffoldBg = Color(0xFFFBFBFC);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(_isEditing ? "Edit Permissions" : "Role Details",
            style: const TextStyle(
                color: Colors.black87, fontWeight: FontWeight.bold)),
        actions: [
          roleAsync.when(
            data: (role) => !_isEditing
                ? TextButton.icon(
                    onPressed: () => setState(() => _isEditing = true),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text("Edit"),
                  )
                : const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: roleAsync.when(
        data: (role) {
          _initializeLocalState(role);
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRoleInfoCard(), // Refactored into a Card
                const SizedBox(height: 20),
                const Divider(
                    thickness: 1.2,
                    color: Color(0xFFE0E0E0)), // Distinct Separation
                const SizedBox(height: 20),
                _buildPermissionsSection(),
                const SizedBox(height: 40),
                if (_isEditing) _buildActionButtons(),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
    );
  }

  Widget _buildRoleInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("ROLE DETAILS",
              style: TextStyle(
                  color: Color(0xFF0A6ED1),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.1)),
          const SizedBox(height: 16),
          _isEditing
              ? TextField(
                  controller: _roleNameController,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                      hintText: "Role Name", border: UnderlineInputBorder()),
                )
              : Text(_roleNameController.text,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
          const SizedBox(height: 12),
          _isEditing
              ? TextField(
                  controller: _roleDescController,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                  decoration: const InputDecoration(
                      hintText: "Description", border: UnderlineInputBorder()),
                )
              : Text(
                  _roleDescController.text.isEmpty
                      ? "No description provided."
                      : _roleDescController.text,
                  style: const TextStyle(
                      fontSize: 15, color: Colors.black54, height: 1.4),
                ),
        ],
      ),
    );
  }

  Widget _buildPermissionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4.0),
          child: Text("Permissions",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _buildTableHeaderPill("Module", flex: 2),
            _buildTableHeaderPill("View", flex: 1),
            _buildTableHeaderPill("Create/Edit", flex: 1),
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _modules.length,
          itemBuilder: (context, index) => _buildPermissionRow(_modules[index]),
        ),
      ],
    );
  }

  Widget _buildTableHeaderPill(String label, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFE1EEFA),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(label,
              style: const TextStyle(
                  color: Color(0xFF0A6ED1),
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
        ),
      ),
    );
  }

  Widget _buildPermissionRow(String module) {
    final displayName = module
        .replaceAll('_MANAGEMENT', '')
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .map((s) => s[0].toUpperCase() + s.substring(1))
        .join(' ');

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(displayName,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87)),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Checkbox(
                value: _isModuleChecked(module, 'VIEW'),
                activeColor: const Color(0xFF0A6ED1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
                onChanged: _isEditing
                    ? (val) => _toggleModulePermissions(module, 'VIEW', val)
                    : null,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Checkbox(
                value: _isModuleChecked(module, 'EDIT'),
                activeColor: const Color(0xFF0A6ED1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
                onChanged: _isEditing
                    ? (val) => _toggleModulePermissions(module, 'EDIT', val)
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              _isInitialized = false;
              setState(() => _isEditing = false);
            },
            child:
                const Text("Cancel", style: TextStyle(color: Colors.black87)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A6ED1),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _saveChanges,
            child: const Text("Save Changes",
                style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
