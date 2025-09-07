import 'package:mongo_dart/mongo_dart.dart';
import '../database_config.dart';
import '../database/loacl_database.dart';

class DatabaseSyncService {
  // Source database (main configured database)
  static Db? _sourceDb;

  // Destination database (local database)
  static Db? _destinationDb;

  /// Get source database connection (main configured database)
  static Future<Db> get sourceDatabase async {
    if (_sourceDb == null || _sourceDb!.state != State.open) {
      try {
        _sourceDb = await DatabaseConfig.database;
        print('Source database connected successfully');
      } catch (e) {
        print('Error connecting to source database: $e');
        rethrow;
      }
    }
    return _sourceDb!;
  }

  /// Get destination database connection (local database)
  static Future<Db> get destinationDatabase async {
    if (_destinationDb == null || _destinationDb!.state != State.open) {
      try {
        // Try connecting with admin auth first
        _destinationDb = await Db.create(LoaclDatabaseConfig.connectionString);
        if (_destinationDb!.state != State.open) {
          await _destinationDb!.open();
        }
        print('Destination database connected successfully');
      } catch (e) {
        print('Admin auth failed for destination, trying database auth: $e');
        try {
          // Try with database-specific auth
          _destinationDb = await Db.create(
            LoaclDatabaseConfig.connectionStringWithDbAuth,
          );
          if (_destinationDb!.state != State.open) {
            await _destinationDb!.open();
          }
          print('Destination database connected successfully (db auth)');
        } catch (e2) {
          print('Database auth failed for destination, trying no auth: $e2');
          try {
            // Try without authentication
            _destinationDb = await Db.create(
              LoaclDatabaseConfig.connectionStringNoAuth,
            );
            if (_destinationDb!.state != State.open) {
              await _destinationDb!.open();
            }
            print('Destination database connected successfully (no auth)');
          } catch (e3) {
            print('All connection attempts failed for destination: $e3');
            rethrow;
          }
        }
      }
    }
    return _destinationDb!;
  }

  /// Load data from source database grn collection
  static Future<List<Map<String, dynamic>>> loadGrnDataFromSource() async {
    try {
      final sourceDb = await sourceDatabase;
      final grnCollection = sourceDb.collection(DatabaseConfig.grnCollection);

      // Find all documents in grn collection
      final cursor = await grnCollection.find();
      final documents = await cursor.toList();

      print('Loaded ${documents.length} documents from source grn collection');
      return documents;
    } catch (e) {
      print('Error loading data from source database: $e');
      rethrow;
    }
  }

  /// Load data from source database grn_item collection
  static Future<List<Map<String, dynamic>>> loadGrnItemDataFromSource() async {
    try {
      final sourceDb = await sourceDatabase;
      final grnItemCollection = sourceDb.collection(
        DatabaseConfig.grnItemCollection,
      );

      // Find all documents in grn_item collection
      final cursor = await grnItemCollection.find();
      final documents = await cursor.toList();

      print(
        'Loaded ${documents.length} documents from source grn_item collection',
      );
      return documents;
    } catch (e) {
      print('Error loading grn_item data from source database: $e');
      rethrow;
    }
  }

  /// Load grn_item data by grnSerialNo
  static Future<List<Map<String, dynamic>>> loadGrnItemBySerialNo(
    String grnSerialNo,
  ) async {
    try {
      final sourceDb = await sourceDatabase;
      final grnItemCollection = sourceDb.collection(
        DatabaseConfig.grnItemCollection,
      );

      // Find documents with specific grnSerialNo
      final cursor = await grnItemCollection.find(
        where.eq('grnSerialNo', grnSerialNo),
      );
      final documents = await cursor.toList();

      print(
        'Loaded ${documents.length} grn_item documents for serial: $grnSerialNo',
      );
      return documents;
    } catch (e) {
      print('Error loading grn_item by serial number: $e');
      rethrow;
    }
  }

  /// Insert data into destination database grn collection
  static Future<void> insertGrnDataToDestination(
    List<Map<String, dynamic>> documents,
  ) async {
    try {
      final destinationDb = await destinationDatabase;
      final grnCollection = destinationDb.collection('grn');

      if (documents.isEmpty) {
        print('No documents to insert');
        return;
      }

      // Remove _id field from documents to avoid conflicts
      final documentsToInsert = documents.map((doc) {
        final newDoc = Map<String, dynamic>.from(doc);
        newDoc.remove('_id'); // Remove _id to let MongoDB generate new ones
        return newDoc;
      }).toList();

      // Insert documents
      await grnCollection.insertMany(documentsToInsert);

      print(
        'Successfully inserted ${documentsToInsert.length} documents into destination grn collection',
      );
    } catch (e) {
      print('Error inserting data into destination database: $e');
      rethrow;
    }
  }

  /// Insert data into destination database grn_item collection
  static Future<void> insertGrnItemDataToDestination(
    List<Map<String, dynamic>> documents,
  ) async {
    try {
      final destinationDb = await destinationDatabase;
      final grnItemCollection = destinationDb.collection('grn_item');

      if (documents.isEmpty) {
        print('No grn_item documents to insert');
        return;
      }

      // Clear existing grn_item data first to ensure one-time load
      print('Clearing existing grn_item data from destination...');
      await grnItemCollection.deleteMany({});
      print('Existing grn_item data cleared successfully');

      // Remove _id field from documents to avoid conflicts
      final documentsToInsert = documents.map((doc) {
        final newDoc = Map<String, dynamic>.from(doc);
        newDoc.remove('_id'); // Remove _id to let MongoDB generate new ones
        return newDoc;
      }).toList();

      // Insert documents
      await grnItemCollection.insertMany(documentsToInsert);

      print(
        'Successfully inserted ${documentsToInsert.length} documents into destination grn_item collection (one-time load)',
      );
    } catch (e) {
      print('Error inserting grn_item data into destination database: $e');
      rethrow;
    }
  }

  /// Check if document exists in destination collection to prevent duplicates
  static Future<bool> documentExistsInDestination(
    String collectionName,
    String fieldName,
    dynamic fieldValue,
  ) async {
    try {
      final destinationDb = await destinationDatabase;
      final collection = destinationDb.collection(collectionName);

      final existingDoc = await collection.findOne(
        where.eq(fieldName, fieldValue),
      );
      return existingDoc != null;
    } catch (e) {
      print('Error checking document existence: $e');
      return false;
    }
  }

  /// Insert grn data with duplicate prevention
  static Future<int> insertGrnDataWithDuplicatePrevention(
    List<Map<String, dynamic>> documents,
  ) async {
    try {
      final destinationDb = await destinationDatabase;
      final grnCollection = destinationDb.collection('grn');

      if (documents.isEmpty) {
        print('No documents to insert');
        return 0;
      }

      int insertedCount = 0;

      for (final doc in documents) {
        final serialNo = doc['serialNo']?.toString();
        if (serialNo == null) continue;

        // Check if document already exists
        final exists = await documentExistsInDestination(
          'grn',
          'serialNo',
          serialNo,
        );

        if (!exists) {
          // Remove _id field to avoid conflicts
          final newDoc = Map<String, dynamic>.from(doc);
          newDoc.remove('_id');

          await grnCollection.insertOne(newDoc);
          insertedCount++;
          print('Inserted GRN: $serialNo');
        } else {
          print('GRN already exists, skipping: $serialNo');
        }
      }

      print(
        'Successfully inserted $insertedCount new GRN documents (${documents.length - insertedCount} duplicates skipped)',
      );
      return insertedCount;
    } catch (e) {
      print('Error inserting GRN data with duplicate prevention: $e');
      rethrow;
    }
  }

  /// Insert grn_item data with duplicate prevention
  static Future<int> insertGrnItemDataWithDuplicatePrevention(
    List<Map<String, dynamic>> documents,
  ) async {
    try {
      final destinationDb = await destinationDatabase;
      final grnItemCollection = destinationDb.collection('grn_item');

      if (documents.isEmpty) {
        print('No grn_item documents to insert');
        return 0;
      }

      int insertedCount = 0;

      for (final doc in documents) {
        final itemCode = doc['itemCode']?.toString();
        final grnSerialNo = doc['grnSerialNo']?.toString();

        if (itemCode == null || grnSerialNo == null) continue;

        // Check if document already exists (using combination of itemCode and grnSerialNo)
        final exists =
            await grnItemCollection.findOne(
              where
                  .eq('itemCode', itemCode)
                  .and(where.eq('grnSerialNo', grnSerialNo)),
            ) !=
            null;

        if (!exists) {
          // Remove _id field to avoid conflicts
          final newDoc = Map<String, dynamic>.from(doc);
          newDoc.remove('_id');

          await grnItemCollection.insertOne(newDoc);
          insertedCount++;
          print('Inserted GRN Item: $itemCode for GRN: $grnSerialNo');
        } else {
          print(
            'GRN Item already exists, skipping: $itemCode for GRN: $grnSerialNo',
          );
        }
      }

      print(
        'Successfully inserted $insertedCount new GRN Item documents (${documents.length - insertedCount} duplicates skipped)',
      );
      return insertedCount;
    } catch (e) {
      print('Error inserting GRN Item data with duplicate prevention: $e');
      rethrow;
    }
  }

  /// Sync grn data from source to destination database
  static Future<Map<String, dynamic>> syncGrnData() async {
    try {
      print('Starting GRN data sync...');

      // Load data from source
      final sourceData = await loadGrnDataFromSource();

      if (sourceData.isEmpty) {
        return {
          'success': true,
          'message': 'No data found in source database',
          'documentsProcessed': 0,
        };
      }

      // Insert data into destination
      await insertGrnDataToDestination(sourceData);

      print('GRN data sync completed successfully');
      return {
        'success': true,
        'message': 'Data synced successfully',
        'documentsProcessed': sourceData.length,
      };
    } catch (e) {
      print('Error during GRN data sync: $e');
      return {
        'success': false,
        'message': 'Error during sync: $e',
        'documentsProcessed': 0,
      };
    }
  }

  /// Sync grn_item data from source to destination database
  static Future<Map<String, dynamic>> syncGrnItemData() async {
    try {
      print(
        'Starting GRN Item data sync (one-time load - clearing existing data first)...',
      );

      // Load data from source
      final sourceData = await loadGrnItemDataFromSource();

      if (sourceData.isEmpty) {
        return {
          'success': true,
          'message': 'No GRN Item data found in source database',
          'documentsProcessed': 0,
        };
      }

      // Insert ALL data into destination (clears existing data first)
      await insertGrnItemDataToDestination(sourceData);

      print(
        'GRN Item data sync completed successfully - ${sourceData.length} documents loaded (one-time load)',
      );
      return {
        'success': true,
        'message':
            'GRN Item data synced successfully - ${sourceData.length} documents loaded (one-time load)',
        'documentsProcessed': sourceData.length,
      };
    } catch (e) {
      print('Error during GRN Item data sync: $e');
      return {
        'success': false,
        'message': 'Error during GRN Item sync: $e',
        'documentsProcessed': 0,
      };
    }
  }

  /// Sync both GRN and GRN Item data from source to destination database
  static Future<Map<String, dynamic>> syncBothGrnAndGrnItemData() async {
    try {
      print('Starting combined GRN and GRN Item data sync...');

      // Load GRN data from source
      final grnData = await loadGrnDataFromSource();
      print('Loaded ${grnData.length} GRN documents from source');

      // Load GRN Item data from source
      final grnItemData = await loadGrnItemDataFromSource();
      print('Loaded ${grnItemData.length} GRN Item documents from source');

      if (grnData.isEmpty && grnItemData.isEmpty) {
        return {
          'success': true,
          'message': 'No data found in source database',
          'grnDocumentsProcessed': 0,
          'grnItemDocumentsProcessed': 0,
          'totalDocumentsProcessed': 0,
        };
      }

      int grnInserted = 0;
      int grnItemInserted = 0;

      // Insert GRN data with duplicate prevention
      if (grnData.isNotEmpty) {
        grnInserted = await insertGrnDataWithDuplicatePrevention(grnData);
      }

      // Insert GRN Item data WITHOUT duplicate prevention (one-time load)
      if (grnItemData.isNotEmpty) {
        await insertGrnItemDataToDestination(grnItemData);
        grnItemInserted = grnItemData.length; // All items inserted
        print(
          'Inserted all ${grnItemData.length} GRN Item documents (one-time load)',
        );
      }

      final totalProcessed = grnInserted + grnItemInserted;

      print('Combined sync completed successfully');
      return {
        'success': true,
        'message':
            'Combined sync completed: $grnInserted GRN documents, $grnItemInserted GRN Item documents (one-time load)',
        'grnDocumentsProcessed': grnInserted,
        'grnItemDocumentsProcessed': grnItemInserted,
        'totalDocumentsProcessed': totalProcessed,
      };
    } catch (e) {
      print('Error during combined GRN and GRN Item data sync: $e');
      return {
        'success': false,
        'message': 'Error during combined sync: $e',
        'grnDocumentsProcessed': 0,
        'grnItemDocumentsProcessed': 0,
        'totalDocumentsProcessed': 0,
      };
    }
  }

  /// Sync GRN and its related GRN Items by serial number
  static Future<Map<String, dynamic>> syncGrnWithItemsBySerialNo(
    String serialNo,
  ) async {
    try {
      print('Starting GRN with items sync for serial: $serialNo');

      // Load specific GRN document
      final grnDocument = await loadGrnBySerialNumber(serialNo);
      if (grnDocument == null) {
        return {
          'success': false,
          'message': 'GRN document not found with serial: $serialNo',
          'grnDocumentsProcessed': 0,
          'grnItemDocumentsProcessed': 0,
          'totalDocumentsProcessed': 0,
        };
      }

      // Load related GRN Item documents
      final grnItemDocuments = await loadGrnItemBySerialNo(serialNo);

      int grnInserted = 0;
      int grnItemInserted = 0;

      // Insert GRN document with duplicate prevention
      grnInserted = await insertGrnDataWithDuplicatePrevention([grnDocument]);

      // Insert GRN Item documents with duplicate prevention
      if (grnItemDocuments.isNotEmpty) {
        grnItemInserted = await insertGrnItemDataWithDuplicatePrevention(
          grnItemDocuments,
        );
      }

      final totalProcessed = grnInserted + grnItemInserted;

      print('GRN with items sync completed for serial: $serialNo');
      return {
        'success': true,
        'message':
            'GRN $serialNo synced: $grnInserted GRN document, $grnItemInserted GRN Item documents',
        'grnDocumentsProcessed': grnInserted,
        'grnItemDocumentsProcessed': grnItemInserted,
        'totalDocumentsProcessed': totalProcessed,
      };
    } catch (e) {
      print('Error during GRN with items sync for serial $serialNo: $e');
      return {
        'success': false,
        'message': 'Error during GRN with items sync: $e',
        'grnDocumentsProcessed': 0,
        'grnItemDocumentsProcessed': 0,
        'totalDocumentsProcessed': 0,
      };
    }
  }

  /// Load specific GRN document by serial number
  static Future<Map<String, dynamic>?> loadGrnBySerialNumber(
    String serialNo,
  ) async {
    try {
      final sourceDb = await sourceDatabase;
      final grnCollection = sourceDb.collection(DatabaseConfig.grnCollection);

      final document = await grnCollection.findOne(
        where.eq('serialNo', serialNo),
      );

      if (document != null) {
        print('Found GRN document with serial number: $serialNo');
      } else {
        print('No GRN document found with serial number: $serialNo');
      }

      return document;
    } catch (e) {
      print('Error loading GRN by serial number: $e');
      rethrow;
    }
  }

  /// Insert single GRN document to destination
  static Future<void> insertSingleGrnToDestination(
    Map<String, dynamic> document,
  ) async {
    try {
      final destinationDb = await destinationDatabase;
      final grnCollection = destinationDb.collection('grn');

      // Remove _id field to avoid conflicts
      final docToInsert = Map<String, dynamic>.from(document);
      docToInsert.remove('_id');

      await grnCollection.insertOne(docToInsert);

      print('Successfully inserted single GRN document');
    } catch (e) {
      print('Error inserting single GRN document: $e');
      rethrow;
    }
  }

  /// Test connections to both databases
  static Future<Map<String, bool>> testConnections() async {
    final results = <String, bool>{};

    try {
      await sourceDatabase;
      results['source'] = true;
      print('Source database connection: SUCCESS');
    } catch (e) {
      results['source'] = false;
      print('Source database connection: FAILED - $e');
    }

    try {
      await destinationDatabase;
      results['destination'] = true;
      print('Destination database connection: SUCCESS');
    } catch (e) {
      results['destination'] = false;
      print('Destination database connection: FAILED - $e');
    }

    return results;
  }

  /// Close all database connections
  static Future<void> closeConnections() async {
    try {
      if (_sourceDb != null && _sourceDb!.state == State.open) {
        await _sourceDb!.close();
        _sourceDb = null;
        print('Source database connection closed');
      }

      if (_destinationDb != null && _destinationDb!.state == State.open) {
        await _destinationDb!.close();
        _destinationDb = null;
        print('Destination database connection closed');
      }
    } catch (e) {
      print('Error closing database connections: $e');
    }
  }

  /// Get sample GRN data structure
  static Map<String, dynamic> getSampleGrnData() {
    return {
      "serialNo": "GRN00000001",
      "refNo": "",
      "date": DateTime.now().toUtc(),
      "supplierCode": "K1",
      "supplierName": "Kiming",
      "purchaseOrderNo": "",
      "type": "General",
      "paymentMode": "Credit",
      "remarks": "",
      "itemLocked": false,
      "autoUpdate": false,
      "totalAmount": 0,
      "totalDiscount": 0,
      "additionalDiscount": 0,
      "nbt": 0,
      "tax": 0,
      "advance": 0,
      "purchaseReturn": 0,
      "netAmount": 0,
      "netAmountFinal": 0,
      "status": "saved",
      "createdAt": DateTime.now().toUtc(),
      "updatedAt": DateTime.now().toUtc(),
    };
  }

  /// Get sample GRN Item data structure
  static Map<String, dynamic> getSampleGrnItemData() {
    return {
      "itemCode": "00000001",
      "description": "09.ALARM CLOCK",
      "property": "09.ALARM CLOCK",
      "scale": "NOS",
      "rate": 600,
      "price": 770,
      "qty": 20,
      "discount": 0,
      "amount": 12000,
      "createdAt": DateTime.now().toUtc(),
      "updatedAt": DateTime.now().toUtc(),
      "grnSerialNo": "GRN00000001",
      "quantity": "+20",
    };
  }

  // ==================== TRANSACTION DATA METHODS ====================

  /// Load data from source database transactions collection
  static Future<List<Map<String, dynamic>>>
  loadTransactionDataFromSource() async {
    try {
      final sourceDb = await sourceDatabase;
      final transactionCollection = sourceDb.collection('transactions');

      // Find all documents in transactions collection
      final cursor = await transactionCollection.find();
      final documents = await cursor.toList();

      print(
        'Loaded ${documents.length} documents from source transactions collection',
      );
      return documents;
    } catch (e) {
      print('Error loading transaction data from source database: $e');
      rethrow;
    }
  }

  /// Load transaction data by date range
  static Future<List<Map<String, dynamic>>> loadTransactionDataByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final sourceDb = await sourceDatabase;
      final transactionCollection = sourceDb.collection('transactions');

      // Find documents within date range
      final cursor = await transactionCollection.find(
        where.gte('date', startDate).lte('date', endDate),
      );
      final documents = await cursor.toList();

      print(
        'Loaded ${documents.length} transaction documents for date range: $startDate to $endDate',
      );
      return documents;
    } catch (e) {
      print('Error loading transaction data by date range: $e');
      rethrow;
    }
  }

  /// Load transaction data by transaction ID
  static Future<Map<String, dynamic>?> loadTransactionById(
    String transactionId,
  ) async {
    try {
      final sourceDb = await sourceDatabase;
      final transactionCollection = sourceDb.collection('transactions');

      final document = await transactionCollection.findOne(
        where.eq('transactionId', transactionId),
      );

      if (document != null) {
        print('Found transaction document with ID: $transactionId');
      } else {
        print('No transaction document found with ID: $transactionId');
      }

      return document;
    } catch (e) {
      print('Error loading transaction by ID: $e');
      rethrow;
    }
  }

  /// Insert transaction data into destination database
  static Future<void> insertTransactionDataToDestination(
    List<Map<String, dynamic>> documents,
  ) async {
    try {
      final destinationDb = await destinationDatabase;
      final transactionCollection = destinationDb.collection('transactions');

      if (documents.isEmpty) {
        print('No transaction documents to insert');
        return;
      }

      // Remove _id field from documents to avoid conflicts
      final documentsToInsert = documents.map((doc) {
        final newDoc = Map<String, dynamic>.from(doc);
        newDoc.remove('_id'); // Remove _id to let MongoDB generate new ones
        return newDoc;
      }).toList();

      // Insert documents
      await transactionCollection.insertMany(documentsToInsert);

      print(
        'Successfully inserted ${documentsToInsert.length} documents into destination transactions collection',
      );
    } catch (e) {
      print('Error inserting transaction data into destination database: $e');
      rethrow;
    }
  }

  /// Insert transaction data with duplicate prevention
  static Future<int> insertTransactionDataWithDuplicatePrevention(
    List<Map<String, dynamic>> documents,
  ) async {
    try {
      final destinationDb = await destinationDatabase;
      final transactionCollection = destinationDb.collection('transactions');

      if (documents.isEmpty) {
        print('No transaction documents to insert');
        return 0;
      }

      int insertedCount = 0;

      for (final doc in documents) {
        final transactionId = doc['transactionId']?.toString();
        if (transactionId == null) continue;

        // Check if document already exists
        final exists = await documentExistsInDestination(
          'transactions',
          'transactionId',
          transactionId,
        );

        if (!exists) {
          // Remove _id field to avoid conflicts
          final newDoc = Map<String, dynamic>.from(doc);
          newDoc.remove('_id');

          await transactionCollection.insertOne(newDoc);
          insertedCount++;
          print('Inserted Transaction: $transactionId');
        } else {
          print('Transaction already exists, skipping: $transactionId');
        }
      }

      print(
        'Successfully inserted $insertedCount new transaction documents (${documents.length - insertedCount} duplicates skipped)',
      );
      return insertedCount;
    } catch (e) {
      print('Error inserting transaction data with duplicate prevention: $e');
      rethrow;
    }
  }

  /// Sync transaction data from source to destination database
  static Future<Map<String, dynamic>> syncTransactionData() async {
    try {
      print('Starting transaction data sync...');

      // Load data from source
      final sourceData = await loadTransactionDataFromSource();

      if (sourceData.isEmpty) {
        return {
          'success': true,
          'message': 'No transaction data found in source database',
          'documentsProcessed': 0,
        };
      }

      // Insert data into destination with duplicate prevention
      final insertedCount = await insertTransactionDataWithDuplicatePrevention(
        sourceData,
      );

      print('Transaction data sync completed successfully');
      return {
        'success': true,
        'message': 'Transaction data synced successfully',
        'documentsProcessed': insertedCount,
      };
    } catch (e) {
      print('Error during transaction data sync: $e');
      return {
        'success': false,
        'message': 'Error during transaction sync: $e',
        'documentsProcessed': 0,
      };
    }
  }

  /// Sync transaction data by date range
  static Future<Map<String, dynamic>> syncTransactionDataByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      print(
        'Starting transaction data sync for date range: $startDate to $endDate',
      );

      // Load data from source by date range
      final sourceData = await loadTransactionDataByDateRange(
        startDate,
        endDate,
      );

      if (sourceData.isEmpty) {
        return {
          'success': true,
          'message':
              'No transaction data found in source database for the specified date range',
          'documentsProcessed': 0,
        };
      }

      // Insert data into destination with duplicate prevention
      final insertedCount = await insertTransactionDataWithDuplicatePrevention(
        sourceData,
      );

      print('Transaction data sync by date range completed successfully');
      return {
        'success': true,
        'message': 'Transaction data synced successfully for date range',
        'documentsProcessed': insertedCount,
      };
    } catch (e) {
      print('Error during transaction data sync by date range: $e');
      return {
        'success': false,
        'message': 'Error during transaction sync by date range: $e',
        'documentsProcessed': 0,
      };
    }
  }

  /// Get sample transaction data structure
  static Map<String, dynamic> getSampleTransactionData() {
    return {
      "transactionId": "TXN00000001",
      "date": DateTime.now().toUtc(),
      "time": DateTime.now().toUtc(),
      "customerId": "",
      "customerName": "",
      "items": [],
      "subtotal": 0.0,
      "discount": 0.0,
      "tax": 0.0,
      "total": 0.0,
      "paymentMethod": "Cash",
      "paymentStatus": "Completed",
      "cashierId": "",
      "cashierName": "",
      "location": "Unit 8",
      "status": "Completed",
      "createdAt": DateTime.now().toUtc(),
      "updatedAt": DateTime.now().toUtc(),
    };
  }

  // ==================== BRANDS DATA METHODS ====================

  /// Load data from source database brands collection
  static Future<List<Map<String, dynamic>>> loadBrandsDataFromSource() async {
    try {
      final sourceDb = await sourceDatabase;
      final brandsCollection = sourceDb.collection('brands');

      // Find all documents in brands collection
      final cursor = await brandsCollection.find();
      final documents = await cursor.toList();

      print(
        'Loaded ${documents.length} documents from source brands collection',
      );
      return documents;
    } catch (e) {
      print('Error loading brands data from source database: $e');
      rethrow;
    }
  }

  /// Insert brands data into destination database
  static Future<void> insertBrandsDataToDestination(
    List<Map<String, dynamic>> documents,
  ) async {
    try {
      final destinationDb = await destinationDatabase;
      final brandsCollection = destinationDb.collection('brands');

      if (documents.isEmpty) {
        print('No brands documents to insert');
        return;
      }

      // Remove _id field from documents to avoid conflicts
      final documentsToInsert = documents.map((doc) {
        final newDoc = Map<String, dynamic>.from(doc);
        newDoc.remove('_id'); // Remove _id to let MongoDB generate new ones
        return newDoc;
      }).toList();

      // Insert documents
      await brandsCollection.insertMany(documentsToInsert);

      print(
        'Successfully inserted ${documentsToInsert.length} documents into destination brands collection',
      );
    } catch (e) {
      print('Error inserting brands data into destination database: $e');
      rethrow;
    }
  }

  /// Insert brands data with duplicate prevention
  static Future<int> insertBrandsDataWithDuplicatePrevention(
    List<Map<String, dynamic>> documents,
  ) async {
    try {
      final destinationDb = await destinationDatabase;
      final brandsCollection = destinationDb.collection('brands');

      if (documents.isEmpty) {
        print('No brands documents to insert');
        return 0;
      }

      int insertedCount = 0;

      for (final doc in documents) {
        final location = doc['location']?.toString();
        if (location == null) continue;

        // Check if document already exists (using location as unique identifier)
        final exists = await documentExistsInDestination(
          'brands',
          'location',
          location,
        );

        if (!exists) {
          // Remove _id field to avoid conflicts
          final newDoc = Map<String, dynamic>.from(doc);
          newDoc.remove('_id');

          await brandsCollection.insertOne(newDoc);
          insertedCount++;
          print('Inserted Brand: $location');
        } else {
          print('Brand already exists, skipping: $location');
        }
      }

      print(
        'Successfully inserted $insertedCount new brands documents (${documents.length - insertedCount} duplicates skipped)',
      );
      return insertedCount;
    } catch (e) {
      print('Error inserting brands data with duplicate prevention: $e');
      rethrow;
    }
  }

  /// Sync brands data from source to destination database
  static Future<Map<String, dynamic>> syncBrandsData() async {
    try {
      print('Starting brands data sync...');

      // Load data from source
      final sourceData = await loadBrandsDataFromSource();

      if (sourceData.isEmpty) {
        return {
          'success': true,
          'message': 'No brands data found in source database',
          'documentsProcessed': 0,
        };
      }

      // Insert data into destination with duplicate prevention
      final insertedCount = await insertBrandsDataWithDuplicatePrevention(
        sourceData,
      );

      print('Brands data sync completed successfully');
      return {
        'success': true,
        'message': 'Brands data synced successfully',
        'documentsProcessed': insertedCount,
      };
    } catch (e) {
      print('Error during brands data sync: $e');
      return {
        'success': false,
        'message': 'Error during brands sync: $e',
        'documentsProcessed': 0,
      };
    }
  }

  /// Get sample brands data structure
  static Map<String, dynamic> getSampleBrandsData() {
    return {
      "location": "kiming",
      "createdAt": DateTime.now().toUtc(),
      "updatedAt": DateTime.now().toUtc(),
    };
  }

  // ==================== CASHIERS DATA METHODS ====================

  /// Load data from source database cashiers collection
  static Future<List<Map<String, dynamic>>> loadCashiersDataFromSource() async {
    try {
      final sourceDb = await sourceDatabase;
      final cashiersCollection = sourceDb.collection('cashiers');

      // Find all documents in cashiers collection
      final cursor = await cashiersCollection.find();
      final documents = await cursor.toList();

      print(
        'Loaded ${documents.length} documents from source cashiers collection',
      );
      return documents;
    } catch (e) {
      print('Error loading cashiers data from source database: $e');
      rethrow;
    }
  }

  /// Insert cashiers data into destination database
  static Future<void> insertCashiersDataToDestination(
    List<Map<String, dynamic>> documents,
  ) async {
    try {
      final destinationDb = await destinationDatabase;
      final cashiersCollection = destinationDb.collection('cashiers');

      if (documents.isEmpty) {
        print('No cashiers documents to insert');
        return;
      }

      // Remove _id field from documents to avoid conflicts
      final documentsToInsert = documents.map((doc) {
        final newDoc = Map<String, dynamic>.from(doc);
        newDoc.remove('_id');
        return newDoc;
      }).toList();

      await cashiersCollection.insertMany(documentsToInsert);

      print(
        'Successfully inserted ${documentsToInsert.length} documents into destination cashiers collection',
      );
    } catch (e) {
      print('Error inserting cashiers data into destination database: $e');
      rethrow;
    }
  }

  /// Insert cashiers data with duplicate prevention
  static Future<int> insertCashiersDataWithDuplicatePrevention(
    List<Map<String, dynamic>> documents,
  ) async {
    try {
      final destinationDb = await destinationDatabase;
      final cashiersCollection = destinationDb.collection('cashiers');

      if (documents.isEmpty) {
        print('No cashiers documents to insert');
        return 0;
      }

      int insertedCount = 0;

      for (final doc in documents) {
        final cashierId = doc['cashierId']?.toString();
        if (cashierId == null) continue;

        // Check if document already exists
        final exists = await documentExistsInDestination(
          'cashiers',
          'cashierId',
          cashierId,
        );

        if (!exists) {
          final newDoc = Map<String, dynamic>.from(doc);
          newDoc.remove('_id');
          await cashiersCollection.insertOne(newDoc);
          insertedCount++;
          print('Inserted Cashier: $cashierId');
        } else {
          print('Cashier already exists, skipping: $cashierId');
        }
      }

      print(
        'Successfully inserted $insertedCount new cashiers documents (${documents.length - insertedCount} duplicates skipped)',
      );
      return insertedCount;
    } catch (e) {
      print('Error inserting cashiers data with duplicate prevention: $e');
      rethrow;
    }
  }

  /// Sync cashiers data from source to destination database
  static Future<Map<String, dynamic>> syncCashiersData() async {
    try {
      print('Starting cashiers data sync...');

      // Load data from source
      final sourceData = await loadCashiersDataFromSource();

      if (sourceData.isEmpty) {
        return {
          'success': true,
          'message': 'No cashiers data found in source database',
          'documentsProcessed': 0,
        };
      }

      // Insert data into destination with duplicate prevention
      final insertedCount = await insertCashiersDataWithDuplicatePrevention(
        sourceData,
      );

      print('Cashiers data sync completed successfully');
      return {
        'success': true,
        'message': 'Cashiers data synced successfully',
        'documentsProcessed': insertedCount,
      };
    } catch (e) {
      print('Error during cashiers data sync: $e');
      return {
        'success': false,
        'message': 'Error during cashiers sync: $e',
        'documentsProcessed': 0,
      };
    }
  }

  /// Get sample cashiers data structure
  static Map<String, dynamic> getSampleCashiersData() {
    return {
      "cashierId": "CASHIER0001",
      "cashierName": "John Doe",
      "location": "Unit 8",
      "createdAt": DateTime.now().toUtc(),
      "updatedAt": DateTime.now().toUtc(),
    };
  }
}
