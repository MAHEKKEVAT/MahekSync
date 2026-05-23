import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/utils/responsive.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/mahek_loader.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import '../controllers/sentinel_controller.dart';

class SentinelView extends GetView<SentinelController> {
  const SentinelView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveWidget.isMobile(context);

    return Scaffold(
      backgroundColor: isDark ? AppThemeData.grey10 : AppThemeData.grey2,
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: MahekLoader(showBackgroundOverlay: true, message: 'Loading Sentinel...'));
        }
        return isMobile ? _buildMobileLayout(isDark) : _buildDesktopLayout(isDark);
      }),
    );
  }

  Widget _buildDesktopLayout(bool isDark) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: _buildContent(isDark),
      ),
    );
  }

  Widget _buildMobileLayout(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: _buildContent(isDark),
    );
  }

  Widget _buildContent(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppThemeData.primary50, const Color(0xFF6C63FF)]),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: AppThemeData.primary50.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: Icon(SolarIconsBold.shieldKeyhole, color: Colors.white, size: 40),
          ),
          spaceH(height: 20),
          TextCustom(title: 'Sentinel', fontSize: 28, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
          spaceH(height: 6),
          TextCustom(title: 'Guard your vault with a master password', fontSize: 14, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
          spaceH(height: 32),

          // Status card
          Obx(() => _buildStatusCard(isDark)),
          spaceH(height: 24),

          // Action card
          Obx(() {
            if (!controller.isPasswordSet.value) {
              return _buildCreatePasswordCard(isDark);
            } else if (!controller.isVerified.value) {
              return _buildVerifyCard(isDark);
            } else {
              return _buildManageCard(isDark);
            }
          }),
        ],
      ),
    );
  }

  Widget _buildStatusCard(bool isDark) {
    final isLocked = controller.isLocked.value;
    final isSet = controller.isPasswordSet.value;
    final isVerified = controller.isVerified.value;

    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    if (isLocked) {
      statusColor = AppThemeData.danger300;
      statusLabel = 'Locked';
      statusIcon = SolarIconsBold.lockKeyhole;
    } else if (isSet && isVerified) {
      statusColor = AppThemeData.success400;
      statusLabel = 'Unlocked';
      statusIcon = SolarIconsBold.shieldCheck;
    } else if (isSet) {
      statusColor = AppThemeData.pending400;
      statusLabel = 'Protected';
      statusIcon = SolarIconsBold.shieldKeyhole;
    } else {
      statusColor = AppThemeData.grey5;
      statusLabel = 'Not Set';
      statusIcon = SolarIconsOutline.shieldKeyhole;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
            child: Icon(statusIcon, color: statusColor, size: 24),
          ),
          spaceW(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(title: 'Security Status', fontSize: 12, fontFamily: FontFamily.medium, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                spaceH(height: 2),
                TextCustom(title: statusLabel, fontSize: 18, fontFamily: FontFamily.bold, color: statusColor),
              ],
            ),
          ),
          if (controller.failedAttempts.value > 0 && !isLocked) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppThemeData.danger300.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: TextCustom(title: '${controller.failedAttempts.value}/5 fails', fontSize: 11, fontFamily: FontFamily.bold, color: AppThemeData.danger300),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCreatePasswordCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Set Master Password', SolarIconsOutline.lockKeyhole, isDark),
          spaceH(height: 16),
          _buildPasswordField(controller.passwordController, 'New password', 'At least 6 characters', isDark),
          spaceH(height: 14),
          _buildPasswordField(controller.confirmPasswordController, 'Confirm password', 'Re-enter password', isDark),
          spaceH(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: controller.isLoading.value ? null : controller.createMasterPassword,
              icon: Icon(SolarIconsBold.shieldCheck, color: Colors.white, size: 18),
              label: const TextCustom(title: 'Create Master Password', fontSize: 15, fontFamily: FontFamily.semiBold, color: Colors.white),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemeData.primary50,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Verify Identity', SolarIconsOutline.shieldCheck, isDark),
          spaceH(height: 8),
          TextCustom(title: 'Enter your master password to unlock Sentinel', fontSize: 13, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
          spaceH(height: 16),
          _buildPasswordField(controller.currentPasswordController, 'Master password', 'Enter your password', isDark),
          spaceH(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: controller.isLoading.value ? null : controller.verifyMasterPassword,
              icon: Icon(SolarIconsBold.lockKeyhole, color: Colors.white, size: 18),
              label: const TextCustom(title: 'Unlock', fontSize: 15, fontFamily: FontFamily.semiBold, color: Colors.white),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemeData.primary50,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          spaceH(height: 12),
          Center(
            child: TextButton(
              onPressed: controller.resetMasterPassword,
              child: const TextCustom(title: 'Forgot password?', fontSize: 13, fontFamily: FontFamily.medium, color: AppThemeData.danger300),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManageCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Manage Security', SolarIconsOutline.settings, isDark),
          spaceH(height: 20),

          // Change password section
          _buildPasswordField(controller.currentPasswordController, 'Current password', 'Enter current password', isDark),
          spaceH(height: 14),
          _buildPasswordField(controller.passwordController, 'New password', 'At least 6 characters', isDark),
          spaceH(height: 14),
          _buildPasswordField(controller.confirmPasswordController, 'Confirm new password', 'Re-enter new password', isDark),
          spaceH(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: controller.isLoading.value ? null : controller.updateMasterPassword,
              icon: Icon(SolarIconsBold.penNewRound, color: Colors.white, size: 18),
              label: const TextCustom(title: 'Update Password', fontSize: 15, fontFamily: FontFamily.semiBold, color: Colors.white),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemeData.primary50,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          spaceH(height: 12),

          // Reset password
          Center(
            child: TextButton.icon(
              onPressed: controller.resetMasterPassword,
              icon: Icon(SolarIconsOutline.dangerTriangle, color: AppThemeData.danger300, size: 16),
              label: const TextCustom(title: 'Reset Master Password', fontSize: 13, fontFamily: FontFamily.medium, color: AppThemeData.danger300),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(color: AppThemeData.primary50.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: AppThemeData.primary50, size: 16),
        ),
        spaceW(width: 10),
        TextCustom(title: title, fontSize: 16, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
      ],
    );
  }

  Widget _buildPasswordField(TextEditingController ctrl, String label, String hint, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(title: label, fontSize: 11, fontFamily: FontFamily.medium, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
        spaceH(height: 6),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? AppThemeData.grey8 : AppThemeData.grey3, width: 0.5),
          ),
          child: TextField(
            controller: ctrl,
            obscureText: true,
            style: TextStyle(fontFamily: FontFamily.medium, fontSize: 14, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(fontFamily: FontFamily.regular, fontSize: 14, color: isDark ? AppThemeData.grey6 : AppThemeData.grey5),
              prefixIcon: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppThemeData.primary50.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(SolarIconsOutline.lockKeyhole, color: AppThemeData.primary50, size: 18),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppThemeData.primary50, width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              filled: true,
              fillColor: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }
}
