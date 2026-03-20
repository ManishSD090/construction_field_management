import 'package:flutter/material.dart';
import 'dpr_details_screen.dart'; 
import 'wpr_details_screen.dart';

class InspectionDetailScreen extends StatefulWidget {
  final String projectName;

  const InspectionDetailScreen({super.key, required this.projectName});

  @override
  State<InspectionDetailScreen> createState() => _InspectionDetailScreenState();
}

class _InspectionDetailScreenState extends State<InspectionDetailScreen> {
  // Toggle state: true = DPR, false = WPR
  bool isDprSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D6EFD),
        elevation: 0,
        centerTitle: false,
        title: const Text("Inspection", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          
          // Custom Tab Toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: const Color(0xFFE9ECEF),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Expanded(child: _buildTabButton("DPR", isDprSelected, () => setState(() => isDprSelected = true))),
                  Expanded(child: _buildTabButton("WPR", !isDprSelected, () => setState(() => isDprSelected = false))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Dynamic Content Area
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

  // --- TAB UI SWITCHER ---

  Widget _buildTabButton(String title, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D6EFD) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  // --- DPR CONTENT ---

  Widget _buildDprContent() {
    final List<Map<String, dynamic>> dprReports = [
      {"date": "20 Feb 2026", "preparedBy": "Ajay Singh", "status": "Approved"},
      {"date": "19 Feb 2026", "preparedBy": "Ajay Singh", "status": "Pending"},
      {"date": "18 Feb 2026", "preparedBy": "Ajay Singh", "status": "Rejected"},
    ];

    return _buildSharedTabLayout(
      key: const ValueKey('dpr'),
      dateButtonLabel: "MM/DD/YYYY",
      reports: dprReports,
    );
  }

  // --- WPR CONTENT ---

  Widget _buildWprContent() {
    final List<Map<String, dynamic>> wprReports = [
      {"date": "15 Feb - 21 Feb 2026", "preparedBy": "Ajay Singh", "status": "Approved"},
      {"date": "8 Feb - 14 Feb 2026", "preparedBy": "Ajay Singh", "status": "Pending"},
      {"date": "1 Feb - 7 Feb 2026", "preparedBy": "Ajay Singh", "status": "Rejected"},
    ];

    return _buildSharedTabLayout(
      key: const ValueKey('wpr'),
      dateButtonLabel: "MM/YYYY", // WPR uses Month/Year
      reports: wprReports,
    );
  }

  // --- SHARED UI COMPONENTS ---

  Widget _buildSharedTabLayout({required Key key, required String dateButtonLabel, required List<Map<String, dynamic>> reports}) {
    return Padding(
      key: key, 
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search",
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                suffixIcon: Icon(Icons.mic, color: Colors.grey.shade600),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Filters Row
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

          // List of Reports
          Expanded(
            child: ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return _buildReportCard(
                  context, 
                  report['date'], 
                  report['preparedBy'], 
                  report['status'], 
                  widget.projectName // Passed from the stateful widget
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutlineButton(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF0D6EFD)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(text, style: const TextStyle(color: Color(0xFF0D6EFD), fontSize: 13)),
          const SizedBox(width: 8),
          Icon(icon, color: const Color(0xFF0D6EFD), size: 16),
        ],
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, String date, String author, String status, String projectName) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            if (isDprSelected) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DprDetailsScreen(
                    date: date,
                    projectName: projectName,
                  ),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WprDetailsScreen(
                    dateRange: date, // Using the 'date' string as the dateRange
                    projectName: projectName,
                  ),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(date, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text("Prepared by: ", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                        Text(author, style: const TextStyle(color: Color(0xFF0D6EFD), fontSize: 13)),
                      ],
                    ),
                  ],
                ),
                _buildStatusBadge(status),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    
    switch (status) {
      case 'Approved':
        bgColor = const Color(0xFF00A67E);
        textColor = Colors.white;
        break;
      case 'Rejected':
        bgColor = const Color(0xFFFC3D39);
        textColor = Colors.white;
        break;
      case 'Pending':
      default:
        bgColor = Colors.transparent; 
        textColor = const Color(0xFF0D6EFD);
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: status == 'Pending' ? 0 : 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}