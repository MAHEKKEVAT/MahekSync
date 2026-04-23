// lib/app/modules/splash_screen/views/splash_screen_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/dark_theme_provider.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import '../controllers/splash_screen_controller.dart';

class SplashScreenView extends GetView<SplashScreenController> {
  const SplashScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDark = themeChange.isDarkTheme();

    return Scaffold(
      backgroundColor: isDark ? AppThemeData.grey10 : const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Animated Background Elements
          _buildAnimatedBackground(isDark),

          // Main Content
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 600),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Animated Avatar with Lottie Ring
                          _buildAnimatedAvatar(isDark),
                          spaceH(height: 32),

                          // Brand Name
                          _buildBrandName(isDark),
                          spaceH(height: 12),

                          // Admin Badge
                          _buildAdminBadge(isDark),
                          spaceH(height: 40),

                          // Status Message
                          _buildStatusMessage(isDark),
                          spaceH(height: 8),

                          // Sub Status Message
                          _buildSubStatusMessage(isDark),
                          spaceH(height: 32),

                          // Progress Bar
                          _buildProgressBar(isDark),
                          spaceH(height: 24),

                          // Loading Indicator
                          _buildLoadingIndicator(isDark),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Security Card (Bottom Right)
          _buildSecurityCard(isDark),
        ],
      ),
    );
  }

  // ==================== ANIMATED AVATAR WITH LOTTIE RING ====================
  Widget _buildAnimatedAvatar(bool isDark) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.elasticOut,
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 460,
            height: 460,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5D54F2).withValues(alpha: 0.3 * value),
                  blurRadius: 40,
                  spreadRadius: 8,
                ),
                BoxShadow(
                  color: const Color(0xFF8B7EFF).withValues(alpha: 0.15 * value),
                  blurRadius: 60,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Lottie Animated Ring (Outer)
                SizedBox(
                  width: 470,
                  height: 470,
                  child: Lottie.asset(
                    'assets/animation/anim_avatar.json',
                    fit: BoxFit.contain,
                    repeat: true,
                    animate: true,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback: Gradient ring if Lottie fails
                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const SweepGradient(
                            colors: [
                              Color(0xFF5D54F2),
                              Color(0xFF8B7EFF),
                              Color(0xFFA78BFA),
                              Color(0xFF5D54F2),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Profile Image (Center)
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppThemeData.grey8 : Colors.white,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(55),
                    child: Image.asset(
                      'assets/images/cropped_circle_image.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback avatar
                        return Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF5D54F2),
                                Color(0xFF8B7EFF),
                              ],
                            ),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 50,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Inner glow ring
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF5D54F2).withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==================== ANIMATED BACKGROUND ====================
  Widget _buildAnimatedBackground(bool isDark) {
    return Positioned.fill(
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(seconds: 3),
        builder: (context, double value, child) {
          return CustomPaint(
            painter: _BackgroundPainter(
              animationValue: value,
              isDark: isDark,
            ),
            child: Container(),
          );
        },
      ),
    );
  }

  // ==================== ADMIN BADGE ====================
  Widget _buildAdminBadge(bool isDark) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF5D54F2).withValues(alpha: 0.15),
                    const Color(0xFF8B7EFF).withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: const Color(0xFF5D54F2).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.admin_panel_settings_rounded,
                    size: 16,
                    color: Color(0xFF5D54F2),
                  ),
                  spaceW(width: 8),
                  const TextCustom(
                    title: 'ADMIN',
                    fontSize: 13,
                    fontFamily: FontFamily.semiBold,
                    color: Color(0xFF5D54F2),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ==================== BRAND NAME ====================
  Widget _buildBrandName(bool isDark) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.8, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                isDark ? Colors.white : AppThemeData.grey10,
                const Color(0xFF5D54F2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              'Mahek',
              style: TextStyle(
                fontFamily: FontFamily.bold,
                fontSize: 64,
                letterSpacing: 4,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: const Color(0xFF5D54F2).withValues(alpha: 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ==================== STATUS MESSAGE ====================
  Widget _buildStatusMessage(bool isDark) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Obx(() => TextCustom(
            title: controller.statusMessage.value,
            fontSize: 18,
            fontFamily: FontFamily.medium,
            color: isDark ? AppThemeData.grey3 : AppThemeData.grey8,
            textAlign: TextAlign.center,
          )),
        );
      },
    );
  }

  // ==================== SUB STATUS MESSAGE ====================
  Widget _buildSubStatusMessage(bool isDark) {
    return Obx(() => TextCustom(
      title: controller.subStatusMessage.value,
      fontSize: 15,
      fontFamily: FontFamily.regular,
      color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
      textAlign: TextAlign.center,
    ));
  }

  // ==================== PROGRESS BAR ====================
  Widget _buildProgressBar(bool isDark) {
    return Column(
      children: [
        Obx(() => ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: controller.progressValue.value,
            minHeight: 4,
            backgroundColor: isDark
                ? AppThemeData.grey8.withValues(alpha: 0.3)
                : AppThemeData.grey3.withValues(alpha: 0.5),
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color(0xFF5D54F2),
            ),
          ),
        )),
        spaceH(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Obx(() => TextCustom(
              title: '${(controller.progressValue.value * 100).toInt()}%',
              fontSize: 12,
              fontFamily: FontFamily.medium,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            )),
          ],
        ),
      ],
    );
  }

  // ==================== LOADING INDICATOR ====================
  Widget _buildLoadingIndicator(bool isDark) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      builder: (context, double value, child) {
        return SizedBox(
          width: 32,
          height: 32,
          child: Transform.scale(
            scale: value,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                const Color(0xFF5D54F2).withValues(alpha: 0.6),
              ),
            ),
          ),
        );
      },
    );
  }

  // ==================== SECURITY CARD ====================
  Widget _buildSecurityCard(bool isDark) {
    return Positioned(
      bottom: 24,
      right: 24,
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOut,
        builder: (context, double value, child) {
          return Opacity(
            opacity: value * 0.9,
            child: Transform.translate(
              offset: Offset(30 * (1 - value), 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppThemeData.grey9.withValues(alpha: 0.8)
                      : Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? AppThemeData.grey7.withValues(alpha: 0.3)
                        : AppThemeData.grey3.withValues(alpha: 0.5),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF34D399)],
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    spaceW(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextCustom(
                          title: 'Secure Environment',
                          fontSize: 13,
                          fontFamily: FontFamily.semiBold,
                          color: isDark ? AppThemeData.grey2 : AppThemeData.grey8,
                        ),
                        spaceH(height: 2),
                        TextCustom(
                          title: 'Encrypted session verified',
                          fontSize: 11,
                          fontFamily: FontFamily.regular,
                          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==================== CUSTOM PAINTER FOR BACKGROUND ====================
class _BackgroundPainter extends CustomPainter {
  final double animationValue;
  final bool isDark;

  _BackgroundPainter({
    required this.animationValue,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Gradient background
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
        AppThemeData.grey10,
        const Color(0xFF1A1A2E),
        const Color(0xFF16213E),
      ]
          : [
        const Color(0xFFF8FAFC),
        const Color(0xFFEEF2FF),
        const Color(0xFFE0E7FF),
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..shader = gradient);

    // Animated circles
    final circle1Paint = Paint()
      ..color = (isDark ? Colors.white : const Color(0xFF5D54F2))
          .withValues(alpha: 0.03 * animationValue)
      ..style = PaintingStyle.fill;

    final circle2Paint = Paint()
      ..color = (isDark ? const Color(0xFF5D54F2) : const Color(0xFF8B7EFF))
          .withValues(alpha: 0.04 * animationValue)
      ..style = PaintingStyle.fill;

    final circle3Paint = Paint()
      ..color = (isDark ? const Color(0xFF8B7EFF) : const Color(0xFFA78BFA))
          .withValues(alpha: 0.02 * animationValue)
      ..style = PaintingStyle.fill;

    // Circle 1 - Top Right
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.15),
      size.width * 0.4 * animationValue,
      circle1Paint,
    );

    // Circle 2 - Bottom Left
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.85),
      size.width * 0.35 * animationValue,
      circle2Paint,
    );

    // Circle 3 - Center Background
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.width * 0.6 * animationValue,
      circle3Paint,
    );

    // Subtle grid pattern
    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : AppThemeData.grey10)
          .withValues(alpha: 0.02 * animationValue)
      ..strokeWidth = 0.5;

    const gridSpacing = 40.0;
    for (double x = 0; x < size.width; x += gridSpacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }
    for (double y = 0; y < size.height; y += gridSpacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}