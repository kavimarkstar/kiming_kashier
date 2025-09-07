// All GRN-related methods have been removed from this file.
import 'package:kiming_kashier/Server/database/loacl_database.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../database/database_config.dart';

class DatabaseSyncService {
  static Db? _sourceDb;
  static Db? _destinationDb;

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

  static Future<Db> get destinationDatabase async {
    if (_destinationDb == null || _destinationDb!.state != State.open) {
      try {
        // Primary: connect directly to local kashier DB
        final localConn = LocalDatabaseConfig.connectionString;
        _destinationDb = await Db.create(localConn);
        if (_destinationDb!.state != State.open) {
          await _destinationDb!.open();
        }
        print(
          'Destination database connected successfully (localhost:27017/kashier)',
        );
      } catch (e) {
        print('Local connection to destination failed: $e');
        try {
          // Fallback: connect to localhost without DB in URI
          final localNoDb = LocalDatabaseConfig.connectionString;
          _destinationDb = await Db.create(localNoDb);
          if (_destinationDb!.state != State.open) {
            await _destinationDb!.open();
          }
          print(
            'Destination database connected successfully (localhost:27017)',
          );
        } catch (e2) {
          print('All attempts to connect to local destination DB failed: $e2');
          rethrow;
        }
      }
    }
    return _destinationDb!;
  }

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

  // ! ==================== BRANDS DATA METHODS ====================

  static Future<List<Map<String, dynamic>>> loadBrandsDataFromSource() async {
    try {
      final sourceDb = await sourceDatabase;
      final brandsCollection = sourceDb.collection('brands');
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
      final documentsToInsert = documents.map((doc) {
        final newDoc = Map<String, dynamic>.from(doc);
        newDoc.remove('_id');
        return newDoc;
      }).toList();
      await brandsCollection.insertMany(documentsToInsert);
      print(
        'Successfully inserted ${documentsToInsert.length} documents into destination brands collection',
      );
    } catch (e) {
      print('Error inserting brands data into destination database: $e');
      rethrow;
    }
  }

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
        final exists = await documentExistsInDestination(
          'brands',
          'location',
          location,
        );
        if (!exists) {
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

  static Future<Map<String, dynamic>> syncBrandsData() async {
    try {
      print('Starting brands data sync...');
      final sourceData = await loadBrandsDataFromSource();
      if (sourceData.isEmpty) {
        return {
          'success': true,
          'message': 'No brands data found in source database',
          'documentsProcessed': 0,
        };
      }
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

  static Map<String, dynamic> getSampleBrandsData() {
    return {
      "location": "kiming",
      "createdAt": DateTime.now().toUtc(),
      "updatedAt": DateTime.now().toUtc(),
    };
  }

  // ! ==================== CASHIER DATA METHODS ====================

  static Future<List<Map<String, dynamic>>> loadCashiersDataFromSource() async {
    try {
      final sourceDb = await sourceDatabase;
      final cashiersCollection = sourceDb.collection(
        DatabaseConfig.cashiersCollection,
      );
      final cursor = await cashiersCollection.find();
      final documents = await cursor.toList();
      print(
        'Loaded ${documents.length} documents from source ${DatabaseConfig.cashiersCollection} collection',
      );
      return documents;
    } catch (e) {
      print('Error loading cashiers data from source database: $e');
      rethrow;
    }
  }

  static Future<void> insertCashiersDataToDestination(
    List<Map<String, dynamic>> documents,
  ) async {
    try {
      final destinationDb = await destinationDatabase;
      final cashiersCollection = destinationDb.collection(
        DatabaseConfig.cashiersCollection,
      );

      if (documents.isEmpty) {
        print('No cashiers documents to insert');
        return;
      }

      final documentsToInsert = documents.map((doc) {
        final newDoc = Map<String, dynamic>.from(doc);
        newDoc.remove('_id');
        return newDoc;
      }).toList();

      await cashiersCollection.insertMany(documentsToInsert);

      print(
        'Successfully inserted ${documentsToInsert.length} documents into destination ${DatabaseConfig.cashiersCollection} collection',
      );
    } catch (e) {
      print('Error inserting cashiers data into destination database: $e');
      rethrow;
    }
  }

  static Future<int> insertCashiersDataWithDuplicatePrevention(
    List<Map<String, dynamic>> documents,
  ) async {
    try {
      final destinationDb = await destinationDatabase;
      final cashiersCollection = destinationDb.collection(
        DatabaseConfig.cashiersCollection,
      );

      if (documents.isEmpty) {
        print('No cashiers documents to insert');
        return 0;
      }

      int insertedCount = 0;

      for (final doc in documents) {
        // Prefer cashierId as unique key; fall back to cashierUsername
        String? uniqueValue;
        String uniqueField = 'cashierId';
        if (doc['cashierId'] != null) {
          uniqueValue = doc['cashierId']?.toString();
          uniqueField = 'cashierId';
        } else if (doc['cashierUsername'] != null) {
          uniqueValue = doc['cashierUsername']?.toString();
          uniqueField = 'cashierUsername';
        } else {
          // No suitable unique identifier; skip to avoid duplicates or corruption
          print(
            'Skipping cashier document without unique identifier (cashierId/cashierUsername)',
          );
          continue;
        }

        final exists = await documentExistsInDestination(
          DatabaseConfig.cashiersCollection,
          uniqueField,
          uniqueValue,
        );

        if (!exists) {
          final newDoc = Map<String, dynamic>.from(doc);
          newDoc.remove('_id');
          await cashiersCollection.insertOne(newDoc);
          insertedCount++;
          print('Inserted Cashier (${uniqueField}): $uniqueValue');
        } else {
          print(
            'Cashier already exists, skipping (${uniqueField}): $uniqueValue',
          );
        }
      }

      print(
        'Successfully inserted $insertedCount new ${DatabaseConfig.cashiersCollection} documents (${documents.length - insertedCount} duplicates skipped)',
      );
      return insertedCount;
    } catch (e) {
      print('Error inserting cashiers data with duplicate prevention: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> syncCashiersData() async {
    try {
      print('Starting cashiers data sync...');
      final sourceData = await loadCashiersDataFromSource();

      if (sourceData.isEmpty) {
        return {
          'success': true,
          'message': 'No cashiers data found in source database',
          'documentsProcessed': 0,
        };
      }

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

  static Map<String, dynamic> getCahiersBrandsData() {
    return {
      "location": "kiming",
      "createdAt": DateTime.now().toUtc(),
      "updatedAt": DateTime.now().toUtc(),
    };
  }

  // ! ==================== PRODUCTS DATA METHODS ====================

  static Future<List<Map<String, dynamic>>> loadItemsDataFromSource() async {
    try {
      final sourceDb = await sourceDatabase;
      final itemsCollection = sourceDb.collection(
        DatabaseConfig.productsCollection,
      );
      final cursor = await itemsCollection.find();
      final documents = await cursor.toList();
      print(
        'Loaded ${documents.length} documents from source ${DatabaseConfig.productsCollection} collection',
      );
      return documents;
    } catch (e) {
      print('Error loading items data from source database: $e');
      rethrow;
    }
  }

  static Future<void> insertItemsDataToDestination(
    List<Map<String, dynamic>> documents,
  ) async {
    try {
      final destinationDb = await destinationDatabase;
      final itemsCollection = destinationDb.collection(
        DatabaseConfig.productsCollection,
      );

      if (documents.isEmpty) {
        print('No items documents to insert');
        return;
      }

      final documentsToInsert = documents.map((doc) {
        final newDoc = Map<String, dynamic>.from(doc);
        newDoc.remove('_id');
        return newDoc;
      }).toList();

      await itemsCollection.insertMany(documentsToInsert);

      print(
        'Successfully inserted ${documentsToInsert.length} documents into destination ${DatabaseConfig.productsCollection} collection',
      );
    } catch (e) {
      print('Error inserting items data into destination database: $e');
      rethrow;
    }
  }

  static Future<int> insertItemsDataWithDuplicatePrevention(
    List<Map<String, dynamic>> documents,
  ) async {
    try {
      final destinationDb = await destinationDatabase;
      final itemsCollection = destinationDb.collection(
        DatabaseConfig.productsCollection,
      );

      if (documents.isEmpty) {
        print('No items documents to insert');
        return 0;
      }

      int insertedCount = 0;

      for (final doc in documents) {
        // Prefer itemCode as unique key; fall back to barcode, then description/invDescription
        String? uniqueValue;
        String uniqueField = 'itemCode';

        if (doc['itemCode'] != null) {
          uniqueValue = doc['itemCode']?.toString();
          uniqueField = 'itemCode';
        } else if (doc['barcode'] != null) {
          uniqueValue = doc['barcode']?.toString();
          uniqueField = 'barcode';
        } else if (doc['invDescription'] != null) {
          uniqueValue = doc['invDescription']?.toString();
          uniqueField = 'invDescription';
        } else if (doc['description'] != null) {
          uniqueValue = doc['description']?.toString();
          uniqueField = 'description';
        } else {
          // No suitable unique identifier; skip to avoid duplicates or corruption
          print(
            'Skipping product document without unique identifier (itemCode/barcode/description)',
          );
          continue;
        }

        final exists = await documentExistsInDestination(
          DatabaseConfig.productsCollection,
          uniqueField,
          uniqueValue,
        );

        if (!exists) {
          final newDoc = Map<String, dynamic>.from(doc);
          newDoc.remove('_id');
          await itemsCollection.insertOne(newDoc);
          insertedCount++;
          print('Inserted Product (${uniqueField}): $uniqueValue');
        } else {
          print(
            'Product already exists, skipping (${uniqueField}): $uniqueValue',
          );
        }
      }

      print(
        'Successfully inserted $insertedCount new ${DatabaseConfig.productsCollection} documents (${documents.length - insertedCount} duplicates skipped)',
      );
      return insertedCount;
    } catch (e) {
      print('Error inserting items data with duplicate prevention: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> syncItemsData() async {
    try {
      print('Starting items data sync...');
      final sourceData = await loadItemsDataFromSource();

      if (sourceData.isEmpty) {
        return {
          'success': true,
          'message': 'No items data found in source database',
          'documentsProcessed': 0,
        };
      }

      final insertedCount = await insertItemsDataWithDuplicatePrevention(
        sourceData,
      );

      print('Items data sync completed successfully');
      return {
        'success': true,
        'message': 'Items data synced successfully',
        'documentsProcessed': insertedCount,
      };
    } catch (e) {
      print('Error during items data sync: $e');
      return {
        'success': false,
        'message': 'Error during items sync: $e',
        'documentsProcessed': 0,
      };
    }
  }

  static Map<String, dynamic> getItemsSampleData() {
    return {
      "name": "sample product",
      "createdAt": DateTime.now().toUtc(),
      "updatedAt": DateTime.now().toUtc(),
    };
  }

  // generic helper to update destination documents by matching field
  static Future<int> _updateDocumentsByMatchField(
    String collectionName,
    String matchField,
    List<Map<String, dynamic>> sourceDocs,
  ) async {
    try {
      final destinationDb = await destinationDatabase;
      final collection = destinationDb.collection(collectionName);
      if (sourceDocs.isEmpty) {
        print('No documents to update for $collectionName');
        return 0;
      }

      int updatedCount = 0;
      for (final doc in sourceDocs) {
        final matchValue = doc[matchField]?.toString();
        if (matchValue == null) continue;

        final existing = await collection.findOne(
          where.eq(matchField, matchValue),
        );
        if (existing != null) {
          final newDoc = Map<String, dynamic>.from(doc);
          newDoc.remove('_id'); // avoid overriding _id

          final modifier = ModifierBuilder();
          newDoc.forEach((k, v) {
            modifier.set(k, v);
          });

          await collection.update(where.eq(matchField, matchValue), modifier);
          updatedCount++;
          print(
            'Updated document in $collectionName where $matchField = $matchValue',
          );
        } else {
          // no matching document found; skip
        }
      }

      print('Updated $updatedCount documents in $collectionName');
      return updatedCount;
    } catch (e) {
      print('Error updating documents in $collectionName: $e');
      rethrow;
    }
  }

  // update brands by 'location'
  static Future<Map<String, dynamic>> updateBrandsData() async {
    try {
      print('Starting brands data update...');
      final sourceData = await loadBrandsDataFromSource();
      if (sourceData.isEmpty) {
        return {
          'success': true,
          'message': 'No brands data found in source database',
          'documentsUpdated': 0,
        };
      }
      final updatedCount = await _updateDocumentsByMatchField(
        'brands',
        'location',
        sourceData,
      );
      print('Brands data update completed successfully');
      return {
        'success': true,
        'message': 'Brands data updated successfully',
        'documentsUpdated': updatedCount,
      };
    } catch (e) {
      print('Error during brands data update: $e');
      return {
        'success': false,
        'message': 'Error during brands update: $e',
        'documentsUpdated': 0,
      };
    }
  }

  // update cashiers using preferred unique fields
  static Future<Map<String, dynamic>> updateCashiersData() async {
    try {
      print('Starting cashiers data update...');
      final sourceData = await loadCashiersDataFromSource();
      if (sourceData.isEmpty) {
        return {
          'success': true,
          'message': 'No cashiers data found in source database',
          'documentsUpdated': 0,
        };
      }

      int updatedCount = 0;
      final destinationDb = await destinationDatabase;
      final collection = destinationDb.collection(
        DatabaseConfig.cashiersCollection,
      );

      for (final doc in sourceData) {
        String? matchField;
        String? matchValue;

        if (doc['cashierId'] != null) {
          matchField = 'cashierId';
          matchValue = doc['cashierId']?.toString();
        } else if (doc['cashierUsername'] != null) {
          matchField = 'cashierUsername';
          matchValue = doc['cashierUsername']?.toString();
        } else {
          print('Skipping cashier without unique identifier for update');
          continue;
        }

        if (matchValue == null) continue;

        final existing = await collection.findOne(
          where.eq(matchField, matchValue),
        );
        if (existing != null) {
          final newDoc = Map<String, dynamic>.from(doc)..remove('_id');
          final modifier = ModifierBuilder();
          newDoc.forEach((k, v) => modifier.set(k, v));
          await collection.update(where.eq(matchField, matchValue), modifier);
          updatedCount++;
          print('Updated Cashier (${matchField}): $matchValue');
        }
      }

      print('Cashiers data update completed. Updated: $updatedCount');
      return {
        'success': true,
        'message': 'Cashiers data updated successfully',
        'documentsUpdated': updatedCount,
      };
    } catch (e) {
      print('Error during cashiers data update: $e');
      return {
        'success': false,
        'message': 'Error during cashiers update: $e',
        'documentsUpdated': 0,
      };
    }
  }

  // update items/products using preferred unique fields
  static Future<Map<String, dynamic>> updateItemsData() async {
    try {
      print('Starting items data update...');
      final sourceData = await loadItemsDataFromSource();
      if (sourceData.isEmpty) {
        return {
          'success': true,
          'message': 'No items data found in source database',
          'documentsUpdated': 0,
        };
      }

      int updatedCount = 0;
      final destinationDb = await destinationDatabase;
      final collection = destinationDb.collection(
        DatabaseConfig.productsCollection,
      );

      for (final doc in sourceData) {
        String? matchField;
        String? matchValue;

        if (doc['itemCode'] != null) {
          matchField = 'itemCode';
          matchValue = doc['itemCode']?.toString();
        } else if (doc['barcode'] != null) {
          matchField = 'barcode';
          matchValue = doc['barcode']?.toString();
        } else if (doc['invDescription'] != null) {
          matchField = 'invDescription';
          matchValue = doc['invDescription']?.toString();
        } else if (doc['description'] != null) {
          matchField = 'description';
          matchValue = doc['description']?.toString();
        } else {
          print('Skipping product without unique identifier for update');
          continue;
        }

        if (matchValue == null) continue;

        final existing = await collection.findOne(
          where.eq(matchField, matchValue),
        );
        if (existing != null) {
          final newDoc = Map<String, dynamic>.from(doc)..remove('_id');
          final modifier = ModifierBuilder();
          newDoc.forEach((k, v) => modifier.set(k, v));
          await collection.update(where.eq(matchField, matchValue), modifier);
          updatedCount++;
          print('Updated Product (${matchField}): $matchValue');
        }
      }

      print('Items data update completed. Updated: $updatedCount');
      return {
        'success': true,
        'message': 'Items data updated successfully',
        'documentsUpdated': updatedCount,
      };
    } catch (e) {
      print('Error during items data update: $e');
      return {
        'success': false,
        'message': 'Error during items update: $e',
        'documentsUpdated': 0,
      };
    }
  }

  // convenience method to run all updates
  static Future<Map<String, dynamic>> updateAllData() async {
    try {
      final brandsResult = await updateBrandsData();
      final cashiersResult = await updateCashiersData();
      final itemsResult = await updateItemsData();

      final totalUpdated =
          (brandsResult['documentsUpdated'] as int? ?? 0) +
          (cashiersResult['documentsUpdated'] as int? ?? 0) +
          (itemsResult['documentsUpdated'] as int? ?? 0);

      return {
        'success': true,
        'message': 'All update operations completed',
        'totalUpdated': totalUpdated,
        'details': {
          'brands': brandsResult,
          'cashiers': cashiersResult,
          'items': itemsResult,
        },
      };
    } catch (e) {
      print('Error during full update: $e');
      return {
        'success': false,
        'message': 'Error during full update: $e',
        'totalUpdated': 0,
      };
    }
  }

  // helper to remove all documents from a destination collection (keeps indexes if possible)
  static Future<int> _clearDestinationCollection(String collectionName) async {
    try {
      final destinationDb = await destinationDatabase;
      final collection = destinationDb.collection(collectionName);

      // Try deleteMany (preferred if available)
      try {
        // some mongo_dart versions expose deleteMany as a method
        // ignore: unused_local_variable
        final result = await Function.apply(collection.deleteMany, [
          <String, dynamic>{},
        ]);
        print('Cleared collection $collectionName using deleteMany.');
        // if result is a Map or WriteResult, we cannot reliably parse count; return 1 to indicate success
        return 1;
      } catch (_) {
        // fallback to remove (older mongo_dart)
        try {
          await collection.remove(<String, dynamic>{});
          print(
            'Cleared collection $collectionName using remove(selector={}).',
          );
          return 1;
        } catch (_) {
          // as a last resort, drop the collection entirely (this will remove indexes)
          try {
            await collection.drop();
            // recreate collection (best-effort) by accessing it once; indexes will be lost
            destinationDb.collection(collectionName);
            print(
              'Dropped collection $collectionName as fallback clear method.',
            );
            return 1;
          } catch (e) {
            print(
              'Failed to clear collection $collectionName by any method: $e',
            );
            rethrow;
          }
        }
      }
    } catch (e) {
      print('Error clearing destination collection $collectionName: $e');
      rethrow;
    }
  }

  // Clear only the preview collections: brands, cashiers, products
  static Future<Map<String, dynamic>> clearPreviewCollections() async {
    final result = <String, dynamic>{
      'success': true,
      'details': <String, dynamic>{},
    };

    try {
      // brands
      try {
        await _clearDestinationCollection('brands');
        result['details']['brands'] = {'cleared': true};
      } catch (e) {
        result['details']['brands'] = {'cleared': false, 'error': e.toString()};
        result['success'] = false;
      }

      // cashiers
      try {
        await _clearDestinationCollection(DatabaseConfig.cashiersCollection);
        result['details']['cashiers'] = {'cleared': true};
      } catch (e) {
        result['details']['cashiers'] = {
          'cleared': false,
          'error': e.toString(),
        };
        result['success'] = false;
      }

      // products
      try {
        await _clearDestinationCollection(DatabaseConfig.productsCollection);
        result['details']['products'] = {'cleared': true};
      } catch (e) {
        result['details']['products'] = {
          'cleared': false,
          'error': e.toString(),
        };
        result['success'] = false;
      }

      return result;
    } catch (e) {
      print('Error clearing preview collections: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Replace destination "brands" collection with source data
  static Future<Map<String, dynamic>> syncBrandsReplaceAll() async {
    try {
      print('Starting brands replace-sync (clear & insert)...');
      final sourceData = await loadBrandsDataFromSource();
      final destinationCollectionName = 'brands';

      // clear destination
      await _clearDestinationCollection(destinationCollectionName);

      if (sourceData.isEmpty) {
        print('No brands data in source to insert after clear.');
        return {
          'success': true,
          'message': 'Destination brands cleared; no source data to insert',
          'inserted': 0,
        };
      }

      final destinationDb = await destinationDatabase;
      final destColl = destinationDb.collection(destinationCollectionName);

      final documentsToInsert = sourceData.map((doc) {
        final newDoc = Map<String, dynamic>.from(doc);
        newDoc.remove('_id');
        return newDoc;
      }).toList();

      await destColl.insertMany(documentsToInsert);

      print(
        'Inserted ${documentsToInsert.length} brand documents into destination (after clear)',
      );
      return {
        'success': true,
        'message': 'Brands replaced successfully',
        'inserted': documentsToInsert.length,
      };
    } catch (e) {
      print('Error during brands replace-sync: $e');
      return {
        'success': false,
        'message': 'Error during brands replace-sync: $e',
        'inserted': 0,
      };
    }
  }

  // Replace destination cashiers collection
  static Future<Map<String, dynamic>> syncCashiersReplaceAll() async {
    try {
      print('Starting cashiers replace-sync (clear & insert)...');
      final sourceData = await loadCashiersDataFromSource();
      final destinationCollectionName = DatabaseConfig.cashiersCollection;

      await _clearDestinationCollection(destinationCollectionName);

      if (sourceData.isEmpty) {
        print('No cashiers data in source to insert after clear.');
        return {
          'success': true,
          'message': 'Destination cashiers cleared; no source data to insert',
          'inserted': 0,
        };
      }

      final destinationDb = await destinationDatabase;
      final destColl = destinationDb.collection(destinationCollectionName);

      final documentsToInsert = sourceData.map((doc) {
        final newDoc = Map<String, dynamic>.from(doc);
        newDoc.remove('_id');
        return newDoc;
      }).toList();

      await destColl.insertMany(documentsToInsert);

      print(
        'Inserted ${documentsToInsert.length} cashier documents into destination (after clear)',
      );
      return {
        'success': true,
        'message': 'Cashiers replaced successfully',
        'inserted': documentsToInsert.length,
      };
    } catch (e) {
      print('Error during cashiers replace-sync: $e');
      return {
        'success': false,
        'message': 'Error during cashiers replace-sync: $e',
        'inserted': 0,
      };
    }
  }

  // Replace destination products/items collection
  static Future<Map<String, dynamic>> syncItemsReplaceAll() async {
    try {
      print('Starting items/products replace-sync (clear & insert)...');
      final sourceData = await loadItemsDataFromSource();
      final destinationCollectionName = DatabaseConfig.productsCollection;

      await _clearDestinationCollection(destinationCollectionName);

      if (sourceData.isEmpty) {
        print('No items data in source to insert after clear.');
        return {
          'success': true,
          'message': 'Destination items cleared; no source data to insert',
          'inserted': 0,
        };
      }

      final destinationDb = await destinationDatabase;
      final destColl = destinationDb.collection(destinationCollectionName);

      final documentsToInsert = sourceData.map((doc) {
        final newDoc = Map<String, dynamic>.from(doc);
        newDoc.remove('_id');
        return newDoc;
      }).toList();

      await destColl.insertMany(documentsToInsert);

      print(
        'Inserted ${documentsToInsert.length} item documents into destination (after clear)',
      );
      return {
        'success': true,
        'message': 'Items replaced successfully',
        'inserted': documentsToInsert.length,
      };
    } catch (e) {
      print('Error during items replace-sync: $e');
      return {
        'success': false,
        'message': 'Error during items replace-sync: $e',
        'inserted': 0,
      };
    }
  }

  // Convenience: replace all three collections (brands, cashiers, items)
  static Future<Map<String, dynamic>> replaceAllCollections() async {
    try {
      final brandsResult = await syncBrandsReplaceAll();
      final cashiersResult = await syncCashiersReplaceAll();
      final itemsResult = await syncItemsReplaceAll();

      final totalInserted =
          (brandsResult['inserted'] as int? ?? 0) +
          (cashiersResult['inserted'] as int? ?? 0) +
          (itemsResult['inserted'] as int? ?? 0);

      return {
        'success': true,
        'message': 'Replace all collections completed',
        'totalInserted': totalInserted,
        'details': {
          'brands': brandsResult,
          'cashiers': cashiersResult,
          'items': itemsResult,
        },
      };
    } catch (e) {
      print('Error during replaceAllCollections: $e');
      return {
        'success': false,
        'message': 'Error during replace all collections: $e',
        'totalInserted': 0,
      };
    }
  }
}
