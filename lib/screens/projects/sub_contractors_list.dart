import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Added Riverpod
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/models/contractor.dart'; // Import your models
import 'package:construction_erp/controllers/subcontractor/subcontractor_controller.dart'; // Import your controller
import 'package:construction_erp/screens/projects/sub_contractor_details.dart';

class SubContractorsList extends ConsumerStatefulWidget {
  final String projectId; // Assuming you pass the current project ID
  const SubContractorsList({super.key, required this.projectId});

  @override
  ConsumerState<SubContractorsList> createState() => _SubContractorsListState();
}

class _SubContractorsListState extends ConsumerState<SubContractorsList> {
  // We'll use a Future to fetch the projects specific to this screen
  late Future<List<ContractorProject>> _projectsFuture;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  void _loadProjects() {
    // Calling the method from your SubcontractorController
    _projectsFuture = ref
        .read(subcontractorControllerProvider.notifier)
        .getContractorProjects(widget.projectId);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- 1. Search Bar ---
        _buildSearchBar(),

        const SizedBox(height: 20),

        // --- 2. Header Row ---
        _buildHeader(),

        const SizedBox(height: 15),

        // --- 3. List of Projects (Async) ---
        FutureBuilder<List<ContractorProject>>(
          future: _projectsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                  child: Text("No subcontractors found for this project."));
            }

            final projects = snapshot.data!;

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: projects.length,
              separatorBuilder: (context, index) => const SizedBox(height: 15),
              itemBuilder: (context, index) {
                return _buildSubContractorCard(projects[index]);
              },
            );
          },
        ),
      ],
    );
  }

  // Refactored Card to use ContractorProject Model
  Widget _buildSubContractorCard(ContractorProject project) {
    Color statusColor;
    // Mapping your TaskStatus enum/string to UI Colors
    switch (project.status.name.toLowerCase()) {
      case 'completed':
        statusColor = const Color(0xFF009688);
        break;
      case 'inprogress':
      case 'ongoing':
        statusColor = const Color(0xFFFFC107);
        break;
      default:
        statusColor = const Color(0xFFEF5350);
    }

    return InkWell(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => SubContractorDetailsScreen(),
        //   ),
        // );
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
              color: Colors.black.withOpacity(0.03),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        project.contractor?.name ??
                            '', // Using title from model
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          project.status.name.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _buildRichText("Work Type: ", project.workType.name),
                  const SizedBox(height: 4),
                  _buildRichText(
                      "Contract Amount: ", "₹${project.contractAmount}"),
                  const SizedBox(height: 4),
                  _buildRichText("Progress: ", "${project.progress}%"),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 40.0),
              child: Icon(Icons.arrow_forward, color: Colors.grey, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRichText(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 13, color: Colors.grey),
        children: [
          TextSpan(text: label),
          TextSpan(
            text: value,
            style: const TextStyle(
                color: AppColors.primaryBlue, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // --- Search Bar UI ---
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const TextField(
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: Colors.grey),
          hintText: "Search Sub Contractors",
          border: InputBorder.none,
        ),
      ),
    );
  }

  // --- Header UI ---
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Sub-contractors List",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            // Delete Icon Box

            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.alertRed,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.delete_outline,
                  color: Colors.white, size: 18),
            ),

            const SizedBox(width: 8),

            // Filter Chip

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Text("Filter By",
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  SizedBox(width: 4),
                  Icon(Icons.tune, size: 14)
                ],
              ),
            ),
          ],
        ),
        // IconButton(
        //   onPressed: _loadProjects, // Refresh button logic
        //   icon: const Icon(Icons.refresh, size: 20),
        // )
      ],
    );
  }
}
