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

            _sectionTitle("Documents"),
            _documentsSection(),
            const SizedBox(height: 24),

            _sectionTitle("Issues"),
            _textSection(dpr.challenges ?? dpr.issuesFound),
            const SizedBox(height: 24),

            _sectionTitle("Tasks"),
            _textSection(dpr.nextDayTaskName ?? "No tasks planned."),
            const SizedBox(height: 12),
            const Divider(color: Colors.grey, thickness: 0.5),
            
            const SizedBox(height: 12),
            _sectionTitle("Notes"),
            _textSection(dpr.nextDayNotes ?? dpr.notes ?? "No plans provided for the next day."),
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
    
    String visitors = "None";
    if (dpr.siteVisitors.isNotEmpty) {
      try {
        final firstVisitor = dpr.siteVisitors.first;
        visitors = firstVisitor['name'] ?? "Visitor";
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
            Expanded(
              child: Text(dpr.projectName ?? "Project Name", 
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryBlue),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text("Mumbai | ID-${dpr.reportNo.length > 4 ? dpr.reportNo.substring(dpr.reportNo.length - 4) : dpr.reportNo}", 
              style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Site Visitor: $visitors", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
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
    final completed = dpr.completedWork ?? "No tasks recorded";
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Tasks subtasks", isCombined: true),
        const Divider(height: 1, thickness: 1),
        const SizedBox(height: 12),
        _taskRow(completed, "1/1", "Completed", const Color(0xFF2ECC71)),
      ],
    );
  }

  Widget _taskRow(String name, String subtext, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: Text("Task: $name", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark))),
          Text(subtext, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryBlue)),
          const SizedBox(width: 15),
          Container(
            width: 80,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
            child: Text(status, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _attendanceSection() {
    final int workers = dpr.workersPresent ?? 0;
    final int staff = dpr.staffPresent ?? 0;
    final int total = dpr.totalWorkers ?? (workers + staff);
    
    String subWorkerCount = "0 workers";
    if (dpr.subContractorName != null) {
      subWorkerCount = "4 workers"; 
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Attendance $total/30 Present", isCombined: true),
        const Divider(height: 1, thickness: 1),
        const SizedBox(height: 12),
        _listRow("Workers", "$workers/20", isValueBlue: true),
        _listRow("Staff", "$staff/10", isValueBlue: true),
        _listRow("Sub-Contractor", subWorkerCount, isValueBlue: true),
      ],
    );
  }

  Widget _materialsSection() {
  final consumptions = dpr.materialConsumptions ?? [];
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionTitle("Materials"),
      const Divider(height: 1, thickness: 1),
      const SizedBox(height: 12),
      // If no data, show a placeholder instead of just the column headers
      if (consumptions.isEmpty)
        const Text("No materials recorded", style: TextStyle(color: Colors.grey, fontSize: 13))
      else
        ...consumptions.map((c) => _listRow(
          c.material?.name ?? "Material", 
          "${c.quantity} ${c.unit}", 
          isValueBlue: true
        )),
    ],
  );
}

  Widget _equipmentsSection() {
    List<dynamic> eqList = [];
    if (dpr.equipmentUsed != null && dpr.equipmentUsed!.startsWith('[')) {
      try { eqList = jsonDecode(dpr.equipmentUsed!); } catch (_) {}
    } else if (dpr.equipments.isNotEmpty) {
      eqList = dpr.equipments;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Equipments"),
        const Divider(height: 1, thickness: 1),
        const SizedBox(height: 12),
        if (eqList.isEmpty)
           _listRow("Name", "Hrs used  Fuel", isValueBlue: true)
        else
          ...eqList.map((e) {
            String name = "Equipment";
            String hours = "0";
            if (e is Map) {
              name = e['name']?.toString() ?? "Equipment";
              hours = e['hours']?.toString() ?? "0";
            } else if (e is DPREquipment) {
              name = e.name;
              hours = e.hoursUsed.toString();
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark))),
                Text("$hours Hrs used", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryBlue)),
                const SizedBox(width: 20),
                const Text("Fuel", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryBlue)),
              ],
            );
          }),
      ],
    );
  }

  Widget _photosSection() {
    final photos = dpr.photos;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: photos.isEmpty 
        ? List.generate(3, (index) => _emptyBox())
        : photos.take(6).map((p) => _imageBox(p.imageUrl)).toList(),
    );
  }

  Widget _documentsSection() {
    final docs = dpr.documents;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: docs.isEmpty 
        ? List.generate(3, (index) => _emptyBox())
        : docs.map((d) => _emptyBox()).toList(),
    );
  }

  // -------------------- Core Helpers --------------------

  Widget _textSection(String? text) {
    return Text(
      (text == null || text.trim().isEmpty || text == "null") ? "No details provided." : text,
      style: const TextStyle(fontSize: 13, color: AppColors.textDark, height: 1.4),
    );
  }

  Widget _listRow(String title, String value, {bool isValueBlue = false, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 13, fontWeight: isBold ? FontWeight.w900 : FontWeight.w600, color: AppColors.textDark)),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: isBold ? FontWeight.w900 : FontWeight.w700, color: isValueBlue ? AppColors.primaryBlue : AppColors.textDark)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t, {bool isCombined = false}) {
    if (isCombined) {
      final parts = t.split(' ');
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(text: parts[0], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textDark)),
              const TextSpan(text: " "),
              TextSpan(text: parts.skip(1).join(' '), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryBlue)),
            ],
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(t, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textDark)),
    );
  }

  Widget _weatherChip(String weather) {
    return Row(
      children: [
        Icon(weather.toLowerCase().contains('sunny') ? Icons.wb_sunny_outlined : Icons.cloud_outlined, size: 16, color: AppColors.primaryBlue),
        const SizedBox(width: 4),
        Text(weather, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primaryBlue)),
      ],
    );
  }

  Widget _emptyBox() {
    return Container(
      height: 70, width: 90,
      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _imageBox(String url) {
    return Container(
      height: 70, width: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
      ),
    );
  }

  Widget _bottomApproveBar(BuildContext context) {
    final status = dpr.status.name.toLowerCase();
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
          onPressed: isApproved ? null : () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: isApproved ? Colors.grey : const Color(0xFF17A589),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            elevation: 0,
          ),
          child: Text(
            isApproved ? "Approved" : "Send For Approval",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
      ),
    );
  }
}