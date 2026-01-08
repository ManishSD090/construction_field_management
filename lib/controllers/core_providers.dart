import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Import your services
import 'package:construction_erp/core/dio_client.dart';
import 'package:construction_erp/core/services/secure_storage_service.dart';
import 'package:construction_erp/database/database.dart';

// --- CORE INFRASTRUCTURE PROVIDERS ---

/// Global instance of DioClient for API calls
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

/// Global instance of Secure Storage
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

/// Global instance of the Drift Database
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

/// Global Stream for Connectivity (Online/Offline status)
final connectivityStreamProvider =
    StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});
