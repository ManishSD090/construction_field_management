import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_erp/controllers/auth/auth_controller.dart';
import 'package:construction_erp/controllers/admin/dashboard_controller.dart';
import 'package:construction_erp/routes.dart';
import 'package:construction_erp/models/user.dart';
// ✅ Import the new screen
import 'package:construction_erp/screens/admin/approvals_screen.dart';
import 'package:construction_erp/screens/inventory/inventory_dashboard_screen.dart';
import 'package:construction_erp/screens/transactions/ledger_screen.dart';

class DashboardTab extends ConsumerWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.value;

    // Watch the dashboard controller provider
    final dashboardAsync = ref.watch(dashboardControllerProvider);

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(dashboardControllerProvider.notifier).refresh();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, ref, user),
            const SizedBox(height: 20),

            // Handle Loading, Error, and Data states
            dashboardAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stackTrace) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Error loading dashboard:\n$error',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
              data: (dashboardState) =>
                  _buildDashboardContent(context, dashboardState),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, DashboardState state) {
    final quickActions = state.summary?['quickActions'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Quick actions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 18),
              _buildQuickActionsGrid(context, quickActions),
            ],
          ),
        ),
        const SizedBox(height: 25),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recent activity",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to full activity feed if needed
                    },
                    child: const Text("View all",
                        style: TextStyle(color: Colors.blue)),
                  )
                ],
              ),
              const SizedBox(height: 10),
              _buildRecentActivityList(state.recentActivities),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, User? user) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
      decoration: const BoxDecoration(
        color: Color(0xFF0D6EFD),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("WELCOME BACK,",
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 5),
              Text(user?.name ?? "Loading...",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              Text(user?.role?.name ?? "Contractor",
                  style: const TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
          Stack(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications,
                    color: Colors.white, size: 28),
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                      color: Colors.red, shape: BoxShape.circle),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid(
      BuildContext context, Map<String, dynamic>? quickActions) {
    // Safely extract counts and labels, providing fallbacks if null
    final txCount = quickActions?['transactions']?['count']?.toString() ?? '0';
    final txLabel =
        quickActions?['transactions']?['unit']?.toString() ?? 'Requests';

    final invValue =
        quickActions?['inventory']?['formattedValue']?.toString() ?? '₹0';
    final invLabel =
        quickActions?['inventory']?['unit']?.toString() ?? 'Total Usage';

    final appCount = quickActions?['approvals']?['count']?.toString() ?? '0';
    final appLabel =
        quickActions?['approvals']?['unit']?.toString() ?? 'pending';

    final projCount = quickActions?['projects']?['count']?.toString() ?? '0';
    final projLabel =
        quickActions?['projects']?['unit']?.toString() ?? 'active';

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.3,
      children: [
        _buildActionCard(Icons.person_outline, Colors.blue[50]!, Colors.blue,
            "Transactions", "$txCount $txLabel", () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TransactionScreen()),
          );
        }),
        _buildActionCard(Icons.assignment_outlined, Colors.teal[50]!,
            Colors.teal, "Inventory", "$invValue $invLabel", () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const InventoryDashboardScreen()),
          );
        }),
        // ✅ CLICKABLE APPROVALS CARD
        _buildActionCard(Icons.description_outlined, Colors.orange[50]!,
            Colors.orange, "Approvals", "$appCount $appLabel", () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ApprovalsScreen()),
          );
        }),
        _buildActionCard(Icons.inventory_2_outlined, Colors.red[50]!,
            Colors.redAccent, "Projects", "$projCount $projLabel", () {
          Navigator.pushNamed(context, AppRoutes.home,
              arguments: HomeArguments.project);
        }),
      ],
    );
  }

  // ✅ Updated to accept `onTap`
  Widget _buildActionCard(IconData icon, Color bgColor, Color iconColor,
      String title, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const Spacer(),
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityList(List<dynamic> activities) {
    if (activities.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 30.0),
        child: Center(
          child: Text("No recent activities found.",
              style: TextStyle(color: Colors.grey, fontSize: 15)),
        ),
      );
    }

    return Column(
      children: activities.map((activity) {
        final type = activity['type'] as String? ?? '';
        final title = activity['title'] as String? ?? 'Unknown Activity';
        final subtitle = activity['description'] as String? ?? '';
        final timestampStr = activity['timestamp'] as String? ?? '';
        final projectName =
            activity['projectName'] as String? ?? 'Unknown Project';

        // Setup Icon and Color based on Backend activity Type
        IconData icon = Icons.info_outline;
        Color color = Colors.grey;

        switch (type) {
          case 'TASK_COMPLETED':
            icon = Icons.assignment_turned_in;
            color = Colors.blue;
            break;
          case 'DPR_SUBMITTED':
            icon = Icons.book;
            color = Colors.green;
            break;
          case 'CHECK_IN':
            icon = Icons.check_circle_outline;
            color = Colors.orange;
            break;
          case 'TRANSACTION':
            icon = Icons.attach_money;
            color = Colors.purple;
            break;
          case 'MATERIAL_REQUEST':
            icon = Icons.inventory;
            color = Colors.redAccent;
            break;
        }

        // Parse timestamp and generate "time ago" string
        String timeAgo = "Just now";
        if (timestampStr.isNotEmpty) {
          try {
            final date = DateTime.parse(timestampStr);
            final difference = DateTime.now().difference(date);
            if (difference.inDays > 0) {
              timeAgo = "${difference.inDays} d ago";
            } else if (difference.inHours > 0) {
              timeAgo = "${difference.inHours} h ago";
            } else if (difference.inMinutes > 0) {
              timeAgo = "${difference.inMinutes} m ago";
            }
          } catch (e) {
            // Fallback if parsing fails
            timeAgo = timestampStr.split('T').first;
          }
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _buildActivityItem(
              icon, color, title, subtitle, timeAgo, projectName),
        );
      }).toList(),
    );
  }

  Widget _buildActivityItem(IconData icon, Color color, String title,
      String subtitle, String time, String projectName) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              spreadRadius: 1,
              blurRadius: 5),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 12, color: Colors.blueGrey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(projectName,
                          style: const TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
