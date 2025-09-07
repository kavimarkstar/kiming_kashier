class LoaclDatabaseConfig {
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
}
