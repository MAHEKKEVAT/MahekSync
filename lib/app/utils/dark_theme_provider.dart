import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'dark_theme_preference.dart';

class DarkThemeProvider with ChangeNotifier {
  DarkThemePreference darkThemePreference = DarkThemePreference();
  int _darkTheme = 1;

  int get darkTheme => _darkTheme;

  set darkTheme(int value) {
    _darkTheme = value;
    darkThemePreference.setDarkTheme(value);
    notifyListeners();
  }

  /// Returns the effective [ThemeMode] for MaterialApp.
  ThemeMode get themeMode {
    switch (_darkTheme) {
      case 0:
        return ThemeMode.dark;
      case 1:
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  bool isDarkTheme() {
    return darkTheme == 0
        ? true
        : darkTheme == 1
            ? false
            : _getSystemDark();
  }

  bool _getSystemDark() {
    final brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.dark;
  }

  @Deprecated('Use _getSystemDark() instead')
  bool getSystemThem() => _getSystemDark();
}
