import 'package:mongo_dart/mongo_dart.dart';

class LocalDatabaseConfig {
  static String get host => 'localhost';
  static int get port => 27017;
  static String get databaseName => 'kashier';
  static String get username => '';
  static String get password => '';

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

  // Get the brands collection
  static Future get brandsDbCollection async {
    final db = await Db.create(connectionStringNoAuth);
    await db.open();
    return db.collection('brands');
  }

  // Get the cashiers collection
  static Future get cashiersDbCollection async {
    final db = await Db.create(connectionStringNoAuth);
    await db.open();
    return db.collection('cashiers');
  }

  // Get the products collection
  static Future get productsDbCollection async {
    final db = await Db.create(connectionStringNoAuth);
    await db.open();
    return db.collection('products');
  }

  // Get the bills collection
  static Future get billsDbCollection async {
    final db = await Db.create(connectionStringNoAuth);
    await db.open();
    return db.collection('bills');
  }
}
