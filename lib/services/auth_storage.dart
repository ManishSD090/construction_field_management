import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const _phoneKey = 'phone';
  static const _passwordKey = 'password';
  static const _registeredKey = 'registered';

  /// Save user after OTP + password setup
  static Future<void> saveUser(String phone, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_phoneKey, phone);
    await prefs.setString(_passwordKey, password);
    await prefs.setBool(_registeredKey, true);
  }

  /// Check if the given phone number is registered
  static Future<bool> isRegistered(String phone) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_phoneKey) == phone &&
          (prefs.getBool(_registeredKey) ?? false);
    } catch (_) {
      return false;
    }
  }

  /// Verify login credentials
  static Future<bool> verifyPassword(String phone, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_phoneKey) == phone &&
          prefs.getString(_passwordKey) == password;
    } catch (_) {
      return false;
    }
  }

  /// Get saved phone number (used on app launch)
  static Future<String?> getSavedPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phoneKey);
  }

  /// Logout user
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
