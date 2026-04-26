// lib/app/modules/categories/views/categories_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/dark_theme_provider.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/utils/mahek_responsive.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/mahek_loader.dart';
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
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: MahekLoader(showBackgroundOverlay: true, message: 'Loading Categories...')
          );
        }
        return MahekResponsive.isMobile(context) || MahekResponsive.isTablet(context)
            ? _buildMobileLayout(isDark, context)
            : _buildDesktopLayout(isDark, context);
      }),
    );
  }

  // ═══════════════════════════════════════
  // DESKTOP LAYOUT
  // ═══════════════════════════════════════
  Widget _buildDesktopLayout(bool isDark, BuildContext context) {
    final panelWidth = MahekResponsive.filterPanelWidth(context);
    return Row(
      children: [
        // Left Panel - Add/Edit Form
        Container(
          width: panelWidth,
          padding: MahekResponsive.responsivePadding(context),
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
              _buildHeader(isDark, context),
              spaceH(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildForm(isDark, context),
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
            padding: MahekResponsive.responsivePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildListHeader(isDark, context),
                spaceH(height: 16),
                _buildSearchBar(isDark, context),
                spaceH(height: 20),
                Expanded(child: _buildCategoriesContent(isDark, context)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════
  // MOBILE/TABLET LAYOUT
  // ═══════════════════════════════════════
  Widget _buildMobileLayout(bool isDark, BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(MahekResponsive.responsivePadding(context).left),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isDark, context),
          spaceH(height: 16),
          _buildForm(isDark, context),
          spaceH(height: 16),
          _buildActionButtons(isDark),
          spaceH(height: 20),
          _buildListHeader(isDark, context),
          spaceH(height: 12),
          _buildSearchBar(isDark, context),
          spaceH(height: 16),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: _buildCategoriesContent(isDark, context),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════
  Widget _buildHeader(bool isDark, BuildContext context) {
    final iconSize = MahekResponsive.isMobile(context) ? 44.0 : 56.0;
    final titleSize = MahekResponsive.responsiveFontSize(context, mobile: 16, tablet: 18, laptop: 20, desktop: 20);
    final subSize = MahekResponsive.responsiveFontSize(context, mobile: 11, tablet: 12, laptop: 13, desktop: 13);

    return Obx(() => Container(
      padding: EdgeInsets.all(MahekResponsive.isMobile(context) ? 14 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppThemeData.primary50.withValues(alpha: isDark ? 0.15 : 0.08),
            AppThemeData.primary4.withValues(alpha: isDark ? 0.08 : 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppThemeData.primary50.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppThemeData.primary50, AppThemeData.primary4]),
              borderRadius: BorderRadius.circular(iconSize * 0.32),
              boxShadow: [BoxShadow(color: AppThemeData.primary50.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Icon(
              controller.editingCategory.value == null ? Icons.add_rounded : Icons.edit_rounded,
              color: Colors.white,
              size: iconSize * 0.5,
            ),
          ),
          spaceW(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(
                  title: controller.editingCategory.value == null ? 'Add New Category' : 'Edit Category',
                  fontSize: titleSize,
                  fontFamily: FontFamily.bold,
                  color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                ),
                spaceH(height: 2),
                TextCustom(
                  title: controller.editingCategory.value == null ? 'Create and organize your inventory' : 'Update category information',
                  fontSize: subSize,
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

  // ═══════════════════════════════════════
  // FORM
  // ═══════════════════════════════════════
  Widget _buildForm(bool isDark, BuildContext context) {
    final inputFontSize = MahekResponsive.responsiveFontSize(context, mobile: 13, tablet: 14, laptop: 15, desktop: 15);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.primaryBlack.withValues(alpha: 0.5) : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppThemeData.grey8.withValues(alpha: 0.3) : AppThemeData.grey3.withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.03), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormLabel('CATEGORY NAME', Icons.category_rounded, isDark),
          spaceH(height: 8),
          _buildTextField(controller: controller.nameController, hintText: 'e.g. Electronics, Furniture', icon: Icons.category_rounded, isDark: isDark, fontSize: inputFontSize),
          spaceH(height: 20),
          _buildFormLabel('DESCRIPTION', Icons.description_outlined, isDark),
          spaceH(height: 8),
          _buildTextField(controller: controller.descriptionController, hintText: 'Briefly describe this category...', icon: Icons.description_outlined, isDark: isDark, maxLines: 3, fontSize: inputFontSize),
          spaceH(height: 20),
          _buildFormLabel('CATEGORY ICON', Icons.image_outlined, isDark),
          spaceH(height: 8),
          _buildIconUploader(isDark),
        ],
      ),
    );
  }

  Widget _buildFormLabel(String text, IconData icon, bool isDark) {
    return Row(
      children: [
        Container(
          width: 24, height: 24,
          decoration: BoxDecoration(color: AppThemeData.primary50.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: AppThemeData.primary50, size: 14),
        ),
        spaceW(width: 10),
        TextCustom(title: text, fontSize: 12, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey4 : AppThemeData.grey7),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required bool isDark,
    int maxLines = 1,
    double fontSize = 15,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.02), blurRadius: 8, offset: const Offset(0, 2))],
        border: Border.all(color: isDark ? AppThemeData.grey8.withValues(alpha: 0.5) : AppThemeData.grey3.withValues(alpha: 0.5)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(fontFamily: FontFamily.medium, fontSize: fontSize, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(fontFamily: FontFamily.regular, fontSize: fontSize, color: isDark ? AppThemeData.grey6 : AppThemeData.grey5),
          prefixIcon: Container(margin: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppThemeData.primary50.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: AppThemeData.primary50, size: 20)),
          filled: true, fillColor: Colors.transparent,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppThemeData.primary50, width: 2)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      } else if (editingCategory != null && editingCategory.iconUrl != null && editingCategory.iconUrl!.isNotEmpty) {
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
        height: 140,
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppThemeData.primary50.withValues(alpha: 0.3), width: 1.5, style: BorderStyle.solid),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.02), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(gradient: LinearGradient(colors: [AppThemeData.primary50.withValues(alpha: 0.15), AppThemeData.primary4.withValues(alpha: 0.1)]), borderRadius: BorderRadius.circular(16)),
              child: Icon(Icons.cloud_upload_outlined, size: 28, color: AppThemeData.primary50),
            ),
            spaceH(height: 12),
            TextCustom(title: 'Click to upload icon', fontSize: 14, fontFamily: FontFamily.semiBold, color: AppThemeData.primary50),
            spaceH(height: 4),
            TextCustom(title: 'PNG, JPG (Recommended)', fontSize: 11, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
          ],
        ),
      ),
    );
  }

  Widget _buildIconPreview(bool isDark, {dynamic memoryImage, String? networkUrl}) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppThemeData.primary50.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.02), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 140, height: 140,
              decoration: BoxDecoration(gradient: LinearGradient(colors: [AppThemeData.primary50.withValues(alpha: 0.15), AppThemeData.primary4.withValues(alpha: 0.05)]), borderRadius: BorderRadius.circular(16)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: memoryImage != null
                    ? Image.memory(memoryImage, fit: BoxFit.contain, errorBuilder: (_, __, ___) => Icon(Icons.broken_image_outlined, color: isDark ? AppThemeData.grey6 : AppThemeData.grey5, size: 40))
                    : networkUrl != null && networkUrl.isNotEmpty
                    ? NetworkImageWidget(imageUrl: networkUrl, fit: BoxFit.cover)
                    : Icon(Icons.category_rounded, color: AppThemeData.primary50, size: 40),
              ),
            ),
          ),
          Positioned(
            top: 8, right: 8,
            child: Row(
              children: [
                GestureDetector(onTap: controller.pickIcon, child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(gradient: LinearGradient(colors: [AppThemeData.primary50, AppThemeData.primary4]), borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: AppThemeData.primary50.withValues(alpha: 0.4), blurRadius: 8)]), child: const Icon(Icons.edit_outlined, color: Colors.white, size: 16))),
                spaceW(width: 6),
                GestureDetector(onTap: controller.removeIcon, child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(gradient: LinearGradient(colors: [AppThemeData.danger300, AppThemeData.danger400]), borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: AppThemeData.danger300.withValues(alpha: 0.4), blurRadius: 8)]), child: const Icon(Icons.close, color: Colors.white, size: 16))),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.primaryBlack.withValues(alpha: 0.5) : AppThemeData.primaryWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? AppThemeData.grey8.withValues(alpha: 0.3) : AppThemeData.grey3.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isSaving.value ? null : controller.saveCategory,
                style: ElevatedButton.styleFrom(backgroundColor: AppThemeData.primary50, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 3, shadowColor: AppThemeData.primary50.withValues(alpha: 0.5)),
                child: controller.isSaving.value
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(isEditing ? Icons.save_rounded : Icons.add_rounded, color: Colors.white, size: 20), spaceW(width: 8), TextCustom(title: isEditing ? 'Update Category' : 'Create Category', fontSize: 15, fontFamily: FontFamily.bold, color: Colors.white)]),
              ),
            ),
            if (isEditing) ...[
              spaceH(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: controller.cancelEditing,
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), side: BorderSide(color: isDark ? AppThemeData.grey7 : AppThemeData.grey4, width: 1.5)),
                  child: TextCustom(title: 'Cancel', fontSize: 14, fontFamily: FontFamily.semiBold, color: isDark ? AppThemeData.grey4 : AppThemeData.grey7),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  // ═══════════════════════════════════════
  // LIST HEADER
  // ═══════════════════════════════════════
  Widget _buildListHeader(bool isDark, BuildContext context) {
    final titleSize = MahekResponsive.responsiveFontSize(context, mobile: 18, tablet: 20, laptop: 22, desktop: 22);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite, isDark ? AppThemeData.grey9.withValues(alpha: 0.5) : AppThemeData.grey1]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppThemeData.grey8.withValues(alpha: 0.3) : AppThemeData.grey3.withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.03), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 44, height: 44, decoration: BoxDecoration(gradient: LinearGradient(colors: [AppThemeData.primary50.withValues(alpha: 0.15), AppThemeData.primary4.withValues(alpha: 0.1)]), borderRadius: BorderRadius.circular(14)), child: Icon(Icons.category_rounded, color: AppThemeData.primary50, size: 24)),
              spaceW(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextCustom(title: 'Categories', fontSize: titleSize, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
                  spaceH(height: 2),
                  Obx(() => TextCustom(title: '${controller.filteredCategories.length} categories', fontSize: 12, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey4 : AppThemeData.grey6)),
                ],
              ),
            ],
          ),
          Obx(() => Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: isDark ? AppThemeData.grey9 : AppThemeData.grey1, borderRadius: BorderRadius.circular(14), border: Border.all(color: isDark ? AppThemeData.grey8 : AppThemeData.grey3)),
            child: Row(
              children: [
                _buildViewToggle(icon: Icons.grid_view_rounded, isSelected: controller.isGridView.value, onTap: () => controller.isGridView.value = true, isDark: isDark),
                _buildViewToggle(icon: Icons.list_rounded, isSelected: !controller.isGridView.value, onTap: () => controller.isGridView.value = false, isDark: isDark),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildViewToggle({required IconData icon, required bool isSelected, required VoidCallback onTap, required bool isDark}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: isSelected ? LinearGradient(colors: [AppThemeData.primary50, AppThemeData.primary4]) : null,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected ? [BoxShadow(color: AppThemeData.primary50.withValues(alpha: 0.3), blurRadius: 8)] : null,
        ),
        child: Icon(icon, size: 20, color: isSelected ? Colors.white : (isDark ? AppThemeData.grey5 : AppThemeData.grey6)),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark, BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.03), blurRadius: 12, offset: const Offset(0, 4))]),
      child: TextField(
        onChanged: controller.updateSearchQuery,
        style: TextStyle(fontFamily: FontFamily.medium, fontSize: 14, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
        decoration: InputDecoration(
          hintText: 'Search categories...',
          hintStyle: TextStyle(fontFamily: FontFamily.regular, fontSize: 14, color: isDark ? AppThemeData.grey6 : AppThemeData.grey5),
          prefixIcon: Container(margin: const EdgeInsets.all(8), decoration: BoxDecoration(gradient: LinearGradient(colors: [AppThemeData.primary50.withValues(alpha: 0.15), AppThemeData.primary4.withValues(alpha: 0.1)]), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.search_rounded, color: AppThemeData.primary50, size: 20)),
          filled: true, fillColor: Colors.transparent,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppThemeData.primary50, width: 2)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildCategoriesContent(bool isDark, BuildContext context) {
    return Obx(() {
      if (controller.filteredCategories.isEmpty) return _buildEmptyState(isDark, context);
      return controller.isGridView.value ? _buildGridView(isDark, context) : _buildListView(isDark, context);
    });
  }

  Widget _buildEmptyState(bool isDark, BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: isDark ? AppThemeData.primaryBlack.withValues(alpha: 0.5) : AppThemeData.primaryWhite, borderRadius: BorderRadius.circular(28), border: Border.all(color: isDark ? AppThemeData.grey8.withValues(alpha: 0.3) : AppThemeData.grey3.withValues(alpha: 0.3))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 90, height: 90, decoration: BoxDecoration(gradient: LinearGradient(colors: [AppThemeData.primary50.withValues(alpha: 0.15), AppThemeData.primary4.withValues(alpha: 0.08)]), borderRadius: BorderRadius.circular(26)), child: Icon(Icons.category_outlined, size: 48, color: AppThemeData.primary50.withValues(alpha: 0.6))),
            spaceH(height: 20),
            TextCustom(title: 'No categories yet', fontSize: 18, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey3 : AppThemeData.grey8),
            spaceH(height: 8),
            TextCustom(title: 'Add your first category using the form', fontSize: 14, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView(bool isDark, BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: MahekResponsive.maxCrossAxisExtent(context),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: MahekResponsive.cardAspectRatio(context),
      ),
      itemCount: controller.filteredCategories.length,
      itemBuilder: (context, index) => _buildCategoryGridCard(controller.filteredCategories[index], isDark, context),
    );
  }

  Widget _buildListView(bool isDark, BuildContext context) {
    return ListView.separated(
      itemCount: controller.filteredCategories.length,
      separatorBuilder: (_, __) => spaceH(height: 12),
      itemBuilder: (context, index) => _buildCategoryListCard(controller.filteredCategories[index], isDark, context),
    );
  }

  Widget _buildCategoryGridCard(CategoryModel category, bool isDark, BuildContext context) {
    final nameSize = MahekResponsive.responsiveFontSize(context, mobile: 14, tablet: 15, laptop: 16, desktop: 18);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite, isDark ? AppThemeData.grey9.withValues(alpha: 0.5) : AppThemeData.grey1]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppThemeData.grey8.withValues(alpha: 0.3) : AppThemeData.grey3.withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: InkWell(
        onTap: () => controller.startEditing(category),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(gradient: LinearGradient(colors: [AppThemeData.primary50.withValues(alpha: 0.12), AppThemeData.primary4.withValues(alpha: 0.06)]), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppThemeData.primary50.withValues(alpha: 0.15))),
                child: category.iconUrl != null && category.iconUrl!.isNotEmpty
                    ? ClipRRect(borderRadius: BorderRadius.circular(16), child: NetworkImageWidget(imageUrl: category.iconUrl!, fit: BoxFit.contain))
                    : Icon(Icons.category_rounded, color: AppThemeData.primary50, size: 48),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: TextCustom(title: category.name ?? 'Unknown', fontSize: nameSize, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10, maxLine: 1)),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(gradient: LinearGradient(colors: [AppThemeData.primary50.withValues(alpha: 0.15), AppThemeData.primary4.withValues(alpha: 0.1)]), borderRadius: BorderRadius.circular(16)), child: TextCustom(title: '${category.itemCount ?? 0}', fontSize: 11, fontFamily: FontFamily.bold, color: AppThemeData.primary50)),
                      ],
                    ),
                    spaceH(height: 4),
                    TextCustom(title: category.shortDescription, fontSize: 12, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6, maxLine: 2),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildActionChip(Icons.edit_outlined, isDark ? AppThemeData.grey4 : AppThemeData.grey7, () => controller.startEditing(category), isDark),
                        spaceW(width: 6),
                        _buildActionChip(Icons.delete_outline, AppThemeData.danger300, () => controller.deleteCategory(category), isDark, isDanger: true),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryListCard(CategoryModel category, bool isDark, BuildContext context) {
    final nameSize = MahekResponsive.responsiveFontSize(context, mobile: 14, tablet: 16, laptop: 17, desktop: 17);
    return InkWell(
      onTap: () => controller.startEditing(category),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite, isDark ? AppThemeData.grey9.withValues(alpha: 0.5) : AppThemeData.grey1]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? AppThemeData.grey8.withValues(alpha: 0.3) : AppThemeData.grey3.withValues(alpha: 0.3)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(gradient: LinearGradient(colors: [AppThemeData.primary50.withValues(alpha: 0.15), AppThemeData.primary4.withValues(alpha: 0.08)]), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppThemeData.primary50.withValues(alpha: 0.15))),
              child: category.iconUrl != null && category.iconUrl!.isNotEmpty
                  ? ClipRRect(borderRadius: BorderRadius.circular(16), child: NetworkImageWidget(imageUrl: category.iconUrl!, fit: BoxFit.cover))
                  : Icon(Icons.category_rounded, color: AppThemeData.primary50, size: 30),
            ),
            spaceW(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: TextCustom(title: category.name ?? 'Unknown', fontSize: nameSize, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10)),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(gradient: LinearGradient(colors: [AppThemeData.primary50.withValues(alpha: 0.15), AppThemeData.primary4.withValues(alpha: 0.1)]), borderRadius: BorderRadius.circular(16)), child: TextCustom(title: '${category.itemCount ?? 0} items', fontSize: 11, fontFamily: FontFamily.bold, color: AppThemeData.primary50)),
                    ],
                  ),
                  spaceH(height: 4),
                  TextCustom(title: category.shortDescription, fontSize: 13, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6, maxLine: 2),
                ],
              ),
            ),
            Row(
              children: [
                _buildActionChip(Icons.edit_outlined, isDark ? AppThemeData.grey4 : AppThemeData.grey7, () => controller.startEditing(category), isDark),
                spaceW(width: 6),
                _buildActionChip(Icons.delete_outline, AppThemeData.danger300, () => controller.deleteCategory(category), isDark, isDanger: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChip(IconData icon, Color color, VoidCallback onTap, bool isDark, {bool isDanger = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: isDanger ? LinearGradient(colors: [AppThemeData.danger50.withValues(alpha: isDark ? 0.15 : 0.8), AppThemeData.danger100.withValues(alpha: isDark ? 0.1 : 0.5)]) : null,
          color: isDanger ? null : (isDark ? AppThemeData.grey9 : AppThemeData.grey1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}