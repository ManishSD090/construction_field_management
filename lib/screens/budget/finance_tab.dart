import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'package:construction_erp/models/project.dart';
import 'package:construction_erp/models/budget.dart';
import 'package:construction_erp/models/enums.dart';

import 'package:construction_erp/controllers/finance/financial_controller.dart';

import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/screens/budget/budget_screen.dart';
import 'package:construction_erp/screens/budget/transaction_history_screen.dart';
import 'package:construction_erp/screens/budget/add_record_screen.dart';
import 'package:construction_erp/screens/budget/create_budget_screen.dart';

class ProjectFinancialsTab extends ConsumerWidget {
  final Project project;
  final bool isHeaderVisible;

  const ProjectFinancialsTab({
    super.key,
    required this.project,
    this.isHeaderVisible = false,
  });

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      symbol: '₹',
      locale: 'en_IN',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch ALL budgets for this project to check for Drafts/Pending as fallback
    final budgetsAsync = ref.watch(projectBudgetsProvider(project.id));

    return budgetsAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, stack) => Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Failed to load financials: $err',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () =>
                    ref.invalidate(projectBudgetsProvider(project.id)),
                icon: const Icon(Icons.refresh),
                label: const Text("Retry"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                ),
              )
            ],
          ),
        ),
      ),
      data: (budgets) {
        if (budgets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.folder,
                      size: 80,
                      color: AppColors.primaryBlue,
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      child: const Icon(
                        Icons.search,
                        size: 34,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  "Budget Not Found!",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 26),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CreateBudgetScreen(project: project),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      "Create Budget",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () =>
                      ref.invalidate(projectBudgetsProvider(project.id)),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text("Refresh"),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        }

        // Smart Selection: Try to find the active budget, otherwise fallback to the most recent one (Draft/Pending)
        final Budget budget = budgets.firstWhere(
          (b) => b.isActive || b.status == BudgetStatus.active,
          orElse: () => budgets.first,
        );

        final double spentVal = budget.totalSpent;
        final double committedVal = budget.totalCommitted;
        final double remainingVal =
            budget.totalRemaining > 0 ? budget.totalRemaining : 0;

        final bool isChartEmpty =
            spentVal == 0 && committedVal == 0 && remainingVal == 0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              // Row with status and Refresh Button
              Row(
                children: [
                  Expanded(child: _buildStatusBanner(budget.status)),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      ref.invalidate(projectBudgetsProvider(project.id));
                      ref.invalidate(projectCashboxProvider(project.id));
                      ref.invalidate(activeProjectBudgetProvider(project.id));
                    },
                    icon:
                        const Icon(Icons.refresh, color: AppColors.primaryBlue),
                    tooltip: "Refresh Financials",
                  ),
                ],
              ),

              // Top Approved Budget Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Total Approved Budget",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatCurrency(budget.totalApproved),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BudgetScreen(project: project),
                          ),
                        );
                      },
                      child: const Text(
                        "View Budget",
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Middle Section: Cards & Pie Chart
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        _buildBudgetCard(
                          title: "Total Expenses",
                          amount: _formatCurrency(budget.totalSpent),
                          color: AppColors.alertRed,
                        ),
                        const SizedBox(height: 12),
                        _buildBudgetCard(
                          title: "Available Balance",
                          amount: _formatCurrency(budget.totalRemaining),
                          color: AppColors.primaryBlue,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: SizedBox(
                      height: 160,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              sections: isChartEmpty
                                  ? [
                                      PieChartSectionData(
                                        color: Colors.grey.shade200,
                                        value: 100,
                                        radius: 12,
                                        showTitle: false,
                                      ),
                                    ]
                                  : [
                                      if (spentVal > 0)
                                        PieChartSectionData(
                                          color: AppColors.alertRed,
                                          value: spentVal,
                                          radius: 12,
                                          showTitle: false,
                                        ),
                                      if (committedVal > 0)
                                        PieChartSectionData(
                                          color: const Color(
                                              0xFF00C4B4), // Reserved
                                          value: committedVal,
                                          radius: 12,
                                          showTitle: false,
                                        ),
                                      if (remainingVal > 0)
                                        PieChartSectionData(
                                          color: AppColors.primaryBlue,
                                          value: remainingVal,
                                          radius: 12,
                                          showTitle: false,
                                        ),
                                    ],
                            ),
                          ),
                          if (isChartEmpty)
                            Text(
                              "No Data",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade400,
                              ),
                            ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),

              // View Transactions Link
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TransactionHistoryScreen(
                        budgetId: budget.id,
                        projectId: project.id,
                      ),
                    ),
                  );
                },
                child: const Text(
                  "View Transactions",
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Conditional Action Button
              if (!isHeaderVisible && budget.status == BudgetStatus.active)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddRecordScreen(
                                budgetId: budget.id,
                                initialType: RecordType.expense),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        "Add Record",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBanner(BudgetStatus status) {
    Color bgColor;
    Color textColor;
    String text;
    IconData icon;

    switch (status) {
      case BudgetStatus.active:
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        text = "Active Budget";
        icon = Icons.check_circle;
        break;
      case BudgetStatus.pendingApproval:
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade800;
        text = "Pending Approval";
        icon = Icons.hourglass_empty;
        break;
      case BudgetStatus.draft:
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
        text = "Draft Budget";
        icon = Icons.edit_document;
        break;
      case BudgetStatus.rejected:
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        text = "Budget Rejected";
        icon = Icons.cancel;
        break;
      default:
        bgColor = AppColors.primaryBlue.withOpacity(0.1);
        textColor = AppColors.primaryBlue;
        text = status.name.toUpperCase();
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 18),
          const SizedBox(width: 8),
          Text(
            "Showing: $text",
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard({
    required String title,
    required String amount,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        border: Border(left: BorderSide(color: color, width: 4)),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
