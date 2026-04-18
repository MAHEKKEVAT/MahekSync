// lib/app/utils/font_family.dart
class FontFamily {
  // SF Pro Display Fonts - based on actual files in assets/fonts
  static const String blackItalic = "SFProDisplayBlackItalic";
  static const String bold = "SFProDisplayBold";
  static const String heavyItalic = "SFProDisplayHeavyItalic";
  static const String lightItalic = "SFProDisplayLightItalic";
  static const String medium = "SFProDisplayMedium";
  static const String regular = "SFProDisplayRegular";
  static const String semiBoldItalic = "SFProDisplaySemiBoldItalic";
  static const String thinItalic = "SFProDisplayThinItalic";
  static const String ultraLightItalic = "SFProDisplayUltraLightItalic";

  // Use available fonts for non-italic variants
  static const String black = "SFProDisplayBold";           // Fallback to Bold
  static const String heavy = "SFProDisplayBold";           // Fallback to Bold
  static const String boldItalic = "SFProDisplayHeavyItalic"; // Fallback to Heavy Italic
  static const String semiBold = "SFProDisplayMedium";      // Fallback to Medium
  static const String mediumItalic = "SFProDisplaySemiBoldItalic"; // Fallback to SemiBold Italic
  static const String regularItalic = "SFProDisplayLightItalic"; // Fallback to Light Italic
  static const String italic = "SFProDisplayLightItalic";   // Fallback to Light Italic
  static const String light = "SFProDisplayRegular";        // Fallback to Regular
  static const String thin = "SFProDisplayRegular";         // Fallback to Regular
  static const String ultraLight = "SFProDisplayRegular";   // Fallback to Regular

  // Aliases
  static const String extraBold = "SFProDisplayBold";
  static const String extraBoldItalic = "SFProDisplayHeavyItalic";
}