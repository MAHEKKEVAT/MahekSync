import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:maheksync/app/widgets/mahek_loader.dart';
import 'package:get/get.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'package:maheksync/app/widgets/network_image_widget.dart';
import 'package:maheksync/app/widgets/text_field_widget.dart';
import '../controllers/vault_crud_controller.dart';

class VaultCrudView extends GetView<VaultCrudController> {
  const VaultCrudView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppThemeData.grey10 : AppThemeData.grey2,
      appBar: AppBar(
        backgroundColor: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(SolarIconsOutline.altArrowLeft, color: isDark ? AppThemeData.grey4 : AppThemeData.grey7, size: 20),
        ),
        title: Obx(() => TextCustom(
          title: controller.isEditMode.value ? 'Edit Item' : 'Add Item',
          fontSize: 18,
          fontFamily: FontFamily.bold,
          color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
        )),
        actions: [
          Obx(() => TextButton(
            onPressed: controller.isLoading.value ? null : controller.saveItem,
            child: controller.isLoading.value
                ?  const MahekLoader(size: 20, showBranding: false)
                :  TextCustom(title: 'Save', fontSize: 14, fontFamily: FontFamily.semiBold, color: AppThemeData.primary50),
          )),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _buildForm(isDark),
      ),
    );
  }

  Widget _buildForm(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon/Image uploader at the top
          _buildSectionTitle('Item Icon', SolarIconsOutline.gallery, isDark),
          spaceH(height: 10),
          _buildIconUploader(isDark),
          spaceH(height: 20),

          _buildSectionTitle('Basic Information', SolarIconsOutline.infoCircle, isDark),
          spaceH(height: 12),
          TextFieldWidget(
            title: 'Title',
            hintText: 'e.g. Gmail Account',
            controller: controller.titleController,
            onPress: () {},
            prefix: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppThemeData.primary50.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(SolarIconsOutline.lockKeyhole, color: AppThemeData.primary50, size: 18),
            ),
          ),
          spaceH(height: 14),
          TextFieldWidget(
            title: 'Website / URL',
            hintText: 'https://...',
            controller: controller.websiteController,
            onPress: () {},
            prefix: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppThemeData.primary50.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(SolarIconsOutline.link, color: AppThemeData.primary50, size: 18),
            ),
          ),
          spaceH(height: 20),
          _buildSectionTitle('Category', SolarIconsOutline.tag, isDark),
          spaceH(height: 10),
          _buildCategorySelector(isDark),
          spaceH(height: 20),
          _buildSectionTitle('Credentials', SolarIconsOutline.key, isDark),
          spaceH(height: 12),
          TextFieldWidget(
            title: 'Email',
            hintText: 'user@email.com',
            controller: controller.emailController,
            onPress: () {},
            prefix: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppThemeData.primary50.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(SolarIconsOutline.letter, color: AppThemeData.primary50, size: 18),
            ),
          ),
          spaceH(height: 14),
          TextFieldWidget(
            title: 'Username',
            hintText: 'Username',
            controller: controller.usernameController,
            onPress: () {},
            prefix: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppThemeData.primary50.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(SolarIconsOutline.user, color: AppThemeData.primary50, size: 18),
            ),
          ),
          spaceH(height: 14),
          Obx(() => TextFieldWidget(
            title: 'Password',
            hintText: 'Enter password',
            controller: controller.passwordController,
            obscureText: controller.obscurePassword.value,
            onPress: () {},
            prefix: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppThemeData.primary50.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(SolarIconsOutline.lockKeyhole, color: AppThemeData.primary50, size: 18),
            ),
            suffix: GestureDetector(
              onTap: () => controller.obscurePassword.value = !controller.obscurePassword.value,
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppThemeData.primary50.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  controller.obscurePassword.value ? SolarIconsOutline.eyeClosed : SolarIconsOutline.eye,
                  color: AppThemeData.primary50,
                  size: 18,
                ),
              ),
            ),
          )),
          spaceH(height: 14),
          TextFieldWidget(
            title: 'Phone',
            hintText: '+1 234 567 890',
            controller: controller.phoneController,
            onPress: () {},
            prefix: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppThemeData.primary50.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(SolarIconsOutline.phone, color: AppThemeData.primary50, size: 18),
            ),
          ),
          spaceH(height: 20),
          _buildSectionTitle('Notes', SolarIconsOutline.notes, isDark),
          spaceH(height: 10),
          TextFieldWidget(
            title: 'Notes',
            hintText: 'Additional notes...',
            controller: controller.notesController,
            onPress: () {},
            line: 3,
            prefix: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppThemeData.primary50.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(SolarIconsOutline.notes, color: AppThemeData.primary50, size: 18),
            ),
          ),
          spaceH(height: 20),
          _buildSectionTitle('Tags', SolarIconsOutline.tag, isDark),
          spaceH(height: 10),
          _buildTagsInput(isDark),
          spaceH(height: 24),
          _buildSaveButton(isDark),
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
        TextCustom(title: title, fontSize: 14, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey3 : AppThemeData.grey7),
      ],
    );
  }

  Widget _buildCategorySelector(bool isDark) {
    final categoryIcons = {
      'PASSWORD': SolarIconsOutline.lockKeyhole,
      'API_KEY': SolarIconsOutline.key,
      'WIFI': SolarIconsOutline.lock,
      'BANK': SolarIconsOutline.card,
      'EMAIL': SolarIconsOutline.letter,
      'SUBSCRIPTION': SolarIconsOutline.star,
      'LICENSE': SolarIconsOutline.document,
      'NOTE': SolarIconsOutline.notes,
      'VEHICLE': SolarIconsOutline.bus,
      'SERVER': SolarIconsOutline.server,
      'DEVICE': SolarIconsOutline.smartphone,
    };

    return Obx(() => Wrap(
      spacing: 8,
      runSpacing: 8,
      children: controller.categories.map((cat) {
        final isSelected = controller.selectedCategory.value == cat;
        return GestureDetector(
          onTap: () => controller.selectedCategory.value = cat,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppThemeData.primary50.withValues(alpha: 0.15) : (isDark ? AppThemeData.grey9 : AppThemeData.grey1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isSelected ? AppThemeData.primary50 : (isDark ? AppThemeData.grey8 : AppThemeData.grey3), width: isSelected ? 1.5 : 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(categoryIcons[cat] ?? SolarIconsOutline.lockKeyhole, size: 14, color: isSelected ? AppThemeData.primary50 : (isDark ? AppThemeData.grey6 : AppThemeData.grey5)),
                spaceW(width: 6),
                TextCustom(
                  title: cat.replaceAll('_', ' '),
                  fontSize: 11,
                  fontFamily: isSelected ? FontFamily.bold : FontFamily.medium,
                  color: isSelected ? AppThemeData.primary50 : (isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    ));
  }

  Widget _buildTagsInput(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? AppThemeData.grey8 : AppThemeData.grey3, width: 0.5),
                ),
                child: TextField(
                  controller: controller.tagController,
                  style: TextStyle(fontFamily: FontFamily.medium, fontSize: 14, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
                  decoration: InputDecoration(
                    hintText: 'Add tag...',
                    hintStyle: TextStyle(fontFamily: FontFamily.regular, fontSize: 14, color: isDark ? AppThemeData.grey6 : AppThemeData.grey5),
                    prefixIcon: Icon(SolarIconsOutline.tag, color: AppThemeData.primary50, size: 18),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                  onSubmitted: (_) => controller.addTag(),
                ),
              ),
            ),
            spaceW(width: 8),
            GestureDetector(
              onTap: controller.addTag,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppThemeData.primary50, borderRadius: BorderRadius.circular(12)),
                child: Icon(SolarIconsOutline.addCircle, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
        spaceH(height: 8),
        Obx(() => Wrap(
          spacing: 6,
          runSpacing: 6,
          children: controller.tags.map((tag) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: AppThemeData.primary50.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextCustom(title: '#$tag', fontSize: 12, fontFamily: FontFamily.medium, color: AppThemeData.primary50),
                spaceW(width: 4),
                GestureDetector(
                  onTap: () => controller.removeTag(tag),
                  child: Icon(SolarIconsOutline.closeCircle, size: 14, color: AppThemeData.primary50),
                ),
              ],
            ),
          )).toList(),
        )),
      ],
    );
  }

  // ==================== IMAGE UPLOAD SECTION ====================
  Widget _buildIconUploader(bool isDark) {
    return Obx(() {
      if (controller.selectedIcon.value != null && controller.iconBytes.value != null) {
        return _buildIconPreview(isDark, bytes: controller.iconBytes.value);
      } else if (controller.editingItem.value?.iconUrl != null && controller.editingItem.value!.iconUrl!.isNotEmpty) {
        return _buildIconPreview(isDark, networkUrl: controller.editingItem.value!.iconUrl);
      }
      return _buildUploadButton(isDark);
    });
  }

  Widget _buildIconPreview(bool isDark, {Uint8List? bytes, String? networkUrl}) {
    return Container(
      height: 120,
      width: 120,
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppThemeData.primary50.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Stack(
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: bytes != null
                  ? Image.memory(bytes, width: 96, height: 96, fit: BoxFit.cover)
                  : networkUrl != null
                      ? NetworkImageWidget(imageUrl: networkUrl, fit: BoxFit.cover, height: 96, width: 96)
                      : Icon(SolarIconsBold.lockKeyhole, color: AppThemeData.primary50, size: 48),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: controller.pickIcon,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: AppThemeData.primary50, borderRadius: BorderRadius.circular(8)),
                child: Icon(SolarIconsOutline.pen, color: Colors.white, size: 14),
              ),
            ),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                controller.selectedIcon.value = null;
                controller.iconBytes.value = null;
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: AppThemeData.danger300, borderRadius: BorderRadius.circular(8)),
                child: Icon(SolarIconsOutline.closeCircle, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadButton(bool isDark) {
    return GestureDetector(
      onTap: controller.pickIcon,
      child: Container(
        height: 120,
        width: 120,
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppThemeData.primary50.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(SolarIconsOutline.cloudUpload, color: AppThemeData.primary50, size: 32),
            spaceH(height: 6),
            TextCustom(title: 'Upload', fontSize: 11, fontFamily: FontFamily.medium, color: AppThemeData.primary50),
            TextCustom(title: 'Icon', fontSize: 10, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey6 : AppThemeData.grey5),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(bool isDark) {
    return Obx(() => SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.isLoading.value ? null : controller.saveItem,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppThemeData.primary50,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          disabledBackgroundColor: AppThemeData.primary50.withValues(alpha: 0.5),
        ),
        child: controller.isLoading.value
            ? const MahekLoader(size: 22, showBranding: false)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(SolarIconsBold.checkCircle, color: Colors.white, size: 18),
                  spaceW(width: 8),
                  Obx(() => TextCustom(
                    title: controller.isEditMode.value ? 'Update Item' : 'Create Item',
                    fontSize: 15,
                    fontFamily: FontFamily.semiBold,
                    color: Colors.white,
                  )),
                ],
              ),
      ),
    ));
  }
}
