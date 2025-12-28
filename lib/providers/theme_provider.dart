import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 主题状态管理 Provider
class ThemeProvider extends ChangeNotifier {
  final SharedPreferences prefs;
  ThemeMode _themeMode;

  ThemeProvider({required this.prefs})
      : _themeMode = _loadThemeMode(prefs);

  static ThemeMode _loadThemeMode(SharedPreferences prefs) {
    final themeModeKey = prefs.getString('theme_mode') ?? 'system';
    return ThemeMode.values.firstWhere(
      (mode) => mode.toString() == 'ThemeMode.$themeModeKey',
      orElse: () => ThemeMode.system,
    );
  }

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.dark) return true;
    if (_themeMode == ThemeMode.light) return false;
    return false; // System mode handled by MaterialApp
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await prefs.setString('theme_mode', mode.toString().split('.').last);
  }

  void toggleTheme() {
    final newMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    setThemeMode(newMode);
  }
}
