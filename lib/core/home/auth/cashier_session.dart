import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class CashierSession {
  static const String _sessionKey = 'cashier_session';

  // Current logged-in cashier data
  static Map<String, dynamic>? _currentCashier;

  // Callback for session changes
  static VoidCallback? _onSessionChanged;

  // Getters
  static Map<String, dynamic>? get currentCashier => _currentCashier;
  static bool get isLoggedIn => _currentCashier != null;
  static String? get cashierName => _currentCashier?['fullName'];
  static String? get cashierUsername => _currentCashier?['cashierUsername'];
  static String? get cashierId => _currentCashier?['_id']?.toString();

  // Set callback for session changes
  static void setOnSessionChanged(VoidCallback? callback) {
    _onSessionChanged = callback;
  }

  // Notify session change
  static void _notifySessionChanged() {
    _onSessionChanged?.call();
  }

  // Set current cashier session
  static Future<void> setCashierSession(
    Map<String, dynamic> cashierData,
  ) async {
    try {
      _currentCashier = cashierData;

      // Save to SharedPreferences for persistence
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = jsonEncode(cashierData);
      await prefs.setString(_sessionKey, sessionJson);

      print('Cashier session saved: ${cashierData['fullName']}');

      // Notify session change
      _notifySessionChanged();
    } catch (e) {
      print('Error saving cashier session: $e');
    }
  }

  // Load cashier session from SharedPreferences
  static Future<void> loadCashierSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = prefs.getString(_sessionKey);

      if (sessionJson != null) {
        _currentCashier = jsonDecode(sessionJson);
        print('Cashier session loaded: ${_currentCashier?['fullName']}');
      }
    } catch (e) {
      print('Error loading cashier session: $e');
      _currentCashier = null;
    }
  }

  // Clear cashier session (logout)
  static Future<void> clearCashierSession() async {
    try {
      _currentCashier = null;

      // Remove from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);

      print('Cashier session cleared');

      // Notify session change
      _notifySessionChanged();
    } catch (e) {
      print('Error clearing cashier session: $e');
    }
  }

  // Check if session is valid (optional: add expiration check)
  static bool isSessionValid() {
    return _currentCashier != null && _currentCashier!['isActive'] == true;
  }

  // Logout method (alias for clearCashierSession)
  static Future<void> logout() async {
    await clearCashierSession();
  }
}
