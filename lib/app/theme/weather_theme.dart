import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════════════════
//  WEATHER THEME EXTENSION — Single source of truth for all weather colors
//  Access via: Theme.of(context).extension<WeatherThemeExtension>()!
// ══════════════════════════════════════════════════════════════════════

@immutable
class WeatherThemeExtension extends ThemeExtension<WeatherThemeExtension> {
  // ── Text ─────────────────────────────────────────────────────────
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  // ── Glass card ───────────────────────────────────────────────────
  final Color glassBackground;
  final Color glassBorder;
  final Color glassNoiseOverlay;
  final double glassBlurSigma;

  // ── Background ───────────────────────────────────────────────────
  final List<Color> backgroundGradient;

  // ── Accents ──────────────────────────────────────────────────────
  final Color accentBlue;
  final Color accentCyan;
  final Color accentOrange;
  final Color accentPurple;
  final Color accentGreen;
  final Color accentYellow;
  final Color accentRed;

  // ── Weather condition ────────────────────────────────────────────
  final Color conditionGlow;

  // ── Badges / chips ───────────────────────────────────────────────
  final Color badgeBackground;
  final Color badgeBorder;

  // ── Dividers / subtle elements ───────────────────────────────────
  final Color divider;
  final Color iconMuted;

  // ── Particles ────────────────────────────────────────────────────
  final Color particleColor;
  final Color cloudColor;

  // ── Status dots ──────────────────────────────────────────────────
  final Color statusOk;
  final Color statusError;

  // ── Input / search ───────────────────────────────────────────────
  final Color inputBackground;
  final Color inputBorder;
  final Color inputHint;

  // ── Scaffold (weather-specific override) ─────────────────────────
  final Color scaffoldBg;

  const WeatherThemeExtension({
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.glassBackground,
    required this.glassBorder,
    required this.glassNoiseOverlay,
    required this.glassBlurSigma,
    required this.backgroundGradient,
    required this.accentBlue,
    required this.accentCyan,
    required this.accentOrange,
    required this.accentPurple,
    required this.accentGreen,
    required this.accentYellow,
    required this.accentRed,
    required this.conditionGlow,
    required this.badgeBackground,
    required this.badgeBorder,
    required this.divider,
    required this.iconMuted,
    required this.particleColor,
    required this.cloudColor,
    required this.statusOk,
    required this.statusError,
    required this.inputBackground,
    required this.inputBorder,
    required this.inputHint,
    required this.scaffoldBg,
  });

  // ── DARK THEME ───────────────────────────────────────────────────
  factory WeatherThemeExtension.dark() {
    return const WeatherThemeExtension(
      textPrimary: Color(0xFFFFFFFF),
      textSecondary: Color(0xFFAAB3C5),
      textMuted: Color(0xFF7C8798),
      glassBackground: Color(0x12FFFFFF),
      glassBorder: Color(0x14FFFFFF),
      glassNoiseOverlay: Color(0x09FFFFFF),
      glassBlurSigma: 24,
      backgroundGradient: [
        Color(0xFF08101B),
        Color(0xFF0F172A),
        Color(0xFF162238),
      ],
      accentBlue: Color(0xFF5E5CE6),
      accentCyan: Color(0xFF64D2FF),
      accentOrange: Color(0xFFFF9F0A),
      accentPurple: Color(0xFFAF52DE),
      accentGreen: Color(0xFF34C759),
      accentYellow: Color(0xFFFFD60A),
      accentRed: Color(0xFFFF453A),
      conditionGlow: Color(0x33FFB040),
      badgeBackground: Color(0x1EFFFFFF),
      badgeBorder: Color(0x0DFFFFFF),
      divider: Color(0x0FFFFFFF),
      iconMuted: Color(0x66FFFFFF),
      particleColor: Color(0xB3FFFFFF),
      cloudColor: Color(0x33FFFFFF),
      statusOk: Color(0xFF34C759),
      statusError: Color(0xFFFF453A),
      inputBackground: Color(0x14FFFFFF),
      inputBorder: Color(0x1AFFFFFF),
      inputHint: Color(0x4DFFFFFF),
      scaffoldBg: Color(0xFF08101B),
    );
  }

  // ── LIGHT THEME ──────────────────────────────────────────────────
  factory WeatherThemeExtension.light() {
    return const WeatherThemeExtension(
      textPrimary: Color(0xFF121826),
      textSecondary: Color(0xFF5A6472),
      textMuted: Color(0xFF8A93A3),
      glassBackground: Color(0xE6FFFFFF),
      glassBorder: Color(0x33FFFFFF),
      glassNoiseOverlay: Color(0x08000000),
      glassBlurSigma: 24,
      backgroundGradient: [
        Color(0xFFE8F0FE),
        Color(0xFFD6E8F7),
        Color(0xFFC5DCF0),
      ],
      accentBlue: Color(0xFF5E5CE6),
      accentCyan: Color(0xFF32B5D7),
      accentOrange: Color(0xFFE8860A),
      accentPurple: Color(0xFF9B4DCA),
      accentGreen: Color(0xFF28A745),
      accentYellow: Color(0xFFD4A800),
      accentRed: Color(0xFFDC3545),
      conditionGlow: Color(0x22FFB040),
      badgeBackground: Color(0x1A000000),
      badgeBorder: Color(0x0D000000),
      divider: Color(0x0D000000),
      iconMuted: Color(0x66121826),
      particleColor: Color(0x4D121826),
      cloudColor: Color(0x1A8A93A3),
      statusOk: Color(0xFF28A745),
      statusError: Color(0xFFDC3545),
      inputBackground: Color(0x0D000000),
      inputBorder: Color(0x1A000000),
      inputHint: Color(0x665A6472),
      scaffoldBg: Color(0xFFE8F0FE),
    );
  }

  // ── Weather-condition-specific overrides ──────────────────────────

  /// Returns a copy with the background gradient and glow adjusted
  /// for the given weather condition + night flag.
  WeatherThemeExtension withCondition({
    required String condition,
    required bool isNight,
  }) {
    final bg = _conditionGradient(condition, isNight);
    final glow = _conditionGlowColor(condition, isNight);
    return copyWith(backgroundGradient: bg, conditionGlow: glow);
  }

  static List<Color> _conditionGradient(String condition, bool isNight) {
    if (condition == 'rainy' || condition == 'stormy') {
      return isNight
          ? const [Color(0xFF070D1A), Color(0xFF0E1829), Color(0xFF14203A)]
          : const [Color(0xFF141E35), Color(0xFF1A2A48), Color(0xFF1E3050)];
    }
    if (condition == 'snowy') {
      return const [Color(0xFF2A3A58), Color(0xFF3A4E6E), Color(0xFF4A5E7E)];
    }
    if (condition == 'foggy') {
      return const [Color(0xFF1E2838), Color(0xFF283444), Color(0xFF323E4E)];
    }
    if (condition == 'cloudy') {
      return isNight
          ? const [Color(0xFF0A1020), Color(0xFF101828), Color(0xFF162035)]
          : const [Color(0xFF182844), Color(0xFF1E3050), Color(0xFF243858)];
    }
    if (isNight) {
      return const [Color(0xFF060A18), Color(0xFF0C1228), Color(0xFF121A35)];
    }
    final hour = DateTime.now().hour + DateTime.now().minute / 60.0;
    if (hour >= 5.0 && hour < 7.5) {
      return const [Color(0xFF2A1548), Color(0xFF5A2A60), Color(0xFFC87040)];
    }
    if (hour >= 7.5 && hour < 12.0) {
      return const [Color(0xFF1040A0), Color(0xFF1A5ADF), Color(0xFF4A95FF)];
    }
    if (hour >= 12.0 && hour < 17.0) {
      return const [Color(0xFF1530A0), Color(0xFF1A5ADF), Color(0xFF60B5FF)];
    }
    if (hour >= 17.0 && hour < 19.5) {
      return const [Color(0xFF2E1260), Color(0xFF7A2858), Color(0xFFD07038)];
    }
    return const [Color(0xFF0A1220), Color(0xFF101A30), Color(0xFF182240)];
  }

  static Color _conditionGlowColor(String condition, bool isNight) {
    switch (condition) {
      case 'rainy':
        return const Color(0x4D3A6FA0);
      case 'stormy':
        return const Color(0x405A7AC0);
      case 'snowy':
        return const Color(0x338AA0C0);
      case 'cloudy':
        return const Color(0x266080A0);
      default:
        return isNight
            ? const Color(0x332A3060)
            : const Color(0x26FFB040);
    }
  }

  @override
  WeatherThemeExtension copyWith({
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? glassBackground,
    Color? glassBorder,
    Color? glassNoiseOverlay,
    double? glassBlurSigma,
    List<Color>? backgroundGradient,
    Color? accentBlue,
    Color? accentCyan,
    Color? accentOrange,
    Color? accentPurple,
    Color? accentGreen,
    Color? accentYellow,
    Color? accentRed,
    Color? conditionGlow,
    Color? badgeBackground,
    Color? badgeBorder,
    Color? divider,
    Color? iconMuted,
    Color? particleColor,
    Color? cloudColor,
    Color? statusOk,
    Color? statusError,
    Color? inputBackground,
    Color? inputBorder,
    Color? inputHint,
    Color? scaffoldBg,
  }) {
    return WeatherThemeExtension(
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      glassBackground: glassBackground ?? this.glassBackground,
      glassBorder: glassBorder ?? this.glassBorder,
      glassNoiseOverlay: glassNoiseOverlay ?? this.glassNoiseOverlay,
      glassBlurSigma: glassBlurSigma ?? this.glassBlurSigma,
      backgroundGradient: backgroundGradient ?? this.backgroundGradient,
      accentBlue: accentBlue ?? this.accentBlue,
      accentCyan: accentCyan ?? this.accentCyan,
      accentOrange: accentOrange ?? this.accentOrange,
      accentPurple: accentPurple ?? this.accentPurple,
      accentGreen: accentGreen ?? this.accentGreen,
      accentYellow: accentYellow ?? this.accentYellow,
      accentRed: accentRed ?? this.accentRed,
      conditionGlow: conditionGlow ?? this.conditionGlow,
      badgeBackground: badgeBackground ?? this.badgeBackground,
      badgeBorder: badgeBorder ?? this.badgeBorder,
      divider: divider ?? this.divider,
      iconMuted: iconMuted ?? this.iconMuted,
      particleColor: particleColor ?? this.particleColor,
      cloudColor: cloudColor ?? this.cloudColor,
      statusOk: statusOk ?? this.statusOk,
      statusError: statusError ?? this.statusError,
      inputBackground: inputBackground ?? this.inputBackground,
      inputBorder: inputBorder ?? this.inputBorder,
      inputHint: inputHint ?? this.inputHint,
      scaffoldBg: scaffoldBg ?? this.scaffoldBg,
    );
  }

  @override
  WeatherThemeExtension lerp(WeatherThemeExtension? other, double t) {
    if (other is! WeatherThemeExtension) return this;
    return WeatherThemeExtension(
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      glassBackground: Color.lerp(glassBackground, other.glassBackground, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      glassNoiseOverlay: Color.lerp(glassNoiseOverlay, other.glassNoiseOverlay, t)!,
      glassBlurSigma: glassBlurSigma + (other.glassBlurSigma - glassBlurSigma) * t,
      backgroundGradient: List<Color>.generate(
        backgroundGradient.length,
        (i) => Color.lerp(
          backgroundGradient[i],
          i < other.backgroundGradient.length ? other.backgroundGradient[i] : backgroundGradient[i],
          t,
        )!,
      ),
      accentBlue: Color.lerp(accentBlue, other.accentBlue, t)!,
      accentCyan: Color.lerp(accentCyan, other.accentCyan, t)!,
      accentOrange: Color.lerp(accentOrange, other.accentOrange, t)!,
      accentPurple: Color.lerp(accentPurple, other.accentPurple, t)!,
      accentGreen: Color.lerp(accentGreen, other.accentGreen, t)!,
      accentYellow: Color.lerp(accentYellow, other.accentYellow, t)!,
      accentRed: Color.lerp(accentRed, other.accentRed, t)!,
      conditionGlow: Color.lerp(conditionGlow, other.conditionGlow, t)!,
      badgeBackground: Color.lerp(badgeBackground, other.badgeBackground, t)!,
      badgeBorder: Color.lerp(badgeBorder, other.badgeBorder, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      iconMuted: Color.lerp(iconMuted, other.iconMuted, t)!,
      particleColor: Color.lerp(particleColor, other.particleColor, t)!,
      cloudColor: Color.lerp(cloudColor, other.cloudColor, t)!,
      statusOk: Color.lerp(statusOk, other.statusOk, t)!,
      statusError: Color.lerp(statusError, other.statusError, t)!,
      inputBackground: Color.lerp(inputBackground, other.inputBackground, t)!,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t)!,
      inputHint: Color.lerp(inputHint, other.inputHint, t)!,
      scaffoldBg: Color.lerp(scaffoldBg, other.scaffoldBg, t)!,
    );
  }
}
