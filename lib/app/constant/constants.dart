// ignore_for_file: depend_on_referenced_packages, non_MahekConstant_identifier_names, deprecated_member_use
import 'dart:developer' as developer;
import 'dart:math';
import 'package:maheksync/app/dependency/shimmer.dart';
import 'package:maheksync/app/models/user_model.dart';
import 'package:maheksync/app/utils/dark_theme_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../utils/app_colors.dart';

enum Status { active, inactive }

class MahekConstant {
  static bool isLogin = false;
  static bool isDemo = false;
  static String clientIdForGoogleLogin = "";
  static RxString appName = "MahekAdmin".obs;
  static String? appIconLight;
  static String? appIconDark;

  static const String googleLoginType = 'google';
  static const String appleLoginType = "apple";
  static const String emailLoginType = "email";
  static String phoneLoginType = 'phone';
  static String adminRoleId = "e6b30c67-8bcf-4971-aaf7-b5e23284b77b";

  static String? ownerAppColor;
  static bool get isSuperAdmin => ownerModel?.id == adminRoleId;

  static const userPlaceHolder = 'assets/images/user_placeholder.png';
  static String user = 'user';
  static UserModel? ownerModel;
  static String senderId = "";

  // Ad Settings (from settings/ad_settings)
  static bool autoApproveAds = false;
  static bool autoApproveEditedAds = false;
  static bool freeAdListing = false;
  static bool unlimitedAdDuration = false;
  static int freeAdListingDays = 30;
  static int minRange = 50;
  static int maxRange = 200;

  static  int pageSize = 10;


  static String? selectedMap;

  static String jsonFileURL = "";
  static String googleMapKey = "AIzaSyBwI28ucDsERHEx5O6ybrmeKSoBY98tmmA";
  static String distanceType = "KM";
  static String webNotificationKey = "";
  static String? countryCode = '+91';
  static String termsAndConditions = "";
  static String privacyPolicy = "";
  static String aboutApp = "";

  static const String profileImageFolder = 'profile_images';
  static const String profileImageFieldKey = 'profilePic';
  static const String loaderMsgUploadingImage = 'Uploading profile image...';
  static const String loaderMsgSavingProfile = 'Saving profile...';
  static const Duration profileSaveAnimDuration = Duration(milliseconds: 300);

  static const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  static final Random _rnd = Random();

  static String getRandomString(int length) => String.fromCharCodes(Iterable.generate(length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  static TextStyle defaultTextStyle({double size = 24.00, Color color = Colors.black}) {
    return TextStyle(fontSize: size, color: color, fontWeight: FontWeight.w600, fontFamily: FontFamily.medium);
  }

  static void isDemoSet(bool? isDemoMahekConstant) {
    if (kDebugMode) {
      MahekConstant.isDemo = false;
    } else {
      MahekConstant.isDemo = isDemoMahekConstant ?? true;
    }
  }

  static Widget loader({BuildContext? context}) {
    bool isDark = false;
    if (context != null) {
      try {
        isDark = Provider.of<DarkThemeProvider>(context, listen: false).isDarkTheme();
      } catch (_) {}
    }
    final base = isDark ? AppThemeData.grey9 : AppThemeData.grey3;
    final highlight = isDark ? AppThemeData.grey8 : AppThemeData.grey2;
    final color = isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite;

    return Center(
      child: Shimmer.fromColors(
        baseColor: base,
        highlightColor: highlight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(height: 14, width: 180, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
            spaceH(height: 10),
            Container(height: 14, width: 140, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
            spaceH(height: 10),
            Container(height: 14, width: 160, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
          ],
        ),
      ),
    );
  }

  static bool hasValidUrl(String value) {
    String pattern = r'(http|https)://[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:/~+#-]*[\w@?^=%&amp;/~+#-])?';
    RegExp regExp = RegExp(pattern);
    if (value.isEmpty) {
      return false;
    } else if (!regExp.hasMatch(value)) {
      return false;
    }
    return true;
  }

  static String? validateEmail(String? value) {
    String pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value ?? '')) {
      return 'Enter valid email';
    } else {
      return null;
    }
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty || value.length < 6) {
      return "Minimum password length should be 6";
    } else {
      return null;
    }
  }

  static String maskMobileNumber({String? mobileNumber, String? countryCode}) {
    String maskedNumber = 'x' * (mobileNumber!.length - 2) + mobileNumber.substring(mobileNumber.length - 2);
    return MahekConstant.isDemo ? "$countryCode $maskedNumber" : "$countryCode $mobileNumber";
  }




  static InputDecoration DefaultInputDecoration(BuildContext context, {Color? fillColor}) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return InputDecoration(
      iconColor: AppThemeData.primary50,
      isDense: true,
      filled: true,
      fillColor: fillColor ?? (themeChange.isDarkTheme() ? AppThemeData.grey10 : AppThemeData.grey1),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      disabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemeData.grey10 : AppThemeData.grey2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemeData.grey10 : AppThemeData.grey2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemeData.grey10 : AppThemeData.grey2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemeData.grey10 : AppThemeData.grey2),
      ),
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemeData.grey10 : AppThemeData.grey2),
      ),
      hintText: "Select Brand",
      hintStyle: TextStyle(fontSize: 14, color: themeChange.isDarkTheme() ? AppThemeData.grey10 : AppThemeData.grey2, fontWeight: FontWeight.w500, fontFamily: FontFamily.medium),
    );
  }

  static InputDecoration DefaultInputDecorationForDrawerWidgets(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return InputDecoration(
      iconColor: AppThemeData.primary50,
      isDense: true,
      filled: true,
      fillColor: themeChange.isDarkTheme() ? AppThemeData.grey10 : AppThemeData.grey1,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      disabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemeData.grey10 : AppThemeData.grey2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemeData.grey10 : AppThemeData.grey2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemeData.grey10 : AppThemeData.grey2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemeData.grey10 : AppThemeData.grey2),
      ),
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemeData.grey10 : AppThemeData.grey2),
      ),
      hintText: "Select Brand",
      hintStyle: TextStyle(fontSize: 14, color: themeChange.isDarkTheme() ? AppThemeData.grey10 : AppThemeData.grey2, fontWeight: FontWeight.w500, fontFamily: FontFamily.medium),
    );
  }

  static String fullNameString(String? firstName, String? lastName) {
    try {
      return '${firstName ?? ''} ${lastName ?? ''}'.trim();
    } catch (e) {
      return '';
    }
  }


  static const String loginBackgroundAsset = 'assets/images/login_bg.png';

  // ── Animation Duration Constants (for glassmorphic effects) ──────────
  /// Duration for the floating orb animation cycle in the sidebar
  static const Duration navOrbAnimDuration = Duration(milliseconds: 6000);

  /// Duration for the floating orb animation cycle in the header
  static const Duration headerOrbAnimDuration = Duration(milliseconds: 7000);

  /// Blur sigma values for glassmorphic BackdropFilter
  static const double navBlurSigma = 22.0;
  static const double headerBlurSigma = 18.0;

  // ── Glassmorphic Overlay Opacity ──────────────────────────────────────
  /// Dark mode overlay opacity applied over the blurred background
  static const double glassOverlayDarkOpacity = 0.55;

  /// Light mode overlay opacity applied over the blurred background
  static const double glassOverlayLightOpacity = 0.65;

  /// Border opacity for glass panels
  static const double glassBorderDarkOpacity = 0.3;
  static const double glassBorderLightOpacity = 0.5;

  // ── Nav Item Colors on Glass ──────────────────────────────────────────
  /// Selected nav item background opacity on glass (dark)
  static const double navItemSelectedDarkOpacity = 0.22;

  /// Selected nav item background opacity on glass (light)
  static const double navItemSelectedLightOpacity = 0.14;

  /// Selected nav item border opacity on glass
  static const double navItemBorderSelectedOpacity = 0.3;

  /// Section divider opacity on glass
  static const double navDividerDarkOpacity = 0.12;
  static const double navDividerLightOpacity = 0.2;


  static List<String> generateSearchKeywords(String text) {
    if (text.isEmpty) return [];

    final lower = text.toLowerCase().trim();
    final List<String> keywords = [];

    final words = lower.split(' ').where((w) => w.isNotEmpty).toList();

    for (int i = 0; i < words.length; i++) {
      for (int j = i + 1; j <= words.length; j++) {
        keywords.add(words.sublist(i, j).join(' '));
      }
    }

    for (var word in words) {
      for (int i = 1; i <= word.length; i++) {
        keywords.add(word.substring(0, i));
      }
    }

    for (int i = 1; i <= lower.length; i++) {
      keywords.add(lower.substring(0, i));
    }

    return keywords.toSet().toList();
  }

  static String getUuid() {
    try {
      return const Uuid().v4();
    } catch (e, stack) {
      developer.log('Error generating UUID: ', error: e, stackTrace: stack);
      return '';
    }
  }

}

class StatusDetails {
  final String text;
  final Color textColor;
  final Color backgroundColor;

  StatusDetails({required this.text, required this.textColor, required this.backgroundColor});
}
