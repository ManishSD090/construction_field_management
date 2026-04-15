import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:construction_erp/controllers/inspection/inspection_controller.dart';
import 'package:construction_erp/models/dpr.dart';
import 'dpr_details_screen.dart'; 
import 'wpr_details_screen.dart';

class InspectionDetailScreen extends ConsumerStatefulWidget {
  final String projectId;
  final String projectName;

  const InspectionDetailScreen({super.key, required this.projectId, required this.projectName});

  @override
  ConsumerState<InspectionDetailScreen> createState() => _InspectionDetailScreenState();
}

class _InspectionDetailScreenState extends ConsumerState<InspectionDetailScreen> {
  bool isDprSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D6EFD),
        elevation: 0,
        centerTitle: false,
        title: const Text("Pending Inspections", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(16))),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              height: 45,
              decoration: BoxDecoration(color: const Color(0xFFE9ECEF), borderRadius: BorderRadius.circular(30)),
              child: Row(
                children: [
                  Expanded(child: _buildTabButton("DPR", isDprSelected, () => setState(() => isDprSelected = true))),
                  Expanded(child: _buildTabButton("WPR", !isDprSelected, () => setState(() => isDprSelected = false))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isDprSelected ? _buildDprContent() : _buildWprContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: isSelected ? const Color(0xFF0D6EFD) : Colors.transparent, borderRadius: BorderRadius.circular(30)),
        child: Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade600, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, fontSize: 15)),
      ),
    );
  }

  Widget _buildDprContent() {
    final dprAsync = ref.watch(pendingInspectionDprProvider(widget.projectId));

    return dprAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text("Error: $err")),
      data: (dprs) {
        if (dprs.isEmpty) {
          return const Center(
            child: Text("No DPRs pending inspection.", style: TextStyle(color: Colors.grey, fontSize: 16)),
          );
        }
        return _buildSharedTabLayout(
          key: const ValueKey('dpr'),
          dateButtonLabel: "MM/DD/YYYY",
          dprs: dprs,
        );
      }
    );
  }

  Widget _buildWprContent() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          _buildReportCardRaw(
            "Current Week Progress",
            "System Generated",
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => WprDetailsScreen(dateRange: "Current Week", projectId: widget.projectId, projectName: widget.projectName))),
          )
        ],
      ),
    );
  }

  Widget _buildSharedTabLayout({required Key key, required String dateButtonLabel, required List<DailyProgressReport> dprs}) {
    return Padding(
      key: key, 
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.grey.shade300)),
            child: TextField(decoration: InputDecoration(hintText: "Search", hintStyle: TextStyle(color: Colors.grey.shade500), prefixIcon: Icon(Icons.search, color: Colors.grey.shade600), suffixIcon: Icon(Icons.mic, color: Colors.grey.shade600), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 14))),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildOutlineButton(dateButtonLabel, Icons.calendar_today_outlined),
              _buildOutlineButton("Filter", Icons.tune),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.blue.shade200, thickness: 1),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: dprs.length,
              itemBuilder: (context, index) {
                final dpr = dprs[index];
                return _buildReportCardRaw(
                  DateFormat("dd MMM yyyy").format(dpr.date),
                  dpr.preparedBy?.name ?? "Unknown",
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => DprDetailsScreen(dprId: dpr.id, date: DateFormat("dd MMM yyyy").format(dpr.date), projectName: widget.projectName))),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutlineButton(String text, IconData icon) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFF0D6EFD)), borderRadius: BorderRadius.circular(20)), child: Row(children: [Text(text, style: const TextStyle(color: Color(0xFF0D6EFD), fontSize: 13)), const SizedBox(width: 8), Icon(icon, color: const Color(0xFF0D6EFD), size: 16)]));
  }

  Widget _buildReportCardRaw(String title, String author, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 1,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Row(children: [Text("Prepared by: ", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)), Text(author, style: const TextStyle(color: Color(0xFF0D6EFD), fontSize: 13))]),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFF0D6EFD).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Text("Pending", style: TextStyle(color: Color(0xFF0D6EFD), fontWeight: FontWeight.w700, fontSize: 12)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}