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
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 920 : double.infinity,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveWidget.isMobile(context) ? 16 : 32,
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
                ],
              ),
            ),
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
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: AppThemeData.neonPurpleBlueGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppThemeData.neonGlow(
              AppThemeData.neonPurple,
              blur: 12,
              opacity: 0.15,
            ),
          ),
          child: const Icon(
            Icons.person_rounded,
            color: Colors.white,
            size: 22,
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
              spaceH(height: 2),
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
          Expanded(flex: 5, child: _buildAvatarCard(context, controller, isDark)),
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
        _buildAvatarSection(context, controller, isDark),
        spaceH(height: 24),
        _buildFormCard(controller, isDark),
      ],
    );
  }

  Widget _buildAvatarCard(
      BuildContext context, AdminProfileController controller, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      decoration: BoxDecoration(
        color: isDark
            ? AppThemeData.surfaceElevated.withValues(alpha: 0.6)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppThemeData.surfaceBorder.withValues(alpha: 0.4)
              : AppThemeData.grey3,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildAvatarCircle(context, controller, isDark, size: 140),
          spaceH(height: 20),
          ListenableBuilder(
            listenable: controller.fullNameController,
            builder: (_, __) => TextCustom(
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
            builder: (_, __) => TextCustom(
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

  Widget _buildAvatarSection(
      BuildContext context, AdminProfileController controller, bool isDark) {
    return Center(
      child: Column(
        children: [
          _buildAvatarCircle(context, controller, isDark, size: 120),
          spaceH(height: 14),
          _buildChangePhotoButton(controller, isDark, fullWidth: false),
          Obx(() => _buildRemoveButton(controller, isDark)),
        ],
      ),
    );
  }

  void _showImageOptionsSheet(
      BuildContext context, AdminProfileController controller, bool isDark) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.only(top: 12, bottom: 24),
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.grey10 : Colors.white,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppThemeData.grey7 : AppThemeData.grey3,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.image_outlined,
                  color: isDark
                      ? AppThemeData.textNeonPurple
                      : AppThemeData.primary50),
              title: Text('View Image',
                  style: TextStyle(
                      color: isDark
                          ? AppThemeData.grey1
                          : AppThemeData.grey10)),
              onTap: () {
                Get.back();
                controller.viewFullScreenImage(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline,
                  color: AppThemeData.danger300),
              title: const Text('Delete Photo',
                  style: TextStyle(color: AppThemeData.danger300)),
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
              gradient: AppThemeData.geminiGradient,
              boxShadow: AppThemeData.neonGlow(
                AppThemeData.neonPurple,
                blur: 24,
                opacity: 0.2,
              ),
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
                        ? Image.network(
                            previewPath,
                            fit: BoxFit.cover,
                            width: innerSize,
                            height: innerSize,
                          )
                        : Image.file(
                            File(previewPath),
                            fit: BoxFit.cover,
                            width: innerSize,
                            height: innerSize,
                          ))
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
                          size: size * 0.4,
                          color: isDark
                              ? AppThemeData.grey5
                              : AppThemeData.grey6,
                        ),
                      ),
              ),
            ),
          ),
        ),
      );
    });
  }

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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
          decoration: BoxDecoration(
            color: AppThemeData.neonPurple.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppThemeData.neonPurple.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt_rounded,
                size: 17,
                color: isDark
                    ? AppThemeData.textNeonPurple
                    : AppThemeData.primary50,
              ),
              spaceW(width: 8),
              Obx(() => TextCustom(
                    title: controller.hasImage ? 'Change Photo' : 'Add Photo',
                    fontSize: 13,
                    fontFamily: FontFamily.semiBold,
                    color: isDark
                        ? AppThemeData.textNeonPurple
                        : AppThemeData.primary50,
                  )),
            ],
          ),
        ),
      ),
    );
  }

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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
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
                Icon(
                  Icons.close_rounded,
                  size: 15,
                  color: AppThemeData.danger300,
                ),
                spaceW(width: 6),
                TextCustom(
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

  Widget _buildFormCard(AdminProfileController controller, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark
            ? AppThemeData.surfaceElevated.withValues(alpha: 0.6)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppThemeData.surfaceBorder.withValues(alpha: 0.4)
              : AppThemeData.grey3,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.edit_note_rounded,
                size: 20,
                color: isDark
                    ? AppThemeData.textNeonPurple
                    : AppThemeData.primary50,
              ),
              spaceW(width: 8),
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
          spaceH(height: 22),
          _buildFieldLabel('Full Name *', isDark),
          spaceH(height: 8),
          _buildTextField(
            controller: controller.fullNameController,
            hint: 'Enter your full name',
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
          _buildFieldLabel('Phone Number', isDark),
          spaceH(height: 8),
          _buildTextField(
            controller: controller.phoneController,
            hint: 'Enter your phone number',
            icon: Icons.phone_outlined,
            isDark: isDark,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

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
    final fillColor = enabled
        ? (isDark ? AppThemeData.grey9 : AppThemeData.grey2)
        : (isDark
              ? AppThemeData.grey9.withValues(alpha: 0.5)
              : AppThemeData.grey2.withValues(alpha: 0.6));

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      enabled: enabled,
      style: TextStyle(
        fontFamily: FontFamily.regular,
        fontSize: 14,
        color: enabled
            ? (isDark ? AppThemeData.grey1 : AppThemeData.grey10)
            : (isDark ? AppThemeData.grey5 : AppThemeData.grey6),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: FontFamily.regular,
          fontSize: 14,
          color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
        ),
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark
                ? AppThemeData.surfaceBorder.withValues(alpha: 0.3)
                : AppThemeData.grey3,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppThemeData.primary50, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        prefixIcon: Icon(
          icon,
          color: enabled
              ? (isDark ? AppThemeData.grey5 : AppThemeData.grey6)
              : (isDark ? AppThemeData.grey7 : AppThemeData.grey4),
          size: 19,
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget _buildSaveButton(AdminProfileController controller, bool isDark) {
    return Obx(
      () => Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: AppThemeData.neonPurpleBlueGradient,
          boxShadow: AppThemeData.neonGlow(
            AppThemeData.neonPurple,
            blur: 20,
            opacity: 0.25,
          ),
        ),
        child: ElevatedButton(
          onPressed: controller.isLoading
              ? null
              : controller.saveProfileChanges,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: controller.isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextCustom(
                      title: 'Save Changes',
                      fontSize: 15,
                      fontFamily: FontFamily.semiBold,
                      color: Colors.white,
                    ),
                    spaceW(width: 8),
                    const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 19,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

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
        style: MahekLoaderStyle.aurora,
        showBackgroundOverlay: false,
        size: 56,
      ),
    );
  }
}
