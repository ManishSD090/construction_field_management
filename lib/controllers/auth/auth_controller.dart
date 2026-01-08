import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart'; // Import Dio for exception handling

// Import your existing files
import 'package:construction_erp/controllers/core_providers.dart';
import 'package:construction_erp/core/dio_client.dart';
import 'package:construction_erp/core/services/secure_storage_service.dart';
import 'package:construction_erp/database/database.dart';
import 'package:construction_erp/core/mappers/user_mapper.dart';
import 'package:construction_erp/models/user.dart';
import 'package:construction_erp/models/permission.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, User?>(() {
  return AuthController();
});

// ==============================================================================
// CONTROLLER
// ==============================================================================

class AuthController extends AsyncNotifier<User?> {
  DioClient get _dioClient => ref.read(dioClientProvider);
  SecureStorageService get _storage => ref.read(secureStorageProvider);
  AppDatabase get _db => ref.read(databaseProvider);

  /// 1. Initialization
  @override
  Future<User?> build() async {
    // ----------------------------------------------------------------------
    //  LISTENER: Handle "Offline -> Online" transition
    // ----------------------------------------------------------------------
    ref.listen(connectivityStreamProvider, (previous, next) {
      next.whenData((results) {
        final isOnline = !results.contains(ConnectivityResult.none);

        if (isOnline && state.value != null) {
          print("Connection restored. Syncing profile in background...");
          _backgroundSync();
        }
      });
    });

    // ----------------------------------------------------------------------
    //  INITIAL LOAD
    // ----------------------------------------------------------------------
    final hasSession = await _storage.hasSession();
    if (!hasSession) return null;

    final connectivityResults = await Connectivity().checkConnectivity();
    final isOnline = !connectivityResults.contains(ConnectivityResult.none);

    // A. Online: Try to Sync
    if (isOnline) {
      try {
        return await _fetchAndSyncProfile();
      } catch (e) {
        // Server Down / Timeout / 401
        print(
            "Online sync failed (Server might be down). Falling back to local.");
        await _handleSyncError(e);
      }
    }

    // B. Fallback: Local DB
    final userEntity = await _db.getCurrentUser();
    if (userEntity != null) {
      final user = userEntity.toDomain();
      PermissionManager.initFromCodes(user.permissions ?? []);
      return user;
    }

    // C. No local data? Logout.
    await logout();
    return null;
  }

  /// Helper: Fetch profile, update DB, return Domain User
  Future<User> _fetchAndSyncProfile() async {
    final response = await _dioClient.dio.get('/auth/profile');
    final data = response.data['data'];
    final userDomain = User.fromJson(data['user'] ?? data);

    await _db.saveUserOnLogin(userDomain.toEntity());
    PermissionManager.initFromCodes(userDomain.permissions ?? []);

    return userDomain;
  }

  /// NEW: Syncs data without showing a loading spinner
  Future<void> _backgroundSync() async {
    try {
      final updatedUser = await _fetchAndSyncProfile();
      state = AsyncValue.data(updatedUser);
    } catch (e) {
      // Handle Token Expiry during background sync
      await _handleSyncError(e);
    }
  }

  /// NEW: Centralized Error Handler for Syncing
  Future<void> _handleSyncError(Object e) async {
    if (e is DioException) {
      // CASE A: SESSION EXPIRED (Critical)
      if (e.response?.statusCode == 401) {
        print("Critical: Session expired. Logging out.");
        await logout();
        return;
      }

      // CASE B: SERVER DOWN / TIMEOUT (Transient)
      // We explicitly identify these so we don't logout.
      final isServerIssue = e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError ||
          (e.response?.statusCode != null && e.response!.statusCode! >= 500);

      if (isServerIssue) {
        print("Server is unreachable. Using local data.");
        // DO NOT LOGOUT. Just return, allowing build() to load from DB.
        return;
      }
    }

    // Log unexpected errors
    print("Unexpected sync error: $e");
  }

  // ============================================================================
  // PASSWORD LOGIN
  // ============================================================================

  Future<void> loginWithPassword(
      {required String identifier, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final response = await _dioClient.dio.post('/auth/login', data: {
        'identifier': identifier,
        'password': password,
      });

      return _handleAuthResponse(response.data);
    });
  }

  // ============================================================================
  // OTP LOGIN
  // ============================================================================

  Future<void> requestLoginOtp({required String identifier}) async {
    await _dioClient.dio.post('/auth/login-with-otp', data: {
      'identifier': identifier,
    });
  }

  Future<void> verifyLoginOtp({
    required String identifier,
    required String otp,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final response =
          await _dioClient.dio.post('/auth/verify-otp-login', data: {
        'identifier': identifier,
        'otp': otp,
      });

      return _handleAuthResponse(response.data);
    });
  }

  // ============================================================================
  // HELPERS & LOGOUT
  // ============================================================================

  Future<User> _handleAuthResponse(Map<String, dynamic> data) async {
    final responseData = data['data'];

    final userDomain = User.fromJson(responseData['user']);
    final accessToken = responseData['tokens']['accessToken'];
    final refreshToken = responseData['tokens']['refreshToken'];

    await _storage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    await _db.saveUserOnLogin(userDomain.toEntity());
    PermissionManager.initFromCodes(userDomain.permissions ?? []);

    return userDomain;
  }

  /// 3. Logout Method
  Future<void> logout() async {
    // A. Check Connectivity
    final connectivityResults = await Connectivity().checkConnectivity();
    final isOnline = !connectivityResults.contains(ConnectivityResult.none);

    // B. Call API if Online
    if (isOnline) {
      try {
        final userId = state.value?.id;
        if (userId != null) {
          await _dioClient.dio.post('/auth/logout', data: {
            'userId': userId,
          });
          print('Logout API call successful');
        }
      } catch (e) {
        print('Logout API call failed: $e');
      }
    }

    // C. Local Logout (Always executes)
    PermissionManager.clear();
    await _db.logout();
    await _storage.deleteAll();

    // D. Reset State
    state = const AsyncValue.data(null);
  }
}
