import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';

class NoInternetWidget extends StatelessWidget {
  final Widget child; // This is your actual app screen
  const NoInternetWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Keep the current screen in the background (blurred or dimmed)
          Opacity(opacity: 0.3, child: child),

          // The prompt
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi_off_rounded,
                      size: 64, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  const Text(
                    "Connection Lost",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Please check your internet settings to continue working.",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      // This opens the Wi-Fi settings directly
                      AppSettings.openAppSettings(type: AppSettingsType.wifi);
                    },
                    icon: const Icon(Icons.settings),
                    label: const Text("Open Network Settings"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
