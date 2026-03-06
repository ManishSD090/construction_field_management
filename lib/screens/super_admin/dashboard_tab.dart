import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/widgets/super_admin/admin_stat_card.dart';
import 'package:construction_erp/widgets/super_admin/system_alert_card.dart';
import 'package:construction_erp/controllers/auth/auth_controller.dart';
import 'package:construction_erp/controllers/super_admin/super_admin_controller.dart';

class DashboardTab extends ConsumerWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch Auth State for Header
    final authState = ref.watch(authControllerProvider);
    final user = authState.value;
    final displayName = user?.name ?? 'Super Admin';
    final displayRole = user?.role?.name ?? 'Super Admin';

    // 2. Watch Dashboard Data Provider
    final dashboardAsync = ref.watch(superAdminDashboardProvider);

    return RefreshIndicator(
      onRefresh: () => ref.refresh(superAdminDashboardProvider.future),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(displayName, displayRole),
            dashboardAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.only(top: 100),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(child: Text("Error loading dashboard: $err")),
              ),
              data: (data) {
                final stats = data['stats'] as Map<String, dynamic>;
                final activities = data['recentActivities'] as List<dynamic>;

                final active = stats['activeCompanies'] ?? 0;
                final suspended = stats['suspendedCompanies'] ?? 0;
                final totalCompanies = active + suspended;
                final donutValue =
                    totalCompanies > 0 ? (suspended / totalCompanies) : 0.0;

                return Container(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Row 1: Active/Suspended & Donut Chart ---
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child: Column(
                              children: [
                                AdminStatCard(
                                  label: "Active\nCompanies",
                                  value: active.toString(),
                                  valueColor: AppColors.primaryBlue,
                                  isHorizontal: true,
                                ),
                                const SizedBox(height: 16),
                                AdminStatCard(
                                  label: "Suspended\nCompanies",
                                  value: suspended.toString(),
                                  valueColor: AppColors.alertRed,
                                  isHorizontal: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 5,
                            child: _buildDonutChart(totalCompanies, donutValue),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // --- Row 2: Users & Projects ---
                      Row(
                        children: [
                          Expanded(
                            child: AdminStatCard(
                              label: "Total users",
                              value: stats['totalUsers']?.toString() ?? "0",
                              isHorizontal: false,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AdminStatCard(
                              label: "Active projects",
                              value: stats['activeProjects']?.toString() ?? "0",
                              isHorizontal: false,
                            ),
                          ),
                        ],
                      ),

                      // const SizedBox(height: 16),

                      // // --- Revenue Banner (Still hardcoded if not in API) ---
                      // _buildRevenueBanner("₹4,80,000"),

                      const SizedBox(height: 24),

                      // --- Alerts (Now using dynamic activities) ---
                      SystemAlertCard(
                        alerts: activities
                            .take(10)
                            .map((a) => a['description'] as String)
                            .toList(),
                        onViewAll: () {
                          // Navigate to detailed activity log
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String name, String role) {
    return AppBar(
      backgroundColor: AppColors.primaryBlue,
      elevation: 0,
      toolbarHeight: 92,
      automaticallyImplyLeading: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("WELCOME BACK,",
              style: TextStyle(fontSize: 12, color: Colors.white70)),
          const SizedBox(height: 2),
          Text(name,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          Text(role,
              style: TextStyle(
                  fontSize: 13, color: Colors.white.withOpacity(0.85))),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: IconButton(
            icon: const Icon(Icons.notifications_none_rounded,
                color: Colors.white),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildDonutChart(int total, double percentSuspended) {
    return Container(
      height: 147,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 110,
            width: 110,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const CircularProgressIndicator(
                    value: 1.0, color: AppColors.primaryBlue, strokeWidth: 10),
                CircularProgressIndicator(
                  value: percentSuspended,
                  color: AppColors.alertRed,
                  strokeWidth: 10,
                  strokeCap: StrokeCap.round,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(total.toString(),
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const Text("Total\nCompanies",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 9, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
