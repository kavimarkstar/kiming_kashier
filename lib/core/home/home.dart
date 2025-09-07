import 'dart:convert';
import 'dart:io';

import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:kiming_kashier/core/view/bottom/bottom.dart';
import 'package:kiming_kashier/core/view/keyboard/keyboard.dart';
import 'package:kiming_kashier/core/view/middle/middle.dart';
import 'package:kiming_kashier/core/view/top/top.dart';
import 'package:kiming_kashier/database/database_config.dart';
import 'package:kiming_kashier/main.dart';
import 'package:kiming_kashier/theme/theme.dart';
import 'package:window_manager/window_manager.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomePage>
    with TickerProviderStateMixin, WindowListener {
  bool isShow = false;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _init();

    // Start with keyboard visible
    _animationController.reverse();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    _animationController.dispose();
    super.dispose();
  }

  void showBottom() {
    setState(() {
      isShow = !isShow;
    });

    if (isShow) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  // Database configuration controllers
  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _init() async {
    // Set the initial full screen state

    // Try to auto-load database configuration
    try {
      final configLoaded = await DatabaseConfig.autoLoadConfig();
      if (configLoaded) {
        print('Database configuration auto-loaded successfully');
      } else {
        print('No database configuration found to auto-load');
        // Show Database Setup popup if no saved path exists
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showDatabaseSetupPopup();
        });
      }
    } catch (e) {
      print('Error auto-loading database configuration: $e');
      // Show Database Setup popup if the saved file path exists but file is not found
      if (e.toString().contains('FILE_NOT_FOUND')) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showDatabaseSetupPopup();
        });
      }
    }

    setState(() {});
  }

  void _showDatabaseSetupPopup() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) => _DatabaseSetupDialog(),
    );
  }

  // ignore: non_constant_identifier_names
  Widget _DatabaseSetupDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(width: 0.2, color: Colors.white),
          borderRadius: const BorderRadius.all(Radius.circular(6)),
        ),
        child: BlurryContainer(
          blur: 5,
          elevation: 0,
          color: Colors.white.withOpacity(0.05),
          padding: const EdgeInsets.all(8),
          borderRadius: const BorderRadius.all(Radius.circular(6)),
          width: MediaQuery.of(context).size.width * 0.4,
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Database Setup',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),

                // Local file path section
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Local Configuration Path',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[300],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        DatabaseConfig.localConfigPath.isEmpty
                            ? 'No local path set'
                            : DatabaseConfig.localConfigPath,
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                      SizedBox(height: 8),
                      _buildDialogButton(
                        'Change Local Path',
                        () => _selectLocalFilePath(),
                        backgroundColor: Colors.blue.withOpacity(0.2),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),
                _buildDialogTextField('Host', 'Host', _hostController),
                SizedBox(height: 10),
                _buildDialogTextField('Port', 'Port', _portController),
                SizedBox(height: 10),
                _buildDialogTextField('Name', 'Name', _nameController),
                SizedBox(height: 10),
                _buildDialogTextField(
                  'Username',
                  'Username',
                  _usernameController,
                ),
                SizedBox(height: 10),
                _buildDialogTextField(
                  'Password',
                  'Password',
                  _passwordController,
                ),

                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDialogButton(
                      'Load Config',
                      () => _loadConfigFromFile(),
                      backgroundColor: Colors.blue.withOpacity(0.1),
                    ),

                    Row(
                      children: [
                        _buildDialogButton(
                          'Cancel',
                          () => Navigator.pop(context),
                          backgroundColor: Colors.white.withOpacity(0.05),
                        ),
                        SizedBox(width: 10),
                        _buildDialogButton(
                          'Create & Export',
                          () => _saveConfigAsJson(),
                        ),
                        SizedBox(width: 10),
                        _buildDialogButton('Save', () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MyApp()),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods for database setup dialog
  Widget _buildDialogTextField(
    String label,
    String hint,
    TextEditingController controller,
  ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildDialogButton(
    String label,
    VoidCallback onPressed, {
    Color? backgroundColor,
  }) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: backgroundColor ?? AppTheme.primaryColor,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      onPressed: onPressed,
      child: Text(label, style: TextStyle(color: Colors.white)),
    );
  }

  Future<void> _selectLocalFilePath() async {
    try {
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Select Local Configuration File Path',
        fileName: 'database_config.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
        initialDirectory: Platform.isWindows
            ? '${Platform.environment['USERPROFILE']}\\Documents'
            : Platform.isMacOS
            ? '${Platform.environment['HOME']}/Documents'
            : Platform.isLinux
            ? '${Platform.environment['HOME']}/Documents'
            : null,
      );

      if (outputFile != null) {
        await DatabaseConfig.saveLocalConfigPath(outputFile);
        setState(() {});

        if (mounted) {
          AppTheme.showSuccessMessage(
            context,
            'Local file path updated: $outputFile',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppTheme.showErrorMessage(context, 'Error selecting file path: $e');
      }
    }
  }

  Future<void> _loadConfigFromFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Load Database Configuration',
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        await DatabaseConfig.initializeWithConfig(filePath);

        // Update form fields with loaded data
        setState(() {
          _hostController.text = DatabaseConfig.host;
          _portController.text = DatabaseConfig.port.toString();
          _nameController.text = DatabaseConfig.databaseName;
          _usernameController.text = DatabaseConfig.username;
          _passwordController.text = DatabaseConfig.password;
        });

        if (mounted) {
          Navigator.pop(context);
          AppTheme.showSuccessMessage(
            context,
            'Database configuration loaded and connected successfully!',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppTheme.showErrorMessage(context, 'Error loading configuration: $e');
      }
    }
  }

  Future<void> _saveConfigAsJson() async {
    try {
      final config = {
        "host": _hostController.text,
        "port": int.tryParse(_portController.text) ?? 27017,
        "name": _nameController.text,
        "username": _usernameController.text,
        "password": _passwordController.text,
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(config);

      // Update DatabaseConfig class with current form data
      DatabaseConfig.updateConfig(
        host: _hostController.text,
        port: int.tryParse(_portController.text) ?? 27017,
        databaseName: _nameController.text,
        username: _usernameController.text,
        password: _passwordController.text,
      );

      // If local path is set, save to that path
      if (DatabaseConfig.localConfigPath.isNotEmpty) {
        await DatabaseConfig.saveToJsonFile(DatabaseConfig.localConfigPath);
      } else {
        // Open file picker to save to desktop
        await _saveToFileManager(jsonString);
      }

      if (mounted) {
        Navigator.pop(context);
        AppTheme.showSuccessMessage(
          context,
          'Configuration saved and applied successfully!',
        );
      }
    } catch (e) {
      if (mounted) {
        AppTheme.showErrorMessage(context, 'Error saving configuration: $e');
      }
    }
  }

  Future<void> _saveToFileManager(String jsonString) async {
    try {
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Database Configuration',
        fileName: 'database_config.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
        initialDirectory: Platform.isWindows
            ? '${Platform.environment['USERPROFILE']}\\Desktop'
            : Platform.isMacOS
            ? '${Platform.environment['HOME']}/Desktop'
            : Platform.isLinux
            ? '${Platform.environment['HOME']}/Desktop'
            : null,
      );

      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsString(jsonString);
        print('File saved to: $outputFile');
      }
    } catch (e) {
      print('Error saving file: $e');
      rethrow;
    }
  }

  @override
  void onWindowEvent(String eventName) {
    if (eventName == 'enter-full-screen') {
      setState(() {});
    } else if (eventName == 'leave-full-screen') {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff151515),
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                hedderbuild(context, showBottom),

                middlebuild(context),
                bottombuild(context, isShow),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return Container(
                width:
                    MediaQuery.of(context).size.width *
                    0.3 *
                    _slideAnimation.value,
                height: MediaQuery.of(context).size.height,
                child: _slideAnimation.value > 0
                    ? Opacity(opacity: _slideAnimation.value, child: Keyboard())
                    : SizedBox.shrink(),
              );
            },
          ),
        ],
      ),
    );
  }
}
