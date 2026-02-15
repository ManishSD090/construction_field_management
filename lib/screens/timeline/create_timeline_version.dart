import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/controllers/timeline/timeline_controller.dart';
import 'package:construction_erp/models/timeline.dart';

class CreateTimelineVersionScreen extends ConsumerStatefulWidget {
  final String timelineId;

  const CreateTimelineVersionScreen({super.key, required this.timelineId});

  @override
  ConsumerState<CreateTimelineVersionScreen> createState() =>
      _CreateTimelineVersionScreenState();
}

class _CreateTimelineVersionScreenState
    extends ConsumerState<CreateTimelineVersionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();
  final _changesCtrl = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isBaseline = false;
  bool _isLoading = false;
  String? _copyFromVersionId;

  List<TimelineVersion> _availableVersions = [];

  @override
  void initState() {
    super.initState();
    _fetchExistingVersions();
  }

  Future<void> _fetchExistingVersions() async {
    try {
      final versions = await ref
          .read(timelineControllerProvider.notifier)
          .getTimelineVersions(widget.timelineId);

      setState(() {
        _availableVersions = versions;
        // Default name if versions exist
        if (versions.isNotEmpty) {
          int nextVer = versions
                  .map((e) => e.versionNumber)
                  .reduce((a, b) => a > b ? a : b) +
              1;
          _nameCtrl.text = "Version $nextVer";
        } else {
          _nameCtrl.text = "Version 1";
        }
      });
    } catch (e) {
      debugPrint("Error fetching versions: $e");
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    _changesCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? _startDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          _startCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
        } else {
          _endDate = picked;
          _endCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please select start and end dates"),
          backgroundColor: AppColors.alertRed));
      return;
    }

    setState(() => _isLoading = true);

    final payload = {
      "name": _nameCtrl.text.trim(),
      if (_descCtrl.text.isNotEmpty) "description": _descCtrl.text.trim(),
      "startDate": DateFormat('yyyy-MM-dd').format(_startDate!),
      "endDate": DateFormat('yyyy-MM-dd').format(_endDate!),
      "changesSummary": _changesCtrl.text.trim(),
      "isBaseline": _isBaseline,
      if (_copyFromVersionId != null) "copyFromVersion": _copyFromVersionId,
    };

    try {
      await ref
          .read(timelineControllerProvider.notifier)
          .createVersion(widget.timelineId, payload);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("New Version Created!"),
            backgroundColor: AppColors.successGreen));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: AppColors.alertRed));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("New Timeline Version",
            style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("Version Name"),
              _buildTextField(_nameCtrl, "e.g., Version 2: Re-planning"),
              const SizedBox(height: 15),
              _buildLabel("Description"),
              _buildTextField(_descCtrl, "Brief description of this version",
                  maxLines: 2),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                      child: _buildDatePicker("Start Date", _startCtrl, true)),
                  const SizedBox(width: 15),
                  Expanded(
                      child: _buildDatePicker("End Date", _endCtrl, false)),
                ],
              ),
              const SizedBox(height: 15),
              _buildLabel("Changes Summary"),
              _buildTextField(_changesCtrl, "What changed in this version?",
                  maxLines: 2),
              const SizedBox(height: 20),
              const Divider(color: AppColors.lightGrey),
              const SizedBox(height: 10),
              if (_availableVersions.isNotEmpty) ...[
                _buildLabel("Copy tasks from previous version (Optional)"),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _copyFromVersionId,
                      hint: const Text("Select a version to copy tasks from"),
                      isExpanded: true,
                      items: _availableVersions.map((v) {
                        return DropdownMenuItem(
                          value: v.versionNumber
                              .toString(), // Controller expects String ID or version number? Backend controller says `parseInt(copyFromVersion)`, so send number as string.
                          child: Text("${v.versionNumber} - ${v.name}"),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setState(() => _copyFromVersionId = val),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
              ],
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Set as Baseline?",
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text(
                    "This will make this version the standard for comparison."),
                value: _isBaseline,
                activeColor: AppColors.primaryBlue,
                onChanged: (val) => setState(() => _isBaseline = val ?? false),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Create Version",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)));

  Widget _buildTextField(TextEditingController controller, String hint,
      {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: (val) => val == null || val.isEmpty ? "Required" : null,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildDatePicker(
      String label, TextEditingController controller, bool isStart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        GestureDetector(
          onTap: () => _selectDate(isStart),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: AbsorbPointer(
              child: TextFormField(
                controller: controller,
                validator: (val) =>
                    val == null || val.isEmpty ? "Required" : null,
                decoration: const InputDecoration(
                  hintText: "YYYY-MM-DD",
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  suffixIcon: Icon(Icons.calendar_month_outlined,
                      size: 20, color: AppColors.primaryBlue),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
