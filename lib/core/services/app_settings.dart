import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persisted user preferences: theme mode and locale.
class AppSettings {
  AppSettings(this._prefs);

  final SharedPreferences _prefs;
  static const _keyTheme = 'theme_mode';
  static const _keyLocale = 'locale_code';

  ThemeMode get themeMode {
    switch (_prefs.getString(_keyTheme)) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String get localeCode => _prefs.getString(_keyLocale) ?? 'en';

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(_keyTheme, mode.name);
  }

  Future<void> setLocale(String code) async {
    await _prefs.setString(_keyLocale, code);
  }
}