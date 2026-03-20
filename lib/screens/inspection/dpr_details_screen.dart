import 'package:flutter/material.dart';

class DprDetailsScreen extends StatefulWidget {
  final String date;
  final String projectName;

  const DprDetailsScreen({
    super.key,
    required this.date,
    required this.projectName,
  });

  @override
  State<DprDetailsScreen> createState() => _DprDetailsScreenState();
}

class _DprDetailsScreenState extends State<DprDetailsScreen> {
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
        title: const Text("DPR Details", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                  
                  // Sections
                  _buildSectionCard("Description", const SizedBox(height: 40)), // Empty area as per design
                  _buildProgressSection(),
                  _buildTasksSection(),
                  _buildAttendanceSection(),
                  _buildMaterialsSection(),
                  _buildEquipmentsSection(),
                  _buildBudgetSection(),
                  _buildGridSection("Photos"),
                  _buildGridSection("Documents"),
                  _buildSectionCard("Issues", const SizedBox(height: 40)),
                  _buildSimpleTasksSection(),
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
        Text(widget.date.toUpperCase(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.projectName, style: const TextStyle(color: Color(0xFF0D6EFD), fontSize: 14, fontWeight: FontWeight.w500)),
            Text("Mumbai | ID-2341", style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Site Visitor: Name", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Row(
              children: [
                const Icon(Icons.wb_sunny_outlined, color: Color(0xFF0D6EFD), size: 18),
                const SizedBox(width: 4),
                const Text("Sunny", style: TextStyle(color: Color(0xFF0D6EFD), fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // --- REUSABLE CARD WRAPPER ---

  Widget _buildSectionCard(String title, Widget content, {Widget? trailing}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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

  // --- SPECIFIC SECTIONS ---

  Widget _buildProgressSection() {
    return _buildSectionCard(
      "Progress",
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Custom Two-Tone Progress Bar
          Container(
            height: 35,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFB9D5FF), // Light blue track
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 120, // Example width for progress
                  decoration: const BoxDecoration(
                    color: Color(0xFF0D6EFD), // Main progress
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
                  ),
                ),
                Container(
                  width: 12, // Small green tip indicating added progress
                  decoration: const BoxDecoration(
                    color: Color(0xFF00A67E), // Green tip
                    borderRadius: BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
                  ),
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

  Widget _buildAttendanceSection() {
    return _buildSectionCard(
      "Attendance",
      Column(
        children: [
          _buildListRow("Workers", "16/20"),
          _buildListRow("Staff", "6/10"),
          _buildListRow("Sub-Contractor", "4 workers"),
        ],
      ),
      trailing: const Text("22/30 Present", style: TextStyle(color: Color(0xFF0D6EFD), fontSize: 14, fontWeight: FontWeight.w600)),
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
          return Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSimpleTasksSection() {
    return _buildSectionCard(
      "Tasks",
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Padding(padding: EdgeInsets.symmetric(vertical: 4), child: Text("Name")),
          Padding(padding: EdgeInsets.symmetric(vertical: 4), child: Text("Name")),
          Padding(padding: EdgeInsets.symmetric(vertical: 4), child: Text("Name")),
        ],
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
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
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
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30), // Extra bottom padding for safe area
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          )
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
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF0D6EFD)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF0D6EFD), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement Approve Logic
                  },
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
                  onPressed: () {
                    // TODO: Implement Reject Logic
                  },
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