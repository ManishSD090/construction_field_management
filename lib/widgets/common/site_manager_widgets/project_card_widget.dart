import 'package:flutter/material.dart';

class ProjectCardWidget extends StatelessWidget {
  final String title;
  final String id;
  final String location;
  final double progress; // 0.0 to 1.0
  final String status; // 'Ongoing', 'Completed', 'On Hold'

  const ProjectCardWidget({
    Key? key,
    required this.title,
    required this.id,
    required this.location,
    required this.progress,
    required this.status,
  }) : super(key: key);

  Color getStatusColor() {
    switch (status) {
      case 'Ongoing': return Colors.orange;
      case 'Completed': return Colors.green;
      case 'On Hold': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("$location | $id", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: getStatusColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(status, style: TextStyle(color: getStatusColor(), fontSize: 10, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Progress : ${(progress * 100).toInt()}%", style: const TextStyle(fontWeight: FontWeight.w600)),
              // Add priority icon/text here if needed
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            borderRadius: BorderRadius.circular(4),
            minHeight: 6,
          )
        ],
      ),
    );
  }
}