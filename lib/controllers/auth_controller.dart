import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import your existing files
import 'package:construction_erp/core/dio_client.dart';
import 'package:construction_erp/core/services/secure_storage_service.dart';
import 'package:construction_erp/database/database.dart';
import 'package:construction_erp/core/mappers/user_mapper.dart';
import 'package:construction_erp/models/user.dart';

// ==============================================================================
// PROVIDERS
// ==============================================================================

/// Dependency Injection
final dioClientProvider = Provider((ref) => DioClient());
final secureStorageProvider = Provider((ref) => SecureStorageService());
final databaseProvider = Provider((ref) => AppDatabase());

/// The Main Auth Controller
final authControllerProvider = AsyncNotifierProvider<AuthController, User?>(() {
  return AuthController();
});

// ==============================================================================
// CONTROLLER
// ==============================================================================

class AuthController extends AsyncNotifier<User?> {
  // Dependencies (Lazy loaded)
  DioClient get _dioClient => ref.read(dioClientProvider);
  SecureStorageService get _storage => ref.read(secureStorageProvider);
  AppDatabase get _db => ref.read(databaseProvider);

  /// 1. Initialization: Check for local session on app start
  @override
  Future<User?> build() async {
    // A. Check if we have a valid session token
    final hasSession = await _storage.hasSession();
    if (!hasSession) return null;

    // B. If yes, try to get the user from the local Offline DB
    final userEntity = await _db.getCurrentUser();

    // C. If local data exists, return it (Domain mapping required)
    if (userEntity != null) {
      return userEntity.toDomain();
    }

    // D. Edge case: Token exists but DB is empty? (Optional: Fetch profile from API)
    // For now, we force logout to be safe
    await logout();
    return null;
  }

  /// 2. Login Method
  Future<void> login(
      {required String identifier, required String password}) async {
    // Set state to loading
    state = const AsyncValue.loading();

    // Guard handles try/catch automatically
    state = await AsyncValue.guard(() async {
      // A. Call API
      final response = await _dioClient.dio.post('/auth/login', data: {
        'identifier': identifier,
        'password': password,
      });

      // B. Parse User (Domain Model) from Response
      // Assuming response structure: { "data": { "user": ..., "tokens" : { "accessToken": "...", "refreshToken": "..." } } }
      final data = response.data['data'];

      final userDomain = User.fromJson(data['user']);

      final accessToken = data['tokens']['accessToken'];
      final refreshToken = data['tokens']['refreshToken'];

      // C. Save Tokens Securely
      await _storage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      // D. Save User to Offline DB (Convert Domain -> Entity)
      // Note: We use the helper method _mapDomainToEntity defined below
      await _db.saveUserOnLogin(userDomain.toEntity());

      // E. Return the authenticated user to update the state
      return userDomain;
    });
  }

  /// 3. Logout Method
  Future<void> logout() async {
    // A. Clear Local DB
    await _db.logout();

    // B. Clear Secure Storage
    await _storage.deleteAll();

    // C. Reset State to null
    state = const AsyncValue.data(null);
  }
}
