import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_erp/controllers/admin/role_controller.dart';

class CreateRoleScreen extends ConsumerStatefulWidget {
  const CreateRoleScreen({super.key});

  @override
  ConsumerState<CreateRoleScreen> createState() => _CreateRoleScreenState();
}

class _CreateRoleScreenState extends ConsumerState<CreateRoleScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  // Selected permission codes to be sent to the backend
  final Set<String> _selectedPermissionCodes = {};

  // Modules aligned with the RoleInfoScreen for consistency
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
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // --- Logic Mapping (Mirrored from RoleInfoScreen) ---

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
    setState(() {
      final relevantCodes = _getCodesForModule(module, type);
      if (value == true) {
        _selectedPermissionCodes.addAll(relevantCodes);
      } else {
        _selectedPermissionCodes.removeAll(relevantCodes);
      }
    });
  }

  // --- Submission ---

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Calls the createRole method in the controller
        await ref.read(roleControllerProvider.notifier).createRole(
              _nameController.text.trim(),
              _descController.text.trim(),
              _selectedPermissionCodes.toList(),
            );

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Role created successfully!")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error creating role: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          "Create New Role",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRoleInfoCard(),
              const SizedBox(height: 24),
              const Divider(thickness: 1.2, color: Color(0xFFE0E0E0)),
              const SizedBox(height: 24),
              _buildPermissionsSection(),
              const SizedBox(height: 40),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI Components (Reference Styled) ---

  Widget _buildRoleInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
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
          const Text("ROLE DEFINITION",
              style: TextStyle(
                  color: Color(0xFF0A6ED1),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.1)),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
                hintText: "E.g. Site Manager", labelText: "Role Name"),
            validator: (val) => val!.isEmpty ? "Role name is required" : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descController,
            maxLines: 2,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
            decoration: const InputDecoration(
                hintText: "Describe the responsibilities...",
                labelText: "Description"),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Access Control",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Row(
          children: [
            _buildHeaderPill("Module", flex: 2),
            _buildHeaderPill("View", flex: 1),
            _buildHeaderPill("Edit", flex: 1),
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

  Widget _buildHeaderPill(String label, {required int flex}) {
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
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
            child: Checkbox(
              value: _isModuleChecked(module, 'VIEW'),
              activeColor: const Color(0xFF0A6ED1),
              onChanged: (val) => _toggleModulePermissions(module, 'VIEW', val),
            ),
          ),
          Expanded(
            flex: 1,
            child: Checkbox(
              value: _isModuleChecked(module, 'EDIT'),
              activeColor: const Color(0xFF0A6ED1),
              onChanged: (val) => _toggleModulePermissions(module, 'EDIT', val),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0A6ED1),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: const Text("Create Role",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ),
    );
  }
}
