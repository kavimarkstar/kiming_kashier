// ignore_for_file: camel_case_types

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kiming_kashier/database/database_config.dart';

class db_connection_check extends StatefulWidget {
  // ignore: use_super_parameters
  const db_connection_check({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _db_connection_checkState createState() => _db_connection_checkState();
}

class _db_connection_checkState extends State<db_connection_check>
    with TickerProviderStateMixin {
  bool _isConnected = false;
  bool _isChecking = false;

  Timer? _checkTimer;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize pulse animation
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startConnectionCheck();
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startConnectionCheck() {
    // Check immediately
    _checkConnection();

    // Set up periodic checking every 10 seconds for real-time updates
    _checkTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      _checkConnection();
    });
  }

  Future<void> _checkConnection() async {
    if (_isChecking) return; // Prevent multiple simultaneous checks

    setState(() {
      _isChecking = true;
    });

    // Start pulse animation while checking
    _pulseController.repeat(reverse: true);

    try {
      // Try to get database connection
      final db = await DatabaseConfig.database;

      // Test the connection with a simple operation
      final cursor = db.collection('test').find();
      await cursor.toList();

      setState(() {
        _isConnected = true;
      });
    } catch (e) {
      setState(() {
        _isConnected = false;
      });
    } finally {
      // Stop pulse animation
      _pulseController.stop();
      _pulseController.reset();

      setState(() {
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return
    // Animated Status Light
    AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isChecking ? _pulseAnimation.value : 1.0,
          child: IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.wifi,
              color: _isChecking
                  ? Colors.orange
                  : _isConnected
                  ? Color(0xff00a877)
                  : Colors.red,
              shadows: [
                BoxShadow(
                  color:
                      (_isChecking
                              ? Colors.orange
                              : _isConnected
                              ? Color(0xff00a877)
                              : Colors.red)
                          .withOpacity(0.6),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
