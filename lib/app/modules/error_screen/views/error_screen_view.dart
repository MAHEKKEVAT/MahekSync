import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/dark_theme_provider.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/constant/round_shape_button.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'package:provider/provider.dart';
import 'package:solar_icons/solar_icons.dart';
import '../controllers/error_screen_controller.dart';

class ErrorScreenView extends GetView<ErrorScreenController> {
  const ErrorScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDark = themeChange.isDarkTheme();
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 650;

    return Scaffold(
      backgroundColor: isDark ? AppThemeData.primaryBlack : AppThemeData.grey1,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 24 : 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 404
                  Text(
                    '404',
                    style: TextStyle(
                      fontFamily: FontFamily.bold,
                      fontSize: isMobile ? 72 : 96,
                      color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                      letterSpacing: 4,
                      height: 1,
                    ),
                  ),
                  spaceH(height: 16),

                  // Accent divider
                  Container(
                    width: 60,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppThemeData.primary50,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  spaceH(height: 24),

                  // Title
                  TextCustom(
                    title: 'Page Not Found',
                    fontSize: isMobile ? 20 : 24,
                    fontFamily: FontFamily.bold,
                    color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                  ),
                  spaceH(height: 12),

                  // Description
                  TextCustom(
                    title: 'The page you\'re looking for doesn\'t exist or you don\'t have access to it.',
                    fontSize: 14,
                    fontFamily: FontFamily.regular,
                    color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                    textAlign: TextAlign.center,
                  ),
                  spaceH(height: 28),

                  // URL pill
                  _buildUrlPill(isDark),
                  spaceH(height: 32),

                  // Login button
                  _buildLoginButton(isDark),
                  spaceH(height: 16),

                  // Back to Home
                  _buildBackLink(isDark),
                  spaceH(height: 40),

                  // Logo
                  _buildLogo(isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUrlPill(bool isDark) {
    final path = controller.attemptedPath;
    if (path.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? AppThemeData.grey9.withValues(alpha: 0.6)
            : AppThemeData.grey2.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? AppThemeData.grey7.withValues(alpha: 0.3)
              : AppThemeData.grey3.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            SolarIconsOutline.linkSquare,
            size: 14,
            color: AppThemeData.primary50.withValues(alpha: 0.7),
          ),
          spaceW(width: 8),
          Flexible(
            child: Text(
              path,
              style: TextStyle(
                fontFamily: FontFamily.medium,
                fontSize: 12,
                color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: RoundShapeButton(
        title: 'Go to Login',
        buttonColor: AppThemeData.primary50,
        buttonTextColor: AppThemeData.primaryWhite,
        onTap: () => controller.goToLogin(),
        borderRadius: 14,
        height: 50,
        titleWidget: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextCustom(
              title: 'Go to Login',
              fontSize: 15,
              fontFamily: FontFamily.semiBold,
              color: AppThemeData.primaryWhite,
            ),
            spaceW(width: 8),
            Icon(
              SolarIconsOutline.arrowRight,
              color: AppThemeData.primaryWhite,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackLink(bool isDark) {
    return GestureDetector(
      onTap: () => controller.goHome(),
      child: TextCustom(
        title: 'Back to Home',
        fontSize: 13,
        fontFamily: FontFamily.medium,
        color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
      ),
    );
  }

  Widget _buildLogo(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: AppThemeData.primary50,
            borderRadius: BorderRadius.circular(5),
          ),
          child: const Icon(SolarIconsBold.bolt, color: Colors.white, size: 11),
        ),
        spaceW(width: 8),
        Text(
          'MAHEK',
          style: TextStyle(
            fontFamily: FontFamily.bold,
            fontSize: 11,
            letterSpacing: 3,
            color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
          ),
        ),
      ],
    );
  }
}
