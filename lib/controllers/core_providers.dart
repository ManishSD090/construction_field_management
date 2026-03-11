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

// Fetch Projects
final projectsProvider = FutureProvider<List<dynamic>>((ref) async {
  final dioClient = ref.watch(dioClientProvider);
  // Using your existing Dio instance from core_providers
  final response = await dioClient.dio.get('/projects');
  
  // Based on your backend structure: { success: true, data: [...] }
  return response.data['data'] as List<dynamic>;
});

// Fetch Materials (for the dynamic materials rows)
final materialsProvider = FutureProvider<List<dynamic>>((ref) async {
  final dioClient = ref.watch(dioClientProvider);
  final response = await dioClient.dio.get('/inventory'); // or your material endpoint
  return response.data['data'] as List<dynamic>;
});