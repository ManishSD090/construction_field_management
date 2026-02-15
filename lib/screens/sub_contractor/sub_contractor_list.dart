import 'package:construction_erp/routes.dart';
import 'package:construction_erp/screens/sub_contractor/create_sub_contractor.dart';
import 'package:construction_erp/screens/sub_contractor/sub_contractor_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/controllers/subcontractor/subcontractor_controller.dart';
import 'package:construction_erp/models/contractor.dart';
// import 'package:construction_erp/screens/subcontractor/subcontractor_details.dart';

class SubcontractorListScreen extends ConsumerStatefulWidget {
  const SubcontractorListScreen({super.key});

  @override
  ConsumerState<SubcontractorListScreen> createState() =>
      _SubcontractorListScreenState();
}

class _SubcontractorListScreenState
    extends ConsumerState<SubcontractorListScreen> {
  final ScrollController _scrollController = ScrollController();

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subState = ref.watch(subcontractorControllerProvider);

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
      body: subState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (state) {
          if (state.subcontractors.isEmpty) {
            return const Center(child: Text("No subcontractors found."));
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(subcontractorControllerProvider.notifier).refresh(),
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildSearchBar(ref),
                    const SizedBox(height: 25),
                    _buildListHeader(),
                    const SizedBox(height: 15),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.subcontractors.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 15),
                      itemBuilder: (context, index) {
                        return _SubcontractorCard(
                            contractor: state.subcontractors[index]);
                      },
                    ),
                    if (state.isLoadingMore)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: CircularProgressIndicator(),
                      ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          );
        },
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

  Widget _buildSearchBar(WidgetRef ref) {
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
        textAlignVertical: TextAlignVertical.center,
        onChanged: (value) {
          ref
              .read(subcontractorControllerProvider.notifier)
              .refresh(search: value);
        },
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
}

class _SubcontractorCard extends StatelessWidget {
  final Contractor contractor;

  const _SubcontractorCard({required this.contractor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigating to details.
        // Note: SubContractorDetailsScreen usually expects a contractorProjectId.
        // If you are viewing a general profile, you may need a different route.
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
                    contractor.name[0].toUpperCase(),
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
                        contractor.workTypes
                            .map((e) =>
                                e.name[0].toUpperCase() + e.name.substring(1))
                            .join(", "),
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
                    // _buildStatusTag(contractor.isBlacklisted),
                  ],
                ),
                // ✅ Right arrow added beside the info/status section
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

  Widget _buildStatusTag(bool isBlacklisted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: isBlacklisted
            ? AppColors.alertRed.withOpacity(0.1)
            : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isBlacklisted ? "BLACKLISTED" : "ACTIVE",
        style: TextStyle(
          color: isBlacklisted ? AppColors.alertRed : Colors.green,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
