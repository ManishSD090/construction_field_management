import 'package:flutter/material.dart';
import '../../core/services/app_colors.dart';
import '../../widgets/super_admin/admin_stat_card.dart';
import '../../widgets/super_admin/system_alert_card.dart';
import './create_company.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Row 1: Active/Suspended & Donut Chart ---
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
    );
  }
}

class _CreateCompanySheet extends StatelessWidget {
  const _CreateCompanySheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                height: 5,
                width: 60,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 10),
              const Expanded(child: CreateCompanyScreen()),
            ],
          ),
        );
      },
    );
  }
}
