import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maheksync/app/theme/weather_theme.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';

class AppTheme {
  AppTheme._();

  static ThemeData dark() {
    return ThemeData(
      fontFamily: FontFamily.regular,
      fontFamilyFallback: const ['NotoSans'],
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppThemeData.grey10,
      primaryColor: AppThemeData.primary50,
      colorScheme: const ColorScheme.dark(
        surface: Color(0xFF0D0F14),
        surfaceContainer: Color(0xFF161822),
        surfaceContainerHighest: Color(0xFF1C1E2A),
        onSurface: Color(0xFFFFFFFF),
        primary: Color(0xFF5D54F2),
        onPrimary: Color(0xFFFFFFFF),
        secondary: Color(0xFF64D2FF),
        onSecondary: Color(0xFF000000),
        error: Color(0xFFFF453A),
        onError: Color(0xFFFFFFFF),
        outline: Color(0xFF2A2D3E),
      ),
      appBarTheme: const AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF111318).withValues(alpha: 0.95),
        elevation: 24,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        barrierColor: Colors.black.withValues(alpha: 0.6),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppThemeData.grey10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.06),
        thickness: 0.5,
      ),
      extensions: [
        WeatherThemeExtension.dark(),
      ],
    );
  }

  static ThemeData light() {
    return ThemeData(
      fontFamily: FontFamily.regular,
      fontFamilyFallback: const ['NotoSans'],
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFE8F0FE),
      primaryColor: AppThemeData.primary50,
      colorScheme: const ColorScheme.light(
        surface: Color(0xFFF8FAFD),
        surfaceContainer: Color(0xFFEEF2F7),
        surfaceContainerHighest: Color(0xFFE2E8F0),
        onSurface: Color(0xFF121826),
        primary: Color(0xFF5E5CE6),
        onPrimary: Color(0xFFFFFFFF),
        secondary: Color(0xFF32B5D7),
        onSecondary: Color(0xFF000000),
        error: Color(0xFFDC3545),
        onError: Color(0xFFFFFFFF),
        outline: Color(0xFFCBD5E1),
      ),
      appBarTheme: const AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.95),
        elevation: 24,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        barrierColor: Colors.black.withValues(alpha: 0.3),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.black.withValues(alpha: 0.06),
        thickness: 0.5,
      ),
      extensions: [
        WeatherThemeExtension.light(),
      ],
    );
  }

  /// Returns a [ThemeData] with the weather extension overridden by condition.
  static ThemeData darkWithCondition(String condition, bool isNight) {
    final base = dark();
    final weatherExt = base.extension<WeatherThemeExtension>()!
        .withCondition(condition: condition, isNight: isNight);
    return base.copyWith(extensions: [weatherExt]);
  }

  static ThemeData lightWithCondition(String condition, bool isNight) {
    final base = light();
    final weatherExt = base.extension<WeatherThemeExtension>()!
        .withCondition(condition: condition, isNight: isNight);
    return base.copyWith(extensions: [weatherExt]);
  }
}
