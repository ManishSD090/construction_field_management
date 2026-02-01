import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- IMPORTS ---
import '../../core/services/app_colors.dart';
import '../../widgets/super_admin/company_tile.dart';
import 'package:construction_erp/controllers/super_admin/super_admin_controller.dart';
import 'package:construction_erp/routes.dart'; // Ensure this points to your routes file

class CompaniesListTab extends ConsumerStatefulWidget {
  const CompaniesListTab({super.key});

  @override
  ConsumerState<CompaniesListTab> createState() => _CompaniesListTabState();
}

class _CompaniesListTabState extends ConsumerState<CompaniesListTab> {
  // Search Debounce Timer
  Timer? _debounce;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  /// Handles Search Input with a 500ms delay to reduce API calls
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref
          .read(superAdminControllerProvider.notifier)
          .searchAndRefresh(search: query);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Watch the Controller State
    final asyncState = ref.watch(superAdminControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.primaryBlue,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(28),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text("Companies",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ),
        centerTitle: false,
      ),

      // --- Floating Action Button (Add Company) ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // If you have a named route for create, use pushNamed.
          // Otherwise, standard push is fine for now.
          Navigator.pushNamed(context, AppRoutes.createCompany);
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
                borderRadius: BorderRadius.circular(23),
                border:
                    Border.all(color: const Color.fromARGB(255, 56, 56, 56)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged, // Hook up the debounce logic
                decoration: InputDecoration(
                  hintText: "Search Companies",
                  hintStyle:
                      TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  // Optional: Clear button
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : const Icon(Icons.mic, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // --- 2. Filter Button (Visual Only for now) ---
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // <--- Pushes items to edges
              children: [
                // 1. Title on the Left
                const Text(
                  "Companies List",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),

                // 2. Filter Button on the Right
                GestureDetector(
                  onTap: () {
                    // TODO: Show Filter BottomSheet
                    print("Filter Button Pressed");
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors
                          .white, // Added background color for clearer touch area
                      border: Border.all(color: AppColors.primaryBlue),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Filter",
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                        SizedBox(width: 4),
                        Icon(Icons.filter_list, size: 14, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // --- 3. Company List (With Riverpod State) ---
          Expanded(
            child: asyncState.when(
              // A. LOADING STATE (Initial Load)
              loading: () => const Center(child: CircularProgressIndicator()),

              // B. ERROR STATE
              error: (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Error loading companies",
                        style: TextStyle(color: Colors.red[700])),
                    TextButton(
                      onPressed: () =>
                          ref.refresh(superAdminControllerProvider),
                      child: const Text("Retry"),
                    )
                  ],
                ),
              ),

              // C. DATA STATE (List Loaded)
              data: (state) {
                if (state.companies.isEmpty) {
                  return const Center(child: Text("No companies found."));
                }

                // Infinite Scroll Listener
                return NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    // Trigger load more when user reaches 90% of the list
                    if (scrollInfo.metrics.pixels >=
                        scrollInfo.metrics.maxScrollExtent * 0.9) {
                      ref
                          .read(superAdminControllerProvider.notifier)
                          .loadNextPage();
                    }
                    return true;
                  },
                  child: RefreshIndicator(
                    onRefresh: () => ref
                        .read(superAdminControllerProvider.notifier)
                        .searchAndRefresh(search: _searchController.text),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      // Add +1 to count if we are loading more to show the spinner
                      itemCount: state.companies.length +
                          (state.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Show Bottom Spinner
                        if (index == state.companies.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final company = state.companies[index];
                        return CompanyTile(
                          company: company,
                          onTap: () {
                            // --- NAVIGATION USING APP ROUTES ---
                            Navigator.pushNamed(
                              context,
                              AppRoutes.companyDetails,
                              arguments: company, // Pass the object
                            );
                          },
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
