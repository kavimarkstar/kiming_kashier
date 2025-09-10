import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';

/// App Theme Configuration
/// Defines the color scheme, text styles, and component themes for Kiming Inventory Suite
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // ==================== COLOR SCHEME ====================

  /// Primary brand color - Windows 11 blue
  static const Color primaryColor = Color(0xFF00E297);

  /// Primary color with opacity variations
  static const Color primaryLight = Color(0xFF40A9FF);
  static const Color primaryDark = Color(0xFF005A9E);

  /// Secondary accent color
  static const Color secondaryColor = Color(0xFF605E5C);

  /// Background colors
  static const Color backgroundColor = Color(
    0xFFF3F2F1,
  ); // Windows 11 background
  static const Color surfaceColor = Colors.white;
  static const Color cardColor = Colors.white;

  /// Text colors
  static const Color textPrimary = Color(0xFF323130);
  static const Color textSecondary = Color(0xFF605E5C);
  static const Color textTertiary = Color(0xFF8A8886);
  static const Color textDisabled = Color(0xFFC8C6C4);

  /// Border and divider colors
  static const Color borderColor = Color(0xFFE1DFDD);
  static const Color dividerColor = Color(0xFFE1DFDD);

  /// Status colors
  static const Color successColor = Color(0xFF107C10);
  static const Color warningColor = Color(0xFFD83B01);
  static const Color errorColor = Color(0xFFD13438);
  static const Color infoColor = Color(0xFF0078D4);

  /// Shadow colors
  static const Color shadowColor = Color(0x1A000000);
  static const Color shadowColorLight = Color(0x0A000000);

  // ==================== TEXT STYLES ====================

  /// Display text styles
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: -0.25,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  /// Headline text styles
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  /// Title text styles
  static const TextStyle titleLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  /// Body text styles
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textPrimary,
  );

  /// Label text styles
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  // ==================== COMPONENT THEMES ====================

  /// App bar theme
  static const AppBarTheme appBarTheme = AppBarTheme(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    iconTheme: IconThemeData(color: Colors.white, size: 24),
  );

  /// Elevated button theme
  static final ElevatedButtonThemeData elevatedButtonTheme =
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      );

  /// Outlined button theme
  static final OutlinedButtonThemeData outlinedButtonTheme =
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      );

  /// Text button theme
  static final TextButtonThemeData textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    ),
  );

  /// Input decoration theme
  static final InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: surfaceColor,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: borderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: primaryColor, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: errorColor),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: errorColor, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    labelStyle: const TextStyle(color: textSecondary),
    hintStyle: const TextStyle(color: textTertiary),
  );

  /// Card theme
  static final CardThemeData cardTheme = CardThemeData(
    color: surfaceColor,
    elevation: 2,
    shadowColor: shadowColor,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    margin: const EdgeInsets.all(8),
  );

  /// Divider theme
  static const DividerThemeData dividerTheme = DividerThemeData(
    color: dividerColor,
    thickness: 1,
    space: 1,
  );

  /// Icon theme
  static const IconThemeData iconTheme = IconThemeData(
    color: textSecondary,
    size: 24,
  );

  /// Icon theme for primary color
  static const IconThemeData primaryIconTheme = IconThemeData(
    color: primaryColor,
    size: 24,
  );

  /// Icon theme for white color
  static const IconThemeData whiteIconTheme = IconThemeData(
    color: Colors.white,
    size: 24,
  );

  // ==================== CUSTOM DECORATIONS ====================

  /// Popup window decoration
  static BoxDecoration get popupWindowDecoration => BoxDecoration(
    color: surfaceColor,
    borderRadius: BorderRadius.circular(6),
    boxShadow: [
      BoxShadow(
        color: shadowColor,
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  );

  // ==================== SCAFFOLD MESSAGE HELPERS ====================

  /// Show success message
  static void showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        margin: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.65,
          bottom: 100,
          right: 0,
        ),

        content: Container(
          decoration: BoxDecoration(
            border: Border.all(width: 0.5, color: Colors.white),
            borderRadius: BorderRadius.circular(12),
          ),
          child: BlurryContainer(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            blur: 10,
            elevation: 10,

            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Success',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        message,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFE1E1E1),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SnackBarAction(
                  label: 'Dismiss',
                  textColor: Colors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Show error message
  static void showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        margin: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.65,
          bottom: 100,
          right: 0,
        ),
        content: Container(
          decoration: BoxDecoration(
            border: Border.all(width: 0.5, color: Colors.white),
            borderRadius: BorderRadius.circular(12),
          ),
          child: BlurryContainer(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            blur: 10,
            elevation: 10,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.error, color: Colors.red, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Error',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        message,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFE1E1E1),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SnackBarAction(
                  label: 'Dismiss',
                  textColor: Colors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.transparent.withOpacity(0.00),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Show warning message
  static void showWarningMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        margin: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.65,
          bottom: 100,
          right: 0,
        ),
        content: Container(
          decoration: BoxDecoration(
            border: Border.all(width: 0.5, color: Colors.white),
            borderRadius: BorderRadius.circular(12),
          ),
          child: BlurryContainer(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            blur: 10,
            elevation: 10,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.warning,
                    color: Colors.orange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Warning',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        message,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFE1E1E1),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SnackBarAction(
                  label: 'Dismiss',
                  textColor: Colors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Show info message
  static void showInfoMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        margin: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.65,
          bottom: 100,
          right: 0,
        ),
        content: Container(
          decoration: BoxDecoration(
            border: Border.all(width: 0.5, color: Colors.white),
            borderRadius: BorderRadius.circular(12),
          ),
          child: BlurryContainer(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            blur: 10,
            elevation: 10,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.info, color: Colors.blue, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Information',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        message,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFE1E1E1),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SnackBarAction(
                  label: 'Dismiss',
                  textColor: Colors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Show loading message
  static void showLoadingMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        margin: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.65,
          bottom: 100,
          right: 0,
        ),
        content: Container(
          decoration: BoxDecoration(
            border: Border.all(width: 0.5, color: Colors.white),
            borderRadius: BorderRadius.circular(12),
          ),
          child: BlurryContainer(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            blur: 10,
            elevation: 10,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Loading',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        message,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFE1E1E1),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SnackBarAction(
                  label: 'Dismiss',
                  textColor: Colors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Tab button decoration
  static BoxDecoration get tabButtonDecoration => BoxDecoration(
    color: primaryColor,
    borderRadius: BorderRadius.circular(6),
    boxShadow: [
      BoxShadow(
        color: primaryColor.withOpacity(0.3),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  /// Status indicator decoration
  static BoxDecoration get statusIndicatorDecoration => BoxDecoration(
    color: successColor,
    borderRadius: BorderRadius.circular(12),
  );

  // ==================== THEME ====================

  /// App theme data
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: Color(0xFF1F1F1F),
        background: Color(0xFF0F0F0F),
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFFE1E1E1),
        onBackground: Color(0xFFE1E1E1),
        onError: Colors.white,
      ),

      // Text themes with dark colors
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: Color(0xFFE1E1E1),
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE1E1E1),
          letterSpacing: -0.25,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE1E1E1),
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE1E1E1),
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE1E1E1),
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE1E1E1),
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE1E1E1),
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE1E1E1),
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE1E1E1),
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Color(0xFFE1E1E1),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFFE1E1E1),
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Color(0xFFE1E1E1),
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFFE1E1E1),
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFFE1E1E1),
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Color(0xFFE1E1E1),
        ),
      ),

      // Component themes for dark mode
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1F1F1F),
        foregroundColor: Color(0xFFE1E1E1),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE1E1E1),
        ),
        iconTheme: IconThemeData(color: Color(0xFFE1E1E1), size: 24),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF404040)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF404040)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        labelStyle: const TextStyle(color: Color(0xFFB0B0B0)),
        hintStyle: const TextStyle(color: Color(0xFF808080)),
      ),

      cardTheme: CardThemeData(
        color: const Color(0xFF1F1F1F),
        elevation: 2,
        shadowColor: const Color(0x40000000),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        margin: const EdgeInsets.all(8),
      ),

      dividerTheme: const DividerThemeData(
        color: Color(0xFF404040),
        thickness: 1,
        space: 1,
      ),

      iconTheme: const IconThemeData(color: Color(0xFFB0B0B0), size: 24),

      // SnackBar theme for scaffold messages
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF1F1F1F),
        contentTextStyle: const TextStyle(
          color: Color(0xFFE1E1E1),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        actionTextColor: primaryColor,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 8,
      ),

      // Scaffold background
      scaffoldBackgroundColor: const Color(0xFF0F0F0F),
    );
  }
}

/// Extension methods for easy theme access
extension ThemeExtension on BuildContext {
  /// Get text styles
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Get color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Get primary color
  Color get primaryColor => colorScheme.primary;

  /// Get background color
  Color get backgroundColor => colorScheme.background;

  /// Get surface color
  Color get surfaceColor => colorScheme.surface;

  /// Show success message
  void showSuccess(String message) =>
      AppTheme.showSuccessMessage(this, message);

  /// Show error message
  void showError(String message) => AppTheme.showErrorMessage(this, message);

  /// Show warning message
  void showWarning(String message) =>
      AppTheme.showWarningMessage(this, message);

  /// Show info message
  void showInfo(String message) => AppTheme.showInfoMessage(this, message);

  /// Show loading message
  void showLoading(String message) =>
      AppTheme.showLoadingMessage(this, message);
}
