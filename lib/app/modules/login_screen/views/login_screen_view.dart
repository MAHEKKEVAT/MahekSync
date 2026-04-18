// lib/app/modules/auth/views/login_screen_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/routes/app_pages.dart';
import 'package:provider/provider.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/dark_theme_provider.dart';
import 'package:maheksync/app/utils/font_family.dart';
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
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDark ? AppThemeData.grey10 : AppThemeData.primaryWhite,
      body: screenSize.width > 900
          ? _buildDesktopLayout(context, isDark)
          : _buildMobileLayout(context, isDark),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, bool isDark) {
    return Row(
      children: [
        // Left Panel - Immersive Brand Section
        Expanded(
          flex: 5,
          child: _buildBrandPanel(isDark),
        ),
        // Right Panel - Login Form
        Expanded(
          flex: 4,
          child: _buildLoginPanel(context, isDark),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, bool isDark) {
    return _buildLoginPanel(context, isDark);
  }
  Widget _buildBrandPanel(bool isDark) {
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
          // Background Image with Blur
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
          // Gradient Overlay
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
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(48.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo / Brand
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF5D54F2), Color(0xFF8B7EFF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF5D54F2).withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.bolt_rounded,
                          color: Colors.white,
                          size: 24,
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
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Hero Headline
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF5D54F2), Color(0xFFA78BFA)],
                    ).createShader(bounds),
                    child: Text(
                      'Empowering\nEditorial\nVelocity.',
                      style: TextStyle(
                        fontFamily: FontFamily.bold,
                        fontSize: 64,
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
                  // Supporting Description
                  Container(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Text(
                      'Experience the kinetic flow of modern management. Precision tools designed for the world\'s leading editorial teams.',
                      style: TextStyle(
                        fontFamily: FontFamily.regular,
                        fontSize: 18,
                        height: 1.6,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Demo Access Card - NEW
                  _buildDemoAccessCard(isDark),
                  spaceH(height: 16),
                  // Footer Info
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
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
        ),
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
    return Container(
      color: isDark ? AppThemeData.grey10 : AppThemeData.primaryWhite,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(48.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Welcome Text - Using TextCustom
                  TextCustom(
                    title: 'Welcome Back',
                    fontSize: 36,
                    fontFamily: FontFamily.bold,
                    color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                  ),
                  spaceH(height: 8),
                  TextCustom(
                    title: 'Sign in to your editorial dashboard',
                    fontSize: 16,
                    fontFamily: FontFamily.regular,
                    color: isDark ? AppThemeData.grey5 : AppThemeData.grey7,
                  ),
                  spaceH(height: 40),
                  // Email Field
                  _buildInputLabel('EMAIL ADDRESS', isDark),
                  spaceH(height: 8),
                  _buildEmailField(isDark),
                  spaceH(height: 24),
                  // Password Field
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInputLabel('PASSWORD', isDark),
                      _buildForgotPasswordButton(isDark),
                    ],
                  ),
                  spaceH(height: 8),
                  _buildPasswordField(isDark),
                  spaceH(height: 24),
                  // Remember Me
                  _buildRememberMeCheckbox(isDark),
                  spaceH(height: 32),
                  // Sign In Button
                  _buildSignInButton(context, isDark),
                  spaceH(height: 24),
                  // Sign Up Link
                  _buildSignUpLink(isDark),
                  // Divider
                  Row(
                    children: [
                      Expanded(
                        child: divider(context, height: 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextCustom(
                          title: 'SECURE AUTHENTICATION',
                          fontSize: 11,
                          fontFamily: FontFamily.medium,
                          color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
                        ),
                      ),
                      Expanded(
                        child: divider(context, height: 1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
          borderSide: const BorderSide(
            color: Color(0xFF5D54F2),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppThemeData.danger300,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppThemeData.danger300,
            width: 1.5,
          ),
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
        errorStyle: const TextStyle(
          fontFamily: FontFamily.regular,
          fontSize: 12,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Email is required';
        }
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegex.hasMatch(value)) {
          return 'Enter a valid email';
        }
        return null;
      },
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
          borderSide: const BorderSide(
            color: Color(0xFF5D54F2),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppThemeData.danger300,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppThemeData.danger300,
            width: 1.5,
          ),
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
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
          icon: Icon(
            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            size: 20,
          ),
        ),
        errorStyle: const TextStyle(
          fontFamily: FontFamily.regular,
          fontSize: 12,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password is required';
        }
        if (value.length < 6) {
          return 'Minimum 6 characters';
        }
        return null;
      },
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
        onTap: () {
          setState(() {
            _rememberMe = !_rememberMe;
          });
        },
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
                  ? const Icon(
                Icons.check,
                size: 14,
                color: Colors.white,
              )
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

  // Add this method for the demo access card
  Widget _buildDemoAccessCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                color: Colors.white.withValues(alpha: 0.7),
                size: 18,
              ),
              spaceW(width: 8),
              Text(
                'Quick Demo Access',
                style: TextStyle(
                  fontFamily: FontFamily.medium,
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          spaceH(height: 12),
          Text(
            'Click on a profile to auto-fill credentials',
            style: TextStyle(
              fontFamily: FontFamily.regular,
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
          spaceH(height: 16),
          Row(
            children: [
              _buildProfileChip(
                initial: 'M',
                name: 'Mahek Kevat',
                email: 'mahekjkevat@gmail.com',
                password: 'Mahek@6561',
                color: const Color(0xFF5D54F2),
                isDark: isDark,
              ),
              spaceW(width: 12),
              _buildProfileChip(
                initial: 'A',
                name: 'Admin User',
                email: 'admin@mahek.com',
                password: 'Admin@123',
                color: const Color(0xFF10B981),
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileChip({
    required String initial,
    required String name,
    required String email,
    required String password,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            // Auto-fill credentials
            controller.emailController.text = email;
            controller.passwordController.text = password;

            // Show success message
            Get.snackbar(
              'Credentials Filled',
              'Ready to sign in as $name',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: color.withValues(alpha: 0.9),
              colorText: Colors.white,
              duration: const Duration(seconds: 2),
              margin: const EdgeInsets.all(16),
              borderRadius: 8,
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontFamily: FontFamily.semiBold,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                spaceW(width: 8),
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontFamily: FontFamily.medium,
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildSignInButton(BuildContext context, bool isDark) {
    return Obx(() => Container(
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
            const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    ));
  }
}