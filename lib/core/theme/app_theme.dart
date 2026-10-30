import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color primaryBlue = Color(0xFF385CF2);

  // Shared colors
  static const Color _lightBackground = Color(0xFFF6F8FC);
  static const Color _lightText = Color(0xFF172033);
  static const Color _lightDivider = Color(0xFFE5EAF3);

  static const Color _darkBackground = Color(0xFF10131A);
  static const Color _darkSurface = Color(0xFF171B24);
  static const Color _darkCard = Color(0xFF1B202B);
  static const Color _darkText = Color(0xFFF3F5F9);
  static const Color _darkDivider = Color(0xFF303847);

  static OutlineInputBorder _inputBorder({
    required Color color,
    double width = 1,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: color,
        width: width,
      ),
    );
  }

  // Light theme
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: _lightBackground,
    cardColor: Colors.white,
    dividerColor: _lightDivider,

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: _lightText,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: _lightText,
      ),
      bodyMedium: TextStyle(
        color: _lightText,
      ),
      titleLarge: TextStyle(
        color: _lightText,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: _lightText,
        fontWeight: FontWeight.w600,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: _inputBorder(
        color: _lightDivider,
      ),
      enabledBorder: _inputBorder(
        color: _lightDivider,
      ),
      focusedBorder: _inputBorder(
        color: primaryBlue,
        width: 1.5,
      ),
    ),

    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: Color(0xFFE3EBFF),
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryBlue;
        }
        return null;
      }),
    ),
  );

  // Dark theme
  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: _darkBackground,
    cardColor: _darkCard,
    dividerColor: _darkDivider,

    appBarTheme: const AppBarTheme(
      backgroundColor: _darkSurface,
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: _darkText,
      ),
      bodyMedium: TextStyle(
        color: _darkText,
      ),
      titleLarge: TextStyle(
        color: _darkText,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: _darkText,
        fontWeight: FontWeight.w600,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF202633),
      hintStyle: const TextStyle(
        color: Color(0xFF9AA4B5),
      ),
      border: _inputBorder(
        color: _darkDivider,
      ),
      enabledBorder: _inputBorder(
        color: _darkDivider,
      ),
      focusedBorder: _inputBorder(
        color: primaryBlue,
        width: 1.5,
      ),
    ),

    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: _darkSurface,
      indicatorColor: Color(0xFF293A75),
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryBlue;
        }
        return null;
      }),
    ),
  );
}
