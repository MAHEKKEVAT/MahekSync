// lib/app/modules/add_new_devices/views/add_new_devices_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/dark_theme_provider.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import '../controllers/add_new_devices_controller.dart';

class AddNewDevicesView extends GetView<AddNewDevicesController> {
  const AddNewDevicesView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDark = themeChange.isDarkTheme();

    return Scaffold(
      backgroundColor: isDark ? AppThemeData.grey10 : const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: isDark ? AppThemeData.primaryBlack : Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
            size: 20,
          ),
        ),
        title: TextCustom(
          title: 'Add Purchase Item',
          fontSize: 22,
          fontFamily: FontFamily.bold,
          color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
        ),
        centerTitle: false,
      ),
      body: Row(
        children: [
          // Left Panel - Form Card
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: isDark ? AppThemeData.primaryBlack : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextCustom(
                      title: 'Catalog a new acquisition into the Kinetic repository.',
                      fontSize: 14,
                      fontFamily: FontFamily.regular,
                      color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                    ),
                    spaceH(height: 28),
                    _buildSectionTitle('PRODUCT IDENTITY', isDark),
                    spaceH(height: 16),
                    _buildTextField('ITEM NAME', controller.deviceNameController, 'e.g. Kinetic Sculpture #04', isDark),
                    spaceH(height: 14),
                    Row(
                      children: [
                        Expanded(child: _buildTextField('BRAND NAME', controller.brandNameController, 'The Kinetic Studio', isDark)),
                        spaceW(width: 16),
                        Expanded(child: _buildDropdown('CATEGORY', controller.selectedCategory, controller.categories, isDark)),
                      ],
                    ),
                    spaceH(height: 14),
                    _buildTextField('DESCRIPTION', controller.descriptionController, 'Describe the item\'s movement, material, and aesthetic impact...', isDark, maxLines: 2),
                    spaceH(height: 28),
                    _buildSectionTitle('SPECIFICATIONS & LOGISTICS', isDark),
                    spaceH(height: 16),
                    spaceH(height: 14),
                    Row(
                      children: [
                        Expanded(child: _buildDatePicker(isDark)),
                        spaceW(width: 16),
                        Expanded(child: _buildWarrantyDatePicker(isDark)),
                      ],
                    ),

                    spaceH(height: 14),
                    _buildDatePicker(isDark),
                  ],
                ),
              ),
            ),
          ),
          // Right Panel
          Container(
            width: 340,
            decoration: BoxDecoration(
              color: isDark ? AppThemeData.primaryBlack : Colors.white,
              border: Border(
                left: BorderSide(
                  color: isDark ? AppThemeData.grey9 : AppThemeData.grey2,
                  width: 1,
                ),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroImageCard(isDark),
                  spaceH(height: 24),
                  _buildQuickStats(isDark),
                  spaceH(height: 24),
                  _buildImageUploadSection(isDark),
                  spaceH(height: 24),
                  _buildPrecisionTip(isDark),
                  spaceH(height: 32),
                  _buildActionButtons(isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Add this method:
  Widget _buildWarrantyDatePicker(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(title: 'WARRANTY ENDS', fontSize: 11, fontFamily: FontFamily.medium, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
        spaceH(height: 6),
        Obx(() => GestureDetector(
          onTap: () async {
            final selected = await showDatePicker(
              context: Get.context!,
              initialDate: DateTime.now().add(const Duration(days: 365)),
              firstDate: DateTime.now(),
              lastDate: DateTime(2030),
            );
            if (selected != null) controller.setWarrantyEndDate(selected);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? AppThemeData.grey9 : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? AppThemeData.grey8 : AppThemeData.grey3, width: 0.5),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 18, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                spaceW(width: 12),
                TextCustom(
                  title: controller.warrantyEndDate.value != null
                      ? DateFormat('MM/dd/yyyy').format(controller.warrantyEndDate.value!)
                      : 'dd---yyyy',
                  fontSize: 14,
                  fontFamily: FontFamily.regular,
                  color: controller.warrantyEndDate.value != null
                      ? (isDark ? AppThemeData.grey1 : AppThemeData.grey10)
                      : (isDark ? AppThemeData.grey6 : AppThemeData.grey5),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return TextCustom(
      title: title,
      fontSize: 12,
      fontFamily: FontFamily.semiBold,
      color: isDark ? AppThemeData.grey3 : AppThemeData.grey8,
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint, bool isDark, {int maxLines = 1, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(
          title: label,
          fontSize: 11,
          fontFamily: FontFamily.medium,
          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
        ),
        spaceH(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: TextStyle(
            fontFamily: FontFamily.regular,
            fontSize: 14,
            color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: FontFamily.regular,
              fontSize: 14,
              color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
            ),
            filled: true,
            fillColor: isDark ? AppThemeData.grey9 : const Color(0xFFF1F5F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: isDark ? AppThemeData.grey8 : AppThemeData.grey3, width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF5D54F2), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, RxString selected, List<String> items, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(
          title: label,
          fontSize: 11,
          fontFamily: FontFamily.medium,
          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
        ),
        spaceH(height: 6),
        Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.grey9 : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? AppThemeData.grey8 : AppThemeData.grey3, width: 0.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selected.value,
              isExpanded: true,
              dropdownColor: isDark ? AppThemeData.grey9 : Colors.white,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
              style: TextStyle(fontFamily: FontFamily.regular, fontSize: 14, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
              items: items.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => selected.value = v!,
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildDatePicker(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(title: 'PURCHASE DATE', fontSize: 11, fontFamily: FontFamily.medium, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
        spaceH(height: 6),
        Obx(() => GestureDetector(
          onTap: () async {
            final selected = await showDatePicker(
              context: Get.context!,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2030),
            );
            if (selected != null) controller.setPurchaseDate(selected);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? AppThemeData.grey9 : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? AppThemeData.grey8 : AppThemeData.grey3, width: 0.5),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 18, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                spaceW(width: 12),
                TextCustom(
                  title: controller.purchaseDate.value != null ? DateFormat('MM/dd/yyyy').format(controller.purchaseDate.value!) : 'dd---yyyy',
                  fontSize: 14,
                  fontFamily: FontFamily.regular,
                  color: controller.purchaseDate.value != null ? (isDark ? AppThemeData.grey1 : AppThemeData.grey10) : (isDark ? AppThemeData.grey6 : AppThemeData.grey5),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildHeroImageCard(bool isDark) {
    return GestureDetector(
      onTap: controller.pickImages,
      child: Container(
        height: 180,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF5D54F2).withValues(alpha: isDark ? 0.2 : 0.08),
              const Color(0xFF8B7EFF).withValues(alpha: isDark ? 0.1 : 0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF5D54F2).withValues(alpha: 0.15)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF5D54F2).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.add_photo_alternate_outlined, size: 28, color: Color(0xFF5D54F2)),
            ),
            spaceH(height: 16),
            TextCustom(title: 'Add Visual Reference', fontSize: 16, fontFamily: FontFamily.semiBold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
            spaceH(height: 4),
            TextCustom(title: 'Upload product images', fontSize: 12, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadSection(bool isDark) {
    return Obx(() {
      if (controller.deviceImages.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextCustom(title: 'SELECTED IMAGES', fontSize: 11, fontFamily: FontFamily.semiBold, color: isDark ? AppThemeData.grey4 : AppThemeData.grey6),
              TextButton(
                onPressed: controller.pickImages,
                child: TextCustom(title: 'Add More', fontSize: 12, fontFamily: FontFamily.medium, color: const Color(0xFF5D54F2)),
              ),
            ],
          ),
          spaceH(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(controller.deviceImages.length, (index) {
              return Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: isDark ? AppThemeData.grey7 : AppThemeData.grey3)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(controller.imageBytes[index], fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => controller.removeImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.close, color: Colors.white, size: 12),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      );
    });
  }

  Widget _buildQuickStats(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey9 : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextCustom(title: 'QUICK STATS', fontSize: 11, fontFamily: FontFamily.semiBold, color: isDark ? AppThemeData.grey4 : AppThemeData.grey6),
          spaceH(height: 16),
          _buildStatRow('Division', '—', isDark),
          _buildStatRow('Purchases', '—', isDark),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextCustom(title: 'Asset Status', fontSize: 13, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                child: TextCustom(title: 'DRAFTING', fontSize: 11, fontFamily: FontFamily.semiBold, color: Colors.orange),
              ),
            ],
          ),
          spaceH(height: 12),
          Divider(color: isDark ? AppThemeData.grey8 : AppThemeData.grey3),
          spaceH(height: 12),
          _buildStatRow('Last Modified', 'Just now', isDark),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextCustom(title: label, fontSize: 13, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
          TextCustom(title: value, fontSize: 13, fontFamily: FontFamily.medium, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
        ],
      ),
    );
  }

  Widget _buildPrecisionTip(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF5D54F2).withValues(alpha: isDark ? 0.12 : 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: const Color(0xFF5D54F2).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.lightbulb_outline, color: Color(0xFF5D54F2), size: 20),
              ),
              spaceW(width: 12),
              TextCustom(title: 'Precision Tip', fontSize: 14, fontFamily: FontFamily.semiBold, color: const Color(0xFF5D54F2)),
            ],
          ),
          spaceH(height: 12),
          TextCustom(
            title: 'Ensure the \'Brand Name\' matches the original manufacturer to maintain inventory data integrity.',
            fontSize: 12,
            fontFamily: FontFamily.regular,
            color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: controller.discardChanges,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: BorderSide(color: isDark ? AppThemeData.grey7 : AppThemeData.grey4),
            ),
            child: TextCustom(title: 'Discard', fontSize: 14, fontFamily: FontFamily.medium, color: isDark ? AppThemeData.grey4 : AppThemeData.grey7),
          ),
        ),
        spaceW(width: 12),
        Expanded(
          child: Obx(() => ElevatedButton(
            onPressed: controller.isLoading.value ? null : controller.registerDevice,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5D54F2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              shadowColor: const Color(0xFF5D54F2).withValues(alpha: 0.3),
            ),
            child: controller.isLoading.value
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : TextCustom(title: 'Complete Entry', fontSize: 14, fontFamily: FontFamily.semiBold, color: Colors.white),
          )),
        ),
      ],
    );
  }
}