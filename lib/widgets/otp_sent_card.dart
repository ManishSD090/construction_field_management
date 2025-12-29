import 'package:flutter/material.dart';

class OtpSentCard extends StatelessWidget {
  const OtpSentCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        children: const [
          Text(
            "OTP Sent",
            style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12),
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.green,
            child:
                Icon(Icons.check, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }
}
