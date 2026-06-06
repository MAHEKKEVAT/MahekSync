import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/dark_theme_provider.dart';
import 'package:provider/provider.dart';

import '../constant/constants.dart';

/// Displays the app logo dynamically:
/// - If admin uploaded app icon for the current theme → shows network image
/// - Otherwise → falls back to local assets/images/logo.svg

class AppLogoWidget extends StatelessWidget {
  final double? height;
  final double? width;
  final BoxFit fit;

  const AppLogoWidget({super.key, this.height, this.width, this.fit = BoxFit.contain});

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<DarkThemeProvider>(context).isDarkTheme();
    final dynamicUrl = isDark ? MahekConstant.appIconDark : MahekConstant.appIconLight;

    // Use dynamic icon if available
    if (dynamicUrl != null && dynamicUrl.isNotEmpty && dynamicUrl.startsWith('http')) {
      return Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: (isDark ? AppThemeData.neonPurple : AppThemeData.primary50)
                  .withValues(alpha: 0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
          shape: BoxShape.circle,
        ),
        child: CachedNetworkImage(
          imageUrl: dynamicUrl,
          height: height,
          width: width,
          fit: fit,
          fadeInDuration: Duration.zero,
          placeholderFadeInDuration: Duration.zero,
          placeholder: (_, _) => _fallbackLogo(isDark),
          errorWidget: (_, _, _) => _fallbackLogo(isDark),
        ),
      );
    }

    return _fallbackLogo(isDark);
  }

  Widget _fallbackLogo(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppThemeData.neonPurple : AppThemeData.primary50)
                .withValues(alpha: 0.35),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: SvgPicture.asset(
        'assets/images/logo.svg',
        height: height,
        width: width,
        fit: fit,
        colorFilter: ColorFilter.mode(
          isDark ? AppThemeData.textNeonPurple : AppThemeData.primary50,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}

