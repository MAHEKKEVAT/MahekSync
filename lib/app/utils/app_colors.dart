// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';

class AppThemeData {
  static Color primaryWhite = Color(0xffFFFFFF);
  static Color primaryBlack = Color(0xff0D0D0D);

  // ── Primary (Indigo-Violet spectrum) ────────────────────────────────
  static const Color primary1 = Color(0xffE5ECFF);
  static const Color primary2 = Color(0xffA8C0FF);
  static const Color primary3 = Color(0xff6C94FF);
  static Color primary4 = const Color(0xff3068FF);
  static const Color primary5 = Color(0xff2047B2);
  static const Color primary6 = Color(0xff102766);
  static const Color primary7 = Color(0xff00071A);
  static Color primary50 = const Color(0xff5D54F2);

  // ── Secondary (Warm amber-orange) ───────────────────────────────────
  static const Color secondary1 = Color(0xffFEEDE2);
  static const Color secondary2 = Color(0xffFCC4A0);
  static const Color secondary3 = Color(0xffFA985B);
  static const Color secondary4 = Color(0xffF86C16);
  static const Color secondary5 = Color(0xffAD4C0F);
  static const Color secondary6 = Color(0xff632B08);
  static const Color secondary7 = Color(0xff190A01);

  // ── Grey scale ──────────────────────────────────────────────────────
  static const Color grey10 = Color(0xff1A1A1A);
  static const Color grey9 = Color(0xff2A2A2A);
  static const Color grey8 = Color(0xff3A3A3A);
  static const Color grey7 = Color(0xff4A4A4A);
  static const Color grey6 = Color(0xff6B6B6B);
  static const Color grey5 = Color(0xff9A9A9A);
  static const Color grey4 = Color(0xffD1D1D1);
  static const Color grey3 = Color(0xffE5E5E5);
  static const Color grey2 = Color(0xffF3F3F3);
  static const Color grey1 = Color(0xffFAFAFA);

  // ── Success ─────────────────────────────────────────────────────────
  static const Color success600 = Color(0xff001A0A);
  static const Color success500 = Color(0xff005421);
  static const Color success400 = Color(0xff008E38);
  static const Color success300 = Color(0xff00C750);
  static const Color success200 = Color(0xff4CDA85);
  static const Color success100 = Color(0xff98EDBA);
  static const Color success50 = Color(0xffE5FFF0);

  // ── Danger ──────────────────────────────────────────────────────────
  static const Color danger600 = Color(0xff1A0001);
  static const Color danger500 = Color(0xff5E0004);
  static const Color danger400 = Color(0xffA20007);
  static const Color danger300 = Color(0xffE7000B);
  static const Color danger200 = Color(0xffEF4C54);
  static const Color danger100 = Color(0xffF7989D);
  static const Color danger50 = Color(0xffFFE5E7);

  // ── Pending / Warning ───────────────────────────────────────────────
  static const Color pending600 = Color(0xff1A1400);
  static const Color pending500 = Color(0xff665000);
  static const Color pending400 = Color(0xffB28C00);
  static const Color pending300 = Color(0xffFDC700);
  static const Color pending200 = Color(0xffFED84C);
  static const Color pending100 = Color(0xffFFE998);
  static const Color pending50 = Color(0xffFFF9E5);

  // ══════════════════════════════════════════════════════════════════════
  //  NEON · GEMINI · APPLE INTELLIGENCE  COLOR SYSTEM
  //  Premium futuristic palette for dark-first neon UI
  // ══════════════════════════════════════════════════════════════════════

  // ── Neon Core ───────────────────────────────────────────────────────
  // Vivid, electric colors that glow on dark surfaces
  static const Color neonPurple     = Color(0xFFBF5AF2);  // Electric violet
  static const Color neonBlue       = Color(0xFF5E5CE6);  // Deep indigo
  static const Color neonCyan       = Color(0xFF32D74B);  // Apple green glow
  static const Color neonMint       = Color(0xFF00E5A8);  // Crypto/neon mint
  static const Color neonPink       = Color(0xFFFF375F);  // Apple pink
  static const Color neonOrange     = Color(0xFFFF9F0A);  // Apple amber
  static const Color neonYellow     = Color(0xFFFFD60A);  // Apple gold
  static const Color neonRed        = Color(0xFFFF453A);  // Apple red
  static const Color neonTeal       = Color(0xFF64D2FF);  // Apple teal
  static const Color neonLavender   = Color(0xFFAF52DE);  // Apple purple

  // ── Neon Dim (for backgrounds, borders, subtle glows) ──────────────
  static const Color neonPurpleDim     = Color(0xFF3A1D6E);  // Muted purple bg
  static const Color neonBlueDim       = Color(0xFF1C1A4E);  // Muted indigo bg
  static const Color neonCyanDim       = Color(0xFF0A2E1A);  // Muted green bg
  static const Color neonMintDim       = Color(0xFF0A2E24);  // Muted mint bg
  static const Color neonPinkDim       = Color(0xFF3A0A14);  // Muted pink bg
  static const Color neonOrangeDim     = Color(0xFF3A2500);  // Muted amber bg
  static const Color neonTealDim       = Color(0xFF0A2A3A);  // Muted teal bg

  // ── Gemini Gradient Colors ──────────────────────────────────────────
  // Google Gemini's signature blue→purple→pink gradient
  static const Color geminiBlue       = Color(0xFF4285F4);  // Gemini start
  static const Color geminiIndigo     = Color(0xFF651FFF);  // Gemini mid
  static const Color geminiPurple     = Color(0xFF9C27B0);  // Gemini deep
  static const Color geminiPink       = Color(0xFFE040FB);  // Gemini end
  static const Color geminiCoral      = Color(0xFFFF6D00);  // Gemini warm accent

  // Gemini gradient presets
  static const LinearGradient geminiGradient = LinearGradient(
    colors: [geminiBlue, geminiIndigo, geminiPurple, geminiPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient geminiGradientReversed = LinearGradient(
    colors: [geminiPink, geminiPurple, geminiIndigo, geminiBlue],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static const LinearGradient geminiGradientVertical = LinearGradient(
    colors: [geminiBlue, geminiIndigo, geminiPurple, geminiPink],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Apple Intelligence Colors ───────────────────────────────────────
  // Apple Intelligence: luminous purple→pink→orange→gold animated gradient
  static const Color appleIntelligencePurple = Color(0xFFBF5AF2);  // Core AI purple
  static const Color appleIntelligencePink   = Color(0xFFFF375F);  // AI warm pink
  static const Color appleIntelligenceOrange = Color(0xFFFF9F0A);  // AI glow orange
  static const Color appleIntelligenceGold   = Color(0xFFFFD60A);  // AI gold
  static const Color appleIntelligenceBlue   = Color(0xFF5E5CE6);  // AI cool blue

  // Apple Intelligence gradient presets
  static const LinearGradient appleIntelligenceGradient = LinearGradient(
    colors: [appleIntelligencePurple, appleIntelligencePink, appleIntelligenceOrange, appleIntelligenceGold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient appleIntelligenceGradientCool = LinearGradient(
    colors: [appleIntelligenceBlue, appleIntelligencePurple, appleIntelligencePink],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient appleIntelligenceGradientVertical = LinearGradient(
    colors: [appleIntelligenceBlue, appleIntelligencePurple, appleIntelligencePink, appleIntelligenceOrange, appleIntelligenceGold],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Neon Glow Gradients ─────────────────────────────────────────────
  static const LinearGradient neonPurpleBlueGradient = LinearGradient(
    colors: [neonPurple, neonBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient neonCyanMintGradient = LinearGradient(
    colors: [neonTeal, neonMint],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient neonPinkOrangeGradient = LinearGradient(
    colors: [neonPink, neonOrange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient neonBlueTealGradient = LinearGradient(
    colors: [neonBlue, neonTeal],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient neonSunsetGradient = LinearGradient(
    colors: [neonPink, neonPurple, neonBlue],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  // ── Dark Surface Palette (for neon backgrounds) ─────────────────────
  // Deep dark surfaces that make neon colors pop
  static const Color surfaceVoid       = Color(0xFF050507);  // Deepest black
  static const Color surfaceObsidian   = Color(0xFF0A0A0F);  // Near-black with blue tint
  static const Color surfaceDeep       = Color(0xFF0D0F14);  // Dark navy
  static const Color surfaceDark       = Color(0xFF111318);  // Dark charcoal
  static const Color surfaceMid        = Color(0xFF161822);  // Elevated surface
  static const Color surfaceElevated   = Color(0xFF1C1E2A);  // Card surface
  static const Color surfaceLight      = Color(0xFF242636);  // Hover/active surface
  static const Color surfaceBorder     = Color(0xFF2A2D3E);  // Border color
  static const Color surfaceHighlight  = Color(0xFF353849);  // Highlight border

  // ── Neon Text Tints (for labels on dark bg) ────────────────────────
  static const Color textNeonPurple = Color(0xFFD4A5FF);
  static const Color textNeonBlue   = Color(0xFFA8B8FF);
  static const Color textNeonCyan   = Color(0xFF7EEEE0);
  static const Color textNeonMint   = Color(0xFF66F5C6);
  static const Color textNeonPink   = Color(0xFFFF8FA3);
  static const Color textNeonOrange = Color(0xFFFFBF66);
  static const Color textNeonGold   = Color(0xFFFFE066);

  // ── Glow helpers ────────────────────────────────────────────────────
  /// Returns a BoxShadow that simulates a neon glow effect
  static List<BoxShadow> neonGlow(Color color, {double blur = 20, double spread = 0, double opacity = 0.4}) {
    return [
      BoxShadow(
        color: color.withOpacity(opacity),
        blurRadius: blur,
        spreadRadius: spread,
      ),
      BoxShadow(
        color: color.withOpacity(opacity * 0.5),
        blurRadius: blur * 2,
        spreadRadius: spread,
      ),
    ];
  }

  /// Returns a subtle inner glow decoration for containers
  static BoxDecoration neonGlowBox({
    required Color glowColor,
    Color? bgColor,
    double radius = 16,
    double glowOpacity = 0.15,
    double borderWidth = 1.0,
  }) {
    return BoxDecoration(
      color: bgColor ?? surfaceDeep,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: glowColor.withOpacity(glowOpacity * 2),
        width: borderWidth,
      ),
      boxShadow: neonGlow(glowColor, opacity: glowOpacity),
    );
  }
  static const Color textNeonTeal = Color(0xFF9DD8FF);  // Light pastel teal for dark-mode text

  /// Returns a gradient border decoration (like Gemini/Apple AI rings)
  static BoxDecoration gradientBorderBox({
    required Gradient gradient,
    Color? fillColor,
    double radius = 16,
    double borderWidth = 1.5,
  }) {
    return BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(radius),
    );
    // Usage: Stack with gradient container behind + inner container with fillColor
  }


  static const LinearGradient glassShimmerDark = LinearGradient(
    colors: [
      Color(0x10FFFFFF), // Near-transparent white
      Color(0x05FFFFFF),
      Color(0x10FFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Subtle shimmer gradient for glass surfaces in light mode
  static const LinearGradient glassShimmerLight = LinearGradient(
    colors: [
      Color(0x18FFFFFF),
      Color(0x08FFFFFF),
      Color(0x18FFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

}
