import 'package:flutter/material.dart';

class WprDetailsScreen extends StatefulWidget {
  final String dateRange; // e.g., "15 Feb - 21 Feb 2026"
  final String projectName;

  const WprDetailsScreen({
    super.key,
    required this.dateRange,
    required this.projectName,
  });

  @override
  State<WprDetailsScreen> createState() => _WprDetailsScreenState();
}

class _WprDetailsScreenState extends State<WprDetailsScreen> {
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D6EFD),
        elevation: 0,
        title: const Text("WPR Details", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: Column(
        children: [
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderInfo(),
                  const SizedBox(height: 20),
                  
                  // Specific WPR Sections
                  _buildWeatherSection(),
                  _buildSectionCard("Description", const SizedBox(height: 40)), 
                  
                  // Attendance Header & Chart (No border as per design)
                  const Text("Attendance", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildAttendanceChart(),
                  const SizedBox(height: 20),

                  _buildSubContractorSection(),
                  _buildProgressSection(),
                  _buildTasksSection(),
                  _buildMaterialsSection(),
                  _buildEquipmentsSection(),
                  _buildBudgetSection(),
                  _buildGridSection("Photos"),
                  _buildGridSection("Documents"),
                  _buildNextWeekPlanningSection(),
                  _buildSectionCard("Notes", const SizedBox(height: 40)),
                ],
              ),
            ),
          ),

          // Fixed Bottom Action Area
          _buildBottomActionArea(),
        ],
      ),
    );
  }

  // --- HEADER ---

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
            Text("Mumbai | ID-2341", style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          ],
        ),
      ],
    );
  }

  // --- REUSABLE CARD WRAPPER ---

  Widget _buildSectionCard(String title, Widget content, {Widget? trailing}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 8),
          const Divider(thickness: 1, color: Colors.black87),
          const SizedBox(height: 8),
          content,
        ],
      ),
    );
  }

  // --- WPR SPECIFIC SECTIONS ---

  Widget _buildWeatherSection() {
    return _buildSectionCard(
      "Weather",
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildWeatherDay("01", Icons.wb_sunny_outlined),
          _buildWeatherDay("02", Icons.cloud_outlined),
          _buildWeatherDay("03", Icons.water_drop_outlined),
          _buildWeatherDay("04", Icons.wb_sunny_outlined),
          _buildWeatherDay("05", Icons.wb_sunny_outlined),
          _buildWeatherDay("06", Icons.wb_sunny_outlined),
          _buildWeatherDay("07", Icons.cloud_outlined),
        ],
      ),
    );
  }

  Widget _buildWeatherDay(String day, IconData icon) {
    return Column(
      children: [
        Text(day, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        const SizedBox(height: 8),
        Icon(icon, color: const Color(0xFF0D6EFD), size: 22),
      ],
    );
  }

  Widget _buildAttendanceChart() {
    // Custom Bar Chart matching UI exactly
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Y-Axis Labels
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("40", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text("30", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text("20", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text("10", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text("0", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const SizedBox(width: 8),
                // Chart Area
                Expanded(
                  child: Stack(
                    children: [
                      // Horizontal Grid Lines
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(5, (index) => _buildDashedLine()),
                      ),
                      // Bars
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildStackedBar("01", 120, 20),
                          _buildStackedBar("02", 90, 30),
                          _buildStackedBar("03", 110, 25),
                          _buildStackedBar("04", 120, 25),
                          _buildStackedBar("05", 85, 25),
                          _buildStackedBar("06", 95, 40),
                          _buildStackedBar("07", 100, 30),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Legend / Averages
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(const Color(0xFF0D6EFD), "28", "Workers\n(avg)"),
              const SizedBox(width: 40),
              _buildLegendItem(const Color(0xFF00A67E), "7", "Staff\n(avg)"),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDashedLine() {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              (constraints.constrainWidth() / 8).floor(),
              (index) => Container(width: 4, height: 1, color: Colors.grey.shade300),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStackedBar(String label, double workersHeight, double staffHeight) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 14,
          height: staffHeight,
          decoration: BoxDecoration(color: const Color(0xFF00A67E), borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(height: 2), // Gap between bars
        Container(
          width: 14,
          height: workersHeight,
          decoration: BoxDecoration(color: const Color(0xFF0D6EFD), borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String number, String label) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 12, height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(number, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87), textAlign: TextAlign.center),
          ],
        )
      ],
    );
  }

  Widget _buildSubContractorSection() {
    return _buildSectionCard(
      "Sub Contractor Names",
      Column(
        children: [
          _buildListRow("Sub-Contractor", "6 workers"),
          _buildListRow("Sub-Contractor", "12 workers"),
        ],
      ),
    );
  }

  Widget _buildNextWeekPlanningSection() {
    return _buildSectionCard(
      "Next Week Planning",
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Text("Task Name")),
          Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Text("Task Name")),
        ],
      ),
    );
  }

  // --- SHARED SECTIONS (REUSED FROM DPR) ---

  Widget _buildProgressSection() {
    return _buildSectionCard(
      "Progress",
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 35,
            width: double.infinity,
            decoration: BoxDecoration(color: const Color(0xFFB9D5FF), borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Container(
                  width: 120,
                  decoration: const BoxDecoration(color: Color(0xFF0D6EFD), borderRadius: BorderRadius.horizontal(left: Radius.circular(8))),
                ),
                Container(
                  width: 12,
                  decoration: const BoxDecoration(color: Color(0xFF00A67E), borderRadius: BorderRadius.horizontal(right: Radius.circular(8))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildTextWithBlueHighlight("Today Progress Added - ", "+1.5%"),
          const SizedBox(height: 4),
          _buildTextWithBlueHighlight("Current Overall Progress - ", "29.5%"),
        ],
      ),
    );
  }

  Widget _buildTasksSection() {
    return _buildSectionCard(
      "Tasks",
      Column(
        children: [
          _buildTaskRow("Task Name", "4/4", "Completed", const Color(0xFF00A67E)),
          _buildTaskRow("Task Name", "2/3", "In Progress", const Color(0xFFE5B869)),
          _buildTaskRow("Task Name", "0/2", "Pending", const Color(0xFFFC3D39)),
        ],
      ),
      trailing: const Text("Subtasks", style: TextStyle(color: Color(0xFF0D6EFD), fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildMaterialsSection() {
    return _buildSectionCard(
      "Materials",
      Column(
        children: [
          _buildListRow("Name", "Quantity Used"),
          _buildListRow("Name", "Quantity Used"),
          _buildListRow("Name", "Quantity Used"),
        ],
      ),
    );
  }

  Widget _buildEquipmentsSection() {
    return _buildSectionCard(
      "Equipments",
      Column(
        children: [
          _buildEquipmentRow("Name", "Hrs used", "Fuel"),
          _buildEquipmentRow("Name", "Hrs used", "Fuel"),
          _buildEquipmentRow("Name", "Hrs used", "Fuel"),
        ],
      ),
    );
  }

  Widget _buildBudgetSection() {
    return _buildSectionCard(
      "Budget",
      Column(
        children: [
          _buildListRow("Labour", "₹1,20,000"),
          _buildListRow("Material", "₹40,000"),
          _buildListRow("Equipment", "₹25,000"),
          _buildListRow("Sub-contractor", "₹85,000"),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Total", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text("₹2,70,000", style: TextStyle(color: Color(0xFF0D6EFD), fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridSection(String title) {
    return _buildSectionCard(
      title,
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(3, (index) {
          return Container(width: 90, height: 90, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)));
        }),
      ),
    );
  }

  // --- REUSABLE ROW BUILDERS ---

  Widget _buildTaskRow(String title, String fraction, String status, Color badgeColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(title)),
          Expanded(flex: 1, child: Text(fraction, style: const TextStyle(color: Color(0xFF0D6EFD), fontSize: 12))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(6)),
            child: Text(status, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildListRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value, style: const TextStyle(color: Color(0xFF0D6EFD))),
        ],
      ),
    );
  }

  Widget _buildEquipmentRow(String title, String hrs, String fuel) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(title)),
          Expanded(flex: 1, child: Text(hrs, style: const TextStyle(color: Color(0xFF0D6EFD)))),
          Text(fuel, style: const TextStyle(color: Color(0xFF0D6EFD))),
        ],
      ),
    );
  }

  Widget _buildTextWithBlueHighlight(String baseText, String highlight) {
    return RichText(
      text: TextSpan(
        style: TextStyle(color: Colors.grey.shade800, fontSize: 13),
        children: [
          TextSpan(text: baseText),
          TextSpan(text: highlight, style: const TextStyle(color: Color(0xFF0D6EFD), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --- FIXED BOTTOM SECTION ---

  Widget _buildBottomActionArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, -4), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Reasons or Suggestions", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(
            controller: _reasonController,
            decoration: InputDecoration(
              hintText: "Enter the description",
              hintStyle: TextStyle(color: Colors.blue.shade200, fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF0D6EFD))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF0D6EFD), width: 1.5)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A67E),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: const Text("Approve", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFC3D39),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: const Text("Reject", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}