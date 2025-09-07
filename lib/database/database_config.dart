import 'dart:convert';
import 'dart:io';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseConfig {
  // MongoDB connection settings - now dynamic (empty by default, must load from JSON)
  static String _host = '';
  static int _port = 0;
  static String _databaseName = '';
  static String _username = '';
  static String _password = '';

  // Flag to check if configuration is loaded
  static bool _isConfigLoaded = false;

  // Local file path for configuration
  static String _localConfigPath = '';

  // Getters for configuration
  static String get host => _host;
  static int get port => _port;
  static String get databaseName => _databaseName;
  static String get username => _username;
  static String get password => _password;
  static bool get isConfigLoaded => _isConfigLoaded;
  static String get localConfigPath => _localConfigPath;

  // Save local config path to SharedPreferences
  static Future<void> saveLocalConfigPath(String filePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('local_config_path', filePath);
      _localConfigPath = filePath;
      print('Local config path saved: $filePath');
    } catch (e) {
      print('Error saving local config path: $e');
      rethrow;
    }
  }

  // Load local config path from SharedPreferences
  static Future<String?> loadLocalConfigPath() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final path = prefs.getString('local_config_path');
      if (path != null) {
        _localConfigPath = path;
        print('Local config path loaded: $path');
      }
      return path;
    } catch (e) {
      print('Error loading local config path: $e');
      return null;
    }
  }

  // Auto-load configuration from saved local path
  static Future<bool> autoLoadConfig() async {
    try {
      final savedPath = await loadLocalConfigPath();
      if (savedPath != null && savedPath.isNotEmpty) {
        final file = File(savedPath);
        if (await file.exists()) {
          await loadFromJsonFile(savedPath);
          print('Configuration auto-loaded from: $savedPath');
          return true;
        } else {
          print('Saved config file not found: $savedPath');
          return false;
        }
      } else {
        print('No local config path saved');
        return false;
      }
    } catch (e) {
      print('Error auto-loading configuration: $e');
      return false;
    }
  }

  // Load configuration from JSON file
  static Future<void> loadFromJsonFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final config = jsonDecode(jsonString) as Map<String, dynamic>;

        // Only use data from JSON file, no fallback to defaults
        _host = config['host']?.toString() ?? '';
        _port = int.tryParse(config['port']?.toString() ?? '') ?? 0;
        _databaseName = config['name']?.toString() ?? '';
        _username = config['username']?.toString() ?? '';
        _password = config['password']?.toString() ?? '';

        // Validate that required fields are loaded
        if (_host.isEmpty || _port == 0 || _databaseName.isEmpty) {
          throw Exception(
            'Invalid configuration: Missing required fields (host, port, name)',
          );
        }

        _isConfigLoaded = true;

        print('Database configuration loaded from: $filePath');
        print('Host: $_host, Port: $_port, Database: $_databaseName');
        print('Username: $_username');

        // Close existing connection to force reconnection with new config
        await closeDatabase();
      } else {
        print('Configuration file not found: $filePath');
        throw Exception('Configuration file not found: $filePath');
      }
    } catch (e) {
      print('Error loading configuration from file: $e');
      _isConfigLoaded = false;
      rethrow;
    }
  }

  // Initialize database connection with loaded configuration
  static Future<void> initializeWithConfig(String filePath) async {
    try {
      await loadFromJsonFile(filePath);
      // Save the local config path for future auto-loading
      await saveLocalConfigPath(filePath);
      // Test the connection
      await database;
      print(
        'Database initialized successfully with configuration from: $filePath',
      );
      print('Connection string: $connectionString');
    } catch (e) {
      print('Error initializing database with configuration: $e');
      rethrow;
    }
  }

  // Update configuration from config dialog
  static void updateConfig({
    required String host,
    required int port,
    required String databaseName,
    required String username,
    required String password,
  }) {
    _host = host;
    _port = port;
    _databaseName = databaseName;
    _username = username;
    _password = password;
    _isConfigLoaded = true;

    print('Database configuration updated:');
    print('Host: $_host, Port: $_port, Database: $_databaseName');
  }

  // Save current configuration to JSON file
  static Future<void> saveToJsonFile(String filePath) async {
    try {
      final config = {
        'host': _host,
        'port': _port,
        'name': _databaseName,
        'username': _username,
        'password': _password,
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(config);
      final file = File(filePath);
      await file.writeAsString(jsonString);

      print('Database configuration saved to: $filePath');
    } catch (e) {
      print('Error saving configuration to file: $e');
      rethrow;
    }
  }

  // Build connection string
  static String get connectionString {
    if (username.isNotEmpty && password.isNotEmpty) {
      return 'mongodb://$username:$password@$host:$port/$databaseName?authSource=admin';
    } else {
      return 'mongodb://$host:$port/$databaseName';
    }
  }

  // Alternative connection string with different auth source
  static String get connectionStringWithDbAuth {
    if (username.isNotEmpty && password.isNotEmpty) {
      return 'mongodb://$username:$password@$host:$port/$databaseName?authSource=$databaseName';
    } else {
      return 'mongodb://$host:$port/$databaseName';
    }
  }

  // Connection string without authentication
  static String get connectionStringNoAuth {
    return 'mongodb://$host:$port/$databaseName';
  }

  // Collection names
  static const String productsCollection = 'products';
  static const String categoriesCollection = 'categories';
  static const String suppliersCollection = 'suppliers';
  static const String subCategoriesCollection = 'sub_categories';
  static const String grnCollection = 'grn';
  static const String grnItemCollection = 'grn_item';
  static const String suspendGrnCollection = 'Suspend_grn';
  static const String cashiersCollection = 'cashiers';
  static const String brandsCollection = 'brands';

  // Database timeout settings
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration operationTimeout = Duration(seconds: 60);

  // Retry settings
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);

  // Database instance
  static Db? _db;

  // Get database connection
  static Future<Db> get database async {
    // Check if configuration is loaded
    if (!_isConfigLoaded) {
      throw Exception(
        'Database configuration not loaded. Please load a configuration file first.',
      );
    }

    if (_db == null || _db!.state != State.open) {
      try {
        // Try connecting with admin auth first
        _db = await Db.create(connectionString);
        if (_db!.state != State.open) {
          await _db!.open();
        }
        print(
          'Database connected successfully to: $host:$port/$databaseName (admin auth)',
        );
      } catch (e) {
        print('Admin auth failed, trying database auth: $e');
        try {
          // Try with database-specific auth
          _db = await Db.create(connectionStringWithDbAuth);
          if (_db!.state != State.open) {
            await _db!.open();
          }
          print(
            'Database connected successfully to: $host:$port/$databaseName (db auth)',
          );
        } catch (e2) {
          print('Database auth failed, trying no auth: $e2');
          try {
            // Try without authentication
            _db = await Db.create(connectionStringNoAuth);
            if (_db!.state != State.open) {
              await _db!.open();
            }
            print(
              'Database connected successfully to: $host:$port/$databaseName (no auth)',
            );
          } catch (e3) {
            print('All connection attempts failed: $e3');
            rethrow;
          }
        }
      }
    }
    return _db!;
  }

  // Get collections
  static Future<DbCollection> get suppliersDbCollection async {
    final db = await database;
    return db.collection(suppliersCollection);
  }

  static Future<DbCollection> get productsDbCollection async {
    final db = await database;
    return db.collection(productsCollection);
  }

  static Future<DbCollection> get categoriesDbCollection async {
    final db = await database;
    return db.collection(categoriesCollection);
  }

  static Future<DbCollection> get subCategoriesDbCollection async {
    final db = await database;
    return db.collection(subCategoriesCollection);
  }

  static Future<DbCollection> get grnDbCollection async {
    final db = await database;
    return db.collection(grnCollection);
  }

  static Future<DbCollection> get grnItemDbCollection async {
    final db = await database;
    return db.collection(grnItemCollection);
  }

  static Future<DbCollection> get suspendGrnDbCollection async {
    final db = await database;
    return db.collection(suspendGrnCollection);
  }

  static Future<DbCollection> get cashiersDbCollection async {
    final db = await database;
    return db.collection(cashiersCollection);
  }

  static Future<DbCollection> get brandsDbCollection async {
    final db = await database;
    return db.collection(brandsCollection);
  }

  // Close database connection
  static Future<void> closeDatabase() async {
    if (_db != null && _db!.state == State.open) {
      await _db!.close();
      _db = null;
    }
  }
}
