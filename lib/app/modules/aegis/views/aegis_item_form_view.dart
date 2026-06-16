import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/widgets/mahek_loader.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/network_image_widget.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'package:maheksync/app/widgets/text_field_widget.dart';
import 'package:maheksync/app/constant/round_shape_button.dart';
import '../controllers/aegis_controller.dart';

class AegisItemFormView extends GetView<AegisController> {
  const AegisItemFormView({super.key});

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => TextCustom(
              title: controller.isEditMode.value ? 'Edit Vault Item' : 'Add Vault Item',
              fontSize: 18,
              fontFamily: FontFamily.bold,
              color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
            )),
            const SizedBox(height: 2),
            TextCustom(
              title: 'Store your credentials and important information securely.',
              fontSize: 11,
              fontFamily: FontFamily.regular,
              color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
            ),
          ],
        ),
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
          _buildSectionHeader(SolarIconsOutline.infoCircle, 'Basic Information', 'Add the main details of your item.', isDark),
          spaceH(height: 14),
          _buildTwoColumnRow(
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
          ),
          spaceH(height: 20),
          _buildIconUpload(isDark),
          spaceH(height: 24),

          _buildSectionHeader(SolarIconsOutline.tag, 'Category', 'Select the type of item you\'re storing.', isDark),
          spaceH(height: 12),
          _buildCategorySelector(isDark),
          spaceH(height: 24),

          _buildSectionHeader(SolarIconsOutline.key, 'Credentials', 'Add login credentials and related information.', isDark),
          spaceH(height: 14),
          _buildTwoColumnRow(
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
          ),
          spaceH(height: 14),
          Obx(() => _buildTwoColumnRow(
            TextFieldWidget(
              title: 'Password',
              hintText: 'Enter password',
              controller: controller.formPasswordController,
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
            ),
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
          )),
          spaceH(height: 24),

          _buildSectionHeader(SolarIconsOutline.notes, 'Notes', 'Add any additional notes about this item.', isDark),
          spaceH(height: 12),
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
          spaceH(height: 24),

          _buildSectionHeader(SolarIconsOutline.tag, 'Tags', 'Organize your item with tags.', isDark),
          spaceH(height: 12),
          _buildTagsInput(isDark),
          spaceH(height: 32),

          _buildSaveButton(isDark),
          spaceH(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, String subtitle, bool isDark) {
    return Row(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(color: AppThemeData.primary50.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppThemeData.primary50, size: 18),
        ),
        spaceW(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextCustom(title: title, fontSize: 15, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey2 : AppThemeData.grey9),
              const SizedBox(height: 2),
              TextCustom(title: subtitle, fontSize: 11, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey6 : AppThemeData.grey5),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTwoColumnRow(Widget left, Widget right) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        spaceW(width: 14),
        Expanded(child: right),
      ],
    );
  }

  Widget _buildIconUpload(bool isDark) {
    return Row(
      children: [
        Obx(() {
          final hasIcon = controller.iconBytes.value != null || controller.selectedIcon.value != null;
          final existingUrl = controller.editingItem.value?.iconUrl;

          return GestureDetector(
            onTap: controller.pickIcon,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isDark ? AppThemeData.grey9 : AppThemeData.grey2,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: hasIcon ? AppThemeData.primary50 : (isDark ? AppThemeData.grey7 : AppThemeData.grey4),
                    width: hasIcon ? 1.5 : 1,
                  ),
                ),
                child: hasIcon
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: controller.iconBytes.value != null
                            ? Image.memory(controller.iconBytes.value!, fit: BoxFit.cover)
                            : (kIsWeb
                                ? Image.network(controller.selectedIcon.value!.path, fit: BoxFit.cover)
                                : Image.file(File(controller.selectedIcon.value!.path), fit: BoxFit.cover)),
                      )
                    : (existingUrl != null && existingUrl.isNotEmpty)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: NetworkImageWidget(imageUrl: existingUrl, fit: BoxFit.cover),
                          )
                        : Icon(
                            SolarIconsOutline.galleryAdd,
                            color: isDark ? AppThemeData.grey5 : AppThemeData.grey5,
                            size: 24,
                          ),
              ),
            ),
          );
        }),
        spaceW(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextCustom(
                title: 'Item Icon',
                fontSize: 13,
                fontFamily: FontFamily.semiBold,
                color: isDark ? AppThemeData.grey2 : AppThemeData.grey9,
              ),
              spaceH(height: 2),
              TextCustom(
                title: 'Upload a custom icon for this vault item',
                fontSize: 11,
                fontFamily: FontFamily.regular,
                color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
              ),
              spaceH(height: 6),
              Row(
                children: [
                  GestureDetector(
                    onTap: controller.pickIcon,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppThemeData.primary50.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppThemeData.primary50.withValues(alpha: 0.2)),
                      ),
                      child: Obx(() => TextCustom(
                        title: (controller.iconBytes.value != null || controller.selectedIcon.value != null)
                            ? 'Change Icon' : 'Upload',
                        fontSize: 11,
                        fontFamily: FontFamily.medium,
                        color: AppThemeData.primary50,
                      )),
                    ),
                  ),
                  Obx(() {
                    final hasIcon = controller.iconBytes.value != null || controller.selectedIcon.value != null;
                    if (!hasIcon) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: GestureDetector(
                        onTap: controller.removeIcon,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppThemeData.danger300.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppThemeData.danger300.withValues(alpha: 0.2)),
                          ),
                          child: const TextCustom(
                            title: 'Remove',
                            fontSize: 11,
                            fontFamily: FontFamily.medium,
                            color: AppThemeData.danger300,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
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

    final categoryLabels = {
      'PASSWORD': 'Password',
      'API_KEY': 'API Key',
      'WIFI': 'WiFi',
      'BANK': 'Bank',
      'EMAIL': 'Email',
      'SUBSCRIPTION': 'Subscription',
      'LICENSE': 'License',
      'NOTE': 'Note',
      'VEHICLE': 'Vehicle',
      'SERVER': 'Server',
      'DEVICE': 'Device',
    };

    final filteredCategories = controller.categories.where((c) => c != 'ALL').toList();

    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filteredCategories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final cat = filteredCategories[index];
          return Obx(() {
            final isSelected = controller.formCategory.value == cat;
            return GestureDetector(
              onTap: () => controller.formCategory.value = cat,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 76,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppThemeData.primary50.withValues(alpha: 0.12)
                      : (isDark ? AppThemeData.grey9 : AppThemeData.grey1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? AppThemeData.primary50 : (isDark ? AppThemeData.grey8 : AppThemeData.grey3),
                    width: isSelected ? 1.5 : 0.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppThemeData.primary50.withValues(alpha: 0.2)
                            : (isDark ? AppThemeData.grey8 : AppThemeData.grey2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        categoryIcons[cat] ?? SolarIconsOutline.lockKeyhole,
                        size: 20,
                        color: isSelected ? AppThemeData.primary50 : (isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextCustom(
                      title: categoryLabels[cat] ?? cat,
                      fontSize: 10,
                      fontFamily: isSelected ? FontFamily.semiBold : FontFamily.medium,
                      color: isSelected ? AppThemeData.primary50 : (isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                      maxLine: 1,
                    ),
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
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
                child: const Icon(SolarIconsOutline.addCircle, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextCustom(
          title: 'Press Enter to add multiple tags.',
          fontSize: 11,
          fontFamily: FontFamily.regular,
          color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
        ),
        spaceH(height: 8),
        Obx(() => Wrap(
          spacing: 6,
          runSpacing: 6,
          children: controller.formTags.map((tag) => Container(
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

  Widget _buildSaveButton(bool isDark) {
    return Obx(() => RoundShapeButton(
      width: double.infinity,
      height: 52,
      title: controller.isLoading.value ? '' : 'Save Vault Item',
      buttonColor: AppThemeData.primary50,
      buttonTextColor: Colors.white,
      borderColor: Colors.transparent,
      borderRadius: 14,
      onTap: controller.isLoading.value ? () {} : controller.saveItem,
      titleWidget: controller.isLoading.value
          ? const MahekLoader(size: 22, showBranding: false)
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(SolarIconsBold.lockKeyhole, color: Colors.white, size: 18),
                SizedBox(width: 10),
                TextCustom(title: 'Save Vault Item', fontSize: 15, fontFamily: FontFamily.semiBold, color: Colors.white),
              ],
            ),
    ));
  }
}
