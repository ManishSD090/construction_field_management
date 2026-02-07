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
import 'package:construction_erp/models/auth_status.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, User?>(() {
  return AuthController();
});

final authStatusProvider = StateProvider<AuthActionStatus?>((ref) => null);

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
        // 1. Sync User Profile
        final user = await fetchAndSyncProfile();

        // 2. Check Status
        await _fetchAuthStatus(identifier: user.phone);

        return user;
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

  // ============================================================================
  // PASSWORD LOGIN
  // ============================================================================

  Future<void> loginWithPassword(
      {required String identifier, required String password}) async {
    state = const AsyncValue.loading();

    // 1. Perform Login & Save Session
    state = await AsyncValue.guard(() async {
      final response = await _dioClient.dio.post('/auth/login', data: {
        'identifier': identifier,
        'password': password,
      });

      final user = await _handleAuthResponse(response.data);

      // 2. Immediately check status after login
      await _fetchAuthStatus(identifier: identifier);

      return user;
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

      final user = await _handleAuthResponse(response.data);

      // Check status immediately
      await _fetchAuthStatus(identifier: identifier);

      return user;
    });
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

  Future<AuthActionStatus> checkStatus({required String identifier}) async {
    return _fetchAuthStatus(identifier: identifier);
  }

  // ============================================================================
  // VERIFICATION & SETUP FLOWS (Refactored for Node.js Backend)
  // ============================================================================

  /// 1. Request OTP
  /// [method] should be 'email' or 'phone'
  Future<void> requestVerificationOtp({required String method}) async {
    // 1. Get current user to find the correct identifier
    final user = state.value;
    if (user == null) throw Exception("User must be logged in to request OTP");

    final identifier = method == 'email' ? user.email : user.phone;

    if (identifier == null || identifier.isEmpty) {
      throw Exception("No $method found for this user.");
    }

    // 2. Call Backend
    await _dioClient.dio.post('/verification/request-otp', data: {
      'identifier': identifier,
    });
  }

  /// 2. Verify OTP
  /// Maps 'email'/'phone' to the specific Backend TYPE strings
  Future<void> submitVerificationOtp(
      {required String otp, required String method // 'email' or 'phone'
      }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final user = state.value;
      if (user == null) throw Exception("User not found");

      final identifier = method == 'email' ? user.email : user.phone;

      // MAP method to Backend Enum Strings
      final verificationType =
          method == 'email' ? 'EMAIL_VERIFICATION' : 'PHONE_VERIFICATION';

      await _dioClient.dio.post('/verification/verify-otp', data: {
        'identifier': identifier,
        'otp': otp,
        'type': verificationType, // Crucial for your backend switch case
      });

      // 3. Refresh Profile & Status to update UI
      final updatedUser = await fetchAndSyncProfile();
      await _fetchAuthStatus(identifier: identifier!);

      return updatedUser;
    });
  }

  /// 3. Complete Account Setup (Set Password)
  Future<void> completeSetup({required String password}) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final user = state.value;
      if (user == null) throw Exception("User not found");

      // Use email as default identifier, fallback to phone
      final identifier = user.email ?? user.phone;

      await _dioClient.dio.post('/verification/complete-setup', data: {
        'identifier': identifier,
        'password': password,
        // Note: confirmPassword is handled in UI validation, not sent to backend
      });

      // 3. Refresh Profile & Status
      final updatedUser = await fetchAndSyncProfile();
      await _fetchAuthStatus(identifier: identifier);

      return updatedUser;
    });
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dioClient.dio.post('/auth/change-password', data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
    } catch (e) {
      // We rethrow the error so the UI can show "Incorrect Password" etc.
      rethrow;
    }
  }

  /// Updates the local user state manually (used after profile updates)
  void updateLocalUser(User user) {
    state = AsyncValue.data(user);
    // Also update the local database so it's persistent offline
    _db.saveUserOnLogin(user.toEntity());
  }

  // ============================================================================
  // HELPERS
  // ============================================================================

  /// Helper: Fetch profile, update DB, return Domain User
  Future<User> fetchAndSyncProfile() async {
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
      final updatedUser = await fetchAndSyncProfile();
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

  Future<AuthActionStatus> _fetchAuthStatus(
      {required String identifier}) async {
    try {
      final response = await _dioClient.dio
          .post('/auth/check-status', data: {'identifier': identifier});
      final status = AuthActionStatus.fromJson(response.data);

      // Update the separate provider
      ref.read(authStatusProvider.notifier).state = status;

      return status;
    } catch (e) {
      // If check fails, we assume no blocks (or handle error)
      return AuthActionStatus(
          needsPassword: false,
          needsVerification: false,
          emailVerified: true,
          phoneVerified: true,
          accountStatus: 'ACTIVE');
    }
  }
}
