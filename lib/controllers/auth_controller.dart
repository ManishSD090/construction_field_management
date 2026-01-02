import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Import your existing files
import 'package:construction_erp/core/dio_client.dart';
import 'package:construction_erp/core/services/secure_storage_service.dart';
import 'package:construction_erp/database/database.dart';
import 'package:construction_erp/core/mappers/user_mapper.dart';
import 'package:construction_erp/models/user.dart';

// ==============================================================================
// PROVIDERS
// ==============================================================================

final dioClientProvider = Provider((ref) => DioClient());
final secureStorageProvider = Provider((ref) => SecureStorageService());
final databaseProvider = Provider((ref) => AppDatabase());

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
    final hasSession = await _storage.hasSession();
    if (!hasSession) return null;

    final connectivityResults = await Connectivity().checkConnectivity();
    final isOnline = !connectivityResults.contains(ConnectivityResult.none);

    if (isOnline) {
      try {
        return await _fetchAndSyncProfile();
      } catch (e) {
        print('Sync failed: $e');
      }
    }

    final userEntity = await _db.getCurrentUser();
    if (userEntity != null) {
      return userEntity.toDomain();
    }

    await logout();
    return null;
  }

  /// Helper: Fetch profile, update DB, return Domain User
  Future<User> _fetchAndSyncProfile() async {
    final response = await _dioClient.dio.get('/auth/profile');
    final data = response.data['data'];
    final userDomain = User.fromJson(data['user'] ?? data);
    await _db.saveUserOnLogin(userDomain.toEntity());
    return userDomain;
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
  // OTP LOGIN (NEW)
  // ============================================================================

  /// Step 1: Request OTP
  /// This does NOT update the state (User is not logged in yet).
  /// Returns void on success, throws error on failure for UI to handle.
  Future<void> requestLoginOtp({required String identifier}) async {
    // We do not set state = loading here because this is usually an intermediate step
    // and we don't want to replace the global User state with null/loading yet.
    await _dioClient.dio.post('/auth/login-with-otp', data: {
      'identifier': identifier,
    });
  }

  /// Step 2: Verify OTP
  /// This performs the actual login and updates the state.
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

  /// Shared method to parse response, save tokens/DB, and return User
  Future<User> _handleAuthResponse(Map<String, dynamic> data) async {
    final responseData = data['data']; // Adjust based on your API wrapper

    // 1. Parse Data
    final userDomain = User.fromJson(responseData['user']);
    final accessToken = responseData['tokens']['accessToken'];
    final refreshToken = responseData['tokens']['refreshToken'];

    // 2. Save Secure Tokens
    await _storage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    // 3. Save User to Local DB
    await _db.saveUserOnLogin(userDomain.toEntity());

    return userDomain;
  }

  Future<void> logout() async {
    await _db.logout();
    await _storage.deleteAll();
    state = const AsyncValue.data(null);
  }
}
