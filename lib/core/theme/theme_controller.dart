import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeController._();

  static final ThemeController instance = ThemeController._();

  static const String _themeKey = 'app_theme_mode';

  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Load the saved theme from SharedPreferences.
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    final Object? savedValue = prefs.get(_themeKey);

    bool isDark = false;

    if (savedValue is bool) {
      isDark = savedValue;
    } else if (savedValue is String) {
      final value = savedValue.toLowerCase().trim();
      isDark = value == 'true' || value == 'dark';
    }

    final newThemeMode = isDark ? ThemeMode.dark : ThemeMode.light;

    if (_themeMode != newThemeMode) {
      _themeMode = newThemeMode;
      notifyListeners();
    }

    // Normalize the stored value to a boolean.
    if (savedValue is! bool || savedValue != isDark) {
      await prefs.setBool(_themeKey, isDark);
    }
  }

  /// Change the theme and save the user's preference.
  Future<void> toggleTheme(bool isDark) async {
    final newThemeMode = isDark ? ThemeMode.dark : ThemeMode.light;

    if (_themeMode == newThemeMode) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_themeKey, isDark);

    _themeMode = newThemeMode;

    notifyListeners();
  }

  /// Set a specific theme mode.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == ThemeMode.system) {
      return;
    }

    await toggleTheme(mode == ThemeMode.dark);
  }
}
