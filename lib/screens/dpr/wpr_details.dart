import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/models/wpr.dart';

class WPRDetailsScreen extends StatelessWidget {
  final WeeklyProgressReport wpr;

  const WPRDetailsScreen({super.key, required this.wpr});

  @override
  Widget build(BuildContext context) {
    // Unpack the aggregated JSON data from the database
    final data = wpr.aggregatedData ?? {};
    
    final attendance = data['attendance'] ?? {};
    final attendanceSummary = attendance['summary'] ?? {};
    
    final progress = data['progress'] ?? {};
    final List weeklyBreakdown = progress['weeklyBreakdown'] ?? [];
    
    final List tasks = data['tasks'] ?? [];
    final List materials = data['materials']?['consumed'] ?? [];
    final List equipment = data['equipment'] ?? [];
    final List photos = data['photos'] ?? [];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        title: Text(wpr.reportNo, style: const TextStyle(color: Colors.white, fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateHeader(),
            const SizedBox(height: 20),

            if (wpr.description != null && wpr.description!.isNotEmpty) ...[
              _sectionLabel("Description & Planning"),
              _infoBox(wpr.description!),
              const SizedBox(height: 24),
            ],

            _sectionLabel("Attendance (Weekly Avg)"),
            _buildAttendanceCard(attendanceSummary),
            const SizedBox(height: 24),

            _sectionLabel("Work Progress"),
            _buildProgressCard(progress),
            const SizedBox(height: 24),

            if (tasks.isNotEmpty) ...[
              _sectionLabel("Completed Tasks"),
              ...tasks.map((t) => _buildDataTile(
                title: t['name'] ?? "Task",
                trailing: t['completed'] ?? "100%",
                isStatus: true,
                status: t['status']
              )),
              const SizedBox(height: 24),
            ],

            if (materials.isNotEmpty) ...[
              _sectionLabel("Material Consumption"),
              ...materials.map((m) => _buildDataTile(
                title: m['name'] ?? "Material",
                subtitle: "Consumed on ${m['date']}",
                trailing: m['quantity'] ?? "0",
              )),
              const SizedBox(height: 24),
            ],

            if (photos.isNotEmpty) ...[
              _sectionLabel("Site Progress Photos"),
              _buildPhotoGrid(photos),
              const SizedBox(height: 24),
            ],
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- UI WIDGETS ---

  Widget _buildDateHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_month, color: AppColors.primaryBlue),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${DateFormat("dd MMM").format(wpr.weekStartDate)} - ${DateFormat("dd MMM yyyy").format(wpr.weekEndDate)}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Text("Weekly Progress Report", style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(Map summary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDeco(),
      child: Column(
        children: [
          _rowInfo("Total Weekly Presence", "${summary['totalPresent'] ?? 0}"),
          const Divider(height: 20),
          _rowInfo("Avg. Workers / Day", "${summary['avgWorkers'] ?? 0}"),
          _rowInfo("Avg. Staff / Day", "${summary['avgStaff'] ?? 0}"),
        ],
      ),
    );
  }

  Widget _buildProgressCard(Map progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDeco(),
      child: Column(
        children: [
          _rowInfo("Added This Week", progress['todayAdded'] ?? "0%", color: Colors.green),
          _rowInfo("Overall Completion", progress['currentOverall'] ?? "0%", color: AppColors.primaryBlue),
        ],
      ),
    );
  }

  Widget _buildDataTile({required String title, String? subtitle, required String trailing, bool isStatus = false, String? status}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: _cardDeco(),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                if (subtitle != null) Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          if (isStatus)
            _badge(status ?? 'Completed')
          else
            Text(trailing, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid(List photos) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8,
      ),
      itemCount: photos.length,
      itemBuilder: (ctx, idx) => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          photos[idx]['url']?.replaceAll('localhost', '172.16.9.36') ?? '',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: Colors.grey[200], child: const Icon(Icons.broken_image)),
        ),
      ),
    );
  }

  // --- HELPERS ---

  Widget _sectionLabel(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 4),
    child: Text(t, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
  );

  Widget _infoBox(String text) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
    child: Text(text, style: const TextStyle(fontSize: 13, height: 1.5)),
  );

  Widget _rowInfo(String label, String val, {Color? color}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13)),
        Text(val, style: TextStyle(fontWeight: FontWeight.bold, color: color ?? AppColors.textDark)),
      ],
    ),
  );

  Widget _badge(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.green.withOpacity(0.5))),
    child: Text(text, style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
  );

  BoxDecoration _cardDeco() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.grey.shade200),
  );
}