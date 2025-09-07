import 'dart:convert';
import 'dart:io';

import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
// ignore: unnecessary_import
import 'package:flutter/services.dart';
import 'package:kiming_kashier/database/database_config.dart';
import 'package:kiming_kashier/theme/theme.dart';

class Config extends StatefulWidget {
  final bool autoLoadExisting;

  const Config({Key? key, this.autoLoadExisting = false}) : super(key: key);

  @override
  _ConfigState createState() => _ConfigState();
}

class _ConfigState extends State<Config> {
  final TextEditingController hostController = TextEditingController();
  final TextEditingController portController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Load default values
  @override
  void initState() {
    super.initState();
    _loadDefaultValues();
    _loadLocalConfigPath();
  }

  void _loadDefaultValues() {
    // Load current DatabaseConfig values if configuration is loaded
    if (DatabaseConfig.isConfigLoaded) {
      hostController.text = DatabaseConfig.host;
      portController.text = DatabaseConfig.port.toString();
      nameController.text = DatabaseConfig.databaseName;
      usernameController.text = DatabaseConfig.username;
      passwordController.text = DatabaseConfig.password;
    } else {
      // Show empty fields if no configuration is loaded
      hostController.text = '';
      portController.text = '';
      nameController.text = '';
      usernameController.text = '';
      passwordController.text = '';
    }
  }

  void _loadLocalConfigPath() async {
    await DatabaseConfig.loadLocalConfigPath();
    setState(() {});
  }

  // Load configuration from a specific file path
  Future<void> loadConfigFromPath(String filePath) async {
    try {
      await DatabaseConfig.initializeWithConfig(filePath);

      // Update form fields with loaded data
      setState(() {
        hostController.text = DatabaseConfig.host;
        portController.text = DatabaseConfig.port.toString();
        nameController.text = DatabaseConfig.databaseName;
        usernameController.text = DatabaseConfig.username;
        passwordController.text = DatabaseConfig.password;
      });

      if (mounted) {
        AppTheme.showSuccessMessage(
          context,
          'Database configuration loaded and connected successfully!',
        );
      }
    } catch (e) {
      if (mounted) {
        AppTheme.showErrorMessage(context, 'Error loading configuration: $e');
      }
    }
  }

  // Create JSON configuration
  Map<String, dynamic> _createJsonConfig() {
    return {
      "host": hostController.text,
      "port": int.tryParse(portController.text) ?? 27017,
      "name": nameController.text,
      "username": usernameController.text,
      "password": passwordController.text,
    };
  }

  // Save JSON to local storage and open file manager
  Future<void> _saveConfigAsJson() async {
    try {
      final config = _createJsonConfig();
      final jsonString = const JsonEncoder.withIndent('  ').convert(config);

      // Update DatabaseConfig class with current form data
      DatabaseConfig.updateConfig(
        host: hostController.text,
        port: int.tryParse(portController.text) ?? 27017,
        databaseName: nameController.text,
        username: usernameController.text,
        password: passwordController.text,
      );

      // Save to local storage first
      await _saveToLocalStorage(jsonString);

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

  // Save to local storage
  Future<void> _saveToLocalStorage(String jsonString) async {
    // For now, we'll just print to console as local storage implementation
    // would depend on your specific storage solution (SharedPreferences, Hive, etc.)
    print('Saving to local storage: $jsonString');
  }

  // Save to file manager (desktop)
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

  // Select new local file path for saving configuration
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

  // Auto-load existing configuration file
  Future<void> _autoLoadExistingConfig() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Load Existing Database Configuration',
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        await loadConfigFromPath(filePath);
      }
    } catch (e) {
      if (mounted) {
        AppTheme.showErrorMessage(context, 'Error loading configuration: $e');
      }
    }
  }

  // Load configuration from JSON file
  Future<void> _loadConfigFromFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Load Database Configuration',
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final file = File(filePath);
        final jsonString = await file.readAsString();
        final config = jsonDecode(jsonString) as Map<String, dynamic>;

        // Update form fields
        setState(() {
          hostController.text = config['host']?.toString() ?? '';
          portController.text = config['port']?.toString() ?? '27017';
          nameController.text = config['name']?.toString() ?? '';
          usernameController.text = config['username']?.toString() ?? '';
          passwordController.text = config['password']?.toString() ?? '';
        });

        // Update DatabaseConfig class with loaded data
        DatabaseConfig.updateConfig(
          host: config['host']?.toString() ?? '',
          port: int.tryParse(config['port']?.toString() ?? '') ?? 27017,
          databaseName: config['name']?.toString() ?? '',
          username: config['username']?.toString() ?? '',
          password: config['password']?.toString() ?? '',
        );

        if (mounted) {
          AppTheme.showSuccessMessage(
            context,
            'Configuration loaded and applied successfully!',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppTheme.showErrorMessage(context, 'Error loading configuration: $e');
      }
    }
  }

  void _showConfigDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
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
                        _buildButton(
                          'Change Local Path',
                          () => _selectLocalFilePath(),
                          backgroundColor: Colors.blue.withOpacity(0.2),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),
                  _buildTextField('Host', 'Host', hostController),
                  SizedBox(height: 10),
                  _buildTextField('Port', 'Port', portController),
                  SizedBox(height: 10),
                  _buildTextField('Name', 'Name', nameController),
                  SizedBox(height: 10),
                  _buildTextField('Username', 'Username', usernameController),
                  SizedBox(height: 10),
                  _buildTextField('Password', 'Password', passwordController),

                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildButton(
                        'Load Config',
                        () => _loadConfigFromFile(),
                        backgroundColor: Colors.blue.withOpacity(0.1),
                      ),
                      Row(
                        children: [
                          _buildButton(
                            'Cancel',
                            () => Navigator.pop(context),
                            backgroundColor: Colors.white.withOpacity(0.05),
                          ),
                          SizedBox(width: 10),
                          _buildButton(
                            'Create & Export',
                            () => _saveConfigAsJson(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Only auto-show config dialog when widget is built if autoLoadExisting is true
    if (widget.autoLoadExisting) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _autoLoadExistingConfig();
      });
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _showConfigDialog,
            child: Text('Show Config'),
          ),
          SizedBox(height: 20),
          if (!DatabaseConfig.isConfigLoaded)
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'No database configuration loaded. Please load a configuration file first.',
                style: TextStyle(color: Colors.orange[800]),
                textAlign: TextAlign.center,
              ),
            ),
          SizedBox(height: 20),
          if (DatabaseConfig.localConfigPath.isNotEmpty)
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                border: Border.all(color: Colors.green),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'Local Configuration Path Set',
                    style: TextStyle(
                      color: Colors.green[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    DatabaseConfig.localConfigPath,
                    style: TextStyle(color: Colors.green[700], fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Configuration will be auto-loaded on app startup',
                    style: TextStyle(color: Colors.green[600], fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(
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

  Widget _buildButton(
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
}
