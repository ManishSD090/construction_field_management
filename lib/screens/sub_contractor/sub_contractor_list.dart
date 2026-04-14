import 'dart:async'; // ✅ Added for Timer (Debounce)
import 'package:construction_erp/screens/sub_contractor/create_sub_contractor.dart';
import 'package:construction_erp/screens/sub_contractor/sub_contractor_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart'; // ✅ Added Dio import for error handling

import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/controllers/subcontractor/subcontractor_controller.dart';
import 'package:construction_erp/models/contractor.dart';

class SubcontractorListScreen extends ConsumerStatefulWidget {
  const SubcontractorListScreen({super.key});

  @override
  ConsumerState<SubcontractorListScreen> createState() =>
      _SubcontractorListScreenState();
}

class _SubcontractorListScreenState
    extends ConsumerState<SubcontractorListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;
  bool _isSearchLoading = false; // ✅ Track local search state

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(subcontractorControllerProvider.notifier).loadNextPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // ✅ Handle Debounced Search
  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      setState(() => _isSearchLoading = true);
      await ref
          .read(subcontractorControllerProvider.notifier)
          .refresh(search: value);
      if (mounted) {
        setState(() => _isSearchLoading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final subStateAsync = ref.watch(subcontractorControllerProvider);
    final subState = subStateAsync.value;
    final contractors = subState?.subcontractors ?? [];

    final bool isReloading = _isSearchLoading ||
        subStateAsync.isLoading ||
        subStateAsync.isRefreshing;
    final bool showLinearLoader =
        _isSearchLoading || (isReloading && contractors.isNotEmpty);
    final bool isLoadingInitial =
        isReloading && contractors.isEmpty && !subStateAsync.hasError;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        title: const Text(
          "Sub-contractors",
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
      ),
      body: Column(
        children: [
          // ✅ MOVED OUTSIDE: Search Bar and Header are now permanently rendered
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: _buildSearchBar(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildListHeader(),
          ),

          // ✅ Top Loading Indicator for seamless searches/reloads
          if (showLinearLoader)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: LinearProgressIndicator(
                minHeight: 3,
                backgroundColor: AppColors.primaryBlue.withOpacity(0.15),
                color: AppColors.primaryBlue,
              ),
            )
          else
            const SizedBox(height: 15),

          // ✅ EXPANDED DATA SECTION
          Expanded(
            child: subStateAsync.when(
              skipLoadingOnReload: true, // Prevents screen wipe
              loading: () => const Center(
                  child:
                      CircularProgressIndicator(color: AppColors.primaryBlue)),
              error: (err, stack) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: _buildErrorState(err, isReloading),
              ),
              data: (state) {
                // Empty state handling
                if (state.subcontractors.isEmpty && !state.isLoadingMore) {
                  return RefreshIndicator(
                    color: AppColors.primaryBlue,
                    onRefresh: () => ref
                        .read(subcontractorControllerProvider.notifier)
                        .refresh(),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: _buildEmptyState(),
                        ),
                      ],
                    ),
                  );
                }

                // Standard List View
                return RefreshIndicator(
                  color: AppColors.primaryBlue,
                  onRefresh: () => ref
                      .read(subcontractorControllerProvider.notifier)
                      .refresh(),
                  child: ListView.separated(
                    controller: _scrollController,
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, bottom: 80),
                    physics: const AlwaysScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: state.subcontractors.length +
                        (state.isLoadingMore ? 1 : 0),
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 15),
                    itemBuilder: (context, index) {
                      if (index == state.subcontractors.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.primaryBlue)),
                        );
                      }
                      return _SubcontractorCard(
                          contractor: state.subcontractors[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const CreateSubContractorScreen();
          }));
        },
        backgroundColor: AppColors.primaryBlue,
        shape: const CircleBorder(),
        child: const Icon(Icons.person_add_alt_1,
            color: AppColors.white, size: 28),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        textAlignVertical: TextAlignVertical.center,
        onChanged: _onSearchChanged, // ✅ Uses debounced search
        decoration: const InputDecoration(
          hintText: "Search by name or trade...",
          hintStyle: TextStyle(color: AppColors.textGrey, fontSize: 16),
          icon: Icon(Icons.search, color: AppColors.textGrey, size: 20),
          border: InputBorder.none,
          isCollapsed: true,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildListHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Sub Contractors",
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark),
        ),
        OutlinedButton.icon(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textDark,
            side: const BorderSide(color: AppColors.lightGrey),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          icon: const Icon(Icons.tune, size: 18),
          label: const Text("Filter"),
        ),
      ],
    );
  }

  // --- Beautiful Error State ---
  Widget _buildErrorState(Object error, bool isReloading) {
    String errorMessage = _parseErrorMessage(error);

    return Center(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20.0),
        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getErrorIcon(error),
                size: 48,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Oops! Something went wrong",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.grey.shade600, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: isReloading
                  ? null
                  : () {
                      ref
                          .read(subcontractorControllerProvider.notifier)
                          .refresh();
                    },
              icon: isReloading
                  ? Container(
                      width: 16,
                      height: 16,
                      padding: const EdgeInsets.all(2),
                      child: const CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.refresh, size: 18),
              label: Text(isReloading ? "Retrying..." : "Try Again"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.primaryBlue.withOpacity(0.7),
                disabledForegroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Beautiful Empty State ---
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 50.0, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.engineering_outlined,
              size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text("No subcontractors found",
              style: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isNotEmpty
                ? "Try adjusting your search terms."
                : "Tap the + button to add a new subcontractor.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // --- Error Parsing Logic ---
  String _parseErrorMessage(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return "Connection timed out. Please check your internet connection.";
        case DioExceptionType.connectionError:
          return "Unable to connect to the server. Please verify your network.";
        case DioExceptionType.badResponse:
          final serverMessage = error.response?.data?['message'];
          return serverMessage ?? "Server error occurred. Please try again.";
        default:
          return "A network error occurred. Please try again.";
      }
    }
    return error.toString().replaceAll('Exception: ', '');
  }

  IconData _getErrorIcon(Object error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.connectionError) {
        return Icons.wifi_off_rounded;
      }
    }
    return Icons.error_outline_rounded;
  }
}

class _SubcontractorCard extends StatelessWidget {
  final Contractor contractor;

  const _SubcontractorCard({required this.contractor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SubcontractorDetailsScreen(subcontractorId: contractor.id),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                  child: Text(
                    contractor.name.isNotEmpty
                        ? contractor.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contractor.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        contractor.workTypes.isNotEmpty
                            ? contractor.workTypes
                                .map((e) =>
                                    e.name[0].toUpperCase() +
                                    e.name.substring(1))
                                .join(", ")
                            : "No Work Types Assigned",
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textGrey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _buildRatingBadge(contractor.rating.toString()),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildInfoChip(Icons.business_center, contractor.type.name),
                    const SizedBox(width: 10),
                  ],
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.textGrey,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRatingBadge(String rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 14),
          const SizedBox(width: 4),
          Text(rating,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.primaryBlue),
        const SizedBox(width: 6),
        Text(label.toUpperCase(),
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
