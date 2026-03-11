import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'package:construction_erp/screens/inventory/inventory_screen.dart';
import 'package:construction_erp/screens/inventory/purchase_order_list_screen.dart';
import 'package:construction_erp/controllers/inventory/inventory_controller.dart'; // Adjust import path as needed

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

class InventoryDashboardScreen extends ConsumerStatefulWidget {
  const InventoryDashboardScreen({super.key});

  @override
  ConsumerState<InventoryDashboardScreen> createState() =>
      _InventoryDashboardScreenState();
}

class _InventoryDashboardScreenState
    extends ConsumerState<InventoryDashboardScreen> {
  // Brand Colors based on UI
  final Color primaryBlue = const Color(0xFF0D6EFD);
  final Color tealColor = const Color(0xFF00C4B4);
  final Color lightBlue = const Color(0xFFE8F1FF);

  // Currency formatter for Indian Rupees
  final currencyFormat =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  bool _isLoadingActivities = true;
  List<ActivityData> _recentActivities = [];

  @override
  void initState() {
    super.initState();
    // Fetch the correct Inventory when this component mounts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(inventoryControllerProvider.notifier).switchToGlobalView();
      _fetchRecentActivities();
    });
  }

  Future<void> _fetchRecentActivities() async {
    setState(() {
      _isLoadingActivities = true;
    });

    try {
      final controller = ref.read(inventoryControllerProvider.notifier);

      // Fetch movements and low stock items in parallel
      final results = await Future.wait([
        controller.getMovementReport(),
        controller.getLowStockReport(),
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

      // 2. Process Low Stock Alerts (Pin them to 'now' so they show at the top)
      for (var item in lowStockItems) {
        combined.add(ActivityData(
          title:
              "${item['status'].toString().replaceAll('_', ' ').split(' ').map((word) {
            if (word.isEmpty) return '';
            return word[0].toUpperCase() + word.substring(1).toLowerCase();
          }).join(' ')}: ${item['name']}",
          subtitle:
              "Available: ${item['currentStock']} ${item['unit']} (Min: ${item['minimumStock']})",
          date: DateTime.now(), // Display as "Just now" to keep attention on it
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
    // Watch the inventory state
    final inventoryStateAsync = ref.watch(inventoryControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Global Inventory",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Refresh action
              ref.read(inventoryControllerProvider.notifier).refresh();
              _fetchRecentActivities();
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
          )
        ],
      ),
      body: inventoryStateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text("Failed to load inventory:\n$error",
                  textAlign: TextAlign.center),
              TextButton(
                onPressed: () {
                  ref.read(inventoryControllerProvider.notifier).refresh();
                  _fetchRecentActivities();
                },
                child: const Text("Retry"),
              )
            ],
          ),
        ),
        data: (state) {
          // Extract dynamic summary values from the controller state
          final summary = state.summary;
          final double equipValue =
              (summary['totalEquipmentValue'] ?? 0).toDouble();
          final double matValue =
              (summary['totalMaterialValue'] ?? 0).toDouble();
          final double totalValue = (summary['totalValue'] ?? 0).toDouble();

          return RefreshIndicator(
            color: primaryBlue,
            onRefresh: () async {
              await ref.read(inventoryControllerProvider.notifier).refresh();
              await _fetchRecentActivities();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Dynamic Inventory Summary Card
                    _buildInventorySummaryCard(
                        equipValue, matValue, totalValue),

                    const SizedBox(height: 24),

                    // 2. Recent Activity Section (Dynamic)
                    _buildRecentActivitySection(),

                    const SizedBox(height: 30),

                    // 3. Primary Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const PurchaseOrderListScreen()),
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
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- Widgets ---

  Widget _buildInventorySummaryCard(
      double equipValue, double matValue, double totalValue) {
    // Calculate percentages for the pie chart
    double equipPercent = totalValue > 0 ? (equipValue / totalValue) * 100 : 0;
    double matPercent = totalValue > 0 ? (matValue / totalValue) * 100 : 100;

    // Provide default gray chart if everything is 0
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
          // Left: Dynamic Donut Chart
          SizedBox(
            height: 120,
            width: 120,
            child: PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 40,
                startDegreeOffset: -90,
                sections: [
                  // Equipment Segment (Teal)
                  PieChartSectionData(
                    color: totalValue > 0 ? tealColor : Colors.grey.shade300,
                    value: equipPercent,
                    title: '',
                    radius: 12,
                    showTitle: false,
                  ),
                  // Material Segment (Blue)
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
          // Right: Dynamic Details
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
                      // Navigate to Inventory List Screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const InventoryScreen()),
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

  // --- Helper Methods for Formatting Activity Data ---

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

    // Capitalize fallback words
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
