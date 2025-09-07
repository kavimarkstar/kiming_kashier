import 'package:flutter/material.dart';
import '../database/util/database_sync_service.dart';

class LocalServerDataLoad extends StatefulWidget {
  LocalServerDataLoad({Key? key}) : super(key: key);

  @override
  _LocalServerDataLoadState createState() => _LocalServerDataLoadState();
}

class _LocalServerDataLoadState extends State<LocalServerDataLoad> {
  bool _isLoading = false;
  String _statusMessage = '';
  bool _isSuccess = false;
  int _documentsProcessed = 0;
  int _grnDocumentsProcessed = 0;
  int _grnItemDocumentsProcessed = 0;
  int _transactionDocumentsProcessed = 0;
  int _brandsDocumentsProcessed = 0;
  int _cashiersDocumentsProcessed = 0; // <-- Add this line
  Map<String, bool> _connectionStatus = {};

  @override
  void initState() {
    super.initState();
    _testConnections();
  }

  Future<void> _testConnections() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing database connections...';
    });

    try {
      final results = await DatabaseSyncService.testConnections();
      setState(() {
        _connectionStatus = results;
        _isLoading = false;
        if (results['source'] == true && results['destination'] == true) {
          _statusMessage = 'Both database connections are successful';
          _isSuccess = true;
        } else {
          _statusMessage = 'Database connection issues detected';
          _isSuccess = false;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error testing connections: $e';
        _isSuccess = false;
      });
    }
  }

  // ==================== LOAD ALL DATA METHOD ====================

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _statusMessage =
          'Starting to load all data (GRN, GRN Items, Transactions, Brands, and Cashiers)...'; // <-- Update message
      _isSuccess = false;
      _documentsProcessed = 0;
      _grnDocumentsProcessed = 0;
      _grnItemDocumentsProcessed = 0;
      _transactionDocumentsProcessed = 0;
      _brandsDocumentsProcessed = 0;
      _cashiersDocumentsProcessed = 0; // <-- Reset cashiers count
    });

    try {
      // Load GRN and GRN Item data
      final grnResult = await DatabaseSyncService.syncBothGrnAndGrnItemData();

      // Load Transaction data
      final transactionResult = await DatabaseSyncService.syncTransactionData();

      // Load Brands data
      final brandsResult = await DatabaseSyncService.syncBrandsData();
      final cashiersResult = await DatabaseSyncService.syncCashiersData(); // <-- Add this line

      setState(() {
        _isLoading = false;
        _grnDocumentsProcessed = grnResult['grnDocumentsProcessed'] ?? 0;
        _grnItemDocumentsProcessed =
            grnResult['grnItemDocumentsProcessed'] ?? 0;
        _transactionDocumentsProcessed =
            transactionResult['documentsProcessed'] ?? 0;
        _brandsDocumentsProcessed = brandsResult['documentsProcessed'] ?? 0;
        _cashiersDocumentsProcessed = cashiersResult['documentsProcessed'] ?? 0; // <-- Add this line
        _documentsProcessed = grnResult['totalDocumentsProcessed'] ?? 0;

        final totalProcessed =
            _documentsProcessed +
            _transactionDocumentsProcessed +
            _brandsDocumentsProcessed +
            _cashiersDocumentsProcessed; // <-- Update total

        if (grnResult['success'] &&
            transactionResult['success'] &&
            brandsResult['success'] &&
            cashiersResult['success']) { // <-- Add cashiersResult
          _statusMessage =
              'All data loaded successfully! Total: $totalProcessed documents processed.';
          _isSuccess = true;
          _showAllDataSuccessDialog();
        } else {
          _statusMessage =
              'Some data loading failed. Check individual results.';
          _isSuccess = false;
          _showErrorDialog(
            'Some data loading operations failed. Check the results above.',
          );
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Unexpected error during data loading: $e';
        _isSuccess = false;
      });
      _showErrorDialog('Unexpected error: $e');
    }
  }

  void _showAllDataSuccessDialog() {
    final totalProcessed =
        _documentsProcessed +
        _transactionDocumentsProcessed +
        _brandsDocumentsProcessed +
        _cashiersDocumentsProcessed; // <-- Update total
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('All Data Loaded Successfully'),
          content: Text(
            'Successfully loaded all data:\n'
            '• $_grnDocumentsProcessed GRN documents\n'
            '• $_grnItemDocumentsProcessed GRN Item documents\n'
            '• $_transactionDocumentsProcessed Transaction documents\n'
            '• $_brandsDocumentsProcessed Brands documents\n'
            '• $_cashiersDocumentsProcessed Cashiers documents\n' // <-- Add cashiers
            'Total: $totalProcessed documents processed',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sync Failed'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Connection Status Card
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Database Connection Status',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        _connectionStatus['source'] == true
                            ? Icons.check_circle
                            : Icons.error,
                        color: _connectionStatus['source'] == true
                            ? Colors.green
                            : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      const Text('Source Database: '),
                      Text(
                        _connectionStatus['source'] == true
                            ? 'Connected'
                            : 'Failed',
                        style: TextStyle(
                          color: _connectionStatus['source'] == true
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        _connectionStatus['destination'] == true
                            ? Icons.check_circle
                            : Icons.error,
                        color: _connectionStatus['destination'] == true
                            ? Colors.green
                            : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      const Text('Destination Database: '),
                      Text(
                        _connectionStatus['destination'] == true
                            ? 'Connected'
                            : 'Failed',
                        style: TextStyle(
                          color: _connectionStatus['destination'] == true
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _testConnections,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Test Connections'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Status Message
          if (_statusMessage.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isSuccess ? Colors.green[50] : Colors.red[50],
                border: Border.all(
                  color: _isSuccess ? Colors.green : Colors.red,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _isSuccess ? Icons.info : Icons.warning,
                    color: _isSuccess ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _statusMessage,
                      style: TextStyle(
                        color: _isSuccess ? Colors.green[800] : Colors.red[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (_statusMessage.isNotEmpty) const SizedBox(height: 20),

          // Load All Data Button
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Data Loading Operations',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Load all data (GRN, GRN Items, Transactions, Brands, and Cashiers) from source to destination database.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),

                  // Single Load All Data Button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton.icon(
                      onPressed:
                          _isLoading ||
                              _connectionStatus['source'] != true ||
                              _connectionStatus['destination'] != true
                          ? null
                          : _loadAllData,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.cloud_download, size: 28),
                      label: Text(
                        _isLoading ? 'Loading All Data...' : 'Load All Data',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  // Results Summary
                  if (_documentsProcessed > 0 ||
                      _transactionDocumentsProcessed > 0 ||
                      _brandsDocumentsProcessed > 0 ||
                      _cashiersDocumentsProcessed > 0) ...[ // <-- Add cashiers
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        border: Border.all(color: Colors.blue[200]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Data Loading Summary',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_grnDocumentsProcessed > 0 ||
                              _grnItemDocumentsProcessed > 0) ...[
                            Text(
                              'GRN Documents: $_grnDocumentsProcessed',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            Text(
                              'GRN Item Documents: $_grnItemDocumentsProcessed',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                          if (_transactionDocumentsProcessed > 0)
                            Text(
                              'Transaction Documents: $_transactionDocumentsProcessed',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.purple,
                              ),
                            ),
                          if (_brandsDocumentsProcessed > 0)
                            Text(
                              'Brands Documents: $_brandsDocumentsProcessed',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                          if (_cashiersDocumentsProcessed > 0) // <-- Add cashiers
                            Text(
                              'Cashiers Documents: $_cashiersDocumentsProcessed',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                          const SizedBox(height: 8),
                          Text(
                            'Total Documents Processed: ${_documentsProcessed + _transactionDocumentsProcessed + _brandsDocumentsProcessed + _cashiersDocumentsProcessed}', // <-- Update total
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Information Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Data Loading Information',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Source Database: Main configured database (from DatabaseConfig)\n'
                    '• Destination Database: Local database (localhost:27017/kashier)\n'
                    '• Collections: grn, grn_item, transactions, brands, cashiers\n' // <-- Add cashiers
                    '• Duplicate Prevention: Documents are checked before insertion\n'
                    '• Data Integrity: ObjectId references are preserved\n'
                    '• All Data Types: GRN, GRN Items, Transaction, Brands, and Cashiers data loaded together', // <-- Add cashiers
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Close database connections when widget is disposed
    DatabaseSyncService.closeConnections();
    super.dispose();
  }
}
