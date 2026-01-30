import 'package:flutter/material.dart';
import '../../widgets/common/site_manager_widgets/action_card.dart'; // Import your widget

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("WELCOME BACK,", style: TextStyle(color: Colors.white70, fontSize: 12)),
                        Text("Person Name", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        Text("Site Engineer", style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                    const Spacer(),
                    const Icon(Icons.notifications, color: Colors.white),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Quick Actions Grid
              const Text("Quick actions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                flex: 2, // Adjust flex based on screen size
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.4,
                  children: [
                    ActionCard(
                      title: "Attendance",
                      subtitle: "45/50",
                      icon: Icons.people_alt,
                      iconColor: Colors.blue,
                      onTap: () {},
                    ),
                    ActionCard(
                      title: "Tasks",
                      subtitle: "12/18 done",
                      icon: Icons.check_circle_outline,
                      iconColor: Colors.green,
                      onTap: () {},
                    ),
                    ActionCard(
                      title: "DPR",
                      subtitle: "20 submitted",
                      icon: Icons.assignment,
                      iconColor: Colors.orange,
                      onTap: () {},
                    ),
                    ActionCard(
                      title: "Projects",
                      subtitle: "3 active",
                      icon: Icons.apartment,
                      iconColor: Colors.purple,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              
              // Recent Activity Section (Simplified List)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Recent activity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(onPressed: () {}, child: const Text("View all")),
                ],
              ),
              Expanded(
                flex: 2,
                child: ListView(
                  children: const [
                     ListTile(
                       leading: Icon(Icons.check_box, color: Colors.blue),
                       title: Text("Task completed"),
                       subtitle: Text("Foundation work - Block A"),
                       trailing: Text("2h ago", style: TextStyle(color: Colors.grey, fontSize: 10)),
                     ),
                     ListTile(
                       leading: Icon(Icons.description, color: Colors.orange),
                       title: Text("DPR submitted"),
                       subtitle: Text("Daily progress report"),
                       trailing: Text("5h ago", style: TextStyle(color: Colors.grey, fontSize: 10)),
                     ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}