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
            width: 400,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
              border: Border(
                right: BorderSide(
                  color: isDark ? AppThemeData.grey9 : AppThemeData.grey3,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isDark),
                spaceH(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildForm(isDark),
                        spaceH(height: 24),
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
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildListHeader(isDark),
                  spaceH(height: 16),
                  _buildSearchBar(isDark),
                  spaceH(height: 20),
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
    return Obx(() => Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppThemeData.primary50.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.category_rounded,
            color: AppThemeData.primary50,
            size: 22,
          ),
        ),
        spaceW(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextCustom(
              title: controller.editingCategory.value == null
                  ? 'Add Category'
                  : 'Edit Category',
              fontSize: 18,
              fontFamily: FontFamily.bold,
              color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
            ),
            TextCustom(
              title: controller.editingCategory.value == null
                  ? 'Create a new category'
                  : 'Update existing category',
              fontSize: 13,
              fontFamily: FontFamily.regular,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            ),
          ],
        ),
      ],
    ));
  }

  Widget _buildForm(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Name
        TextCustom(
          title: 'CATEGORY NAME',
          fontSize: 11,
          fontFamily: FontFamily.medium,
          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
        ),
        spaceH(height: 8),
        TextField(
          controller: controller.nameController,
          style: TextStyle(
            fontFamily: FontFamily.regular,
            fontSize: 14,
            color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
          ),
          decoration: InputDecoration(
            hintText: 'e.g. Electronics, Furniture',
            hintStyle: TextStyle(
              fontFamily: FontFamily.regular,
              fontSize: 14,
              color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
            ),
            filled: true,
            fillColor: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
                width: 0.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF5D54F2),
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
          ),
        ),
        spaceH(height: 20),

        // Description
        TextCustom(
          title: 'DESCRIPTION',
          fontSize: 11,
          fontFamily: FontFamily.medium,
          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
        ),
        spaceH(height: 8),
        TextField(
          controller: controller.descriptionController,
          maxLines: 3,
          style: TextStyle(
            fontFamily: FontFamily.regular,
            fontSize: 14,
            color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
          ),
          decoration: InputDecoration(
            hintText: 'Briefly describe this category...',
            hintStyle: TextStyle(
              fontFamily: FontFamily.regular,
              fontSize: 14,
              color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
            ),
            filled: true,
            fillColor: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
                width: 0.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF5D54F2),
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
        spaceH(height: 20),

        // Icon Upload
        TextCustom(
          title: 'CATEGORY ICON',
          fontSize: 11,
          fontFamily: FontFamily.medium,
          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
        ),
        spaceH(height: 8),
        _buildIconUploader(isDark),
      ],
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
        height: 100,
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppThemeData.grey7 : AppThemeData.grey4,
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 32,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            ),
            spaceH(height: 8),
            TextCustom(
              title: 'Click to upload icon',
              fontSize: 12,
              fontFamily: FontFamily.medium,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            ),
            TextCustom(
              title: 'PNG, JPG (max 512x512)',
              fontSize: 10,
              fontFamily: FontFamily.regular,
              color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconPreview(bool isDark, {dynamic memoryImage, String? networkUrl}) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppThemeData.grey7 : AppThemeData.grey4,
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isDark ? AppThemeData.grey8 : AppThemeData.grey2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: memoryImage != null
                    ? Image.memory(
                  memoryImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.broken_image_outlined,
                      color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
                      size: 32,
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
                  size: 32,
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              children: [
                GestureDetector(
                  onTap: controller.pickIcon,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppThemeData.primary50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
                spaceW(width: 4),
                GestureDetector(
                  onTap: controller.removeIcon,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppThemeData.danger300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 14,
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

      return Row(
        children: [
          if (isEditing)
            Expanded(
              child: OutlinedButton(
                onPressed: controller.cancelEditing,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(
                    color: isDark ? AppThemeData.grey7 : AppThemeData.grey4,
                  ),
                ),
                child: TextCustom(
                  title: 'Cancel',
                  fontSize: 14,
                  fontFamily: FontFamily.medium,
                  color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
                ),
              ),
            ),
          if (isEditing) spaceW(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: controller.isSaving.value ? null : controller.saveCategory,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemeData.primary50,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: controller.isSaving.value
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : TextCustom(
                title: isEditing ? 'Update Category' : 'Create Category',
                fontSize: 14,
                fontFamily: FontFamily.semiBold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildListHeader(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextCustom(
              title: 'Categories',
              fontSize: 20,
              fontFamily: FontFamily.bold,
              color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
            ),
            spaceH(height: 4),
            Obx(() => TextCustom(
              title: '${controller.filteredCategories.length} categories',
              fontSize: 14,
              fontFamily: FontFamily.regular,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            )),
          ],
        ),
        // Grid/List View Toggle
        Obx(() => Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
                borderRadius: BorderRadius.circular(10),
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
            ),
          ],
        )),
      ],
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
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppThemeData.primary50
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected
              ? Colors.white
              : (isDark ? AppThemeData.grey5 : AppThemeData.grey6),
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return TextField(
      onChanged: controller.updateSearchQuery,
      decoration: InputDecoration(
        hintText: 'Search categories...',
        hintStyle: TextStyle(
          fontFamily: FontFamily.regular,
          fontSize: 14,
          color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
          size: 20,
        ),
        filled: true,
        fillColor: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
            width: 0.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF5D54F2),
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 64,
            color: isDark ? AppThemeData.grey7 : AppThemeData.grey4,
          ),
          spaceH(height: 16),
          TextCustom(
            title: 'No categories yet',
            fontSize: 16,
            fontFamily: FontFamily.medium,
            color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
          ),
          spaceH(height: 8),
          TextCustom(
            title: 'Add your first category using the form',
            fontSize: 14,
            fontFamily: FontFamily.regular,
            color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(bool isDark) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 280,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.0,
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
        color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Area
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppThemeData.primary50.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: category.iconUrl != null && category.iconUrl!.isNotEmpty
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: NetworkImageWidget(
                  imageUrl: category.iconUrl!,
                  fit: BoxFit.cover,
                ),
              )
                  : Icon(
                Icons.category_rounded,
                color: AppThemeData.primary50,
                size: 48,
              ),
            ),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextCustom(
                        title: category.name ?? 'Unknown',
                        fontSize: 16,
                        fontFamily: FontFamily.bold,
                        color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                        maxLine: 1,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppThemeData.primary50.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: TextCustom(
                        title: '${category.itemCount ?? 0}',
                        fontSize: 11,
                        fontFamily: FontFamily.bold,
                        color: AppThemeData.primary50,
                      ),
                    ),
                  ],
                ),
                spaceH(height: 4),
                TextCustom(
                  title: category.shortDescription,
                  fontSize: 12,
                  fontFamily: FontFamily.regular,
                  color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                  maxLine: 2,
                ),
                spaceH(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () => controller.startEditing(category),
                      icon: Icon(
                        Icons.edit_outlined,
                        color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
                        size: 18,
                      ),
                    ),
                    IconButton(
                      onPressed: () => controller.deleteCategory(category),
                      icon: Icon(
                        Icons.delete_outline,
                        color: AppThemeData.danger300,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(bool isDark) {
    return ListView.separated(
      itemCount: controller.filteredCategories.length,
      separatorBuilder: (_, __) => spaceH(height: 12),
      itemBuilder: (context, index) {
        final category = controller.filteredCategories[index];
        return _buildCategoryListCard(category, isDark);
      },
    );
  }

  Widget _buildCategoryListCard(CategoryModel category, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppThemeData.primary50.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: category.iconUrl != null && category.iconUrl!.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: NetworkImageWidget(
                imageUrl: category.iconUrl!,
                fit: BoxFit.cover,
              ),
            )
                : Icon(
              Icons.category_rounded,
              color: AppThemeData.primary50,
              size: 28,
            ),
          ),
          spaceW(width: 16),
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
                        fontSize: 16,
                        fontFamily: FontFamily.semiBold,
                        color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppThemeData.primary50.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: TextCustom(
                        title: '${category.itemCount ?? 0} items',
                        fontSize: 11,
                        fontFamily: FontFamily.bold,
                        color: AppThemeData.primary50,
                      ),
                    ),
                  ],
                ),
                spaceH(height: 4),
                TextCustom(
                  title: category.shortDescription,
                  fontSize: 13,
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
              IconButton(
                onPressed: () => controller.startEditing(category),
                icon: Icon(
                  Icons.edit_outlined,
                  color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
                  size: 20,
                ),
              ),
              IconButton(
                onPressed: () => controller.deleteCategory(category),
                icon: Icon(
                  Icons.delete_outline,
                  color: AppThemeData.danger300,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}