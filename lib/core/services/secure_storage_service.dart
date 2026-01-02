import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  // 1. Create the storage instance with platform-specific options
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      resetOnError: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  // 2. Define Keys
  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';

  // ===========================================================================
  // WRITE METHODS
  // ===========================================================================

  /// Save the auth tokens after a successful login
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
  }

  // ===========================================================================
  // READ METHODS
  // ===========================================================================

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  /// Check if user has a valid session token
  Future<bool> hasSession() async {
    final token = await getAccessToken();
    return token != null;
  }

  // ===========================================================================
  // DELETE METHODS (LOGOUT)
  // ===========================================================================

  /// Clear all sensitive data on logout
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}
