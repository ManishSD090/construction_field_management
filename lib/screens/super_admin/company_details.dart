import 'package:construction_erp/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/models/company.dart';
import 'package:construction_erp/controllers/super_admin/super_admin_controller.dart';
import 'package:construction_erp/routes.dart';

class CompanyDetailsScreen extends ConsumerStatefulWidget {
  final Company company;
  const CompanyDetailsScreen({super.key, required this.company});

  @override
  ConsumerState<CompanyDetailsScreen> createState() =>
      _CompanyDetailsScreenState();
}

class _CompanyDetailsScreenState extends ConsumerState<CompanyDetailsScreen> {
  // Local state to hold data (Starts with cached, updates to fresh)
  late Company _company;
  bool _isProcessing = false;
  bool _isLoadingFresh = true;

  final _formKey = GlobalKey<FormState>();
  final _adminNameController = TextEditingController();
  final _adminEmailController = TextEditingController();
  final _adminPhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _company = widget.company;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchFreshDetails();
    });
  }

  @override
  void dispose() {
    _adminNameController.dispose();
    _adminEmailController.dispose();
    _adminPhoneController.dispose();
    super.dispose();
  }

  /// Fetches fresh data using the Controller's getCompanyById
  Future<void> _fetchFreshDetails() async {
    try {
      final freshData = await ref
          .read(superAdminControllerProvider.notifier)
          .getCompanyById(_company.id!);

      if (mounted) {
        setState(() {
          _company = freshData;
          _isLoadingFresh = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching fresh company details: $e");
      if (mounted) setState(() => _isLoadingFresh = false);
    }
  }

  void _navigateToEdit() async {
    final Map<String, dynamic> companyMap = {
      'id': _company.id,
      'companyName': _company.name,
      'officeAddress': _company.officeAddress,
      'registrationNumber': _company.registrationNumber,
      'gstNumber': _company.gstNumber,
      'email': _company.email,
      'website': _company.website,
      'phone': _company.phone,
    };

    await Navigator.pushNamed(context, AppRoutes.updateCompany,
        arguments: companyMap);

    _fetchFreshDetails();
  }

  // --- Add/Update Admin UI Logic ---

  void _showAdminSheet({User? admin}) {
    if (admin != null) {
      _adminNameController.text = admin.name;
      _adminEmailController.text = admin.email ?? "";
      _adminPhoneController.text = admin.phone;
    } else {
      _adminNameController.clear();
      _adminEmailController.clear();
      _adminPhoneController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(admin == null ? "Add Company Admin" : "Update Admin Details",
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextFormField(
                controller: _adminNameController,
                decoration: const InputDecoration(
                    labelText: "Full Name", hintText: "Enter admin name"),
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _adminEmailController,
                decoration: const InputDecoration(
                    labelText: "Email Address", hintText: "Enter email"),
                keyboardType: TextInputType.emailAddress,
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _adminPhoneController,
                decoration: const InputDecoration(
                    labelText: "Phone Number", hintText: "Enter phone"),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () => _handleAdminSubmit(adminId: admin?.id),
                  child: Text(admin == null ? "Create Admin" : "Save Changes",
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleAdminSubmit({String? adminId}) async {
    if (!_formKey.currentState!.validate()) return;

    Navigator.pop(context); // Close sheet
    setState(() => _isProcessing = true);

    try {
      final payload = {
        'name': _adminNameController.text.trim(),
        'email': _adminEmailController.text.trim(),
        'phone': _adminPhoneController.text.trim(),
      };

      if (adminId == null) {
        // Create Logic - Automatically including FULL_COMPANY_ACCESS
        await ref.read(superAdminControllerProvider.notifier).addCompanyAdmin(
          companyId: _company.id!,
          adminData: {
            ...payload,
            'userType': 'COMPANY_ADMIN',
            'permissions': ['FULL_COMPANY_ACCESS'],
          },
        );
      } else {
        // Update Logic - Using the new updateCompanyAdmin method
        await ref
            .read(superAdminControllerProvider.notifier)
            .updateCompanyAdmin(
              companyId: _company.id!,
              adminId: adminId,
              adminData: payload,
            );
      }

      _fetchFreshDetails();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(adminId == null
                ? "Admin added successfully"
                : "Admin updated successfully"),
            backgroundColor: AppColors.successGreen),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Error: $e"), backgroundColor: AppColors.alertRed),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  // --- Admin Permissions Management ---
  void _showAdminPermissionsSheet(User admin) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Permissions: ${admin.name}",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Manage roles and access for this admin",
                style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
            const SizedBox(height: 20),
            _buildPermissionTile("Manage Users", true),
            _buildPermissionTile("Manage Inventory", false),
            _buildPermissionTile("Financial Reports", true),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue),
                onPressed: () => Navigator.pop(context),
                child: const Text("Save Permissions",
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionTile(String title, bool val) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontSize: 14)),
      value: val,
      onChanged: (v) {},
      activeThumbColor: AppColors.primaryBlue,
      contentPadding: EdgeInsets.zero,
    );
  }

  // --- Action Bottom Sheet (Suspension) ---
  void _showActionSheet() {
    final bool isCurrentlyActive = _company.isActive ?? true;
    bool isChecked = false;

    final String title =
        isCurrentlyActive ? "Suspend Company? ⚠️" : "Activate Company? ✅";
    final Color color =
        isCurrentlyActive ? AppColors.alertRed : AppColors.successGreen;
    final String btnText =
        isCurrentlyActive ? "Suspend company" : "Activate company";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setSheetState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: color,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                        color: Colors.black87, fontSize: 15, height: 1.5),
                    children: [
                      const TextSpan(
                          text: "Are you sure you want to proceed for "),
                      TextSpan(
                          text: "${_company.name}?",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                          value: isChecked,
                          activeColor: color,
                          onChanged: (val) =>
                              setSheetState(() => isChecked = val!)),
                    ),
                    const SizedBox(width: 10),
                    const Text("I confirm this action",
                        style: TextStyle(fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isChecked ? color : Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      elevation: 0,
                    ),
                    onPressed: isChecked
                        ? () {
                            Navigator.pop(context);
                            _performStatusChange(!isCurrentlyActive);
                          }
                        : null,
                    child: _isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text(btnText,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Text("Cancel",
                        style: TextStyle(
                            color: AppColors.textGrey,
                            fontWeight: FontWeight.w600)),
                  ),
                )
              ],
            ),
          );
        });
      },
    );
  }

  Future<void> _performStatusChange(bool newStatus) async {
    setState(() => _isProcessing = true);
    try {
      await ref.read(superAdminControllerProvider.notifier).toggleCompanyStatus(
            id: _company.id!,
            isActive: newStatus,
          );

      if (mounted) {
        setState(() {
          _fetchFreshDetails();
        });
        _showSuccessDialog(newStatus);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showSuccessDialog(bool isNowActive) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(isNowActive ? Icons.check_circle : Icons.block,
                        color: isNowActive
                            ? AppColors.successGreen
                            : AppColors.alertRed,
                        size: 60),
                    const SizedBox(height: 16),
                    Text(
                      isNowActive ? "Activated!" : "Suspended!",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(c);
                        },
                        child: const Text("OK",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.primaryBlue)),
                      ),
                    )
                  ],
                ),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    final List<User>? admins = _company.admins;
    final bool isActive = _company.isActive ?? true;

    final int projectCount = _company.counts?.projects ?? 0;
    final int userCount = _company.counts?.users ?? 0;
    final int clientCount = _company.counts?.clients ?? 0;

    final Color statusColor = isActive ? AppColors.tagGreen : AppColors.tagRed;

    final DateTime createdDate = _company.createdAt ?? DateTime.now();
    final String formattedDate =
        "${createdDate.day} ${_getMonth(createdDate.month)} ${createdDate.year}";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Company details",
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          if (_isLoadingFresh)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2)),
            )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(_company.name ?? "N/A",
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                height: 1.2)),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: _navigateToEdit,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit,
                              size: 20, color: AppColors.primaryBlue),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text("ID - ${_company.id?.substring(0, 8) ?? '...'}",
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 13)),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Created on: $formattedDate",
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 13)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          isActive ? "Active" : "Suspended",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 24),

                  // --- Stats ---
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                            "Total clients", clientCount.toString()),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                            "Total Projects", projectCount.toString()),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child:
                            _buildStatCard("Total Users", userCount.toString()),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // --- Company Details ---
                  const Text("Company details",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),

                  _buildDetailRow("Registration Number",
                      _company.registrationNumber ?? "N/A"),
                  _buildDetailRow("GST Number", _company.gstNumber ?? "N/A"),
                  _buildDetailRow("Email", _company.email ?? "N/A",
                      isLink: true),
                  _buildDetailRow("Phone", _company.phone ?? "N/A"),
                  _buildDetailRow("Address", _company.officeAddress ?? "N/A"),

                  const SizedBox(height: 24),

                  // --- Admin Details Header ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Admin details",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      TextButton.icon(
                        onPressed: () => _showAdminSheet(),
                        icon: const Icon(Icons.add_circle_outline,
                            size: 18, color: AppColors.primaryBlue),
                        label: const Text("Add Admin",
                            style: TextStyle(
                                fontSize: 13, color: AppColors.primaryBlue)),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),

                  if (admins != null && admins.isNotEmpty) ...[
                    ...admins.map((admin) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(admin.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                                InkWell(
                                  onTap: () => _showAdminSheet(admin: admin),
                                  child: const Icon(Icons.edit_outlined,
                                      size: 18, color: AppColors.primaryBlue),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _buildDetailRow("Email", admin.email!,
                                isCompact: true),
                            _buildDetailRow("Phone", admin.phone,
                                isCompact: true),
                          ],
                        ),
                      );
                    }),
                  ] else ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text("No Admin Assigned",
                            style: TextStyle(
                                color: AppColors.alertRed,
                                fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // --- Action Button ---
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isActive ? AppColors.alertRed : AppColors.successGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                onPressed: _showActionSheet,
                child: Text(
                  isActive ? "Suspend company" : "Activate company",
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {bool isLink = false, bool isCompact = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isCompact ? 8.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: isLink ? AppColors.primaryBlue : Colors.black87)),
        ],
      ),
    );
  }

  String _getMonth(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return months[month - 1];
  }
}
