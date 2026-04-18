// lib/app/modules/add_new_devices/views/add_new_devices_view.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
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
      backgroundColor: isDark ? AppThemeData.grey10 : const Color(0xFFF8FAFC),
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
          fontSize: 20,
          fontFamily: FontFamily.bold,
          color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.more_horiz,
              color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          // Main Form
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextCustom(
                    title: 'Catalog a new acquisition into the Kinetic repository.',
                    fontSize: 15,
                    fontFamily: FontFamily.regular,
                    color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                  ),
                  spaceH(height: 24),
                  _buildSectionTitle('PRODUCT IDENTITY', isDark),
                  spaceH(height: 16),
                  _buildTextField('ITEM NAME', controller.deviceNameController, 'e.g. Kinetic Sculpture #04', isDark),
                  spaceH(height: 16),
                  _buildTextField('BRAND NAME', controller.brandNameController, 'The Kinetic Studio', isDark),
                  spaceH(height: 16),
                  _buildDropdown('CATEGORY', controller.selectedCategory, controller.categories, isDark),
                  spaceH(height: 16),
                  _buildTextField('DESCRIPTION', controller.descriptionController, 'Describe the item\'s movement, material, and aesthetic impact...', isDark, maxLines: 2),
                  spaceH(height: 24),
                  _buildSectionTitle('SPECIFICATIONS & LOGISTICS', isDark),
                  spaceH(height: 16),
                  _buildTextField('PRODUCT SIZE', controller.productSizeController, '120 × 80 cm', isDark),
                  spaceH(height: 16),
                  _buildTextField('PRODUCT PRICE', controller.priceController, '\$ 0.00', isDark, keyboardType: TextInputType.number),
                  spaceH(height: 16),
                  _buildDatePicker(isDark),
                  spaceH(height: 24),
                  _buildImageUploadSection(isDark),
                ],
              ),
            ),
          ),
          // Right Panel - Stats & Tips
          Container(
            width: 320,
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
                  _buildQuickStats(isDark),
                  spaceH(height: 24),
                  _buildAddImageCard(isDark),
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

  Widget _buildSectionTitle(String title, bool isDark) {
    return TextCustom(
      title: title,
      fontSize: 13,
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
            fillColor: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF5D54F2), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            isDense: true,
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
            color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selected.value,
              isExpanded: true,
              dropdownColor: isDark ? AppThemeData.grey9 : Colors.white,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
              ),
              style: TextStyle(
                fontFamily: FontFamily.regular,
                fontSize: 14,
                color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              ),
              items: items.map((c) => DropdownMenuItem(
                value: c,
                child: Text(c, style: TextStyle(
                  color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                )),
              )).toList(),
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
        TextCustom(
          title: 'PURCHASE DATE',
          fontSize: 11,
          fontFamily: FontFamily.medium,
          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
        ),
        spaceH(height: 6),
        Obx(() => GestureDetector(
          onTap: () async {
            final selected = await showDatePicker(
              context: Get.context!,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2030),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: const Color(0xFF5D54F2),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (selected != null) controller.setPurchaseDate(selected);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                ),
                spaceW(width: 12),
                TextCustom(
                  title: controller.purchaseDate.value != null
                      ? DateFormat('MM/dd/yyyy').format(controller.purchaseDate.value!)
                      : 'dd---yyyy',
                  fontSize: 14,
                  fontFamily: FontFamily.regular,
                  color: controller.purchaseDate.value != null
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

  Widget _buildImageUploadSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextCustom(
              title: 'PRODUCT IMAGES',
              fontSize: 11,
              fontFamily: FontFamily.medium,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            ),
            TextButton.icon(
              onPressed: controller.pickImages,
              icon: Icon(Icons.add_photo_alternate_outlined, size: 16, color: const Color(0xFF5D54F2)),
              label: TextCustom(
                title: 'Add Images',
                fontSize: 12,
                fontFamily: FontFamily.medium,
                color: const Color(0xFF5D54F2),
              ),
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
            ),
          ],
        ),
        spaceH(height: 8),
        Obx(() {
          if (controller.deviceImages.isEmpty) {
            return Container(
              height: 100,
              decoration: BoxDecoration(
                color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
                  style: BorderStyle.solid,
                ),
              ),
              child: Center(
                child: TextCustom(
                  title: 'No images selected',
                  fontSize: 12,
                  fontFamily: FontFamily.regular,
                  color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
                ),
              ),
            );
          }
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(controller.deviceImages.length, (index) {
              return Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? AppThemeData.grey7 : AppThemeData.grey3,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: kIsWeb && controller.imageBytes.length > index
                          ? Image.memory(controller.imageBytes[index], fit: BoxFit.cover)
                          : Image.file(File(controller.deviceImages[index].path), fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => controller.removeImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 12),
                      ),
                    ),
                  ),
                ],
              );
            }),
          );
        }),
      ],
    );
  }

  Widget _buildQuickStats(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextCustom(
            title: 'QUICK STATS',
            fontSize: 11,
            fontFamily: FontFamily.semiBold,
            color: isDark ? AppThemeData.grey4 : AppThemeData.grey6,
          ),
          spaceH(height: 16),
          _buildStatRow('Division', '—', isDark),
          _buildStatRow('Purchases', '—', isDark),
          _buildStatRow('Asset Status', 'DRAFTING', isDark, valueColor: Colors.orange),
          spaceH(height: 12),
          Divider(color: isDark ? AppThemeData.grey8 : AppThemeData.grey3),
          spaceH(height: 12),
          _buildStatRow('Last Modified', 'Just now', isDark),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, bool isDark, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextCustom(
            title: label,
            fontSize: 13,
            fontFamily: FontFamily.regular,
            color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
          ),
          TextCustom(
            title: value,
            fontSize: 13,
            fontFamily: FontFamily.medium,
            color: valueColor ?? (isDark ? AppThemeData.grey1 : AppThemeData.grey10),
          ),
        ],
      ),
    );
  }

  Widget _buildAddImageCard(bool isDark) {
    return GestureDetector(
      onTap: controller.pickImages,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Image.asset(
              'assets/images/add.png',
              width: 48,
              height: 48,
              color: const Color(0xFF5D54F2),
              errorBuilder: (_, __, ___) => Icon(
                Icons.add_photo_alternate_outlined,
                size: 48,
                color: const Color(0xFF5D54F2),
              ),
            ),
            spaceH(height: 12),
            TextCustom(
              title: 'Add Product Images',
              fontSize: 14,
              fontFamily: FontFamily.semiBold,
              color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
            ),
            spaceH(height: 4),
            TextCustom(
              title: 'Upload up to 5 images',
              fontSize: 12,
              fontFamily: FontFamily.regular,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrecisionTip(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF5D54F2).withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF5D54F2).withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF5D54F2).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.lightbulb_outline, color: Color(0xFF5D54F2), size: 18),
              ),
              spaceW(width: 10),
              TextCustom(
                title: 'Precision Tip',
                fontSize: 13,
                fontFamily: FontFamily.semiBold,
                color: const Color(0xFF5D54F2),
              ),
            ],
          ),
          spaceH(height: 12),
          TextCustom(
            title: 'Ensure the \'Brand Name\' matches the original manufacturer to maintain inventory data integrity for analytics.',
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
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              side: BorderSide(color: isDark ? AppThemeData.grey7 : AppThemeData.grey4),
            ),
            child: TextCustom(
              title: 'Discard Draft',
              fontSize: 14,
              fontFamily: FontFamily.medium,
              color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
            ),
          ),
        ),
        spaceW(width: 12),
        Expanded(
          child: Obx(() => ElevatedButton(
            onPressed: controller.isLoading.value ? null : controller.registerDevice,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5D54F2),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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