import 'package:construction_erp/screens/sub_contractor/edit_sub_contractor.dart';
import 'package:construction_erp/screens/sub_contractor/manage_workers_screen.dart'; // Added import for Manage Workers
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/controllers/subcontractor/subcontractor_controller.dart';
import 'package:construction_erp/models/contractor.dart';
import 'package:intl/intl.dart';

class SubcontractorDetailsScreen extends ConsumerWidget {
  final String subcontractorId;

  const SubcontractorDetailsScreen({super.key, required this.subcontractorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(subcontractorControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        title: const Text("Contractor Profile",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<Contractor>(
        future: ref
            .read(subcontractorControllerProvider.notifier)
            .getSubcontractorDetails(subcontractorId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final data = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                // ✅ Pass context and ref to handle actions
                _buildHeader(context, ref, data),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildInfoSection("Business Details", [
                        _infoTile("Contractor ID", data.contractorId),
                        _infoTile("Contact Person", data.contactPerson),
                        _infoTile("Phone", data.phone),
                        _infoTile("Email", data.email ?? "N/A"),
                      ]),
                      const SizedBox(height: 16),
                      _buildWorkTypesSection(data.workTypes),
                      const SizedBox(height: 16),
                      _buildInfoSection("Statutory & Tax", [
                        _infoTile("GST No", data.gstNumber ?? "N/A"),
                        _infoTile("PAN No", data.panNumber ?? "N/A"),
                        _infoTile(
                            "Registration", data.registrationNumber ?? "N/A"),
                        _infoTile("Aadhar", data.aadharNumber ?? "N/A"),
                      ]),
                      const SizedBox(height: 16),
                      _buildInfoSection("Banking Information", [
                        _infoTile("Bank Name", data.bankName ?? "N/A"),
                        _infoTile("Account No", data.bankAccount ?? "N/A"),
                        _infoTile("IFSC Code", data.ifscCode ?? "N/A"),
                        _infoTile("Branch", data.bankBranch ?? "N/A"),
                      ]),
                      const SizedBox(height: 16),
                      _buildFinancialCard(data.financialSummary?.totalPaid ?? 0,
                          data.financialSummary?.pendingAmount ?? 0),
                      const SizedBox(height: 24),
                      // ✅ Added Manage Workers Button
                      _buildManageWorkersButton(context, data.id),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, Contractor data) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      child: Column(
        children: [
          // ✅ Action Row for Edit and Delete
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildActionButton(
                icon: Icons.edit_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditSubContractorScreen(
                        subContractorData: data.toJson(),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                icon: Icons.delete_outline,
                color: Colors.redAccent,
                onTap: () => _confirmDelete(context, ref, data.id),
              ),
            ],
          ),
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(data.name[0],
                style: const TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 15),
          Text(data.name,
              style: const TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            "ID: ${data.contractorId}",
            style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(data.type.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      "${data.rating}",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ Helper for the Header Action Buttons
  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }

  // ✅ Confirm Delete Logic
  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, String id) async {
    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Sub-contractor?"),
        content: const Text(
            "This will permanently remove this contractor from the system."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await ref
                  .read(subcontractorControllerProvider.notifier)
                  .deleteSubcontractor(id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Sub-contractor deleted")),
              );
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (proceed == true) {
      try {
        await ref
            .read(subcontractorControllerProvider.notifier)
            .deleteSubcontractor(id);
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Sub-contractor deleted")),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e")),
          );
        }
      }
    }
  }

  Widget _buildWorkTypesSection(List<dynamic> workTypes) {
    return _buildInfoSection("Specializations", [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: workTypes.map((type) {
          final String label = type is Enum ? type.name : type.toString();
          return Chip(
            label: Text(
              label.replaceAll('_', ' ').toUpperCase(),
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue),
            ),
            backgroundColor: AppColors.primaryBlue.withOpacity(0.05),
            side: const BorderSide(color: AppColors.primaryBlue, width: 0.5),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          );
        }).toList(),
      ),
    ]);
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue)),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: AppColors.textGrey, fontSize: 14)),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildFinancialCard(double paid, double pending) {
    final currency = NumberFormat.currency(symbol: "₹", decimalDigits: 0);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF1E3A8A), AppColors.primaryBlue]),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _finColumn("Total Paid", currency.format(paid)),
          Container(width: 1, height: 40, color: Colors.white24),
          _finColumn("Pending", currency.format(pending)),
        ],
      ),
    );
  }

  Widget _finColumn(String label, String amount) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(amount,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  // ✅ New Manage Workers Button
  Widget _buildManageWorkersButton(BuildContext context, String contractorId) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ManageWorkersScreen(contractorId: contractorId),
            ),
          );
        },
        icon: const Icon(Icons.people_alt_outlined, color: Colors.white),
        label: const Text(
          "Manage Workers",
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
