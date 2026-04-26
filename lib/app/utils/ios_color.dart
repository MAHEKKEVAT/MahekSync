import 'package:flutter/material.dart';

/// ===============================================
/// 🍏 iOS 26/27 Inspired Global Design System
/// Minimal • Glass • Soft • Premium • Reusable
/// ===============================================
class IOSColors {
  IOSColors._();

  // =====================================================
  // 🎯 BASE BRAND COLOR (CHANGE THIS ONLY)
  // =====================================================
  static const Color brand = Color(0xFF6C63FF);

  // =====================================================
  // 🎨 DYNAMIC SHADE GENERATOR
  // =====================================================
  static Color shade(Color color, double factor) {
    return Color.lerp(
      color,
      factor > 0 ? Colors.white : Colors.black,
      factor.abs(),
    )!;
  }

  // Brand Shades
  static Color brand50  = shade(brand, 0.9);
  static Color brand100 = shade(brand, 0.7);
  static Color brand200 = shade(brand, 0.5);
  static Color brand300 = shade(brand, 0.3);
  static Color brand400 = shade(brand, 0.1);
  static Color brand500 = brand;
  static Color brand600 = shade(brand, -0.1);
  static Color brand700 = shade(brand, -0.25);
  static Color brand800 = shade(brand, -0.4);
  static Color brand900 = shade(brand, -0.6);

  // =====================================================
  // 🌑 BACKGROUND SYSTEM
  // =====================================================
  static const Color bgPrimary   = Color(0xFF0E0F13);
  static const Color bgSecondary = Color(0xFF15171C);
  static const Color bgTertiary  = Color(0xFF1B1E24);
  static const Color bgOverlay   = Color(0xCC0E0F13);

  // =====================================================
  // 🧊 SURFACE SYSTEM
  // =====================================================
  static const Color surfacePrimary   = Color(0xFF1C1F26);
  static const Color surfaceSecondary = Color(0xFF22252D);
  static const Color surfaceElevated  = Color(0xFF2A2E38);

  // =====================================================
  // 🪟 GLASSMORPHISM (CORE OF iOS FEEL)
  // =====================================================
  static const Color glassLow   = Color(0x0FFFFFFF);
  static const Color glassMid   = Color(0x1FFFFFFF);
  static const Color glassHigh  = Color(0x2AFFFFFF);

  static BoxDecoration glass = BoxDecoration(
    color: glassMid,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Colors.white.withOpacity(0.08)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.25),
        blurRadius: 25,
        offset: const Offset(0, 10),
      ),
    ],
  );

  // =====================================================
  // ✍️ TEXT SYSTEM
  // =====================================================
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB8BCC8);
  static const Color textTertiary  = Color(0xFF8A8F9C);
  static const Color textDisabled  = Color(0xFF5C5F6B);

  // =====================================================
  // 🧱 BORDERS / DIVIDERS
  // =====================================================
  static const Color borderSubtle = Color(0x14FFFFFF);
  static const Color borderSoft   = Color(0x1FFFFFFF);
  static const Color borderStrong = Color(0x33FFFFFF);

  // =====================================================
  // 🌈 SYSTEM COLORS (GLOBAL USE)
  // =====================================================
  static const Color success = Color(0xFF30D158);
  static const Color warning = Color(0xFFFF9F0A);
  static const Color error   = Color(0xFFFF453A);
  static const Color info    = Color(0xFF0A84FF);

  // =====================================================
  // 🎭 SHADOW SYSTEM (SOFT iOS DEPTH)
  // =====================================================
  static List<BoxShadow> shadowSoft = [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 30,
      offset: const Offset(0, 12),
    ),
  ];

  static List<BoxShadow> glow = [
    BoxShadow(
      color: brand.withOpacity(0.4),
      blurRadius: 30,
      spreadRadius: 1,
    ),
  ];

  // =====================================================
  // 🌈 GRADIENT SYSTEM
  // =====================================================
  static LinearGradient primaryGradient = LinearGradient(
    colors: [brand400, brand700],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient softGradient = LinearGradient(
    colors: [
      Colors.white.withOpacity(0.08),
      Colors.white.withOpacity(0.02),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient glowGradient = LinearGradient(
    colors: [
      brand.withOpacity(0.6),
      brand.withOpacity(0.1),
    ],
  );

  // =====================================================
  // 🖱️ INTERACTION STATES (GLOBAL)
  // =====================================================
  static Color hover   = brand.withOpacity(0.08);
  static Color pressed = brand.withOpacity(0.15);
  static Color focus   = brand.withOpacity(0.25);

  // =====================================================
  // 🧾 GLOBAL CARD STYLE
  // =====================================================
  static BoxDecoration card = BoxDecoration(
    color: surfacePrimary,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: borderSoft),
    boxShadow: shadowSoft,
  );

  // =====================================================
  // 🔘 BUTTON SYSTEM (GLOBAL)
  // =====================================================
  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: brand,
    foregroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
  );

  static ButtonStyle secondaryButton = ElevatedButton.styleFrom(
    backgroundColor: surfaceSecondary,
    foregroundColor: textPrimary,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: BorderSide(color: borderSoft),
    ),
  );

  static ButtonStyle glassButton = ElevatedButton.styleFrom(
    backgroundColor: glassMid,
    foregroundColor: textPrimary,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: BorderSide(color: borderSubtle),
    ),
  );

  // =====================================================
  // 🧊 INPUT FIELD STYLE
  // =====================================================
  static InputDecoration input = InputDecoration(
    filled: true,
    fillColor: surfaceSecondary,
    hintStyle: TextStyle(color: textTertiary),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: borderSubtle),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: brand),
    ),
  );

  // =====================================================
  // 🧠 HELPER UTILITIES
  // =====================================================
  static Color opacity(Color color, double value) {
    return color.withOpacity(value);
  }

  static BorderRadius radius(double r) {
    return BorderRadius.circular(r);
  }
}