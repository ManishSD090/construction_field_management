import 'package:flutter/material.dart';
import 'inspection_detail_screen.dart';

class ProjectListScreen extends StatelessWidget {
  const ProjectListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy Data for Phase 1
    final List<Map<String, String>> projects = [
      {
        "name": "Site A - Residential Block",
        "location": "Mumbai",
        "id": "ID-2341",
        "pending": "2"
      },
      {
        "name": "Site B - Residential Block",
        "location": "Pune",
        "id": "ID-2341",
        "pending": "2"
      },
      {
        "name": "Site C - Residential Block",
        "location": "Mumbai",
        "id": "ID-2312",
        "pending": "2"
      },
      {
        "name": "Site D - Residential Block",
        "location": "Delhi",
        "id": "ID-2341",
        "pending": "2"
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light grey background matches UI
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D6EFD),
        elevation: 0,
        centerTitle: false,
        title: const Text(
          "Inspection",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  hintText: "Search Projects",
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                  suffixIcon: Icon(Icons.mic, color: Colors.grey.shade600),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              "Project List",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Project Cards List
            Expanded(
              child: ListView.builder(
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  final project = projects[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: InkWell(
                      onTap: () {
                        // Navigate to the combined Detail Screen when tapped
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InspectionDetailScreen(
                                projectName: project['name']!),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project['name']!,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${project['location']} | ${project['id']}",
                              style: TextStyle(
                                  color: Colors.grey.shade500, fontSize: 13),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "${project['pending']} Pending Reports",
                              style: const TextStyle(
                                  color: Color(0xFF0D6EFD),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}