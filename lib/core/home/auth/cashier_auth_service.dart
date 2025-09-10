import 'package:kiming_kashier/Server/database/loacl_database.dart';
import 'package:mongo_dart/mongo_dart.dart';

class CashierAuthService {
  // Authenticate cashier with username and password
  static Future<Map<String, dynamic>?> authenticateCashier({
    required String username,
    required String password,
  }) async {
    try {
      final collection = await LocalDatabaseConfig.cashiersDbCollection;

      // Find cashier by username and password
      final cashier = await collection.findOne({
        'cashierUsername': username,
        'cashierPassword': password,
        'isActive': true, // Only allow active cashiers
      });

      if (cashier != null) {
        // Return cashier data without sensitive information
        return {
          '_id': cashier['_id'],
          'fullName': cashier['fullName'],
          'cashierUsername': cashier['cashierUsername'],
          'age': cashier['age'],
          'address': cashier['address'],
          'phoneNumber': cashier['phoneNumber'],
          'countryCode': cashier['countryCode'],
          'nicNumber': cashier['nicNumber'],
          'gender': cashier['gender'],
          'isActive': cashier['isActive'],
          'createdAt': cashier['createdAt'],
          'updatedAt': cashier['updatedAt'],
        };
      }

      return null; // Authentication failed
    } catch (e) {
      print('Error authenticating cashier: $e');
      throw Exception('Authentication failed: $e');
    }
  }

  // Check if cashier exists by username only
  static Future<bool> cashierExists(String username) async {
    try {
      final collection = await LocalDatabaseConfig.cashiersDbCollection;
      final cashier = await collection.findOne({
        'cashierUsername': username,
        'isActive': true,
      });
      return cashier != null;
    } catch (e) {
      print('Error checking cashier existence: $e');
      return false;
    }
  }

  // Get cashier by ID
  static Future<Map<String, dynamic>?> getCashierById(String id) async {
    try {
      final collection = await LocalDatabaseConfig.cashiersDbCollection;
      final cashier = await collection.findOne({
        '_id': ObjectId.fromHexString(id),
        'isActive': true,
      });

      if (cashier != null) {
        return {
          '_id': cashier['_id'],
          'fullName': cashier['fullName'],
          'cashierUsername': cashier['cashierUsername'],
          'age': cashier['age'],
          'address': cashier['address'],
          'phoneNumber': cashier['phoneNumber'],
          'countryCode': cashier['countryCode'],
          'nicNumber': cashier['nicNumber'],
          'gender': cashier['gender'],
          'isActive': cashier['isActive'],
          'createdAt': cashier['createdAt'],
          'updatedAt': cashier['updatedAt'],
        };
      }

      return null;
    } catch (e) {
      print('Error getting cashier by ID: $e');
      return null;
    }
  }
}
