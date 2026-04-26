// lib/app/modules/auth/views/login_screen_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/routes/app_pages.dart';
import 'package:provider/provider.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/dark_theme_provider.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/utils/mahek_responsive.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import '../../auth/controllers/auth_controller.dart';

class LoginScreenView extends StatefulWidget {
  const LoginScreenView({super.key});

  @override
  State<LoginScreenView> createState() => _LoginScreenViewState();
}

class _LoginScreenViewState extends State<LoginScreenView> {
  final AuthController controller = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDark = themeChange.isDarkTheme();

    return Scaffold(
      backgroundColor: isDark ? AppThemeData.grey10 : AppThemeData.primaryWhite,
      body:
          MahekResponsive.isDesktop(context) ||
              MahekResponsive.isLaptop(context)
          ? _buildDesktopLayout(context, isDark)
          : _buildMobileLayout(context, isDark),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(flex: 5, child: _buildBrandPanel(isDark, context)),
        Expanded(flex: 4, child: _buildLoginPanel(context, isDark)),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, bool isDark) {
    return SafeArea(
      child: SingleChildScrollView(child: _buildLoginPanel(context, isDark)),
    );
  }

  Widget _buildBrandPanel(bool isDark, BuildContext context) {
    final padding = MahekResponsive.responsiveFontSize(
      context,
      mobile: 24,
      tablet: 32,
      laptop: 40,
      desktop: 48,
    );
    final headlineSize = MahekResponsive.responsiveFontSize(
      context,
      mobile: 28,
      tablet: 38,
      laptop: 50,
      desktop: 58,
    );
    final descSize = MahekResponsive.responsiveFontSize(
      context,
      mobile: 13,
      tablet: 15,
      laptop: 17,
      desktop: 18,
    );

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF0A1628),
                  const Color(0xFF1A2744),
                  const Color(0xFF0D1B2A),
                ]
              : [
                  const Color(0xFF1A2744),
                  const Color(0xFF2B4162),
                  const Color(0xFF121F3F),
                ],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.35,
              child: Image.asset(
                'assets/images/cityscape_night.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.topRight,
                      radius: 1.5,
                      colors: [
                        Colors.white.withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF5D54F2), Color(0xFF8B7EFF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF5D54F2,
                              ).withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.bolt_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      spaceW(width: 12),
                      Text(
                        'MAHEK',
                        style: TextStyle(
                          fontFamily: FontFamily.bold,
                          fontSize: 22,
                          letterSpacing: 2,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF5D54F2), Color(0xFFA78BFA)],
                    ).createShader(bounds),
                    child: Text(
                      'Empowering\nEditorial\nVelocity.',
                      style: TextStyle(
                        fontFamily: FontFamily.bold,
                        fontSize: headlineSize,
                        height: 1.1,
                        color: Colors.white,
                        letterSpacing: -1,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ),
                  spaceH(height: 24),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Text(
                      'Experience the kinetic flow of modern management. Precision tools designed for the world\'s leading editorial teams.',
                      style: TextStyle(
                        fontFamily: FontFamily.regular,
                        fontSize: descSize,
                        height: 1.6,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      _buildFooterBadge('SYSTEM V4.2.0'),
                      spaceW(width: 16),
                      _buildFooterBadge('PALO ALTO, CA'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: FontFamily.medium,
          fontSize: 12,
          letterSpacing: 1,
          color: Colors.white.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  Widget _buildLoginPanel(BuildContext context, bool isDark) {
    final horizontalPadding = MahekResponsive.responsiveFontSize(
      context,
      mobile: 20,
      tablet: 32,
      laptop: 40,
      desktop: 48,
    );
    final titleSize = MahekResponsive.responsiveFontSize(
      context,
      mobile: 24,
      tablet: 30,
      laptop: 34,
      desktop: 36,
    );
    final subtitleSize = MahekResponsive.responsiveFontSize(
      context,
      mobile: 13,
      tablet: 14,
      laptop: 15,
      desktop: 16,
    );

    return Container(
      color: isDark ? AppThemeData.grey10 : AppThemeData.primaryWhite,
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(horizontalPadding),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextCustom(
                  title: 'Welcome Back',
                  fontSize: titleSize,
                  fontFamily: FontFamily.bold,
                  color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                ),
                spaceH(height: 8),
                TextCustom(
                  title: 'Sign in to your editorial dashboard',
                  fontSize: subtitleSize,
                  fontFamily: FontFamily.regular,
                  color: isDark ? AppThemeData.grey5 : AppThemeData.grey7,
                ),
                spaceH(height: 36),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildInputLabel('EMAIL ADDRESS', isDark),
                      spaceH(height: 8),
                      _buildEmailField(isDark),
                      spaceH(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInputLabel('PASSWORD', isDark),
                          _buildForgotPasswordButton(isDark),
                        ],
                      ),
                      spaceH(height: 8),
                      _buildPasswordField(isDark),
                      spaceH(height: 20),
                      _buildRememberMeCheckbox(isDark),
                      spaceH(height: 28),
                      _buildSignInButton(context, isDark),
                    ],
                  ),
                ),
                spaceH(height: 24),
                // ─── COMPACT MAHEK CARD ───
                _buildCompactMahekCard(isDark),
                spaceH(height: 20),
                _buildSignUpLink(isDark),
                spaceH(height: 20),
                Row(
                  children: [
                    Expanded(child: divider(context, height: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextCustom(
                        title: 'ENTERPRISE SUPPORT',
                        fontSize: 11,
                        fontFamily: FontFamily.medium,
                        color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
                      ),
                    ),
                    Expanded(child: divider(context, height: 1)),
                  ],
                ),
                spaceH(height: 12),
                Center(
                  child: TextCustom(
                    title: 'Mahek Owner',
                    fontSize: 13,
                    fontFamily: FontFamily.semiBold,
                    color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // COMPACT MAHEK CARD (Like Forgot Password style)
  // ═══════════════════════════════════════
  Widget _buildCompactMahekCard(bool isDark) {
    final color = const Color(0xFF5D54F2);
    return GestureDetector(
      onTap: () {
        controller.emailController.text = 'mahekjkevat@gmail.com';
        controller.passwordController.text = 'Mahek@6561';
        Get.snackbar(
          '✓ Ready!',
          'Credentials filled for Mahek Kevat',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: color.withValues(alpha: 0.95),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
          borderRadius: 14,
          icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark
              ? AppThemeData.grey9.withValues(alpha: 0.3)
              : AppThemeData.grey1,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [color, const Color(0xFF8B7EFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'M',
                  style: TextStyle(
                    fontFamily: FontFamily.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            spaceW(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mahek Kevat',
                    style: TextStyle(
                      fontFamily: FontFamily.semiBold,
                      fontSize: 14,
                      color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                    ),
                  ),
                  spaceH(height: 2),
                  Text(
                    'Super Admin • Quick Access',
                    style: TextStyle(
                      fontFamily: FontFamily.regular,
                      fontSize: 11,
                      color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.touch_app_rounded, color: color, size: 14),
                  spaceW(width: 4),
                  Text(
                    'Tap',
                    style: TextStyle(
                      fontFamily: FontFamily.medium,
                      fontSize: 11,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String text, bool isDark) {
    return TextCustom(
      title: text,
      fontSize: 12,
      fontFamily: FontFamily.medium,
      color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
    );
  }

  Widget _buildEmailField(bool isDark) {
    return TextFormField(
      controller: controller.emailController,
      style: TextStyle(
        fontFamily: FontFamily.regular,
        fontSize: 16,
        color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
      ),
      decoration: InputDecoration(
        hintText: 'name@company.com',
        hintStyle: TextStyle(
          fontFamily: FontFamily.regular,
          fontSize: 16,
          color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
        ),
        filled: true,
        fillColor: isDark ? AppThemeData.grey9 : AppThemeData.grey2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF5D54F2), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        prefixIcon: Icon(
          Icons.email_outlined,
          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
          size: 20,
        ),
      ),
      validator: (value) => (value == null || value.isEmpty)
          ? 'Email is required'
          : (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)
                ? 'Enter a valid email'
                : null),
    );
  }

  Widget _buildPasswordField(bool isDark) {
    return TextFormField(
      controller: controller.passwordController,
      obscureText: _obscurePassword,
      style: TextStyle(
        fontFamily: FontFamily.regular,
        fontSize: 16,
        color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
      ),
      decoration: InputDecoration(
        hintText: '••••••••',
        hintStyle: TextStyle(
          fontFamily: FontFamily.regular,
          fontSize: 16,
          color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
        ),
        filled: true,
        fillColor: isDark ? AppThemeData.grey9 : AppThemeData.grey2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF5D54F2), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        prefixIcon: Icon(
          Icons.lock_outline_rounded,
          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
          size: 20,
        ),
        suffixIcon: IconButton(
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            size: 20,
          ),
        ),
      ),
      validator: (value) => (value == null || value.isEmpty)
          ? 'Password is required'
          : (value.length < 6 ? 'Minimum 6 characters' : null),
    );
  }

  Widget _buildForgotPasswordButton(bool isDark) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => controller.forgotPassword(),
        child: TextCustom(
          title: 'Forgot Password?',
          fontSize: 13,
          fontFamily: FontFamily.medium,
          color: const Color(0xFF5D54F2),
        ),
      ),
    );
  }

  Widget _buildRememberMeCheckbox(bool isDark) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => _rememberMe = !_rememberMe),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: _rememberMe
                    ? const Color(0xFF5D54F2)
                    : Colors.transparent,
                border: Border.all(
                  color: _rememberMe
                      ? const Color(0xFF5D54F2)
                      : (isDark ? AppThemeData.grey7 : AppThemeData.grey4),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: _rememberMe
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            spaceW(width: 12),
            TextCustom(
              title: 'Remember this session',
              fontSize: 14,
              fontFamily: FontFamily.regular,
              color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpLink(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextCustom(
          title: 'Don\'t have an account?',
          fontSize: 14,
          fontFamily: FontFamily.regular,
          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
        ),
        spaceW(width: 4),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => Get.toNamed(Routes.SIGN_UP),
            child: TextCustom(
              title: 'Sign Up',
              fontSize: 14,
              fontFamily: FontFamily.semiBold,
              color: const Color(0xFF5D54F2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButton(BuildContext context, bool isDark) {
    return Obx(
      () => Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF5D54F2), Color(0xFF8B7EFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5D54F2).withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: controller.isLoading.value
              ? null
              : () {
                  if (_formKey.currentState!.validate()) {
                    controller.signInWithEmailAndPassword(
                      email: controller.emailController.text.trim(),
                      password: controller.passwordController.text.trim(),
                      rememberMe: _rememberMe,
                    );
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: controller.isLoading.value
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextCustom(
                      title: 'Sign In',
                      fontSize: 16,
                      fontFamily: FontFamily.semiBold,
                      color: Colors.white,
                    ),
                    spaceW(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
