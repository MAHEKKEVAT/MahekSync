import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:maheksync/app/routes/app_pages.dart';
import 'package:provider/provider.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/dark_theme_provider.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/utils/mahek_responsive.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'package:maheksync/app/widgets/text_field_widget.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:solar_icons/solar_icons.dart';
import '../../auth/controllers/auth_controller.dart';

// ══════════════════════════════════════════════════════════════════════════
//  RESPONSIVE BREAKPOINT SYSTEM
// ══════════════════════════════════════════════════════════════════════════

class _ResponsiveScale {
  final double screenW;
  final double screenH;

  // Breakpoint thresholds
  static const double laptopMin = 1024;
  static const double desktopMin = 1280;
  static const double wideMin = 1600;
  static const double ultraMin = 2560;

  _ResponsiveScale(this.screenW, this.screenH);

  bool get isLaptop => screenW >= laptopMin && screenW < desktopMin;
  bool get isDesktop => screenW >= desktopMin && screenW < wideMin;
  bool get isWide => screenW >= wideMin && screenW < ultraMin;
  bool get isUltra => screenW >= ultraMin;

  double get contentMaxWidth {
    if (isUltra) return 1600;
    if (isWide) return 1440;
    if (isDesktop) return 1280;
    return 1400;
  }

  double get horizontalPadding {
    if (isUltra) return 80;
    if (isWide) return 64;
    if (isDesktop) return 48;
    return 32; // laptop
  }

  // ── Login panel ────────────────────────────────────────────────────
  double get loginPanelWidth {
    if (isUltra) return 480;
    if (isWide) return 460;
    return 440; // desktop & laptop
  }

  double get loginPanelPadding {
    if (isUltra) return 40;
    if (isWide) return 38;
    return 36;
  }

  // ── Typography ─────────────────────────────────────────────────────
  double get headlineSize {
    if (isUltra) return 64;
    if (isWide) return 56;
    if (isDesktop) return 50;
    return 42; // laptop
  }

  double get subtitleSize {
    if (isUltra) return 18;
    if (isWide) return 17;
    return 16;
  }

  double get logoSize {
    if (isUltra) return 56;
    if (isWide) return 52;
    return 48;
  }

  double get logoFontSize {
    if (isUltra) return 26;
    if (isWide) return 24;
    return 22;
  }

  // ── Form elements ──────────────────────────────────────────────────
  double get inputBorderRadius {
    if (isUltra) return 16;
    return 14;
  }

  double get buttonHeight {
    if (isUltra) return 58;
    if (isWide) return 56;
    return 54;
  }

  double get buttonBorderRadius {
    if (isUltra) return 18;
    return 16;
  }

  // ── Feature pills ──────────────────────────────────────────────────
  double get pillIconSize => isUltra ? 16 : 14;
  double get pillFontSize => isUltra ? 12 : 11;
  double get pillSpacing => isUltra ? 12 : 10;

  // ── Spacing ────────────────────────────────────────────────────────
  double get sectionGap => isUltra ? 40 : isWide ? 36 : 32;
  double get fieldGap => isUltra ? 24 : 20;
  double get smallGap => isUltra ? 10 : 8;

  // ── Brand section max constraint ───────────────────────────────────
  double get brandMaxWidth {
    if (isUltra) return 680;
    if (isWide) return 600;
    return 520;
  }

  double get descriptionMaxWidth {
    if (isUltra) return 480;
    if (isWide) return 440;
    return 420;
  }

  // ── Gap between brand and login ────────────────────────────────────
  double get sceneGap {
    if (isUltra) return 80;
    if (isWide) return 60;
    return 40;
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  MAIN VIEW
// ══════════════════════════════════════════════════════════════════════════

class LoginScreenView extends StatefulWidget {
  const LoginScreenView({super.key});
  @override
  State<LoginScreenView> createState() => _LoginScreenViewState();
}

class _LoginScreenViewState extends State<LoginScreenView>
    with TickerProviderStateMixin {
  final AuthController controller = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();
  bool _rememberMe = false;
  bool _obscurePassword = true;

  // ── Animation controllers ────────────────────────────────────────────
  late AnimationController _glowCtrl;
  late AnimationController _particleCtrl;
  late AnimationController _waveCtrl;
  late AnimationController _shimmerCtrl;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000))..repeat(reverse: true);
    _particleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 8000))..repeat();
    _waveCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 5000))..repeat(reverse: true);
    _shimmerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500))..repeat();
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _particleCtrl.dispose();
    _waveCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDark = themeChange.isDarkTheme();
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppThemeData.surfaceVoid,

    body: width >= 900
        ? _buildImmersiveDesktop(context, isDark)
        : _buildMobileLayout(context, isDark),
    );
  }

  Widget _buildImmersiveDesktop(BuildContext context, bool isDark) {
    final size = MediaQuery.of(context).size;
    final s = _ResponsiveScale(size.width, size.height);

    return Stack(
      children: [
        // ── LAYER 0: Deep background (EXPANDS to fill any screen) ────
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppThemeData.surfaceVoid,
                AppThemeData.surfaceObsidian,
                Color(0xFF080618),
                AppThemeData.neonBlueDim,
              ],
            ),
          ),
        ),

        // ── LAYER 1: Neural grid (full-bleed atmospheric) ────────────
        Positioned.fill(
          child: CustomPaint(painter: NeuralGridPainter(_waveCtrl)),
        ),

        // ── LAYER 2: Background image ───────────────────────────────
        Positioned.fill(
          child: Opacity(
            opacity: 0.35,
            child: Image.asset(
              'assets/images/login_bg.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ),

        // ── LAYER 3: Atmospheric glow orbs ───────────────────────────
        ..._buildAtmosphericOrbs(),

        // ── LAYER 4: Neural wave ────────────────────────────────────
        Positioned.fill(
          child: CustomPaint(painter: NeuralWavePainter(_waveCtrl)),
        ),

        // ── LAYER 5: Floating particles ─────────────────────────────
        Positioned.fill(
          child: CustomPaint(painter: ParticleFieldPainter(_particleCtrl)),
        ),

        // ── LAYER 9: Cinematic vignette ─────────────────────────────
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  Colors.transparent,
                  AppThemeData.surfaceVoid.withValues(alpha: 0.3),
                  AppThemeData.surfaceVoid.withValues(alpha: 0.7),
                ],
                stops: const [0.4, 0.7, 1.0],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: s.contentMaxWidth,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: s.horizontalPadding,
                  vertical: 40,
                ),
                child: Row(
                  children: [

                    // LEFT SIDE
                    Expanded(
                      flex: 6,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: s.brandMaxWidth,
                          ),
                          child: _buildBrandIdentity(
                            context,
                            s,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: s.sceneGap),

                    // RIGHT SIDE
                    Expanded(
                      flex: 4,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: s.loginPanelWidth,
                          ),
                          child: _buildGlassLoginPanel(
                            context,
                            isDark,
                            s,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  ATMOSPHERIC ORBS — positioned relative to screen edges
  // ══════════════════════════════════════════════════════════════════════

  List<Widget> _buildAtmosphericOrbs() {
    return [
      // Top-right: Purple energy
      Positioned(
        top: -120, right: -80,
        child: AnimatedBuilder(
          animation: _glowCtrl,
          builder: (context, _) {
            return Container(
              width: 500, height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppThemeData.neonPurple.withValues(alpha: _glowCtrl.value * 0.3),
                  AppThemeData.neonBlue.withValues(alpha: _glowCtrl.value * 0.1),
                  Colors.transparent,
                ]),
              ),
            );
          },
        ),
      ),
      // Bottom-left: Teal energy
      Positioned(
        bottom: -150, left: -100,
        child: AnimatedBuilder(
          animation: _glowCtrl,
          builder: (context, _) {
            return Container(
              width: 600, height: 600,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppThemeData.neonTeal.withValues(alpha: (1 - _glowCtrl.value) * 0.2),
                  AppThemeData.neonMint.withValues(alpha: (1 - _glowCtrl.value) * 0.08),
                  Colors.transparent,
                ]),
              ),
            );
          },
        ),
      ),
      // Center-left: Pink ambient (relative)
      Positioned.fill(
        child: AnimatedBuilder(
          animation: _glowCtrl,
          builder: (context, _) {
            return Align(
              alignment: const Alignment(-0.4, -0.2),
              child: Container(
                width: 350, height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    AppThemeData.neonPink.withValues(alpha: _glowCtrl.value * 0.12),
                    Colors.transparent,
                  ]),
                ),
              ),
            );
          },
        ),
      ),
    ];
  }


  // ══════════════════════════════════════════════════════════════════════
  //  BRAND IDENTITY — responsive typography + constrained layout
  // ══════════════════════════════════════════════════════════════════════

  Widget _buildBrandIdentity(BuildContext context, _ResponsiveScale s) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Logo ─────────────────────────────────────────────────
            Row(
              children: [
                AnimatedBuilder(
                  animation: _glowCtrl,
                  builder: (context, _) {
                    return Container(
                      width: s.logoSize, height: s.logoSize,
                      decoration: BoxDecoration(
                        gradient: AppThemeData.appleIntelligenceGradientCool,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: AppThemeData.neonGlow(AppThemeData.neonPurple, blur: 28, opacity: _glowCtrl.value * 0.5),
                      ),
                      child: Icon(SolarIconsBold.bolt, color: Colors.white, size: s.logoSize * 0.54),
                    );
                  },
                ),
                spaceW(width: 14),
                ShaderMask(
                  shaderCallback: (b) => AppThemeData.geminiGradient.createShader(b),
                  child: Text('MAHEK', style: TextStyle(fontFamily: FontFamily.bold, fontSize: s.logoFontSize, letterSpacing: 3, color: Colors.white)),
                ),
              ],
            ),
            SizedBox(height: 90),

            // ── Headline — responsive size ────────────────────────────
            ShaderMask(
              shaderCallback: (b) => AppThemeData.appleIntelligenceGradient.createShader(b),
              child: Text(
                'Your Personal\nIntelligence\nOperating System.',
                style: TextStyle(
                  fontFamily: FontFamily.bold,
                  fontSize: s.headlineSize,
                  height: 1.08,
                  color: Colors.white,
                  letterSpacing: -1.5,
                ),
              ),
            ),
            SizedBox(height: s.sectionGap * 0.75),

            // ── Description — constrained width ───────────────────────
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: s.descriptionMaxWidth),
              child: Text(
                'Next-generation AI workspace. Secure vault, intelligent memory, editorial velocity — all unified in one spatial interface.',
                style: TextStyle(
                  fontFamily: FontFamily.regular,
                  fontSize: s.subtitleSize,
                  height: 1.7,
                  color: AppThemeData.textNeonBlue.withValues(alpha: 0.8),
                ),
              ),
            ),
            SizedBox(height: s.sectionGap),

            // ── Feature pills ────────────────────────────────────────
            Wrap(
              spacing: s.pillSpacing, runSpacing: s.pillSpacing,
              children: [
                _buildFeaturePill(SolarIconsBold.shieldKeyhole, 'Neural Encryption', AppThemeData.neonMint, s),
                _buildFeaturePill(SolarIconsBold.cloudUpload, 'Spatial Sync', AppThemeData.neonTeal, s),
                _buildFeaturePill(SolarIconsBold.magicStick, 'AI Memory', AppThemeData.neonPurple, s),
                _buildFeaturePill(SolarIconsBold.lockKeyhole, 'Zero-Trust Vault', AppThemeData.neonPink, s),
              ],
            ),
            SizedBox(height: 70),

            // ── Footer chips ─────────────────────────────────────────
            Row(
              children: [
                _buildFooterChip('SYNC v4.2', AppThemeData.neonBlue, s),
                spaceW(width: 12),
                _buildFooterChip('QUANTUM READY', AppThemeData.neonPurple, s),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturePill(IconData icon, String label, Color c, _ResponsiveScale s) {
    return AnimatedBuilder(
      animation: _glowCtrl,
      builder: (context, _) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: s.pillSpacing + 4, vertical: 8),
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: c.withValues(alpha: 0.2)),
            boxShadow: AppThemeData.neonGlow(c, blur: 12, opacity: _glowCtrl.value * 0.1),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: c, size: s.pillIconSize),
            spaceW(width: 6),
            Text(label, style: TextStyle(fontFamily: FontFamily.medium, fontSize: s.pillFontSize, color: c.withValues(alpha: 0.9), letterSpacing: 0.3)),
          ]),
        );
      },
    );
  }

  Widget _buildFooterChip(String text, Color c, _ResponsiveScale s) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(border: Border.all(color: c.withValues(alpha: 0.15)), borderRadius: BorderRadius.circular(30)),
      child: Text(text, style: TextStyle(fontFamily: FontFamily.medium, fontSize: 10, letterSpacing: 1.5, color: c.withValues(alpha: 0.5))),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  FLOATING GLASS LOGIN PANEL — FIXED width, NEVER stretches
  // ══════════════════════════════════════════════════════════════════════

  Widget _buildGlassLoginPanel(BuildContext context, bool isDark, _ResponsiveScale s) {
    return AnimatedBuilder(
      animation: _glowCtrl,
      builder: (context, _) {
        return Container(
          constraints: BoxConstraints(
            maxWidth: s.loginPanelWidth,
            maxHeight: 720,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(
                padding: EdgeInsets.all(s.loginPanelPadding),
                decoration: BoxDecoration(
                  color: AppThemeData.surfaceDeep.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: AppThemeData.neonPurple.withValues(alpha: 0.12 + _glowCtrl.value * 0.06),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 60, offset: const Offset(0, 20)),
                    ...AppThemeData.neonGlow(AppThemeData.neonPurple, blur: 40, opacity: _glowCtrl.value * 0.12),
                    BoxShadow(color: AppThemeData.neonBlue.withValues(alpha: 0.03), blurRadius: 0, offset: const Offset(0, -1)),
                  ],
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppThemeData.surfaceElevated.withValues(alpha: 0.3),
                      AppThemeData.surfaceDeep.withValues(alpha: 0.1),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Welcome heading ──────────────────────────────
                    ShaderMask(
                      shaderCallback: (b) => AppThemeData.appleIntelligenceGradientCool.createShader(b),
                      child: TextCustom(title: 'Welcome Back', fontSize: 30, fontFamily: FontFamily.bold, color: Colors.white),
                    ),
                    spaceH(height: 6),
                    TextCustom(
                      title: 'Authenticate to your spatial workspace',
                      fontSize: 14, fontFamily: FontFamily.regular,
                      color: AppThemeData.textNeonBlue.withValues(alpha: 0.6),
                    ),
                    SizedBox(height: s.sectionGap),

                    // ── Form ─────────────────────────────────────────
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputLabel('EMAIL ADDRESS'),
                          SizedBox(height: s.smallGap),
                          _buildEmailField(s),
                          SizedBox(height: s.fieldGap),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildInputLabel('PASSWORD'),
                              _buildForgotPassword(),
                            ],
                          ),
                          SizedBox(height: s.smallGap),
                          _buildPasswordField(s),
                          SizedBox(height: s.fieldGap * 0.9),
                          _buildRememberMe(),
                          SizedBox(height: s.sectionGap * 0.85),
                          _buildSignInButton(s),
                        ],
                      ),
                    ),
                    SizedBox(height: s.sectionGap * 0.75),

                    // ── Sign up + M circle ───────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSignUpLink(),
                        _buildOwnerCircle(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Input label ─────────────────────────────────────────────────────

  Widget _buildInputLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: FontFamily.bold, fontSize: 10,
        color: AppThemeData.textNeonPurple.withValues(alpha: 0.6),
        letterSpacing: 2,
      ),
    );
  }

  // ── Email field ─────────────────────────────────────────────────────

  Widget _buildEmailField(_ResponsiveScale s) {
    return TextFieldWidget(
      hintText: 'name@company.com',
      controller: controller.emailController,
      onPress: () {},
      textInputType: TextInputType.emailAddress,
      validator: (v) => (v == null || v.isEmpty) ? 'Email is required' : (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v) ? 'Enter a valid email' : null),
      prefix: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppThemeData.neonBlue.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(8)),
        child: Icon(SolarIconsOutline.letter, color: AppThemeData.neonBlue.withValues(alpha: 0.6), size: 16),
      ),
      fillColor: AppThemeData.surfaceMid.withValues(alpha: 0.5),
    );
  }

  // ── Password field ──────────────────────────────────────────────────

  Widget _buildPasswordField(_ResponsiveScale s) {
    return TextFieldWidget(
      hintText: '••••••••',
      controller: controller.passwordController,
      onPress: () {},
      obscureText: _obscurePassword,
      validator: (v) => (v == null || v.isEmpty) ? 'Password is required' : (v.length < 6 ? 'Minimum 6 characters' : null),
      prefix: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppThemeData.neonPurple.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(8)),
        child: Icon(SolarIconsOutline.lockKeyhole, color: AppThemeData.neonPurple.withValues(alpha: 0.6), size: 16),
      ),
      suffix: GestureDetector(
        onTap: () => setState(() => _obscurePassword = !_obscurePassword),
        child: Icon(_obscurePassword ? SolarIconsOutline.eye : SolarIconsOutline.eyeClosed, color: AppThemeData.neonPurple.withValues(alpha: 0.5), size: 18),
      ),
      fillColor: AppThemeData.surfaceMid.withValues(alpha: 0.5),
    );
  }

  // ── Forgot password ─────────────────────────────────────────────────

  Widget _buildForgotPassword() {
    return GestureDetector(
      onTap: () => controller.forgotPassword(),
      child: TextCustom(title: 'Forgot?', fontSize: 12, fontFamily: FontFamily.semiBold, color: AppThemeData.neonMint.withValues(alpha: 0.7)),
    );
  }

  // ── Remember me ─────────────────────────────────────────────────────

  Widget _buildRememberMe() {
    return GestureDetector(
      onTap: () => setState(() => _rememberMe = !_rememberMe),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 18, height: 18,
          decoration: BoxDecoration(
            gradient: _rememberMe ? AppThemeData.appleIntelligenceGradientCool : null,
            color: _rememberMe ? null : Colors.transparent,
            border: Border.all(color: _rememberMe ? AppThemeData.neonPurple.withValues(alpha: 0.5) : AppThemeData.surfaceHighlight, width: 1.5),
            borderRadius: BorderRadius.circular(5),
            boxShadow: _rememberMe ? AppThemeData.neonGlow(AppThemeData.neonPurple, blur: 8, opacity: 0.15) : [],
          ),
          child: _rememberMe ? const Icon(SolarIconsBold.checkCircle, size: 10, color: Colors.white) : null,
        ),
        spaceW(width: 8),
        TextCustom(title: 'Remember session', fontSize: 12, fontFamily: FontFamily.regular, color: AppThemeData.textNeonBlue.withValues(alpha: 0.5)),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  CINEMATIC SIGN IN BUTTON — constrained inside panel
  // ══════════════════════════════════════════════════════════════════════

  Widget _buildSignInButton(_ResponsiveScale s) {
    return Obx(() {
      final loading = controller.isLoading.value;
      return AnimatedBuilder(
        animation: Listenable.merge([_glowCtrl, _shimmerCtrl]),
        builder: (context, _) {
          return Container(
            height: s.buttonHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(s.buttonBorderRadius),
              gradient: AppThemeData.appleIntelligenceGradientCool,
              boxShadow: [
                ...AppThemeData.neonGlow(AppThemeData.neonPurple, blur: 32, opacity: loading ? 0.08 : _glowCtrl.value * 0.4),
                BoxShadow(color: AppThemeData.neonPink.withValues(alpha: 0.12), blurRadius: 24, offset: const Offset(0, 6)),
              ],
            ),
            child: Stack(
              children: [
                // ── Shimmer sweep ──────────────────────────────────
                if (!loading)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(s.buttonBorderRadius),
                    child: Align(
                      alignment: Alignment((-1 + _shimmerCtrl.value * 3).clamp(-1.0, 1.0), 0),
                      child: Container(
                        width: 80, height: s.buttonHeight,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            Colors.white.withValues(alpha: 0),
                            Colors.white.withValues(alpha: 0.15),
                            Colors.white.withValues(alpha: 0),
                          ]),
                        ),
                      ),
                    ),
                  ),
                // ── Button content ─────────────────────────────────
                SizedBox(
                  height: s.buttonHeight,
                  child: ElevatedButton(
                    onPressed: loading ? null : () {
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
                      disabledForegroundColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      alignment: Alignment.center,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(s.buttonBorderRadius)),
                    ),
                    child: loading
                        ? const SizedBox(
                            width: 22, height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(
                        'Authenticate',
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: FontFamily.semiBold,
                          color: Colors.white,
                          shadows: const [
                            Shadow(color: Colors.black87, blurRadius: 4, offset: Offset(0, 1)),
                          ],
                        ),
                      ),
                      spaceW(width: 8),
                      const Icon(SolarIconsOutline.arrowRight, color: Colors.white, size: 18, shadows: [Shadow(color: Colors.black87, blurRadius: 4, offset: Offset(0, 1))]),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  // ── Sign up link ────────────────────────────────────────────────────

  Widget _buildSignUpLink() {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      TextCustom(title: 'New?', fontSize: 13, fontFamily: FontFamily.regular, color: AppThemeData.grey6),
      spaceW(width: 4),
      GestureDetector(
        onTap: () => Get.toNamed(Routes.SIGN_UP),
        child: ShaderMask(
          shaderCallback: (b) => AppThemeData.geminiGradient.createShader(b),
          child: const TextCustom(title: 'Create Account', fontSize: 13, fontFamily: FontFamily.semiBold, color: Colors.white),
        ),
      ),
    ]);
  }

  // ── Owner M circle ──────────────────────────────────────────────────

  Widget _buildOwnerCircle() {
    return AnimatedBuilder(
      animation: _glowCtrl,
      builder: (context, _) {
        return Tooltip(
          message: 'Tap to fill credentials',
          preferBelow: true,
          child: GestureDetector(
            onTap: () {
              controller.emailController.text = 'mahekjkevat@gmail.com';
              controller.passwordController.text = 'Mahek@6561';
              Get.snackbar(
                'Ready!',
                'Credentials filled',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppThemeData.neonMint.withValues(alpha: 0.9),
                colorText: AppThemeData.surfaceVoid,
                duration: const Duration(seconds: 2),
                margin: const EdgeInsets.all(16),
                borderRadius: 14,
                icon: Icon(SolarIconsBold.checkCircle, color: AppThemeData.surfaceVoid),
              );
            },
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppThemeData.appleIntelligenceGradientCool,
                boxShadow: AppThemeData.neonGlow(AppThemeData.neonPurple, blur: 12, opacity: _glowCtrl.value * 0.2),
              ),
              child: const Center(child: Text('M', style: TextStyle(fontFamily: FontFamily.bold, fontSize: 13, color: Colors.white))),
            ),
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  MOBILE / TABLET LAYOUT
  // ══════════════════════════════════════════════════════════════════════

  Widget _buildMobileLayout(BuildContext context, bool isDark) {
    return Container(
      decoration: const BoxDecoration(gradient: LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [AppThemeData.surfaceVoid, AppThemeData.surfaceObsidian, AppThemeData.neonBlueDim],
      )),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Logo
            Row(children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(gradient: AppThemeData.appleIntelligenceGradientCool, borderRadius: BorderRadius.circular(12)), child: const Icon(SolarIconsBold.bolt, color: Colors.white, size: 22)),
              spaceW(width: 10),
              ShaderMask(shaderCallback: (b) => AppThemeData.geminiGradient.createShader(b), child: const Text('MAHEK', style: TextStyle(fontFamily: FontFamily.bold, fontSize: 18, letterSpacing: 2.5, color: Colors.white))),
            ]),
            spaceH(height: 40),
            ShaderMask(shaderCallback: (b) => AppThemeData.appleIntelligenceGradientCool.createShader(b), child: const TextCustom(title: 'Welcome Back', fontSize: 28, fontFamily: FontFamily.bold, color: Colors.white)),
            spaceH(height: 6),
            TextCustom(title: 'Authenticate to your workspace', fontSize: 14, fontFamily: FontFamily.regular, color: AppThemeData.textNeonBlue.withValues(alpha: 0.6)),
            spaceH(height: 32),
            // Mobile form card
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: AppThemeData.surfaceDeep.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppThemeData.neonPurple.withValues(alpha: 0.1))),
                  child: Form(key: _formKey, child: Column(children: [
                    _buildInputLabel('EMAIL ADDRESS'), spaceH(height: 8), _buildEmailField(_ResponsiveScale(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height)),
                    spaceH(height: 16),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildInputLabel('PASSWORD'), _buildForgotPassword()]),
                    spaceH(height: 8), _buildPasswordField(_ResponsiveScale(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height)),
                    spaceH(height: 14), _buildRememberMe(), spaceH(height: 24),
                    _buildSignInButton(_ResponsiveScale(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height)),
                  ])),
                ),
              ),
            ),
            spaceH(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildSignUpLink(), _buildOwnerCircle()]),
          ]),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  CUSTOM PAINTERS
// ══════════════════════════════════════════════════════════════════════════

// ── Neural Grid Floor ──────────────────────────────────────────────────

class NeuralGridPainter extends CustomPainter {
  final Animation<double> animation;
  NeuralGridPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    final paint = Paint()
      ..color = AppThemeData.neonPurple.withValues(alpha: 0.03 + t * 0.02)
      ..strokeWidth = 0.5;

    for (var i = 0; i < 20; i++) {
      final y = size.height * 0.6 + (i * 25.0) + sin(t * pi + i * 0.3) * 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    for (var i = 0; i < 30; i++) {
      final x = i * (size.width / 20.0) + cos(t * pi + i * 0.2) * 2;
      canvas.drawLine(Offset(x, size.height * 0.5), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ── Neural Wave ────────────────────────────────────────────────────────

class NeuralWavePainter extends CustomPainter {
  final Animation<double> animation;
  NeuralWavePainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    final cx = size.width * 0.38;
    final cy = size.height * 0.5;

    for (var wave = 0; wave < 3; wave++) {
      final colors = [
        AppThemeData.neonPurple.withValues(alpha: 0.08 - wave * 0.02),
        AppThemeData.neonBlue.withValues(alpha: 0.06 - wave * 0.015),
        AppThemeData.neonTeal.withValues(alpha: 0.04 - wave * 0.01),
      ];

      final path = Path();
      for (var x = 0.0; x < size.width; x += 2) {
        final progress = x / size.width;
        final y = cy + sin(progress * 4 * pi + t * 2 * pi + wave * 0.8) * (60 + wave * 20)
            + cos(progress * 2 * pi + t * pi) * 30;
        if (x == 0) path.moveTo(x, y); else path.lineTo(x, y);
      }

      final paint = Paint()
        ..color = colors[wave]
        ..strokeWidth = 1.5 - wave * 0.3
        ..style = PaintingStyle.stroke;
      canvas.drawPath(path, paint);
    }

    // Glowing nodes along center wave
    for (var i = 0; i < 8; i++) {
      final x = cx - 200 + i * 70.0;
      final progress = x / size.width;
      final y = cy + sin(progress * 4 * pi + t * 2 * pi) * 60 + cos(progress * 2 * pi + t * pi) * 30;
      final nodePaint = Paint()
        ..color = AppThemeData.neonPurple.withValues(alpha: 0.2 + t * 0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawCircle(Offset(x, y), 4 + t * 2, nodePaint);

      final dotPaint = Paint()
        ..color = AppThemeData.neonMint.withValues(alpha: 0.5)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ── Particle Field ─────────────────────────────────────────────────────

class ParticleFieldPainter extends CustomPainter {
  final Animation<double> animation;
  final Random _rng = Random(42);
  ParticleFieldPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;

    for (var i = 0; i < 60; i++) {
      final baseX = _rng.nextDouble() * size.width;
      final baseY = _rng.nextDouble() * size.height;
      final speed = 0.3 + _rng.nextDouble() * 0.7;
      final offset = t * speed * 100;

      final x = (baseX + sin(offset + i) * 20) % size.width;
      final y = (baseY + cos(offset + i * 0.7) * 15) % size.height;
      final radius = 0.5 + _rng.nextDouble() * 1.5;
      final alpha = 0.15 + _rng.nextDouble() * 0.25;

      final colors = [AppThemeData.neonPurple, AppThemeData.neonBlue, AppThemeData.neonTeal, AppThemeData.neonMint, AppThemeData.neonPink];
      final color = colors[i % colors.length].withValues(alpha: alpha);

      canvas.drawCircle(Offset(x, y), radius, Paint()..color = color..style = PaintingStyle.fill);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ── Radar Pulse ────────────────────────────────────────────────────────

class RadarPulsePainter extends CustomPainter {
  final double progress;
  RadarPulsePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final maxRadius = size.width / 2;

    for (var i = 0; i < 3; i++) {
      final p = (progress + i * 0.33) % 1.0;
      final radius = p * maxRadius;
      final alpha = (1 - p) * 0.1;

      final paint = Paint()
        ..color = AppThemeData.neonMint.withValues(alpha: alpha)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(Offset(cx, cy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
