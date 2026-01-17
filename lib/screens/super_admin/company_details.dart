import 'package:construction_erp/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/app_colors.dart';
import '../../models/company.dart';
import '../../controllers/super_admin/companies_controller.dart';

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
  bool _isLoadingFresh = true; // To optionally show a small loading indicator

  @override
  void initState() {
    super.initState();
    // 1. Show cached data immediately
    _company = widget.company;

    // 2. Fetch fresh data in background
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchFreshDetails();
    });
  }

  /// Fetches fresh data using the Controller's getCompanyById
  Future<void> _fetchFreshDetails() async {
    try {
      final freshData = await ref
          .read(companiesControllerProvider.notifier)
          .getCompanyById(_company.id!); // Assuming ID is string

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

  // --- Action Bottom Sheet ---
  void _showActionSheet() {
    // Use local _company state, not widget.company
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
      await ref.read(companiesControllerProvider.notifier).toggleCompanyStatus(
            id: _company.id!,
            isActive: newStatus,
          );

      if (mounted) {
        // Update local state immediately so UI reflects change
        setState(() {
          // If you implemented copyWith in model:
          // _company = _company.copyWith(isActive: newStatus);

          // Or just re-fetch to be safe:
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
                          // We don't necessarily need to pop the screen here
                          // because we updated the state locally.
                          // But if you want to go back to list:
                          // Navigator.pop(context);
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
    // USE LOCAL STATE (_company), NOT WIDGET PARAM
    // final admin = _company.admin; // Assuming model has this
    final List<User>? admins = _company.admins; // Assuming model has this
    final bool isActive = _company.isActive ?? true;

    // Access Counts safely (Model needs to support this)
    final int projectCount = _company.counts?.projects ?? 0;
    final int userCount = _company.counts?.users ?? 0;
    final int clientCount = _company.counts?.clients ?? 0;

    final Color statusColor =
        isActive ? AppColors.successGreen : AppColors.alertRed;
    final Color statusBg =
        isActive ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);

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
          // Optional: Indication that background refresh is happening
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
                  Text(_company.name ?? "N/A",
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.2)),
                  const SizedBox(height: 8),

                  // --- Status Pill ---
                  Row(
                    children: [
                      Text("ID - ${_company.id?.substring(0, 8) ?? '...'}",
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 13)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(4)),
                        child: Text(isActive ? "Active" : "Suspended",
                            style: TextStyle(
                                color: statusColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text("Created on: $formattedDate",
                      style:
                          TextStyle(color: Colors.grey.shade500, fontSize: 12)),

                  const SizedBox(height: 24),

                  // --- Stats Section (Dynamic Counts) ---
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

                  _buildDetailRow(
                      "Registration Number",
                      _company.registrationNumber ??
                          "N/A"), // Ensure model has this
                  _buildDetailRow("GST Number", _company.gstNumber ?? "N/A"),
                  _buildDetailRow("Email", _company.email ?? "N/A",
                      isLink: true),
                  _buildDetailRow("Phone", _company.phone ?? "N/A"),
                  _buildDetailRow("Address", _company.officeAddress ?? "N/A"),

                  const SizedBox(height: 24),

                  // --- Admin Details ---
                  const Text("Admin details",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  if (admins != null && admins.isNotEmpty) ...[
                    // Iterate through the list of admins
                    ...admins.map((admin) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Optional: specific label if there are multiple admins
                          if (admins.length > 1)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text("Admin Account",
                                  style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                            ),

                          _buildDetailRow("Name", admin.name),
                          _buildDetailRow("Email", admin.email!),
                          _buildDetailRow("Phone", admin.phone),

                          // Add spacing between admins so they don't merge visually
                          const SizedBox(height: 24),
                        ],
                      );
                    }),
                  ] else ...[
                    const Text("No Admin Assigned",
                        style: TextStyle(color: Colors.red)),
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

  Widget _buildDetailRow(String label, String value, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
          const SizedBox(height: 4),
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
