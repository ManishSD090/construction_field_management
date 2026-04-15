import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_erp/controllers/inspection/inspection_controller.dart';

class WprDetailsScreen extends ConsumerStatefulWidget {
  final String dateRange; 
  final String projectId; 
  final String projectName;

  const WprDetailsScreen({
    super.key,
    required this.dateRange,
    required this.projectId,
    required this.projectName,
  });

  @override
  ConsumerState<WprDetailsScreen> createState() => _WprDetailsScreenState();
}

class _WprDetailsScreenState extends ConsumerState<WprDetailsScreen> {
  
  @override
  Widget build(BuildContext context) {
    final wprAsync = ref.watch(wprReportProvider(widget.projectId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D6EFD),
        elevation: 0,
        title: const Text("WPR Details", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(16))),
      ),
      body: wprAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error loading WPR:\n$err", textAlign: TextAlign.center)),
        data: (wprData) {
          final description = wprData.description;
          
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderInfo(), 
                      const SizedBox(height: 20),
                      
                      _buildSectionCard("Description", Text(description)), 
                      
                      const Text("Attendance", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _buildAttendanceChart(wprData.attendance), 
                      const SizedBox(height: 20),

                      _buildProgressSection(wprData.progress),
                      _buildBudgetSection(wprData.budget),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.dateRange, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.projectName, style: const TextStyle(color: Color(0xFF0D6EFD), fontSize: 14, fontWeight: FontWeight.w500)),
            Text("ID-WPR", style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionCard(String title, Widget content, {Widget? trailing}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))]),
          const SizedBox(height: 8), const Divider(thickness: 1, color: Colors.black87), const SizedBox(height: 8),
          content,
        ],
      ),
    );
  }

  Widget _buildAttendanceChart(Map<String, dynamic> attendance) {
    final List<dynamic> dailyBreakdown = attendance['dailyBreakdown'] ?? [];
    final String workersAvg = attendance['workersAvg']?.toString() ?? "0";
    final String staffAvg = attendance['staffAvg']?.toString() ?? "0";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [Text("40", style: TextStyle(color: Colors.grey, fontSize: 12)), Text("0", style: TextStyle(color: Colors.grey, fontSize: 12))]),
                const SizedBox(width: 8),
                Expanded(
                  child: Stack(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: dailyBreakdown.map((day) {
                          double workersHeight = (day['workers'] ?? 0) * 3.5;
                          double staffHeight = (day['staff'] ?? 0) * 3.5;
                          if (workersHeight > 100) workersHeight = 100;
                          return _buildStackedBar(day['date']?.toString() ?? "00", workersHeight, staffHeight);
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(const Color(0xFF0D6EFD), workersAvg, "Workers\n(avg)"),
              const SizedBox(width: 40),
              _buildLegendItem(const Color(0xFF00A67E), staffAvg, "Staff\n(avg)"),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStackedBar(String label, double workersHeight, double staffHeight) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (staffHeight > 0) Container(width: 14, height: staffHeight, decoration: BoxDecoration(color: const Color(0xFF00A67E), borderRadius: BorderRadius.circular(4))),
        if (staffHeight > 0) const SizedBox(height: 2), 
        Container(width: 14, height: workersHeight > 0 ? workersHeight : 5, decoration: BoxDecoration(color: const Color(0xFF0D6EFD), borderRadius: BorderRadius.circular(4))),
        const SizedBox(height: 8), Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String number, String label) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(margin: const EdgeInsets.only(top: 4), width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))), const SizedBox(width: 8), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(number, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87), textAlign: TextAlign.center)])]);
  }

  Widget _buildProgressSection(Map<String, dynamic> progress) {
    final todayAdded = progress['todayAdded']?.toString() ?? "0%";
    final currentOverall = progress['currentOverall']?.toString() ?? "0%";

    return _buildSectionCard("Progress", Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("Added This Week - $todayAdded", style: TextStyle(color: Colors.grey.shade800, fontSize: 13)),
      const SizedBox(height: 4),
      Text("Overall Progress - $currentOverall", style: TextStyle(color: Colors.grey.shade800, fontSize: 13)),
    ]));
  }

  Widget _buildBudgetSection(Map<String, dynamic> budget) {
    return _buildSectionCard("Budget", Column(children: [
      _buildListRow("Labour", budget['labour']?.toString() ?? "₹0"),
      _buildListRow("Material", budget['material']?.toString() ?? "₹0"),
      _buildListRow("Equipment", budget['equipment']?.toString() ?? "₹0"),
      const SizedBox(height: 8), const Divider(), const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Total", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)), Text(budget['total']?.toString() ?? "₹0", style: const TextStyle(color: Color(0xFF0D6EFD), fontWeight: FontWeight.bold, fontSize: 15))]),
    ]));
  }

  Widget _buildListRow(String title, String value) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title), Text(value, style: const TextStyle(color: Color(0xFF0D6EFD)))]));
  }
}