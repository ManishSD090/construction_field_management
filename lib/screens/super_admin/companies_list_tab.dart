import 'package:flutter/material.dart';
import '../../utilities/app_colors.dart';
import '../../widgets/super_admin/company_tile.dart';
import '../../models/company.dart'; // Ensure you have your Company model here
import 'create_company.dart';
import 'company_details.dart';

class CompaniesListTab extends StatefulWidget {
  const CompaniesListTab({super.key});

  @override
  State<CompaniesListTab> createState() => _CompaniesListTabState();
}

class _CompaniesListTabState extends State<CompaniesListTab> {
  // Dummy Data - Replace with API data later
  final List<Company> _companies = [
    Company(
      id: '1',
      name: 'ABC Infrastructure Pvt Ltd',
      isActive: true,
      createdAt: DateTime(2025, 8, 12),
      updatedAt: DateTime.now(),
      email: 'admin@abc.com',
    ),
    Company(
      id: '2',
      name: 'XYZ Builders',
      isActive: false, // Suspended
      createdAt: DateTime(2025, 8, 12),
      updatedAt: DateTime.now(),
      email: 'contact@xyzbuilders.com',
    ),
    Company(
      id: '3',
      name: 'LMN Constructions',
      isActive: true,
      createdAt: DateTime(2025, 8, 15),
      updatedAt: DateTime.now(),
      email: 'info@lmnconst.com',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // --- Floating Action Button (Add Company) ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const CreateCompanyScreen()),
          );
        },
        backgroundColor: AppColors.primaryBlue,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),

      body: Column(
        children: [
          // --- 1. Search Bar ---
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(23), // Rounded pill shape
                border: Border.all(color: const Color.fromARGB(255, 56, 56, 56)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search Companies",
                  hintStyle:
                      TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: const Icon(Icons.mic, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // --- 2. Filter Button ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primaryBlue),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text("Filter",
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    SizedBox(width: 4),
                    Icon(Icons.filter_list, size: 14, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // --- 3. Company List ---
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: _companies.length,
              itemBuilder: (context, index) {
                final company = _companies[index];
                return CompanyTile(
                  company: company,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CompanyDetailsScreen(company: company),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
