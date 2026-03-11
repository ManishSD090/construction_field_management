import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/models/dpr.dart';

class DPRDetailsScreen extends StatelessWidget {
  final DailyProgressReport dpr;

  const DPRDetailsScreen({
    super.key,
    required this.dpr,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        title: const Text(
          "DPR Details",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      bottomNavigationBar: _bottomApproveBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerSection(),
            const SizedBox(height: 20),
            
            _sectionTitle("Description"),
            _descriptionBox(),
            const SizedBox(height: 24),

            _tasksSection(),
            const SizedBox(height: 24),

            _attendanceSection(),
            const SizedBox(height: 24),

            _materialsSection(),
            const SizedBox(height: 24),

            _equipmentsSection(),
            const SizedBox(height: 24),

            _sectionTitle("Photos"),
            _photosSection(),
            const SizedBox(height: 24),

            const Divider(color: Colors.grey, thickness: 0.5),
            const SizedBox(height: 12),
            
            _sectionTitle("Issues / Challenges"),
            _textSection(dpr.challenges ?? dpr.issuesFound),
            const SizedBox(height: 24),

            _sectionTitle("Next Day Planning"),
            _textSection(dpr.nextDayTaskName ?? dpr.notes ?? "No plans provided for the next day."),
            const SizedBox(height: 40), 
          ],
        ),
      ),
    );
  }

  // -------------------- UI Sections --------------------

  Widget _headerSection() {
    final dateLabel = DateFormat("dd MMM yyyy").format(dpr.date).toUpperCase();
    final weather = dpr.weather ?? "Sunny";
    
    // Parse Visitors safely
    String visitors = "No Visitors";
    if (dpr.siteVisitors.isNotEmpty) {
      try {
        final firstVisitor = dpr.siteVisitors.first;
        visitors = firstVisitor['name'] ?? "Site Visitor";
            } catch (_) {}
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(dateLabel, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textDark)),
            const Icon(Icons.edit_square, color: Colors.grey, size: 20),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(dpr.projectName ?? "Project Selected", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryBlue)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(visitors, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            _weatherChip(weather),
          ],
        ),
      ],
    );
  }

  Widget _descriptionBox() {
    final desc = (dpr.workDescription.trim().isEmpty) 
        ? "No description provided." 
        : dpr.workDescription;
        
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        desc,
        style: const TextStyle(fontSize: 13, color: AppColors.textDark, height: 1.4),
      ),
    );
  }

  Widget _tasksSection() {
    final completed = dpr.completedWork ?? "N/A";
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Tasks Completed", padBottom: 0),
        const SizedBox(height: 12),
        const Divider(height: 1, thickness: 1),
        const SizedBox(height: 12),
        
        // Removed hardcoded mock tasks. Now only shows what was actually submitted.
        _taskRow(completed, "Completed", const Color(0xFF2ECC71)),
      ],
    );
  }

  Widget _taskRow(String name, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text("Task: $name", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
            child: Text(status, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _attendanceSection() {
    final total = dpr.totalWorkers ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Attendance", padBottom: 0),
        const SizedBox(height: 12),
        const Divider(height: 1, thickness: 1),
        const SizedBox(height: 12),
        
        // Using real total workers sent from backend
        _listRow("Total Workers & Staff", "$total Present", isValueBlue: true),
      ],
    );
  }

  Widget _materialsSection() {
    // Decoding stringified JSON if it comes as a string from the backend
    List<dynamic> matList = [];
    if (dpr.materialsUsed != null && dpr.materialsUsed!.startsWith('[')) {
      try { matList = jsonDecode(dpr.materialsUsed!); } catch (_) {}
    } else    matList = dpr.materials!;
  

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Materials Used"),
        const Divider(height: 1, thickness: 1),
        const SizedBox(height: 12),
        if (matList.isEmpty)
          const Text("No materials recorded.", style: TextStyle(color: Colors.grey))
        else
          ...matList.map((m) {
            String name = "Material";
            String qty = "0";
            if (m is Map) {
              name = m['name'] ?? m['materialId']?.toString() ?? "Material";
              qty = m['quantity']?.toString() ?? m['qtyUsed']?.toString() ?? "0";
            }
            return _listRow("Name: $name", "Qty: $qty", isValueBlue: true);
          }),
      ],
    );
  }

  Widget _equipmentsSection() {
    // Decoding stringified JSON if it comes as a string from the backend
    List<dynamic> eqList = [];
    if (dpr.equipmentUsed != null && dpr.equipmentUsed!.startsWith('[')) {
      try { eqList = jsonDecode(dpr.equipmentUsed!); } catch (_) {}
    } else    eqList = dpr.equipments!;
  

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Equipment Used"),
        const Divider(height: 1, thickness: 1),
        const SizedBox(height: 12),
        if (eqList.isEmpty)
           const Text("No equipment recorded.", style: TextStyle(color: Colors.grey))
        else
          ...eqList.map((e) {
            String name = "Equipment";
            String hours = "0";
            if (e is Map) {
              name = e['name']?.toString() ?? "Equipment";
              hours = e['hours']?.toString() ?? e['hoursUsed']?.toString() ?? "0";
            }
            return _listRow("Name: $name", "$hours hrs used", isValueBlue: true);
          }),
      ],
    );
  }

  Widget _photosSection() {
    final photos = dpr.photos ?? [];
    return photos.isEmpty
        ? Row(children: List.generate(3, (index) => _emptyBox()))
        : Wrap(
            spacing: 12,
            runSpacing: 12,
            children: photos.take(6).map((p) => _imageBox(p.imageUrl)).toList(),
          );
  }

  // -------------------- Core Helpers --------------------

  Widget _textSection(String? text) {
    return Text(
      (text == null || text.trim().isEmpty || text == "null") ? "No details provided." : text,
      style: const TextStyle(fontSize: 13, color: AppColors.textDark),
    );
  }

  Widget _listRow(String title, String value, {bool isValueBlue = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark))),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isValueBlue ? AppColors.primaryBlue : AppColors.textDark)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t, {double padBottom = 12}) => Padding(
    padding: EdgeInsets.only(bottom: padBottom),
    child: Text(t, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textDark)),
  );

  Widget _weatherChip(String weather) {
    IconData icon = Icons.wb_sunny_outlined;
    if (weather.toLowerCase().contains("cloud")) icon = Icons.cloud_outlined;
    if (weather.toLowerCase().contains("rain")) icon = Icons.thunderstorm_outlined;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primaryBlue),
          const SizedBox(width: 6),
          Text(weather, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primaryBlue)),
        ],
      ),
    );
  }

  Widget _emptyBox() {
    return Container(
      height: 70,
      width: 70,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
    );
  }

  Widget _imageBox(String url) {
    return Container(
      height: 70,
      width: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
      ),
    );
  }

  Widget _bottomApproveBar(BuildContext context) {
    // Handling possible nulls safely
    final status = dpr.status.name.toLowerCase() ?? "todo";
    final isApproved = status == "approved" || status == "completed";

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: SizedBox(
        height: 48,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isApproved ? null : () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF17A589), // Teal color matching the design
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            elevation: 0,
          ),
          child: Text(
            isApproved ? "Sent for Approval" : "Send For Approval",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
      ),
    );
  }
}