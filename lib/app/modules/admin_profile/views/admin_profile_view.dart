import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/dark_theme_provider.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/utils/responsive.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/mahek_loader.dart';
import 'package:maheksync/app/widgets/network_image_widget.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'package:maheksync/app/widgets/text_field_widget.dart';
import '../controllers/admin_profile_controller.dart';

class AdminProfileView extends StatelessWidget {
  const AdminProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<DarkThemeProvider>(context);
    final isDark = theme.isDarkTheme();
    final controller = Get.put(AdminProfileController());
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveWidget.isMobile(context) ? 16 : 40,
            vertical: 28,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isDark),
              spaceH(height: 28),
              if (isDesktop)
                _buildDesktopLayout(context, controller, isDark)
              else
                _buildMobileLayout(context, controller, isDark),
              spaceH(height: 28),
              _buildSaveButton(controller, isDark),
              spaceH(height: 16),
              _buildSecurityFooter(isDark),
              spaceH(height: 20),
            ],
          ),
        ),
        Obx(() => _buildLoadingOverlay(controller)),
      ],
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppThemeData.primary50, AppThemeData.primary4],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppThemeData.primary50.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.person_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        spaceW(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextCustom(
                title: 'Edit Profile',
                fontSize: 24,
                fontFamily: FontFamily.bold,
                color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              ),
              spaceH(height: 3),
              TextCustom(
                title: 'Update your personal information and profile photo',
                fontSize: 13,
                fontFamily: FontFamily.regular,
                color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(
      BuildContext context, AdminProfileController controller, bool isDark) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 4, child: _buildAvatarCard(context, controller, isDark)),
          spaceW(width: 24),
          Expanded(flex: 6, child: _buildFormCard(controller, isDark)),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(
      BuildContext context, AdminProfileController controller, bool isDark) {
    return Column(
      children: [
        _buildAvatarCard(context, controller, isDark),
        spaceH(height: 24),
        _buildFormCard(controller, isDark),
      ],
    );
  }

  // ─── Avatar Card ─────────────────────────────────────────────
  Widget _buildAvatarCard(
      BuildContext context, AdminProfileController controller, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
      decoration: _cardDecoration(isDark),
      child: Column(
        children: [
          _buildAvatarCircle(context, controller, isDark, size: 150),
          spaceH(height: 20),
          ListenableBuilder(
            listenable: controller.fullNameController,
            builder: (_, _) => TextCustom(
              title: controller.fullNameController.text.isEmpty
                  ? 'Your Name'
                  : controller.fullNameController.text,
              fontSize: 18,
              fontFamily: FontFamily.semiBold,
              color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              textAlign: TextAlign.center,
            ),
          ),
          spaceH(height: 4),
          ListenableBuilder(
            listenable: controller.emailController,
            builder: (_, _) => TextCustom(
              title: controller.emailController.text.isEmpty
                  ? 'email@example.com'
                  : controller.emailController.text,
              fontSize: 12,
              fontFamily: FontFamily.regular,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
              textAlign: TextAlign.center,
            ),
          ),
          spaceH(height: 24),
          _buildChangePhotoButton(controller, isDark, fullWidth: true),
          Obx(() => _buildRemoveButton(controller, isDark)),
        ],
      ),
    );
  }

  // ─── Avatar Circle ───────────────────────────────────────────
  Widget _buildAvatarCircle(
    BuildContext context,
    AdminProfileController controller,
    bool isDark, {
    required double size,
  }) {
    return Obx(() {
      final previewPath = controller.previewImagePath.value;
      final currentUrl = controller.currentProfilePicUrl;
      final hasPreview = previewPath.isNotEmpty;
      final innerSize = size - 6;

      return GestureDetector(
        onTap: () => controller.hasImage
            ? _showImageOptionsSheet(context, controller, isDark)
            : controller.pickAndCropImage(),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppThemeData.primary50,
                  AppThemeData.primary4,
                  AppThemeData.primary50.withValues(alpha: 0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppThemeData.primary50.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(3),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? AppThemeData.grey10 : AppThemeData.grey1,
              ),
              child: ClipOval(
                child: hasPreview
                    ? (kIsWeb
                        ? Image.network(previewPath, fit: BoxFit.cover, width: innerSize, height: innerSize)
                        : Image.file(File(previewPath), fit: BoxFit.cover, width: innerSize, height: innerSize))
                    : (currentUrl != null && currentUrl.isNotEmpty)
                        ? NetworkImageWidget(
                            imageUrl: currentUrl,
                            height: innerSize,
                            width: innerSize,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
                            child: Icon(
                              Icons.person_rounded,
                              size: size * 0.38,
                              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                            ),
                          ),
              ),
            ),
          ),
        ),
      );
    });
  }

  // ─── Image Options Bottom Sheet ──────────────────────────────
  void _showImageOptionsSheet(
      BuildContext context, AdminProfileController controller, bool isDark) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.only(top: 12, bottom: 24),
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.grey10 : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppThemeData.grey6 : AppThemeData.grey4,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            spaceH(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextCustom(
                title: 'Profile Photo',
                fontSize: 16,
                fontFamily: FontFamily.bold,
                color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              ),
            ),
            spaceH(height: 8),
            _buildSheetOption(
              context: context,
              icon: Icons.fullscreen_rounded,
              iconColor: AppThemeData.primary50,
              title: 'View Full Image',
              isDark: isDark,
              onTap: () {
                Get.back();
                controller.viewFullScreenImage(context);
              },
            ),
            _buildSheetOption(
              context: context,
              icon: Icons.delete_outline_rounded,
              iconColor: AppThemeData.danger300,
              title: 'Delete Photo',
              isDark: isDark,
              onTap: () {
                Get.back();
                controller.removeProfileImage();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetOption({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              spaceW(width: 14),
              TextCustom(
                title: title,
                fontSize: 14,
                fontFamily: FontFamily.medium,
                color: isDark ? AppThemeData.grey2 : AppThemeData.grey9,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Change Photo Button ─────────────────────────────────────
  Widget _buildChangePhotoButton(
    AdminProfileController controller,
    bool isDark, {
    required bool fullWidth,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: controller.pickAndCropImage,
        child: Container(
          width: fullWidth ? double.infinity : null,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isDark
                ? AppThemeData.primaryBlack
                : AppThemeData.primaryWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppThemeData.grey7 : AppThemeData.grey4,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.cloud_upload_rounded,
                size: 24,
                color: isDark ? AppThemeData.textNeonPurple : AppThemeData.primary50,
              ),
              spaceH(height: 6),
              TextCustom(
                title: controller.hasImage ? 'Change Photo' : 'Click to change photo',
                fontSize: 13,
                fontFamily: FontFamily.semiBold,
                color: isDark ? AppThemeData.textNeonPurple : AppThemeData.primary50,
              ),
              spaceH(height: 2),
              TextCustom(
                title: 'JPG, PNG or WEBP. Max size 5MB',
                fontSize: 10,
                fontFamily: FontFamily.regular,
                color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Remove Button ───────────────────────────────────────────
  Widget _buildRemoveButton(AdminProfileController controller, bool isDark) {
    final hasPreview = controller.previewImagePath.value.isNotEmpty;
    if (!hasPreview) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: controller.clearSelectedImage,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: AppThemeData.danger300.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppThemeData.danger300.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.close_rounded, size: 15, color: AppThemeData.danger300),
                spaceW(width: 6),
                const TextCustom(
                  title: 'Remove Selected',
                  fontSize: 12,
                  fontFamily: FontFamily.medium,
                  color: AppThemeData.danger300,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Form Card ───────────────────────────────────────────────
  Widget _buildFormCard(AdminProfileController controller, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: _cardDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppThemeData.primary50.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  Icons.edit_note_rounded,
                  size: 18,
                  color: isDark ? AppThemeData.textNeonPurple : AppThemeData.primary50,
                ),
              ),
              spaceW(width: 10),
              TextCustom(
                title: 'Personal Information',
                fontSize: 16,
                fontFamily: FontFamily.semiBold,
                color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              ),
            ],
          ),
          spaceH(height: 6),
          TextCustom(
            title: 'Fields marked with * are required',
            fontSize: 12,
            fontFamily: FontFamily.regular,
            color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
          ),
          spaceH(height: 24),
          _buildTextField(
            controller: controller.fullNameController,
            hint: 'Full Name *',
            icon: Icons.person_outline_rounded,
            isDark: isDark,
          ),
          spaceH(height: 20),
          _buildFieldLabel(
            'Email Address',
            isDark,
            trailing: _buildDisabledBadge(isDark),
          ),
          spaceH(height: 8),
          _buildTextField(
            controller: controller.emailController,
            hint: 'Email cannot be changed',
            icon: Icons.email_outlined,
            isDark: isDark,
            keyboardType: TextInputType.emailAddress,
            enabled: false,
            suffixIcon: Icon(
              Icons.lock_outline_rounded,
              size: 18,
              color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
            ),
          ),
          spaceH(height: 20),
          _buildTextField(
            controller: controller.phoneController,
            hint: 'Phone Number',
            icon: Icons.phone_outlined,
            isDark: isDark,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  // ─── Disabled Badge ──────────────────────────────────────────
  Widget _buildDisabledBadge(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDark
            ? AppThemeData.neonPurpleDim.withValues(alpha: 0.6)
            : AppThemeData.primary1,
        borderRadius: BorderRadius.circular(6),
      ),
      child: TextCustom(
        title: 'Read Only',
        fontSize: 10,
        fontFamily: FontFamily.medium,
        color: isDark ? AppThemeData.textNeonPurple : AppThemeData.primary50,
      ),
    );
  }

  // ─── Field Label ─────────────────────────────────────────────
  Widget _buildFieldLabel(String label, bool isDark, {Widget? trailing}) {
    return Row(
      children: [
        TextCustom(
          title: label,
          fontSize: 12,
          fontFamily: FontFamily.medium,
          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
        ),
        if (trailing != null) ...[spaceW(width: 8), trailing],
      ],
    );
  }

  // ─── Text Field ──────────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    bool enabled = true,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFieldWidget(
      hintText: hint,
      controller: controller,
      onPress: () {},
      textInputType: keyboardType,
      enabled: enabled,
      inputFormatters: inputFormatters,
      prefix: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppThemeData.primary50.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: enabled
              ? (isDark ? AppThemeData.grey5 : AppThemeData.grey6)
              : (isDark ? AppThemeData.grey7 : AppThemeData.grey4),
          size: 19,
        ),
      ),
      suffix: suffixIcon,
      fillColor: enabled
          ? (isDark ? AppThemeData.grey9 : AppThemeData.grey2)
          : (isDark
              ? AppThemeData.grey9.withValues(alpha: 0.5)
              : AppThemeData.grey2.withValues(alpha: 0.6)),
    );
  }

  // ─── Save Button ─────────────────────────────────────────────
  Widget _buildSaveButton(AdminProfileController controller, bool isDark) {
    return Obx(() => MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: controller.isLoading ? () {} : controller.saveProfileChanges,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            gradient: controller.isLoading
                ? LinearGradient(
                    colors: [
                      AppThemeData.primary50.withValues(alpha: 0.5),
                      AppThemeData.primary4.withValues(alpha: 0.5),
                    ],
                  )
                : const LinearGradient(
                    colors: [
                      Color(0xFF7C3AED),
                      Color(0xFF9333EA),
                      Color(0xFFA855F7),
                      Color(0xFFC084FC),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppThemeData.primary50.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: controller.isLoading
                ? const MahekLoader(size: 22, showBranding: false)
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_rounded, color: Colors.white, size: 20),
                      spaceW(width: 8),
                      const TextCustom(
                        title: 'Save Changes',
                        fontSize: 16,
                        fontFamily: FontFamily.semiBold,
                        color: Colors.white,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    ));
  }

  // ─── Security Footer ─────────────────────────────────────────
  Widget _buildSecurityFooter(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.shield_rounded,
          size: 16,
          color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
        ),
        spaceW(width: 8),
        TextCustom(
          title: 'Your information is encrypted and secure',
          fontSize: 12,
          fontFamily: FontFamily.regular,
          color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
        ),
      ],
    );
  }

  // ─── Loading Overlay ─────────────────────────────────────────
  Widget _buildLoadingOverlay(AdminProfileController controller) {
    if (!controller.isUploadingImage.value && !controller.isSaving.value) {
      return const SizedBox.shrink();
    }
    final message = controller.isUploadingImage.value
        ? MahekConstant.loaderMsgUploadingImage
        : MahekConstant.loaderMsgSavingProfile;
    return Container(
      color: Colors.black.withValues(alpha: 0.45),
      child: MahekLoader(
        message: message,
        showBackgroundOverlay: false,
        size: 200,
      ),
    );
  }

  // ─── Shared Card Decoration ──────────────────────────────────
  BoxDecoration _cardDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(
        color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
        width: 0.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
