import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Controllers
import 'package:construction_erp/controllers/admin/user_controller.dart';
import 'package:construction_erp/controllers/admin/role_controller.dart';
// Import the Project Controller created in the previous step
import 'package:construction_erp/controllers/project/project_controller.dart';

// Models
import 'package:construction_erp/models/user.dart';

class UserInfoScreen extends ConsumerStatefulWidget {
  final String userId;

  const UserInfoScreen({super.key, required this.userId});

  @override
  ConsumerState<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends ConsumerState<UserInfoScreen> {
  bool _isEditing = false;
  bool _isInitialized = false;

  // Controllers for all API fields
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _empIdController;
  late TextEditingController _deptController;
  late TextEditingController _desigController;
  late TextEditingController _salaryController;
  late TextEditingController _aadharController;
  late TextEditingController _bankController;
  late TextEditingController _ifscController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _empIdController = TextEditingController();
    _deptController = TextEditingController();
    _desigController = TextEditingController();
    _salaryController = TextEditingController();
    _aadharController = TextEditingController();
    _bankController = TextEditingController();
    _ifscController = TextEditingController();
  }

  void _initializeData(User user) {
    if (_isInitialized) return;
    _nameController.text = user.name;
    _emailController.text = user.email ?? '';
    _phoneController.text = user.phone;
    _empIdController.text = user.employeeId ?? '';
    _deptController.text = user.department ?? '';
    _desigController.text = user.designation ?? '';
    _salaryController.text = user.salary?.toString() ?? '';
    _aadharController.text = user.aadharNumber ?? '';
    _bankController.text = user.bankAccount ?? '';
    _ifscController.text = user.ifscCode ?? '';
    _isInitialized = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _empIdController.dispose();
    _deptController.dispose();
    _desigController.dispose();
    _salaryController.dispose();
    _aadharController.dispose();
    _bankController.dispose();
    _ifscController.dispose();
    super.dispose();
  }

  Future<void> _handleSave(String id) async {
    try {
      await ref.read(userControllerProvider.notifier).updateUser(id, {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'employeeId': _empIdController.text.trim(),
        'department': _deptController.text.trim(),
        'designation': _desigController.text.trim(),
        'salary': double.tryParse(_salaryController.text.trim()),
        'aadharNumber': _aadharController.text.trim(),
        'bankAccount': _bankController.text.trim(),
        'ifscCode': _ifscController.text.trim(),
      });

      await ref.refresh(userDetailProvider(id).future);

      setState(() {
        _isEditing = false;
        _isInitialized = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Update failed: $e")),
      );
    }
  }

  /// Opens bottom sheet to assign user to a project
  void _showAssignProjectSheet(User user) {
    // Form state for the sheet
    String? selectedProjectId;
    // Auto-fill role from user info
    String? selectedRoleId = user.role?.id;
    // Auto-fill designation from user info
    final designationCtrl = TextEditingController(text: user.designation ?? '');
    DateTime selectedDate = DateTime.now();
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Consumer(
          builder: (context, ref, child) {
            // Fetch data reactively inside the sheet
            final projectAsync = ref.watch(projectControllerProvider);
            final rolesAsync = ref.watch(roleControllerProvider);

            return StatefulBuilder(
              builder: (context, setSheetState) => Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: EdgeInsets.fromLTRB(
                    24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
                child: ListView(
                  controller: scrollController,
                  shrinkWrap: true,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Assign to Project",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 1. Select Project (Fetched via ProjectController)
                    const Text("Select Project",
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    projectAsync.when(
                      data: (state) => DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                        ),
                        hint: const Text("Choose a project"),
                        initialValue: selectedProjectId,
                        items: state.projects
                            .map((p) => DropdownMenuItem(
                                  value: p.id,
                                  child: Text(p.name,
                                      overflow: TextOverflow.ellipsis),
                                ))
                            .toList(),
                        onChanged: (val) =>
                            setSheetState(() => selectedProjectId = val),
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (e, _) => Text("Error loading projects: $e"),
                    ),
                    const SizedBox(height: 16),

                    // 2. Select Role
                    const Text("Project Role",
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    rolesAsync.when(
                      data: (roleState) => DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                          filled: true,
                          fillColor: Color(0xFFF5F5F5),
                        ),
                        hint: const Text("Select role on project"),
                        initialValue: selectedRoleId,
                        items: roleState.roles
                            .map((r) => DropdownMenuItem(
                                  value: r.id,
                                  child: Text(r.name),
                                ))
                            .toList(),
                        onChanged:
                            null, // Disabled: role locked to user profile
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (e, _) => Text("Error loading roles: $e"),
                    ),
                    const SizedBox(height: 16),

                    // 3. Designation
                    const Text("Designation on Site",
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: designationCtrl,
                      enabled:
                          false, // Disabled: designation locked to user profile
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "e.g. Site Supervisor",
                        filled: true,
                        fillColor: Color(0xFFF5F5F5),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 4. Start Date
                    const Text("Start Date",
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setSheetState(() => selectedDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(DateFormat('MMM dd, yyyy')
                                .format(selectedDate)),
                            const Icon(Icons.calendar_today, size: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A6ED1),
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                        onPressed: (isLoading ||
                                selectedProjectId == null ||
                                selectedRoleId == null)
                            ? null
                            : () async {
                                setSheetState(() => isLoading = true);
                                try {
                                  // Construct payload based on backend requirements
                                  final assignmentPayload = [
                                    {
                                      'userId': user.id,
                                      'roleId': selectedRoleId,
                                      'designation':
                                          designationCtrl.text.isNotEmpty
                                              ? designationCtrl.text
                                              : "Team Member",
                                      'startDate':
                                          selectedDate.toIso8601String(),
                                      'isPrimary': false,
                                    }
                                  ];

                                  // Call the ProjectController
                                  await ref
                                      .read(projectControllerProvider.notifier)
                                      .assignTeam(selectedProjectId!,
                                          assignmentPayload);

                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "User assigned to project successfully"),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Assignment failed: $e"),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } finally {
                                  // Check if the sheet is still mounted before updating state
                                  // Note: setSheetState is safe to call only if the StatefulBuilder is active
                                  // But since we might pop, we catch errors or use mounted check if we converted to widget
                                  // Here we just stop loading if still present
                                  try {
                                    setSheetState(() => isLoading = false);
                                  } catch (_) {}
                                }
                              },
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Text("Confirm Assignment",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Opens bottom sheet to reassign user role
  void _showRoleReassignSheet(User user) {
    final rolesAsync = ref.read(roleControllerProvider);
    String? selectedRoleId = user.role?.id;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Reassign User Role",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Current: ${user.role?.name ?? 'None'}",
                  style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 20),
              rolesAsync.when(
                data: (roleState) => DropdownButtonFormField<String>(
                  initialValue: selectedRoleId,
                  items: roleState.roles
                      .map((r) =>
                          DropdownMenuItem(value: r.id, child: Text(r.name)))
                      .toList(),
                  onChanged: (val) => setModalState(() => selectedRoleId = val),
                  decoration:
                      const InputDecoration(border: OutlineInputBorder()),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text("Error loading roles: $e"),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A6ED1)),
                  onPressed:
                      selectedRoleId == null || selectedRoleId == user.role?.id
                          ? null
                          : () async {
                              Navigator.pop(context);
                              await ref
                                  .read(userControllerProvider.notifier)
                                  .updateUserRole(user.id, selectedRoleId!);
                              ref.refresh(userDetailProvider(user.id));
                            },
                  child: const Text("Update User Role",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userDetailProvider(widget.userId));

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(_isEditing ? "Edit Profile" : "User Details",
            style: const TextStyle(
                color: Colors.black87, fontWeight: FontWeight.bold)),
        actions: [
          userAsync.when(
            data: (_) => TextButton.icon(
              onPressed: () => setState(() => _isEditing = !_isEditing),
              icon: Icon(_isEditing ? Icons.close : Icons.edit_outlined,
                  size: 18),
              label: Text(_isEditing ? "Cancel" : "Edit"),
            ),
            error: (_, __) => const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          _initializeData(user);
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(user),
                const SizedBox(height: 24),
                _buildReferenceStyleCard(
                  title: "User Info",
                  rows: [
                    _buildEditableRow("Name", _nameController),
                    _buildEditableRow("Email", _emailController),
                    _buildEditableRow("Phone", _phoneController),
                    _buildEditableRow("Department", _deptController),
                    _buildEditableRow("Designation", _desigController),
                  ],
                ),
                const SizedBox(height: 24),
                _buildReferenceStyleCard(
                  title: "Financial Details",
                  rows: [
                    _buildEditableRow("Salary", _salaryController,
                        inputType: TextInputType.number),
                    _buildEditableRow("Bank Account", _bankController),
                    _buildEditableRow("IFSC Code", _ifscController),
                    _buildEditableRow("Aadhar Number", _aadharController),
                  ],
                ),
                if (_isEditing) ...[
                  const SizedBox(height: 32),
                  _buildSaveButton(user.id),
                ],
                const SizedBox(height: 24),
                if (!_isEditing) _buildAuditCard(user),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
    );
  }

  Widget _buildHeader(User user) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name,
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text(user.role?.name ?? "No Role Assigned",
                      style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF0A6ED1),
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
        if (!_isEditing) ...[
          const SizedBox(height: 16),
          // Actions Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showRoleReassignSheet(user),
                  icon: const Icon(Icons.compare_arrows_sharp, size: 16),
                  label: const Text("Reassign Role"),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: BorderSide(color: Colors.grey.shade300)),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _showAssignProjectSheet(user),
                  icon: const Icon(Icons.assignment_ind_outlined, size: 16),
                  label: const Text("Assign to Project"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A6ED1),
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildReferenceStyleCard(
      {required String title, required List<Widget> rows}) {
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
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 8),
          const Divider(thickness: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 16),
          ...rows,
        ],
      ),
    );
  }

  Widget _buildEditableRow(String label, TextEditingController controller,
      {TextInputType inputType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: _isEditing
          ? TextField(
              controller: controller,
              keyboardType: inputType,
              decoration: InputDecoration(
                  labelText: label,
                  isDense: true,
                  border: const UnderlineInputBorder()),
            )
          : RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 15, color: Colors.black87),
                children: [
                  TextSpan(
                      text: "$label: ",
                      style: const TextStyle(color: Colors.black54)),
                  TextSpan(
                      text: controller.text.isEmpty
                          ? "Not provided"
                          : controller.text,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
    );
  }

  Widget _buildAuditCard(User user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.blueGrey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("ACCOUNT HISTORY",
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey.shade700)),
          const SizedBox(height: 8),
          Text("Invited by: ${user.createdBy?.name ?? 'System'}",
              style: const TextStyle(fontSize: 13, color: Colors.black54)),
          Text("Created: ${user.createdAt?.toLocal().toString().split(' ')[0]}",
              style: const TextStyle(fontSize: 13, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildSaveButton(String id) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0A6ED1),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        onPressed: () => _handleSave(id),
        child: const Text("Save Profile Changes",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
