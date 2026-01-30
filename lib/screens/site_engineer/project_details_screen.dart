import 'package:flutter/material.dart';

class ProjectDetailsScreen extends StatelessWidget {
  final String projectId;
  
  const ProjectDetailsScreen({Key? key, required this.projectId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Project details", style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          bottom: const TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            isScrollable: true, // Allows tabs to fit on small screens
            tabs: [
              Tab(text: "Overview"),
              Tab(text: "Tasks"),
              Tab(text: "DPR"),
              Tab(text: "Attendance"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _OverviewTab(),
            Center(child: Text("Tasks List")),
            Center(child: Text("Daily Progress Reports")),
            Center(child: Text("Attendance Records")),
          ],
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Header Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Site A - Residential Block", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  IconButton(onPressed: (){}, icon: const Icon(Icons.edit, color: Colors.blue)),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statItem("₹ 42L / 80L", "Budget used"),
                  _statItem("124 Days", "Days Left"),
                  _statItem("18/30", "Tasks Done"),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Progress Ring
        const Center(
          child: const Stack(
            alignment: Alignment.center,
            children: [
              const SizedBox(
                width: 150, height: 150,
                child: CircularProgressIndicator(value: 0.75, strokeWidth: 12, backgroundColor: Colors.grey),
              ),
              const Column(
                children: const [
                  Text("75%", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Project Info
        const ListTile(
          leading: Icon(Icons.business),
          title: Text("Client: ABC Infrastructure Pvt Ltd"),
        ),
        const ListTile(
          leading: Icon(Icons.location_on),
          title: Text("Location: Andheri East, Mumbai"),
        ),
      ],
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}