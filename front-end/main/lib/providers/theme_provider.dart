import 'package:flutter/material.dart';
import '../services/hive_service.dart';

enum AppThemeMode { system, light, dark }

class ThemeProvider extends ChangeNotifier {
  ThemeProvider(this._hive);
  final HiveService _hive;
  static const _key = 'themeMode';
  AppThemeMode _mode = AppThemeMode.light;
  AppThemeMode get mode => _mode;
  bool get isDark => _mode == AppThemeMode.dark;
  ThemeMode get themeMode => switch (_mode) {
        AppThemeMode.system => ThemeMode.system,
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark
      };
  Future<void> load() async {
    final stored = _hive.settings.get(_key) as String?;
    _mode = AppThemeMode.values
        .firstWhere((m) => m.name == stored, orElse: () => AppThemeMode.light);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) =>
      setMode(value ? AppThemeMode.dark : AppThemeMode.light);
  Future<void> setMode(AppThemeMode value) async {
    _mode = value;
    notifyListeners();
    await _hive.settings.put(_key, value.name);
  }
}
