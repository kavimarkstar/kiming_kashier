import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

class internet_connection_check extends StatefulWidget {
  const internet_connection_check({Key? key}) : super(key: key);

  @override
  _internet_connection_checkState createState() =>
      _internet_connection_checkState();
}

class _internet_connection_checkState extends State<internet_connection_check>
    with TickerProviderStateMixin {
  bool _isConnected = false;
  bool _isChecking = false;
  String _networkType = 'Unknown';
  Timer? _checkTimer;
  String _lastError = '';
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize pulse animation
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
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

    // Set up periodic checking every 5 seconds for real-time monitoring
    _checkTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      _checkConnection();
    });
  }

  Future<void> _checkConnection() async {
    if (_isChecking) return; // Prevent multiple simultaneous checks

    setState(() {
      _isChecking = true;
    });

    // Start pulse animation when checking
    _pulseController.repeat(reverse: true);

    try {
      // Check internet connectivity by pinging a reliable server
      final result = await InternetAddress.lookup('google.com');

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          _isConnected = true;
          _networkType = _getNetworkType();
          _lastError = '';
        });
      } else {
        setState(() {
          _isConnected = false;
          _networkType = 'Unknown';
          _lastError = 'No internet connection';
        });
      }
    } catch (e) {
      setState(() {
        _isConnected = false;
        _networkType = 'Unknown';
        _lastError = e.toString();
      });
    } finally {
      setState(() {
        _isChecking = false;
      });

      // Stop pulse animation when done checking
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  String _getNetworkType() {
    // This is a simplified network type detection
    // In a real app, you might want to use connectivity_plus package
    return 'WiFi'; // Default to WiFi for now
  }

  IconData _getNetworkIcon() {
    if (_isChecking) {
      return Icons.network_check;
    } else if (_isConnected) {
      switch (_networkType.toLowerCase()) {
        case 'wifi':
          return Icons.wifi;
        case 'mobile':
          return Icons.signal_cellular_4_bar;
        case 'ethernet':
          return Icons.cable;
        default:
          return Icons.network_wifi;
      }
    } else {
      return Icons.wifi_off;
    }
  }

  Color _getNetworkIconColor() {
    if (_isChecking) {
      return Colors.orange;
    } else if (_isConnected) {
      return Colors.white;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),

      child: Tooltip(
        message: _lastError.isNotEmpty
            ? 'Error: $_lastError'
            : _isConnected
            ? 'Internet connected via $_networkType'
            : 'No internet connection',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Network Icon with Pulse Animation
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isChecking ? _pulseAnimation.value : 1.0,
                  child: Container(
                    width: 16,
                    height: 16,
                    child: Icon(
                      _getNetworkIcon(),
                      size: 20,
                      color: _getNetworkIconColor(),
                    ),
                  ),
                );
              },
            ),
            SizedBox(width: 8),
            // Status Text
            Text(
              _isConnected ? 'Online' : 'Offline',
              style: TextStyle(
                color: _isConnected ? Colors.white : Colors.red,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
