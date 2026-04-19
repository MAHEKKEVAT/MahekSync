// lib/app/modules/categories/views/categories_view.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/dark_theme_provider.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/network_image_widget.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import '../../../models/category_model.dart';
import '../controllers/categories_controller.dart';

class CategoriesView extends GetView<CategoriesController> {
  const CategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDark = themeChange.isDarkTheme();

    return Scaffold(
      backgroundColor: isDark ? AppThemeData.grey10 : AppThemeData.grey2,
      body: Row(
        children: [
          // Left Panel - Add/Edit Form
          Container(
            width: 420,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
                  isDark ? AppThemeData.grey9.withValues(alpha: 0.5) : AppThemeData.grey1,
                ],
              ),
              border: Border(
                right: BorderSide(
                  color: isDark ? AppThemeData.grey8.withValues(alpha: 0.3) : AppThemeData.grey3.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isDark),
                spaceH(height: 28),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildForm(isDark),
                        spaceH(height: 28),
                        _buildActionButtons(isDark),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Right Panel - Categories List
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    isDark ? AppThemeData.grey10 : AppThemeData.grey2,
                    isDark ? AppThemeData.grey9.withValues(alpha: 0.3) : AppThemeData.grey1.withValues(alpha: 0.5),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildListHeader(isDark),
                  spaceH(height: 20),
                  _buildSearchBar(isDark),
                  spaceH(height: 24),
                  Expanded(
                    child: _buildCategoriesContent(isDark),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Obx(() => Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppThemeData.primary50.withValues(alpha: isDark ? 0.15 : 0.08),
            AppThemeData.primary4.withValues(alpha: isDark ? 0.08 : 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppThemeData.primary50.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppThemeData.primary50,
                  AppThemeData.primary4,
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppThemeData.primary50.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              controller.editingCategory.value == null
                  ? Icons.add_rounded
                  : Icons.edit_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          spaceW(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(
                  title: controller.editingCategory.value == null
                      ? 'Add New Category'
                      : 'Edit Category',
                  fontSize: 20,
                  fontFamily: FontFamily.bold,
                  color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                ),
                spaceH(height: 4),
                TextCustom(
                  title: controller.editingCategory.value == null
                      ? 'Create and organize your inventory'
                      : 'Update category information',
                  fontSize: 13,
                  fontFamily: FontFamily.regular,
                  color: isDark ? AppThemeData.grey4 : AppThemeData.grey6,
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildForm(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.primaryBlack.withValues(alpha: 0.5) : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppThemeData.grey8.withValues(alpha: 0.3) : AppThemeData.grey3.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Name
          _buildFormLabel('CATEGORY NAME', Icons.category_rounded, isDark),
          spaceH(height: 10),
          _buildTextField(
            controller: controller.nameController,
            hintText: 'e.g. Electronics, Furniture',
            icon: Icons.category_rounded,
            isDark: isDark,
          ),
          spaceH(height: 24),

          // Description
          _buildFormLabel('DESCRIPTION', Icons.description_outlined, isDark),
          spaceH(height: 10),
          _buildTextField(
            controller: controller.descriptionController,
            hintText: 'Briefly describe this category...',
            icon: Icons.description_outlined,
            isDark: isDark,
            maxLines: 3,
          ),
          spaceH(height: 24),

          // Icon Upload
          _buildFormLabel('CATEGORY ICON', Icons.image_outlined, isDark),
          spaceH(height: 10),
          _buildIconUploader(isDark),
        ],
      ),
    );
  }

  Widget _buildFormLabel(String text, IconData icon, bool isDark) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppThemeData.primary50.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppThemeData.primary50,
            size: 14,
          ),
        ),
        spaceW(width: 10),
        TextCustom(
          title: text,
          fontSize: 12,
          fontFamily: FontFamily.bold,
          color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required bool isDark,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isDark ? AppThemeData.grey8.withValues(alpha: 0.5) : AppThemeData.grey3.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(
          fontFamily: FontFamily.medium,
          fontSize: 15,
          color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontFamily: FontFamily.regular,
            fontSize: 14,
            color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppThemeData.primary50.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppThemeData.primary50,
              size: 20,
            ),
          ),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: AppThemeData.primary50,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildIconUploader(bool isDark) {
    return Obx(() {
      final editingCategory = controller.editingCategory.value;
      final selectedIcon = controller.selectedIcon.value;
      final iconBytes = controller.iconBytes.value;

      if (selectedIcon != null && iconBytes != null) {
        return _buildIconPreview(isDark, memoryImage: iconBytes);
      } else if (editingCategory != null &&
          editingCategory.iconUrl != null &&
          editingCategory.iconUrl!.isNotEmpty) {
        return _buildIconPreview(isDark, networkUrl: editingCategory.iconUrl);
      } else {
        return _buildUploadButton(isDark);
      }
    });
  }

  Widget _buildUploadButton(bool isDark) {
    return GestureDetector(
      onTap: controller.pickIcon,
      child: Container(
        width: 320,
        height: 180,
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppThemeData.primary50.withValues(alpha: 0.3),
            width: 1.5,
            style: BorderStyle.solid,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.02),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppThemeData.primary50.withValues(alpha: 0.15),
                    AppThemeData.primary4.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.cloud_upload_outlined,
                size: 28,
                color: AppThemeData.primary50,
              ),
            ),
            spaceH(height: 12),
            TextCustom(
              title: 'Click to upload icon',
              fontSize: 14,
              fontFamily: FontFamily.semiBold,
              color: AppThemeData.primary50,
            ),
            spaceH(height: 4),
            TextCustom(
              title: 'PNG, JPG (Recommended)',
              fontSize: 11,
              fontFamily: FontFamily.regular,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconPreview(bool isDark, {dynamic memoryImage, String? networkUrl}) {
    return Container(
      height: 250,
      width: 330,
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppThemeData.primary50.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppThemeData.primary50.withValues(alpha: 0.15),
                    AppThemeData.primary4.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: memoryImage != null
                    ? Image.memory(
                  memoryImage,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.broken_image_outlined,
                      color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
                      size: 40,
                    );
                  },
                )
                    : networkUrl != null && networkUrl.isNotEmpty
                    ? NetworkImageWidget(
                  imageUrl: networkUrl,
                  fit: BoxFit.cover,
                )
                    : Icon(
                  Icons.category_rounded,
                  color: AppThemeData.primary50,
                  size: 40,
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Row(
              children: [
                GestureDetector(
                  onTap: controller.pickIcon,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppThemeData.primary50,
                          AppThemeData.primary4,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppThemeData.primary50.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
                spaceW(width: 6),
                GestureDetector(
                  onTap: controller.removeIcon,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppThemeData.danger300,
                          AppThemeData.danger400,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppThemeData.danger300.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Obx(() {
      final isEditing = controller.editingCategory.value != null;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.primaryBlack.withValues(alpha: 0.5) : AppThemeData.primaryWhite,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? AppThemeData.grey8.withValues(alpha: 0.3) : AppThemeData.grey3.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Primary Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isSaving.value ? null : controller.saveCategory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppThemeData.primary50,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  shadowColor: AppThemeData.primary50.withValues(alpha: 0.5),
                ),
                child: controller.isSaving.value
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isEditing ? Icons.save_rounded : Icons.add_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    spaceW(width: 8),
                    TextCustom(
                      title: isEditing ? 'Update Category' : 'Create Category',
                      fontSize: 16,
                      fontFamily: FontFamily.bold,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),

            // Cancel Button (only when editing)
            if (isEditing) ...[
              spaceH(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: controller.cancelEditing,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: BorderSide(
                      color: isDark ? AppThemeData.grey7 : AppThemeData.grey4,
                      width: 1.5,
                    ),
                  ),
                  child: TextCustom(
                    title: 'Cancel',
                    fontSize: 15,
                    fontFamily: FontFamily.semiBold,
                    color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildListHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
            isDark ? AppThemeData.grey9.withValues(alpha: 0.5) : AppThemeData.grey1,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppThemeData.grey8.withValues(alpha: 0.3) : AppThemeData.grey3.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppThemeData.primary50.withValues(alpha: 0.15),
                      AppThemeData.primary4.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.category_rounded,
                  color: AppThemeData.primary50,
                  size: 26,
                ),
              ),
              spaceW(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextCustom(
                    title: 'Categories',
                    fontSize: 22,
                    fontFamily: FontFamily.bold,
                    color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                  ),
                  spaceH(height: 2),
                  Obx(() => TextCustom(
                    title: '${controller.filteredCategories.length} categories',
                    fontSize: 13,
                    fontFamily: FontFamily.regular,
                    color: isDark ? AppThemeData.grey4 : AppThemeData.grey6,
                  )),
                ],
              ),
            ],
          ),
          // Grid/List View Toggle
          Obx(() => Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                _buildViewToggle(
                  icon: Icons.grid_view_rounded,
                  isSelected: controller.isGridView.value,
                  onTap: () => controller.isGridView.value = true,
                  isDark: isDark,
                ),
                _buildViewToggle(
                  icon: Icons.list_rounded,
                  isSelected: !controller.isGridView.value,
                  onTap: () => controller.isGridView.value = false,
                  isDark: isDark,
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildViewToggle({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppThemeData.primary50,
              AppThemeData.primary4,
            ],
          )
              : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: AppThemeData.primary50.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: Icon(
          icon,
          size: 22,
          color: isSelected
              ? Colors.white
              : (isDark ? AppThemeData.grey5 : AppThemeData.grey6),
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: controller.updateSearchQuery,
        style: TextStyle(
          fontFamily: FontFamily.medium,
          fontSize: 15,
          color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
        ),
        decoration: InputDecoration(
          hintText: 'Search categories...',
          hintStyle: TextStyle(
            fontFamily: FontFamily.regular,
            fontSize: 15,
            color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppThemeData.primary50.withValues(alpha: 0.15),
                  AppThemeData.primary4.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.search_rounded,
              color: AppThemeData.primary50,
              size: 22,
            ),
          ),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: AppThemeData.primary50,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesContent(bool isDark) {
    return Obx(() {
      if (controller.filteredCategories.isEmpty) {
        return _buildEmptyState(isDark);
      }

      if (controller.isGridView.value) {
        return _buildGridView(isDark);
      } else {
        return _buildListView(isDark);
      }
    });
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.primaryBlack.withValues(alpha: 0.5) : AppThemeData.primaryWhite,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: isDark ? AppThemeData.grey8.withValues(alpha: 0.3) : AppThemeData.grey3.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppThemeData.primary50.withValues(alpha: 0.15),
                    AppThemeData.primary4.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                Icons.category_outlined,
                size: 56,
                color: AppThemeData.primary50.withValues(alpha: 0.6),
              ),
            ),
            spaceH(height: 24),
            TextCustom(
              title: 'No categories yet',
              fontSize: 20,
              fontFamily: FontFamily.bold,
              color: isDark ? AppThemeData.grey3 : AppThemeData.grey8,
            ),
            spaceH(height: 8),
            TextCustom(
              title: 'Add your first category using the form',
              fontSize: 15,
              fontFamily: FontFamily.regular,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView(bool isDark) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 0.70, // Taller cards
      ),
      itemCount: controller.filteredCategories.length,
      itemBuilder: (context, index) {
        final category = controller.filteredCategories[index];
        return _buildCategoryGridCard(category, isDark);
      },
    );
  }

  Widget _buildCategoryGridCard(CategoryModel category, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
            isDark ? AppThemeData.grey9.withValues(alpha: 0.5) : AppThemeData.grey1,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppThemeData.grey8.withValues(alpha: 0.3) : AppThemeData.grey3.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Area - Larger
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppThemeData.primary50.withValues(alpha: 0.12),
                    AppThemeData.primary4.withValues(alpha: 0.06),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppThemeData.primary50.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: category.iconUrl != null && category.iconUrl!.isNotEmpty
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: NetworkImageWidget(
                  imageUrl: category.iconUrl!,
                  fit: BoxFit.contain,
                ),
              )
                  : Icon(
                Icons.category_rounded,
                color: AppThemeData.primary50,
                size: 56,
              ),
            ),
          ),
          // Info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextCustom(
                          title: category.name ?? 'Unknown',
                          fontSize: 18,
                          fontFamily: FontFamily.bold,
                          color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                          maxLine: 1,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppThemeData.primary50.withValues(alpha: 0.15),
                              AppThemeData.primary4.withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextCustom(
                          title: '${category.itemCount ?? 0}',
                          fontSize: 12,
                          fontFamily: FontFamily.bold,
                          color: AppThemeData.primary50,
                        ),
                      ),
                    ],
                  ),
                  spaceH(height: 6),
                  TextCustom(
                    title: category.shortDescription,
                    fontSize: 13,
                    fontFamily: FontFamily.regular,
                    color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                    maxLine: 2,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () => controller.startEditing(category),
                          icon: Icon(
                            Icons.edit_outlined,
                            color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
                            size: 20,
                          ),
                        ),
                      ),
                      spaceW(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppThemeData.danger50.withValues(alpha: isDark ? 0.15 : 0.8),
                              AppThemeData.danger100.withValues(alpha: isDark ? 0.1 : 0.5),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () => controller.deleteCategory(category),
                          icon: Icon(
                            Icons.delete_outline,
                            color: AppThemeData.danger300,
                            size: 20,
                          ),
                        ),
                      ),
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

  Widget _buildListView(bool isDark) {
    return ListView.separated(
      itemCount: controller.filteredCategories.length,
      separatorBuilder: (_, __) => spaceH(height: 16),
      itemBuilder: (context, index) {
        final category = controller.filteredCategories[index];
        return _buildCategoryListCard(category, isDark);
      },
    );
  }

  Widget _buildCategoryListCard(CategoryModel category, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
            isDark ? AppThemeData.grey9.withValues(alpha: 0.5) : AppThemeData.grey1,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppThemeData.grey8.withValues(alpha: 0.3) : AppThemeData.grey3.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppThemeData.primary50.withValues(alpha: 0.15),
                  AppThemeData.primary4.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppThemeData.primary50.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: category.iconUrl != null && category.iconUrl!.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: NetworkImageWidget(
                imageUrl: category.iconUrl!,
                fit: BoxFit.cover,
              ),
            )
                : Icon(
              Icons.category_rounded,
              color: AppThemeData.primary50,
              size: 36,
            ),
          ),
          spaceW(width: 20),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextCustom(
                        title: category.name ?? 'Unknown',
                        fontSize: 17,
                        fontFamily: FontFamily.bold,
                        color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppThemeData.primary50.withValues(alpha: 0.15),
                            AppThemeData.primary4.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextCustom(
                        title: '${category.itemCount ?? 0} items',
                        fontSize: 12,
                        fontFamily: FontFamily.bold,
                        color: AppThemeData.primary50,
                      ),
                    ),
                  ],
                ),
                spaceH(height: 6),
                TextCustom(
                  title: category.shortDescription,
                  fontSize: 14,
                  fontFamily: FontFamily.regular,
                  color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                  maxLine: 2,
                ),
              ],
            ),
          ),
          // Actions
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: IconButton(
                  onPressed: () => controller.startEditing(category),
                  icon: Icon(
                    Icons.edit_outlined,
                    color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
                    size: 22,
                  ),
                ),
              ),
              spaceW(width: 8),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppThemeData.danger50.withValues(alpha: isDark ? 0.15 : 0.8),
                      AppThemeData.danger100.withValues(alpha: isDark ? 0.1 : 0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: IconButton(
                  onPressed: () => controller.deleteCategory(category),
                  icon: Icon(
                    Icons.delete_outline,
                    color: AppThemeData.danger300,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}