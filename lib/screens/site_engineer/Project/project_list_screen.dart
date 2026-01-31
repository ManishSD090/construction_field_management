import 'package:flutter/material.dart';
import '../../../widgets/site_engineer/project_card_widget.dart';
import 'create_project_screen.dart';
import 'project_details_screen.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({Key? key}) : super(key: key);

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Project list", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false, // Hides back button if in bottom nav
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to Create Project Screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateProjectScreen()),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            
            // 1. Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: "Search Projects...",
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 2. Header & Filter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Project List",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Open Filter Modal
                  },
                  icon: const Icon(Icons.filter_list, size: 18, color: Colors.grey),
                  label: const Text("Filter", style: TextStyle(color: Colors.grey)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                )
              ],
            ),

            const SizedBox(height: 16),

            // 3. The List of Projects
            Expanded(
              child: ListView(
                children: [
                  // Item 1: Ongoing
                  GestureDetector(
                    onTap: () => _navigateToDetails(context, "ID-2341"),
                    child: const ProjectCardWidget(
                      title: "Site A - Residential Block",
                      id: "ID-2341",
                      location: "Mumbai",
                      progress: 0.5,
                      status: "Ongoing",
                    ),
                  ),
                  
                  // Item 2: Completed
                  GestureDetector(
                    onTap: () => _navigateToDetails(context, "ID-2342"),
                    child: const ProjectCardWidget(
                      title: "Site B - Commercial Hub",
                      id: "ID-2342",
                      location: "Pune",
                      progress: 1.0,
                      status: "Completed",
                    ),
                  ),

                  // Item 3: On Hold
                  GestureDetector(
                    onTap: () => _navigateToDetails(context, "ID-2343"),
                    child: const ProjectCardWidget(
                      title: "Site C - Warehouse",
                      id: "ID-2343",
                      location: "Nashik",
                      progress: 0.1,
                      status: "On Hold",
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetails(BuildContext context, String projectId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectDetailsScreen(projectId: projectId),
      ),
    );
  }
}