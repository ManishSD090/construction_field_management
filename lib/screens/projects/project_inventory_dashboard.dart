import 'package:construction_erp/screens/projects/project_inventory_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart'; // ✅ Added Dio import for error handling

import 'package:construction_erp/screens/inventory/purchase_order_list_screen.dart';
import 'package:construction_erp/controllers/inventory/inventory_controller.dart';
import 'package:construction_erp/controllers/finance/financial_controller.dart';
import 'package:construction_erp/models/budget.dart';

// A unified model to hold mixed activity data for the UI
class ActivityData {
  final String title;
  final String subtitle;
  final DateTime date;
  final IconData icon;
  final Color color;

  ActivityData({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.icon,
    required this.color,
  });
}

class ProjectInventoryDashboardScreen extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectInventoryDashboardScreen({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<ProjectInventoryDashboardScreen> createState() =>
      _ProjectInventoryDashboardScreenState();
}

class _ProjectInventoryDashboardScreenState
    extends ConsumerState<ProjectInventoryDashboardScreen> {
  // Brand Colors based on UI
  final Color primaryBlue = const Color(0xFF0D6EFD);
  final Color tealColor = const Color(0xFF00C4B4);
  final Color lightBlue = const Color(0xFFE8F1FF);

  // Currency formatter for Indian Rupees
  final currencyFormat =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  bool _isLoadingActivities = true;
  String? _activityError; // ✅ Track specific errors for recent activities
  List<ActivityData> _recentActivities = [];

  @override
  void initState() {
    super.initState();
    // Fetch the correct Project Inventory when this component mounts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(inventoryControllerProvider.notifier)
          .switchToProjectView(widget.projectId);
      _fetchRecentActivities();
    });
  }

  Future<void> _fetchRecentActivities() async {
    setState(() {
      _isLoadingActivities = true;
      _activityError = null;
    });

    try {
      final controller = ref.read(inventoryControllerProvider.notifier);

      // Fetch movements and low stock items in parallel for THIS specific project
      final results = await Future.wait([
        controller.getMovementReport(projectId: widget.projectId),
        controller.getLowStockReport(projectId: widget.projectId),
      ]);

      final movements = results[0] as List<dynamic>;
      final lowStockItems = results[1] as List<Map<String, dynamic>>;

      List<ActivityData> combined = [];

      // 1. Process Stock Movements
      for (var m in movements) {
        final type = m.transactionType?.toString() ?? 'UNKNOWN';
        final notes = m.notes?.toString() ?? 'Stock update';
        final date = m.createdAt as DateTime? ?? DateTime.now();

        combined.add(ActivityData(
          title: _getTitleForTransaction(type),
          subtitle: notes,
          date: date,
          icon: _getIconForTransaction(type),
          color: primaryBlue,
        ));
      }

      // 2. Process Low Stock Alerts
      for (var item in lowStockItems) {
        combined.add(ActivityData(
          title:
              "${item['status'].toString().replaceAll('_', ' ').split(' ').map((word) {
            if (word.isEmpty) return '';
            return word[0].toUpperCase() + word.substring(1).toLowerCase();
          }).join(' ')}: ${item['name']}",
          subtitle:
              "Available: ${item['currentStock']} ${item['unit']} (Min: ${item['minimumStock']})",
          date: DateTime.now(),
          icon: Icons.warning_amber_rounded,
          color: Colors.orange,
        ));
      }

      // Sort all activities descending by date
      combined.sort((a, b) => b.date.compareTo(a.date));

      if (mounted) {
        setState(() {
          _recentActivities = combined;
          _isLoadingActivities = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingActivities = false;
          _activityError = _parseErrorMessage(e); // ✅ Capture the error
        });
      }
    }
  }

  void _showAllActivitiesModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "All Activities & Alerts",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _recentActivities.isEmpty
                        ? const Center(
                            child: Text("No activities found.",
                                style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: _recentActivities.length,
                            itemBuilder: (context, index) {
                              final activity = _recentActivities[index];
                              return _buildActivityItem(
                                icon: activity.icon,
                                title: activity.title,
                                subtitle: activity.subtitle,
                                time: _timeAgo(activity.date),
                                iconColor: activity.color,
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final inventoryStateAsync = ref.watch(inventoryControllerProvider);
    final activeBudgetAsync =
        ref.watch(activeProjectBudgetProvider(widget.projectId));

    final bool isReloading =
        inventoryStateAsync.isLoading || inventoryStateAsync.isRefreshing;

    return inventoryStateAsync.when(
      skipLoadingOnReload: true,
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 40.0),
        child: Center(child: CircularProgressIndicator()),
      ),
      // ✅ Using the centralized beautiful error builder
      error: (error, stack) => _buildMainErrorState(error, isReloading),
      data: (state) {
        final summary = state.summary;
        final double equipValue =
            (summary['totalEquipmentValue'] ?? 0).toDouble();
        final double matValue = (summary['totalMaterialValue'] ?? 0).toDouble();
        final double totalValue = (summary['totalValue'] ?? 0).toDouble();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Refresh Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Inventory Overview",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                isReloading
                    ? Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: primaryBlue),
                        ),
                      )
                    : IconButton(
                        icon: Icon(Icons.refresh, color: primaryBlue),
                        onPressed: () {
                          ref
                              .read(inventoryControllerProvider.notifier)
                              .refresh();
                          _fetchRecentActivities();
                        },
                        tooltip: 'Refresh Dashboard',
                      ),
              ],
            ),
            const SizedBox(height: 8),

            // 1. Dynamic Inventory Summary Card
            _buildInventorySummaryCard(equipValue, matValue, totalValue),

            const SizedBox(height: 24),

            // 2. Budget Section
            _buildBudgetSection(activeBudgetAsync),

            const SizedBox(height: 24),

            // 3. Recent Activity Section
            _buildRecentActivitySection(),

            const SizedBox(height: 30),

            // 4. Primary Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PurchaseOrderListScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Make a Purchase Order",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  // --- Beautiful Main Error UI ---
  Widget _buildMainErrorState(Object error, bool isReloading) {
    String errorMessage = _parseErrorMessage(error);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 60.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getErrorIcon(error),
                size: 60,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Oops! Something went wrong",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.grey.shade600, fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: isReloading
                  ? null
                  : () {
                      ref.read(inventoryControllerProvider.notifier).refresh();
                      _fetchRecentActivities();
                    },
              icon: isReloading
                  ? Container(
                      width: 20,
                      height: 20,
                      padding: const EdgeInsets.all(2),
                      child: const CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.refresh, size: 20),
              label: Text(isReloading ? "Retrying..." : "Try Again"),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: primaryBlue.withOpacity(0.7),
                disabledForegroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
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
          return "Connection timed out. Please check your internet connection or make sure the server is running.";
        case DioExceptionType.connectionError:
          return "Unable to connect to the server. Please verify your network and server IP address.";
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final serverMessage = error.response?.data?['message'];
          return serverMessage ??
              "Server responded with an error ($statusCode). Please try again later.";
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

  // --- Widgets ---

  Widget _buildInventorySummaryCard(
      double equipValue, double matValue, double totalValue) {
    double equipPercent = totalValue > 0 ? (equipValue / totalValue) * 100 : 0;
    double matPercent = totalValue > 0 ? (matValue / totalValue) * 100 : 100;

    if (totalValue == 0) {
      equipPercent = 0;
      matPercent = 100;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            height: 120,
            width: 120,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(enabled: false),
                sectionsSpace: 0,
                centerSpaceRadius: 40,
                startDegreeOffset: -90,
                sections: [
                  PieChartSectionData(
                    color: totalValue > 0 ? tealColor : Colors.grey.shade300,
                    value: equipPercent,
                    title: '',
                    radius: 12,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    color: totalValue > 0 ? primaryBlue : Colors.grey.shade200,
                    value: matPercent,
                    title: '',
                    radius: 12,
                    showTitle: false,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLegendItem(
                    "Equipment", currencyFormat.format(equipValue), tealColor),
                const SizedBox(height: 4),
                _buildLegendItem(
                    "Material", currencyFormat.format(matValue), primaryBlue),
                const SizedBox(height: 8),
                Text(
                  "Inventory: ${currencyFormat.format(totalValue)}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProjectInventoryScreen(
                                  projectId: widget.projectId,
                                )),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("View Inventory",
                        style: TextStyle(fontSize: 12, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, String value, Color color) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 12, color: Colors.black87),
        children: [
          TextSpan(text: "$label: "),
          TextSpan(
            text: value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetSection(AsyncValue<Budget?> activeBudgetAsync) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Project Budget Summary",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const Divider(height: 24),
          activeBudgetAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            ),
            // ✅ Inline localized error state for budget
            error: (error, stack) => Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade100),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline,
                      color: Colors.red.shade400, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Failed to load budget. Pull down to refresh.",
                      style:
                          TextStyle(color: Colors.red.shade700, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            data: (budget) {
              if (budget == null) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    "No active budget assigned to this project.",
                    style: TextStyle(
                        color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                );
              }

              final double totalAmount = (budget.totalApproved ?? 0).toDouble();
              final double remainingAmount =
                  (budget.totalRemaining ?? totalAmount).toDouble();
              final double usedAmount = totalAmount - remainingAmount;

              final double usedPercent = totalAmount > 0
                  ? (usedAmount / totalAmount).clamp(0.0, 1.0)
                  : 0.0;
              final int flexUsed = (usedPercent * 100).toInt();
              final int flexRemaining = 100 - flexUsed;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 35,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCDE1FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        if (flexUsed > 0)
                          Expanded(
                            flex: flexUsed,
                            child: Container(
                              decoration: BoxDecoration(
                                color: primaryBlue,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        if (flexRemaining > 0)
                          Expanded(
                            flex: flexRemaining,
                            child: const SizedBox(),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Total Budget: ${currencyFormat.format(totalAmount)}",
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Used: ${currencyFormat.format(usedAmount)}",
                          style: const TextStyle(
                              fontSize: 13, color: Colors.black87)),
                      Text(
                          "Remaining: ${currencyFormat.format(remainingAmount)}",
                          style:
                              TextStyle(fontSize: 13, color: Colors.grey[700])),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Recent activity",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            TextButton(
              onPressed: _showAllActivitiesModal,
              child: Text("View all",
                  style: TextStyle(
                      color: primaryBlue, fontWeight: FontWeight.bold)),
            )
          ],
        ),
        const SizedBox(height: 8),
        if (_isLoadingActivities)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Center(child: CircularProgressIndicator()),
          )
        // ✅ Localized beautiful error state just for activities
        else if (_activityError != null)
          Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade100),
              ),
              child: Column(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.red.shade400, size: 32),
                  const SizedBox(height: 8),
                  Text(_activityError!,
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(color: Colors.red.shade700, fontSize: 13)),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _fetchRecentActivities,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text("Retry"),
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.red.shade700),
                  )
                ],
              ))
        else if (_recentActivities.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Center(
              child: Text("No recent activities found.",
                  style: TextStyle(color: Colors.grey)),
            ),
          )
        else
          ..._recentActivities.take(5).map((activity) {
            return _buildActivityItem(
              icon: activity.icon,
              title: activity.title,
              subtitle: activity.subtitle,
              time: _timeAgo(activity.date),
              iconColor: activity.color,
            );
          }),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    Color? iconColor,
  }) {
    final effectiveColor = iconColor ?? primaryBlue;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: effectiveColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: effectiveColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
        ],
      ),
    );
  }

  IconData _getIconForTransaction(String type) {
    if (type.contains('INIT') || type.contains('OPENING')) {
      return Icons.inventory_2_outlined;
    }
    if (type.contains('TRANSFER')) return Icons.compare_arrows;
    if (type.contains('CONSUMPTION') || type.contains('USED')) {
      return Icons.trending_down;
    }
    return Icons.assignment_outlined;
  }

  String _getTitleForTransaction(String type) {
    if (type == 'OPENING_STOCK') return "Opening Stock Added";
    if (type == 'PROJECT_INIT') return "Project Stock Initialized";
    if (type == 'TRANSFER_OUT') return "Stock Transferred Out";
    if (type == 'TRANSFER_IN') return "Stock Transferred In";

    return type.replaceAll('_', ' ').split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
