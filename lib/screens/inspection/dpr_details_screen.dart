import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_erp/controllers/inspection/inspection_controller.dart';
import 'package:construction_erp/models/dpr.dart';

class DprDetailsScreen extends ConsumerStatefulWidget {
  final String dprId;
  final String date;
  final String projectName;

  const DprDetailsScreen({
    super.key,
    required this.dprId,
    required this.date,
    required this.projectName,
  });

  @override
  ConsumerState<DprDetailsScreen> createState() => _DprDetailsScreenState();
}

class _DprDetailsScreenState extends ConsumerState<DprDetailsScreen> {
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _handleAction(bool approve) async {
    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));
    try {
      await ref.read(inspectionActionProvider.notifier).approveRejectDPR(
        dprId: widget.dprId,
        isApproved: approve,
        comments: _reasonController.text,
      );
      if (mounted) {
        Navigator.pop(context); 
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(approve ? "DPR Approved Successfully" : "DPR Rejected"), backgroundColor: approve ? Colors.green : Colors.red));
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dprAsync = ref.watch(dprDetailsProvider(widget.dprId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D6EFD),
        elevation: 0,
        title: const Text("DPR Details", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(16))),
      ),
      body: dprAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error loading details: $err")),
        data: (dpr) => Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderInfo(dpr.reportNo, dpr.weather ?? "Sunny"),
                    const SizedBox(height: 20),
                    _buildSectionCard("Description", Text(dpr.workDescription.isNotEmpty ? dpr.workDescription : "No description", style: const TextStyle(fontSize: 14))),
                    _buildAttendanceSection(dpr),
                    _buildBudgetSection(dpr),
                    
                    if (dpr.issuesFound != null && dpr.issuesFound!.isNotEmpty)
                       _buildSectionCard("Issues", Text(dpr.issuesFound!)),
                    if (dpr.notes != null && dpr.notes!.isNotEmpty)
                       _buildSectionCard("Notes", Text(dpr.notes!)),
                       
                    _buildGridSection("Photos", dpr.photos.length),
                  ],
                ),
              ),
            ),
            _buildBottomActionArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo(String reportNo, String weather) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.date.toUpperCase(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.projectName, style: const TextStyle(color: Color(0xFF0D6EFD), fontSize: 14, fontWeight: FontWeight.w500)),
            Text(reportNo, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Site Visitor: -", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Row(children: [Icon(weather.toLowerCase().contains('sun') ? Icons.wb_sunny_outlined : Icons.cloud, color: const Color(0xFF0D6EFD), size: 18), const SizedBox(width: 4), Text(weather, style: const TextStyle(color: Color(0xFF0D6EFD), fontWeight: FontWeight.w500))]),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionCard(String title, Widget content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8), const Divider(thickness: 1, color: Colors.black87), const SizedBox(height: 8),
          content,
        ],
      ),
    );
  }

  Widget _buildAttendanceSection(DailyProgressReport dpr) {
    return _buildSectionCard(
      "Attendance",
      Column(
        children: [
          _buildListRow("Workers Recorded", "${dpr.totalWorkers ?? 0}"),
          _buildListRow("Staff Present", "${dpr.staffPresent ?? 0}"),
        ],
      )
    );
  }

  Widget _buildBudgetSection(DailyProgressReport dpr) {
    return _buildSectionCard(
      "Budget",
      Column(
        children: [
          _buildListRow("Labour", "₹${dpr.laborCost ?? 0}"),
          _buildListRow("Material", "₹${dpr.materialsCost ?? 0}"),
          _buildListRow("Equipment", "₹${dpr.equipmentCost ?? 0}"),
          const SizedBox(height: 8), const Divider(), const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Total", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)), Text("₹${dpr.budgetUsed ?? 0}", style: const TextStyle(color: Color(0xFF0D6EFD), fontWeight: FontWeight.bold, fontSize: 15))]),
        ],
      ),
    );
  }

  Widget _buildGridSection(String title, int count) {
    return _buildSectionCard(
      title,
      Text(count > 0 ? "$count attached" : "None attached", style: const TextStyle(fontSize: 14)),
    );
  }

  Widget _buildListRow(String title, String value) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title), Text(value, style: const TextStyle(color: Color(0xFF0D6EFD)))]));
  }

  Widget _buildBottomActionArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: BoxDecoration(color: const Color(0xFFF8F9FA), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, -4), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Reasons or Suggestions", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(controller: _reasonController, decoration: InputDecoration(hintText: "Enter the description", hintStyle: TextStyle(color: Colors.blue.shade200, fontSize: 14), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF0D6EFD))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF0D6EFD), width: 1.5)))),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: ElevatedButton(onPressed: () => _handleAction(true), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A67E), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 0), child: const Text("Approve", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)))),
              const SizedBox(width: 16),
              Expanded(child: ElevatedButton(onPressed: () => _handleAction(false), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFC3D39), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 0), child: const Text("Reject", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)))),
            ],
          )
        ],
      ),
    );
  }
}