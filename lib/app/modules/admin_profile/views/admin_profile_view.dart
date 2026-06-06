import 'dart:io';
import 'package:flutter/material.dart';
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

    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveWidget.isMobile(context) ? 16 : 32,
            vertical: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextCustom(
                title: 'Edit Profile',
                fontSize: 28,
                fontFamily: FontFamily.bold,
                color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              ),
              spaceH(height: 6),
              TextCustom(
                title: 'Update your personal information and profile photo',
                fontSize: 14,
                fontFamily: FontFamily.regular,
                color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
              ),
              spaceH(height: 28),
              _buildAvatarSection(controller, isDark),
              spaceH(height: 32),
              _buildFormSection(controller, isDark),
              spaceH(height: 32),
              _buildSaveButton(controller, isDark),
            ],
          ),
        ),
        Obx(() => _buildLoadingOverlay(controller)),
      ],
    );
  }

  Widget _buildAvatarSection(AdminProfileController controller, bool isDark) {
    return Center(
      child: Obx(() {
        final previewPath = controller.previewImagePath.value;
        final currentUrl = controller.currentProfilePicUrl;
        final hasPreview = previewPath.isNotEmpty;

        return Column(
          children: [
            GestureDetector(
              onTap: controller.pickProfileImage,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppThemeData.geminiGradient,
                  boxShadow: AppThemeData.neonGlow(
                    AppThemeData.neonPurple,
                    blur: 24,
                    opacity: 0.25,
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
                        ? Image.file(
                      File(previewPath),
                      fit: BoxFit.cover,
                      width: 114,
                      height: 114,
                    )
                        : (currentUrl != null && currentUrl.isNotEmpty)
                        ? NetworkImageWidget(
                      imageUrl: currentUrl,
                      height: 114,
                      width: 114,
                      fit: BoxFit.cover,
                    )
                        : Container(
                      color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
                      child: Icon(
                        Icons.person_rounded,
                        size: 50,
                        color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            spaceH(height: 14),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: controller.pickProfileImage,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppThemeData.neonPurple.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppThemeData.neonPurple.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.camera_alt_rounded,
                        size: 18,
                        color: isDark ? AppThemeData.textNeonPurple : AppThemeData.primary50,
                      ),
                      spaceW(width: 8),
                      TextCustom(
                        title: 'Change Photo',
                        fontSize: 13,
                        fontFamily: FontFamily.semiBold,
                        color: isDark ? AppThemeData.textNeonPurple : AppThemeData.primary50,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (hasPreview) ...[
              spaceH(height: 10),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: controller.clearSelectedImage,
                  child: TextCustom(
                    title: 'Remove selected',
                    fontSize: 12,
                    fontFamily: FontFamily.medium,
                    color: AppThemeData.danger300,
                  ),
                ),
              ),
            ],
          ],
        );
      }),
    );
  }

  Widget _buildFormSection(AdminProfileController controller, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.surfaceElevated.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppThemeData.surfaceBorder.withValues(alpha: 0.4) : AppThemeData.grey3,
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
          _buildFieldLabel('FULL NAME', isDark),
          spaceH(height: 8),
          _buildTextField(
            controller: controller.fullNameController,
            hint: 'Enter your full name',
            icon: Icons.person_outline_rounded,
            isDark: isDark,
          ),
          spaceH(height: 20),
          _buildFieldLabel('EMAIL', isDark),
          spaceH(height: 8),
          _buildTextField(
            controller: controller.emailController,
            hint: 'Enter your email',
            icon: Icons.email_outlined,
            isDark: isDark,
            keyboardType: TextInputType.emailAddress,
          ),
          spaceH(height: 20),
          _buildFieldLabel('PHONE NUMBER', isDark),
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

  Widget _buildFieldLabel(String label, bool isDark) {
    return TextCustom(
      title: label,
      fontSize: 12,
      fontFamily: FontFamily.medium,
      color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        fontFamily: FontFamily.regular,
        fontSize: 15,
        color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
      ),
      decoration: InputDecoration(
        hintText: hint,
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
          borderSide: BorderSide(
            color: AppThemeData.primary50,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        prefixIcon: Icon(
          icon,
          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildSaveButton(AdminProfileController controller, bool isDark) {
    return Obx(() => Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: AppThemeData.neonPurpleBlueGradient,
        boxShadow: AppThemeData.neonGlow(
          AppThemeData.neonPurple,
          blur: 20,
          opacity: 0.3,
        ),
      ),
      child: ElevatedButton(
        onPressed: controller.isLoading ? null : controller.saveProfileChanges,
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
              title: 'Save Changes',
              fontSize: 16,
              fontFamily: FontFamily.semiBold,
              color: Colors.white,
            ),
            spaceW(width: 8),
            const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    ));
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
        style: MahekLoaderStyle.arc,
        showBackgroundOverlay: false,
        size: 56,
      ),
    );
  }
}