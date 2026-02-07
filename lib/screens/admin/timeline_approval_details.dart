import 'package:flutter/material.dart';
import 'package:construction_erp/core/services/app_colors.dart';

class TimelineApprovalDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> approvalData;

  const TimelineApprovalDetailsScreen({super.key, required this.approvalData});

  @override
  State<TimelineApprovalDetailsScreen> createState() =>
      _TimelineApprovalDetailsScreenState();
}

class _TimelineApprovalDetailsScreenState
    extends State<TimelineApprovalDetailsScreen> {
  final TextEditingController _remarksController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Dummy Timeline Data
  final List<Map<String, String>> _milestoneChanges = [
    {
      "milestone": "Foundation",
      "oldDate": "12 Jan",
      "newDate": "15 Jan",
      "reason": "Rain delay"
    },
    {
      "milestone": "Structure",
      "oldDate": "20 Feb",
      "newDate": "25 Feb",
      "reason": "Material shortage"
    },
  ];

  void _showStatusDialog({required bool isApproved}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isApproved ? "Timeline Approved" : "Timeline Rejected",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isApproved
                        ? const Color(0xFF009688)
                        : const Color(0xFFEF5350),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(isApproved ? Icons.check : Icons.close,
                      color: Colors.white, size: 30),
                ),
              ],
            ),
          ),
        );
      },
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Timeline Approvals",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  widget.approvalData['project'] ?? "Project",
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(widget.approvalData['location'] ?? "Manager",
                    style: const TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 20),

                // Table Header
                const Row(
                  children: [
                    Expanded(
                        flex: 3,
                        child: Text("Milestone",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13))),
                    Expanded(
                        flex: 2,
                        child: Text("Old Date",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13))),
                    Expanded(
                        flex: 2,
                        child: Text("New Date",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13))),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(thickness: 1, color: Colors.grey),
                const SizedBox(height: 8),

                // Table Items
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _milestoneChanges.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = _milestoneChanges[index];
                    return Row(
                      children: [
                        Expanded(
                            flex: 3,
                            child: Text(item['milestone']!,
                                style: const TextStyle(fontSize: 13))),
                        Expanded(
                            flex: 2,
                            child: Text(item['oldDate']!,
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.red))),
                        Expanded(
                            flex: 2,
                            child: Text(item['newDate']!,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold))),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 40),

                // Remarks
                const Text("Remarks",
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _remarksController,
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: "Approval/Reject Remarks",
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),

                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showStatusDialog(isApproved: true),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50)),
                        child: const Text("Approve",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showStatusDialog(isApproved: false),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF5350)),
                        child: const Text("Reject",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
