// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:kiming_kashier/Server/database_sync_service.dart';
import 'package:kiming_kashier/core/home/home.dart';
import 'package:kiming_kashier/database/database_config.dart';

import 'package:kiming_kashier/theme/theme.dart';

enum BrandDisplayOption { logoOnly, logoAndName }

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  String _statusMessage = '';
  bool _isSuccess = false;
  int _documentsProcessed = 0;
  int _brandsDocumentsProcessed = 0;
  int _itemsDocumentsProcessed = 0;
  int _cashiersDocumentsProcessed = 0;
  Map<String, bool> _connectionStatus = {};
  // single "run all" state/result
  bool _isRunningAll = false;
  String? _runAllResultMessage;
  Map<String, dynamic>? _runAllResultDetails;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _adminFadeAnimation;
  late Animation<Offset> _adminSlideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller and animations first
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _adminFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );

    _adminSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
          ),
        );

    // Start animation and navigate when animation completes
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Start background data loading after animation completes
        _startBackgroundDataLoading();
        _navigateAfterSplash();
      }
    });
  }

  Future<void> _navigateAfterSplash() async {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomePage()),
    );
  }

  // Background data loading - runs silently without affecting UI
  Future<void> _startBackgroundDataLoading() async {
    try {
      // Load config silently
      bool loaded = DatabaseConfig.isConfigLoaded;
      if (!loaded) {
        loaded = await DatabaseConfig.autoLoadConfig();
      }

      if (!loaded) {
        print('Source config not found - data loading skipped');
        return;
      }

      // Run data loading in background without UI updates
      await _runBackgroundDataOperations();
    } catch (e) {
      print('Background data loading error: $e');
    }
  }

  // Background data operations - no UI state changes
  Future<void> _runBackgroundDataOperations() async {
    try {
      // Test connections silently
      final connResult = await DatabaseSyncService.testConnections();
      if (connResult['source'] != true || connResult['destination'] != true) {
        print('Connection check failed - background data loading skipped');
        return;
      }

      // Clear and replace collections silently
      await DatabaseSyncService.clearPreviewCollections();
      await DatabaseSyncService.replaceAllCollections();

      // Load data silently
      await _loadBackgroundData();

      print('Background data loading completed successfully');
    } catch (e) {
      print('Background data operations error: $e');
    }
  }

  // Background data loading - no UI updates
  Future<void> _loadBackgroundData() async {
    try {
      // Load all data types silently
      await DatabaseSyncService.syncBrandsData();
      await DatabaseSyncService.syncCashiersData();
      await DatabaseSyncService.syncItemsData();

      print('All background data loaded successfully');
    } catch (e) {
      print('Background data loading error: $e');
    }
  }

  // ==================== LOAD ALL DATA METHOD ====================

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _statusMessage =
          'Starting to load all data (GRN, GRN Items, Transactions, Brands, and Cashiers)...';
      _isSuccess = false;
      _documentsProcessed = 0;

      _brandsDocumentsProcessed = 0;
      _itemsDocumentsProcessed = 0;
      _cashiersDocumentsProcessed = 0;
    });

    try {
      // Load Brands data
      final brandsResult = await DatabaseSyncService.syncBrandsData();

      // Load Cashiers data
      final cashiersResult = await DatabaseSyncService.syncCashiersData();

      // Load Items data
      final itemsResult = await DatabaseSyncService.syncItemsData();

      final brandsCount = brandsResult['documentsProcessed'] ?? 0;
      final cashiersCount = cashiersResult['documentsProcessed'] ?? 0;
      final itemsCount = itemsResult['documentsProcessed'] ?? 0;

      final success =
          (brandsResult['success'] == true) &&
          (cashiersResult['success'] == true) &&
          (itemsResult['success'] == true);

      setState(() {
        _isLoading = false;
        _brandsDocumentsProcessed = brandsCount;
        _itemsDocumentsProcessed = itemsCount;
        _cashiersDocumentsProcessed = cashiersCount;
        _documentsProcessed = brandsCount + cashiersCount + itemsCount;
        _isSuccess = success;
        _statusMessage = success
            ? 'All selected data loaded successfully. Total: ${_documentsProcessed} documents.'
            : 'Some data loading operations failed. Check logs for details.';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Unexpected error during data loading: $e';
        _isSuccess = false;
      });
    }
  }

  // Run full workflow: clear preview collections, replace all collections, then load all data
  // ignore: unused_element
  Future<void> _runAllOperations() async {
    setState(() {
      _isRunningAll = true;
      _runAllResultMessage = null;
      _runAllResultDetails = null;
    });

    try {
      // Ensure source configuration is available
      if (!DatabaseConfig.isConfigLoaded) {
        final loaded = await DatabaseConfig.autoLoadConfig();
        if (!loaded) {
          setState(() {
            _runAllResultMessage = 'No source configuration found — aborting';
            _runAllResultDetails = {
              'connections': {'source': false, 'destination': null},
            };
          });
          return;
        }
      }
      // 1) test connections first
      final connResult = await DatabaseSyncService.testConnections();
      if (connResult['source'] != true || connResult['destination'] != true) {
        setState(() {
          _runAllResultMessage = 'Connection check failed — aborting';
          _runAllResultDetails = {'connections': connResult};
        });
        return;
      }

      // 2) clear preview collections
      final clearResult = await DatabaseSyncService.clearPreviewCollections();

      // 3) replace all collections
      final replaceResult = await DatabaseSyncService.replaceAllCollections();

      // 4) load data to update stats/UI
      await _loadAllData();

      final success =
          (clearResult['success'] == true) &&
          (replaceResult['success'] == true);
      setState(() {
        _runAllResultMessage = success
            ? 'Run All completed: cleared, replaced and loaded data successfully'
            : 'Run All completed with some failures (check details)';
        _runAllResultDetails = {
          'connections': connResult,
          'clear': clearResult,
          'replace': replaceResult,
        };
      });
    } catch (e) {
      setState(() {
        _runAllResultMessage = 'Error during Run All: $e';
        _runAllResultDetails = null;
      });
    } finally {
      setState(() => _isRunningAll = false);
    }
  }

  @override
  void dispose() {
    // Close database connections when widget is disposed
    DatabaseSyncService.closeConnections();

    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 160,
                      height: 160,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 30),
                    Text(
                      // show brand name when available
                      "KaptureX",
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 70,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    FadeTransition(
                      opacity: _adminFadeAnimation,
                      child: SlideTransition(
                        position: _adminSlideAnimation,
                        child: Text(
                          "The Point Of Business",
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Icon(Icons.play_circle_fill, size: 26),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
