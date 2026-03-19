import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/models/wpr.dart';
import 'package:construction_erp/controllers/wpr/wpr_controller.dart';
import 'package:construction_erp/screens/dpr/dpr_tab.dart';

class EditWPRScreen extends ConsumerStatefulWidget {
  final WeeklyProgressReport wpr;

  const EditWPRScreen({super.key, required this.wpr});

  @override
  ConsumerState<EditWPRScreen> createState() => _EditWPRScreenState();
}

class _EditWPRScreenState extends ConsumerState<EditWPRScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Initialize with the existing description
    _descriptionController = TextEditingController(text: widget.wpr.description);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _updateWPR() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final payload = {
        'description': _descriptionController.text.trim(),
      };

      // Ensure your WPR controller has an update method
      await ref.read(wprControllerProvider.notifier).updateWPR(widget.wpr.id, payload);

      if (!mounted) return;

      // Refresh the list
      ref.invalidate(wprListProvider(widget.wpr.projectId));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WPR Updated Successfully!'), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update WPR: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Unpack read-only data for display
    final data = widget.wpr.aggregatedData ?? {};
    final attendanceSummary = data['attendance']?['summary'] ?? {};
    final List tasks = data['tasks'] ?? [];

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Edit WPR", 
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700, fontSize: 18)),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _updateWPR,
            child: _isSubmitting 
              ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text("Save", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoTile("Report No", widget.wpr.reportNo),
              _infoTile("Week Range", 
                "${DateFormat("dd MMM").format(widget.wpr.weekStartDate)} - ${DateFormat("dd MMM yyyy").format(widget.wpr.weekEndDate)}"),
              const Divider(height: 32),

              const Text("Edit Description", 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: "Update the weekly summary...",
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Read-only sections to remind the user what is in the report
              const Text("Reference Data (Read-Only)", 
                style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
              const SizedBox(height: 12),
              
              _readOnlyDataCard("Attendance", "${attendanceSummary['totalPresent'] ?? 0} Total Present"),
              if (tasks.isNotEmpty)
                _readOnlyDataCard("Tasks", "${tasks.length} Tasks tracked"),
              
              const SizedBox(height: 20),
              const Center(
                child: Text("Only the description can be modified.", 
                  style: TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _readOnlyDataCard(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontSize: 13, color: Colors.blueGrey)),
        ],
      ),
    );
  }
}