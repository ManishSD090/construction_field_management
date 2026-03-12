import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/models/enums.dart';

// Import BOTH controllers here in the UI layer
import 'package:construction_erp/controllers/approval/approval_controller.dart';
import 'package:construction_erp/controllers/timeline/timeline_controller.dart'; 

class TimelineApprovalDetailsScreen extends ConsumerStatefulWidget {
  final TimelineApprovalItem approvalItem; 

  const TimelineApprovalDetailsScreen({super.key, required this.approvalItem});

  @override
  ConsumerState<TimelineApprovalDetailsScreen> createState() => _TimelineApprovalDetailsScreenState();
}

class _TimelineApprovalDetailsScreenState extends ConsumerState<TimelineApprovalDetailsScreen> {
  final TextEditingController _remarksController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isProcessing = false;

  Future<void> _processApproval(bool isApproved) async {
    if (!isApproved && _remarksController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a reason for rejection.')));
      return;
    }

    setState(() => _isProcessing = true);

    try {
      if (widget.approvalItem.version != null) {
        // IT IS A VERSION APPROVAL
        await ref.read(approvalControllerProvider.notifier).approveRejectVersion(
          timelineId: widget.approvalItem.timeline.id,
          versionNumber: widget.approvalItem.version!.versionNumber,
          isApproved: isApproved,
          reason: _remarksController.text.isNotEmpty ? _remarksController.text : null,
        );
      } else {
        // IT IS A BASE TIMELINE APPROVAL
        await ref.read(approvalControllerProvider.notifier).approveRejectTimeline(
          timelineId: widget.approvalItem.timeline.id,
          isApproved: isApproved,
          reason: _remarksController.text.isNotEmpty ? _remarksController.text : null,
        );
      }

      // ✅ INVALIDATE TIMELINE CACHES HERE IN THE UI INSTEAD!
      ref.invalidate(timelineControllerProvider);
      ref.invalidate(timelineDetailsProvider(widget.approvalItem.timeline.id));

      _showStatusDialog(isApproved: isApproved);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showStatusDialog({required bool isApproved}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(isApproved ? "Approved" : "Rejected", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: isApproved ? const Color(0xFF009688) : const Color(0xFFEF5350), shape: BoxShape.circle),
                  child: Icon(isApproved ? Icons.check : Icons.close, color: Colors.white, size: 30),
                ),
              ],
            ),
          ),
        );
      },
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context); // close dialog
        Navigator.pop(context); // return to lists
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final timeline = widget.approvalItem.timeline;
    final version = widget.approvalItem.version;
    
    final tasks = timeline.timelineTasks ?? [];
    
    final String displayTitle = version != null 
        ? "${timeline.name} (${version.name})" 
        : timeline.name;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: const Text("Timeline Approvals", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 4),
                Text("Manager: ${timeline.createdBy?.name ?? 'System'}", style: const TextStyle(fontSize: 13, color: Colors.grey)),
                
                if (version?.changesSummary != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text("Changes: ${version!.changesSummary}", style: const TextStyle(color: Colors.orange, fontStyle: FontStyle.italic)),
                  )
                ],
                
                const SizedBox(height: 20),

                const Row(
                  children: [
                    Expanded(flex: 3, child: Text("Task", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    Expanded(flex: 2, child: Text("Start", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    Expanded(flex: 2, child: Text("End", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(thickness: 1, color: Colors.grey),
                const SizedBox(height: 8),

                if (tasks.isEmpty)
                  const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Center(child: Text("No tasks found.", style: TextStyle(color: Colors.grey))))
                else
                  ListView.separated(
                    shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                    itemCount: tasks.length,
                    separatorBuilder: (c, i) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final taskItem = tasks[index];
                      final taskName = taskItem.task?.title ?? 'Untitled';
                      final startText = taskItem.plannedStartDate != null ? DateFormat('dd MMM').format(taskItem.plannedStartDate!) : '-';
                      final endText = taskItem.plannedEndDate != null ? DateFormat('dd MMM').format(taskItem.plannedEndDate!) : '-';

                      return Row(
                        children: [
                          Expanded(flex: 3, child: Text(taskName, style: const TextStyle(fontSize: 13))),
                          Expanded(flex: 2, child: Text(startText, style: const TextStyle(fontSize: 13, color: Colors.grey))),
                          Expanded(flex: 2, child: Text(endText, style: const TextStyle(fontSize: 13, color: Colors.green, fontWeight: FontWeight.bold))),
                        ],
                      );
                    },
                  ),

                const SizedBox(height: 40),

                const Text("Remarks", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _remarksController, maxLines: 1,
                  decoration: InputDecoration(hintText: "Approval/Reject Remarks", border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                ),
                const SizedBox(height: 20),

                _isProcessing 
                  ? const Center(child: CircularProgressIndicator()) 
                  : Row(
                      children: [
                        Expanded(child: ElevatedButton(onPressed: () => _processApproval(true), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)), child: const Text("Approve", style: TextStyle(color: Colors.white)))),
                        const SizedBox(width: 20),
                        Expanded(child: ElevatedButton(onPressed: () => _processApproval(false), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF5350)), child: const Text("Reject", style: TextStyle(color: Colors.white)))),
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