// lib/app/modules/auth/views/sign_up_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/dark_theme_provider.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import '../../../constant/show_toast.dart';
import '../controllers/sign_up_controller.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final SignUpController controller = Get.put(SignUpController());
  final _formKey = GlobalKey<FormState>();

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
        // Right Panel - Sign Up Form
        Expanded(
          flex: 5,
          child: _buildSignUpPanel(context, isDark),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, bool isDark) {
    return _buildSignUpPanel(context, isDark);
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
          // Animated background elements
          Positioned.fill(
            child: CustomPaint(
              painter: _BrandBackgroundPainter(isDark: isDark),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(48.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand Identity
                  _buildBrandIdentity(isDark),
                  const Spacer(),
                  // Main Content
                  _buildHeroContent(isDark),
                  spaceH(height: 48),
                  // Social Proof Card
                  _buildSocialProofCard(isDark),
                  const Spacer(),
                  // Footer
                  _buildFooter(isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandIdentity(bool isDark) {
    return Row(
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
            Icons.auto_awesome_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
        spaceW(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mahek',
              style: TextStyle(
                fontFamily: FontFamily.bold,
                fontSize: 20,
                letterSpacing: 1.5,
                color: Colors.white,
              ),
            ),
            Text(
              'Admin',
              style: TextStyle(
                fontFamily: FontFamily.medium,
                fontSize: 11,
                letterSpacing: 2,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        spaceW(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'THE KINETIC EDITORIAL',
            style: TextStyle(
              fontFamily: FontFamily.medium,
              fontSize: 9,
              letterSpacing: 1.5,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroContent(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF5D54F2), Color(0xFFA78BFA)],
          ).createShader(bounds),
          child: Text(
            'Curate your',
            style: TextStyle(
              fontFamily: FontFamily.bold,
              fontSize: 56,
              height: 1.1,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
        ),
        Text(
          'digital masterpiece.',
          style: TextStyle(
            fontFamily: FontFamily.bold,
            fontSize: 56,
            height: 1.1,
            color: Colors.white,
            letterSpacing: -1,
          ),
        ),
        spaceH(height: 24),
        Container(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Text(
            'Step into a high-velocity workspace designed for elite administrative control and editorial precision.',
            style: TextStyle(
              fontFamily: FontFamily.regular,
              fontSize: 18,
              height: 1.6,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialProofCard(bool isDark) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 450),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
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
              _buildAvatarStack(),
              spaceW(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Join 2,400+ curators today',
                    style: TextStyle(
                      fontFamily: FontFamily.semiBold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  spaceH(height: 4),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: Colors.amber[400],
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
          spaceH(height: 16),
          Text(
            '"The kinetic interface has completely redefined how we manage our creative assets. It\'s fast, fluid, and focused."',
            style: TextStyle(
              fontFamily: FontFamily.regular,
              fontSize: 14,
              height: 1.6,
              fontStyle: FontStyle.italic,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          spaceH(height: 12),
          Text(
            '— Sarah Chen, Creative Director',
            style: TextStyle(
              fontFamily: FontFamily.medium,
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarStack() {
    return SizedBox(
      width: 80,
      height: 40,
      child: Stack(
        children: [
          _buildAvatar(0, 'JD'),
          _buildAvatar(28, 'MC'),
          _buildAvatar(56, 'AK'),
        ],
      ),
    );
  }

  Widget _buildAvatar(double left, String text) {
    return Positioned(
      left: left,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5D54F2), Color(0xFF8B7EFF)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: FontFamily.semiBold,
              fontSize: 11,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _buildFooterLink('SUPPORT'),
            spaceW(width: 20),
            _buildFooterLink('SECURITY'),
            spaceW(width: 20),
            _buildFooterLink('V4.2.0'),
          ],
        ),
        Text(
          '© 2024 Mahek Admin',
          style: TextStyle(
            fontFamily: FontFamily.regular,
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterLink(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: FontFamily.medium,
        fontSize: 11,
        letterSpacing: 1.2,
        color: Colors.white.withValues(alpha: 0.4),
      ),
    );
  }

  Widget _buildSignUpPanel(BuildContext context, bool isDark) {
    return Container(
      color: isDark ? AppThemeData.grey10 : AppThemeData.primaryWhite,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(48.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Heading
                  TextCustom(
                    title: 'Create your account',
                    fontSize: 32,
                    fontFamily: FontFamily.bold,
                    color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                  ),
                  spaceH(height: 8),
                  TextCustom(
                    title: 'Start your journey with The Kinetic Editorial.',
                    fontSize: 15,
                    fontFamily: FontFamily.regular,
                    color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                  ),
                  spaceH(height: 36),
                  // Full Name Field
                  _buildInputLabel('FULL NAME', isDark),
                  spaceH(height: 8),
                  _buildFullNameField(isDark),
                  spaceH(height: 20),
                  // Email Field
                  _buildInputLabel('EMAIL ADDRESS', isDark),
                  spaceH(height: 8),
                  _buildEmailField(isDark),
                  spaceH(height: 20),
                  // Password Field
                  _buildInputLabel('PASSWORD', isDark),
                  spaceH(height: 8),
                  _buildPasswordField(isDark),
                  spaceH(height: 6),
                  _buildPasswordHint(isDark),
                  spaceH(height: 24),
                  // Terms Checkbox
                  _buildTermsCheckbox(isDark),
                  spaceH(height: 32),
                  // Sign Up Button
                  _buildSignUpButton(isDark),
                  spaceH(height: 24),
                  // Divider
                  Row(
                    children: [
                      Expanded(child: divider(context, height: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextCustom(
                          title: 'OR CONTINUE WITH',
                          fontSize: 11,
                          fontFamily: FontFamily.medium,
                          color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
                        ),
                      ),
                      Expanded(child: divider(context, height: 1)),
                    ],
                  ),
                  spaceH(height: 20),
                  // Social Login Options (Display only)
                  _buildSocialLoginOptions(isDark),
                  spaceH(height: 32),
                  // Login Link
                  _buildLoginLink(isDark),
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

  Widget _buildFullNameField(bool isDark) {
    return TextFormField(
      controller: controller.fullNameController,
      style: TextStyle(
        fontFamily: FontFamily.regular,
        fontSize: 15,
        color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
      ),
      decoration: InputDecoration(
        hintText: 'John Doe',
        hintStyle: TextStyle(
          fontFamily: FontFamily.regular,
          fontSize: 15,
          color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
        ),
        filled: true,
        fillColor: isDark ? AppThemeData.grey9 : AppThemeData.grey2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF5D54F2),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppThemeData.danger300,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppThemeData.danger300,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        prefixIcon: Icon(
          Icons.person_outline_rounded,
          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
          size: 20,
        ),
        errorStyle: const TextStyle(
          fontFamily: FontFamily.regular,
          fontSize: 12,
        ),
      ),
      validator: controller.validateFullName,
      textCapitalization: TextCapitalization.words,
    );
  }

  Widget _buildEmailField(bool isDark) {
    return TextFormField(
      controller: controller.emailController,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(
        fontFamily: FontFamily.regular,
        fontSize: 15,
        color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
      ),
      decoration: InputDecoration(
        hintText: 'name@example.com',
        hintStyle: TextStyle(
          fontFamily: FontFamily.regular,
          fontSize: 15,
          color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
        ),
        filled: true,
        fillColor: isDark ? AppThemeData.grey9 : AppThemeData.grey2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF5D54F2),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppThemeData.danger300,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppThemeData.danger300,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
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
      validator: controller.validateEmail,
    );
  }

  Widget _buildPasswordField(bool isDark) {
    return Obx(() => TextFormField(
      controller: controller.passwordController,
      obscureText: controller.obscurePassword.value,
      style: TextStyle(
        fontFamily: FontFamily.regular,
        fontSize: 15,
        color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
      ),
      decoration: InputDecoration(
        hintText: '••••••••',
        hintStyle: TextStyle(
          fontFamily: FontFamily.regular,
          fontSize: 15,
          color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
        ),
        filled: true,
        fillColor: isDark ? AppThemeData.grey9 : AppThemeData.grey2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF5D54F2),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppThemeData.danger300,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppThemeData.danger300,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        prefixIcon: Icon(
          Icons.lock_outline_rounded,
          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
          size: 20,
        ),
        suffixIcon: IconButton(
          onPressed: controller.togglePasswordVisibility,
          icon: Icon(
            controller.obscurePassword.value
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            size: 20,
          ),
        ),
        errorStyle: const TextStyle(
          fontFamily: FontFamily.regular,
          fontSize: 12,
        ),
      ),
      validator: controller.validatePassword,
    ));
  }

  Widget _buildPasswordHint(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: TextCustom(
        title: 'Minimum 6 characters, one uppercase, one number',
        fontSize: 11,
        fontFamily: FontFamily.regular,
        color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
      ),
    );
  }

  Widget _buildTermsCheckbox(bool isDark) {
    return Obx(() => MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: controller.toggleTermsAgreement,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: controller.agreedToTerms.value
                    ? const Color(0xFF5D54F2)
                    : Colors.transparent,
                border: Border.all(
                  color: controller.agreedToTerms.value
                      ? const Color(0xFF5D54F2)
                      : (isDark ? AppThemeData.grey7 : AppThemeData.grey4),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: controller.agreedToTerms.value
                  ? const Icon(
                Icons.check,
                size: 14,
                color: Colors.white,
              )
                  : null,
            ),
            spaceW(width: 12),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: FontFamily.regular,
                    fontSize: 13,
                    color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
                  ),
                  children: [
                    const TextSpan(text: 'I agree to the '),
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(
                        color: const Color(0xFF5D54F2),
                        fontFamily: FontFamily.medium,
                      ),
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        color: const Color(0xFF5D54F2),
                        fontFamily: FontFamily.medium,
                      ),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildSignUpButton(bool isDark) {
    return Obx(() => Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
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
            controller.signUpWithEmailAndPassword();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
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
              title: 'Create Account',
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

  Widget _buildSocialLoginOptions(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton(
          icon: 'assets/icons/google_icon.png',
          fallbackIcon: Icons.g_mobiledata,
          label: 'Google',
          isDark: isDark,
          onTap: () {
            ShowToastDialog.showWarning('Google Sign-In coming soon');
          },
        ),
        spaceW(width: 16),
        _buildSocialButton(
          icon: 'assets/icons/github_icon.png',
          fallbackIcon: Icons.code,
          label: 'GitHub',
          isDark: isDark,
          onTap: () {
            ShowToastDialog.showWarning('GitHub Sign-In coming soon');
          },
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required String icon,
    required IconData fallbackIcon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? AppThemeData.grey9 : AppThemeData.grey2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  fallbackIcon,
                  size: 20,
                  color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
                ),
                spaceW(width: 8),
                TextCustom(
                  title: label,
                  fontSize: 13,
                  fontFamily: FontFamily.medium,
                  color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextCustom(
          title: 'Already have an account?',
          fontSize: 14,
          fontFamily: FontFamily.regular,
          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
        ),
        spaceW(width: 4),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: controller.navigateToLogin,
            child: TextCustom(
              title: 'Log in',
              fontSize: 14,
              fontFamily: FontFamily.semiBold,
              color: const Color(0xFF5D54F2),
            ),
          ),
        ),
      ],
    );
  }
}

// Custom painter for brand panel background
class _BrandBackgroundPainter extends CustomPainter {
  final bool isDark;

  _BrandBackgroundPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;

    // Decorative circles
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2),
      size.width * 0.5,
      paint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.8),
      size.width * 0.3,
      paint,
    );

    // Grid lines
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.02)
      ..strokeWidth = 0.5;

    for (double x = 0; x < size.width; x += 50) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        linePaint,
      );
    }

    for (double y = 0; y < size.height; y += 50) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}