// lib/controllers/theme_controller.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static const String _keyThemeMode = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  ThemeController() {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString(_keyThemeMode);
      if (savedMode != null) {
        if (savedMode == 'light') _themeMode = ThemeMode.light;
        if (savedMode == 'dark') _themeMode = ThemeMode.dark;
        if (savedMode == 'system') _themeMode = ThemeMode.system;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading theme mode: $e');
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      String value = 'system';
      if (mode == ThemeMode.light) value = 'light';
      if (mode == ThemeMode.dark) value = 'dark';
      await prefs.setString(_keyThemeMode, value);
    } catch (e) {
      debugPrint('Error saving theme mode: $e');
    }
  }
}