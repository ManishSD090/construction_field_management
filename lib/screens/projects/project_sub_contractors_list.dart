import 'dart:async'; // ✅ Added for Timer (Debounce)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart'; // ✅ Added Dio import for error handling

import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/models/contractor.dart';
import 'package:construction_erp/controllers/subcontractor/subcontractor_controller.dart';
import 'package:construction_erp/screens/projects/project_sub_contractor_details.dart';

class ProjectSubContractorsList extends ConsumerStatefulWidget {
  final String projectId;
  const ProjectSubContractorsList({super.key, required this.projectId});

  @override
  ConsumerState<ProjectSubContractorsList> createState() =>
      _ProjectSubContractorsListState();
}

class _ProjectSubContractorsListState
    extends ConsumerState<ProjectSubContractorsList> {
  late Future<List<ContractorProject>> _projectsFuture;

  bool _isSearchLoading = false;
  bool _isRefreshLoading = false;
  Timer? _debounce;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _projectsFuture = _fetchProjects();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<List<ContractorProject>> _fetchProjects({String search = ''}) {
    return ref
        .read(subcontractorControllerProvider.notifier)
        .getContractorProjectsByProjectId(widget.projectId, search: search);
  }

  Future<void> _refreshData({String? search, bool isSearch = false}) async {
    if (search != null) {
      _searchQuery = search;
    }

    setState(() {
      if (isSearch) {
        _isSearchLoading = true;
        _isRefreshLoading = false;
      } else {
        _isRefreshLoading = true;
        _isSearchLoading = false;
      }
      _projectsFuture = _fetchProjects(search: _searchQuery);
    });

    try {
      await _projectsFuture;
    } catch (_) {
      // Ignored here, FutureBuilder handles the UI display of the error
    } finally {
      if (mounted) {
        setState(() {
          _isSearchLoading = false;
          _isRefreshLoading = false;
        });
      }
    }
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

        // ✅ Top Loading Indicator strictly for searches
        if (_isSearchLoading)
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

        // --- 3. List of Projects (Async) ---
        FutureBuilder<List<ContractorProject>>(
          future: _projectsFuture,
          builder: (context, snapshot) {
            // Show big spinner ONLY on initial load when there is no data
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryBlue)),
              );
            }

            if (snapshot.hasError &&
                (snapshot.data == null || snapshot.data!.isEmpty)) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: _buildErrorState(snapshot.error!),
              );
            }

            final projects = snapshot.data ?? [];

            if (projects.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: _buildEmptyState(),
              );
            }

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

  // --- Search Bar UI ---
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: TextField(
        textAlignVertical: TextAlignVertical.center,
        onChanged: (value) {
          // ✅ Debounce Logic: Wait 500ms after the user stops typing
          if (_debounce?.isActive ?? false) _debounce!.cancel();
          _debounce = Timer(const Duration(milliseconds: 500), () {
            _refreshData(search: value, isSearch: true);
          });
        },
        decoration: const InputDecoration(
          icon: Icon(Icons.search, color: Colors.grey, size: 22),
          hintText: "Search Sub Contractors",
          hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
          border: InputBorder.none,
          isCollapsed: true,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
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
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark),
        ),
        Row(
          children: [
            // ✅ Rotating refresh button strictly for manual refresh
            _isRefreshLoading
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.primaryBlue),
                    ),
                  )
                : IconButton(
                    onPressed: () => _refreshData(isSearch: false),
                    icon: const Icon(Icons.refresh,
                        color: AppColors.primaryBlue, size: 20),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    tooltip: "Refresh List",
                  ),
            const SizedBox(width: 4),

            // Filter Chip
            InkWell(
              onTap: () {
                // Handle filter tap
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border:
                      Border.all(color: AppColors.primaryBlue.withOpacity(0.6)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Text("Filter",
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark)),
                    const SizedBox(width: 4),
                    Icon(Icons.tune,
                        size: 14, color: AppColors.primaryBlue.withOpacity(0.8))
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- Card UI ---
  Widget _buildSubContractorCard(ContractorProject project) {
    Color statusColor;
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectSubContractorDetailsScreen(
              contractorProjectId: project.id,
            ),
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
                      Expanded(
                        child: Text(
                          project.contractor?.name ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
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
                  _buildRichText("Contractor Type: ",
                      project.contractor?.type.name.toUpperCase() ?? ''),
                  const SizedBox(height: 4),
                  _buildRichText(
                      "Work Type: ", project.workType.name.toUpperCase()),
                  const SizedBox(height: 4),
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

  // --- Beautiful Error State ---
  Widget _buildErrorState(Object error) {
    String errorMessage = _parseErrorMessage(error);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
            onPressed: (_isSearchLoading || _isRefreshLoading)
                ? null
                : () => _refreshData(isSearch: false),
            icon: _isRefreshLoading
                ? Container(
                    width: 16,
                    height: 16,
                    padding: const EdgeInsets.all(2),
                    child: const CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.refresh, size: 18),
            label: Text(_isRefreshLoading ? "Retrying..." : "Try Again"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.primaryBlue.withOpacity(0.7),
              disabledForegroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
          ),
        ],
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
          Text("No sub-contractors found",
              style: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
              _searchQuery.isNotEmpty
                  ? "Try adjusting your search terms."
                  : "Add a new sub-contractor to this project.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
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
