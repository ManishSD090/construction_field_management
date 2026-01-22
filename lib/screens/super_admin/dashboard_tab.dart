import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/app_colors.dart';
import '../../widgets/super_admin/admin_stat_card.dart';
import '../../widgets/super_admin/system_alert_card.dart';
import 'package:construction_erp/controllers/auth/auth_controller.dart';

class DashboardTab extends ConsumerWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.value;
    bool showNotification = true;
    // 2. Extract Data (Safely handle nulls)
    // Adjust 'fullname' or 'name' based on your exact User model property
    final displayName = user?.name ?? 'Super Admin';
    final displayRole = user?.role?.name ?? 'Super Admin';
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppBar(
            backgroundColor: AppColors.primaryBlue,
            elevation: 0,
            toolbarHeight: 92,
            automaticallyImplyLeading: false, // removes back arrow

            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(28),
              ),
            ),

            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "WELCOME BACK,",
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(height: 2),
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  displayRole,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ],
            ),

            actions: [
              if (showNotification)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: IconButton(
                    icon: const Icon(Icons.notifications_none_rounded,
                        color: Colors.white),
                    onPressed: () {},
                  ),
                ),
            ],
          ),

          // --- Row 1: Active/Suspended & Donut Chart ---
          Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column: Active & Suspended Cards (Horizontal Layout)
                    const Expanded(
                      flex: 4,
                      child: const Column(
                        children: const [
                          AdminStatCard(
                            label: "Active\nCompanies",
                            value: "200",
                            valueColor: AppColors.primaryBlue,
                            isHorizontal: true, // Text Left, Number Right
                          ),
                          SizedBox(height: 16),
                          AdminStatCard(
                            label: "Suspended\nCompanies",
                            value: "34",
                            valueColor: AppColors.alertRed,
                            isHorizontal: true, // Text Left, Number Right
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Right Column: Donut Chart
                    Expanded(
                      flex: 5,
                      child: Container(
                        height: 147, // Matches height of two cards + gap
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 110,
                              width: 110,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  CircularProgressIndicator(
                                    value: 1.0,
                                    color: AppColors.primaryBlue,
                                    strokeWidth: 10,
                                  ),
                                  CircularProgressIndicator(
                                    value: 0.15,
                                    color: AppColors.alertRed,
                                    strokeWidth: 10,
                                    strokeCap: StrokeCap.round,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "234",
                                        style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        "Total\nCompanies",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 9, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // --- Row 2 ---
                const Row(
                  children: [
                    Expanded(
                      child: AdminStatCard(
                        label: "Total users",
                        value: "1,362",
                        isHorizontal: false,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: AdminStatCard(
                        label: "Active projects",
                        value: "312",
                        isHorizontal: false,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // --- Revenue Banner ---
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryBlue),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total revenue (this month)",
                          style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                      Text("₹4,80,000",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue)),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // --- Alerts ---
                SystemAlertCard(
                  alerts: const [
                    "2 companies nearing plan expiry",
                    "1 company suspended today",
                  ],
                  onViewAll: () {},
                ),

                const SizedBox(height: 20),
              ],
            ),
          )
        ],
      ),
    );
  }
}
