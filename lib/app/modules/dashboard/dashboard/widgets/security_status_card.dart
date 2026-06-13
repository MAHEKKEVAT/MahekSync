import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:maheksync/app/modules/dashboard/controllers/dashboard_home_controller.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'package:solar_icons/solar_icons.dart';

class SecurityStatusCard extends StatefulWidget {
  final DashboardHomeController controller;
  final bool isDark;
  final VoidCallback? onTap;

  const SecurityStatusCard({
    super.key,
    required this.controller,
    required this.isDark,
    this.onTap,
  });

  @override
  State<SecurityStatusCard> createState() => _SecurityStatusCardState();
}

class _SecurityStatusCardState extends State<SecurityStatusCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scoreAnimation = Tween<double>(
      begin: 0,
      end: widget.controller.securityScore / 100,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isGood = widget.controller.isSecurityGood;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.surfaceDeep : AppThemeData.grey1,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppThemeData.surfaceBorder.withValues(alpha: 0.12)
              : AppThemeData.grey3.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppThemeData.neonTeal, AppThemeData.neonBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(SolarIconsBold.shieldCheck,
                    size: 18, color: Colors.white),
              ),
              const SizedBox(width: 14),
              TextCustom(
                title: 'Security Status',
                fontSize: 17,
                fontFamily: FontFamily.bold,
                color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Shield icon with glow
          Center(
            child: AnimatedBuilder(
              animation: _scoreAnimation,
              builder: (context, _) {
                return Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppThemeData.success400.withValues(alpha: _scoreAnimation.value * 0.2),
                        AppThemeData.success400.withValues(alpha: _scoreAnimation.value * 0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: CustomPaint(
                    painter: _ScoreRingPainter(
                      score: _scoreAnimation.value,
                      color: isGood ? AppThemeData.success400 : AppThemeData.pending400,
                      isDark: isDark,
                    ),
                    child: Center(
                      child: Icon(
                        SolarIconsBold.shieldCheck,
                        size: 32,
                        color: isGood
                            ? AppThemeData.success400
                            : AppThemeData.pending400,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isGood ? "You're Protected" : 'Needs Attention',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: FontFamily.bold,
              fontSize: 16,
              color: isGood
                  ? AppThemeData.success400
                  : AppThemeData.pending400,
            ),
          ),
          const SizedBox(height: 18),

          // Metrics
          _MetricRow(
            icon: SolarIconsBold.lockKeyhole,
            label: 'Password Strength',
            value: 'Strong',
            valueColor: AppThemeData.success400,
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _MetricRow(
            icon: SolarIconsBold.shieldKeyhole,
            label: 'Vault Encryption',
            value: 'Active',
            valueColor: AppThemeData.success400,
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _MetricRow(
            icon: SolarIconsBold.cloudUpload,
            label: 'Last Backup',
            value: '2 Days Ago',
            valueColor: AppThemeData.success400,
            isDark: isDark,
          ),
          const SizedBox(height: 16),

          // CTA Button
          GestureDetector(
            onTap: widget.onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppThemeData.neonTeal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppThemeData.neonTeal.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Open Sentinel',
                    style: TextStyle(
                      fontFamily: FontFamily.semiBold,
                      fontSize: 13,
                      color: AppThemeData.neonTeal,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded,
                      size: 15, color: AppThemeData.neonTeal),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool get isDark => widget.isDark;
}

class _MetricRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;
  final bool isDark;

  const _MetricRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: isDark ? AppThemeData.grey4 : AppThemeData.grey7),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: FontFamily.regular,
              fontSize: 12,
              color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: FontFamily.bold,
            fontSize: 12,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  final double score;
  final Color color;
  final bool isDark;

  _ScoreRingPainter({
    required this.score,
    required this.color,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    final bgPaint = Paint()
      ..color = isDark
          ? AppThemeData.surfaceMid.withValues(alpha: 0.5)
          : AppThemeData.grey2
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final scorePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * score.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      scorePaint,
    );

    if (score > 0) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter oldDelegate) =>
      oldDelegate.score != score || oldDelegate.color != color;
}
