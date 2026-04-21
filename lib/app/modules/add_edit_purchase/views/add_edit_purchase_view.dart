// lib/app/modules/add_edit_purchase/views/add_edit_purchase_view.dart
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:maheksync/app/models/category_model.dart';
import 'package:maheksync/app/models/payment_method_model.dart';
import 'package:provider/provider.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/dark_theme_provider.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/network_image_widget.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import '../controllers/add_edit_purchase_controller.dart';

class AddEditPurchaseView extends GetView<AddEditPurchaseController> {
  const AddEditPurchaseView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDark = themeChange.isDarkTheme();

    return Scaffold(
      backgroundColor: isDark ? AppThemeData.grey10 : AppThemeData.grey2,
      appBar: AppBar(
        backgroundColor: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? AppThemeData.grey4 : AppThemeData.grey7, size: 20),
        ),
        title: Obx(() => TextCustom(
          title: controller.isEditMode.value ? 'Edit Purchase' : 'Add Purchase',
          fontSize: 22,
          fontFamily: FontFamily.bold,
          color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
        )),
        actions: [
          TextButton(
            onPressed: controller.savePurchase,
            child: TextCustom(title: 'Save', fontSize: 15, fontFamily: FontFamily.semiBold, color: AppThemeData.primary50),
          ),
        ],
      ),
      body: Row(
        children: [
          // Left Panel - Form
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04), blurRadius: 20, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(isDark),
                    spaceH(height: 28),
                    _buildSectionTitle('IDENTITY & ORIGIN', Icons.inventory_2_outlined, isDark),
                    spaceH(height: 16),
                    _buildTextField('ASSET NAME', controller.assetNameController, 'e.g. Minimalist Aluminum Structure', Icons.shopping_bag_rounded, isDark),
                    spaceH(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildTextField('BRAND', controller.brandController, 'Studio Kinetic', Icons.business_outlined, isDark)),
                        spaceW(width: 16),
                        Expanded(child: _buildCategoryDropdown(isDark)),
                      ],
                    ),
                    spaceH(height: 28),
                    _buildSectionTitle('FINANCIAL DATA', Icons.attach_money_rounded, isDark),
                    spaceH(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildTextField('PRICE (USD)', controller.priceController, '0.00', Icons.attach_money_rounded, isDark, keyboardType: TextInputType.number)),
                        spaceW(width: 16),
                        Expanded(child: _buildPaymentMethodDropdown(isDark)),
                      ],
                    ),
                    spaceH(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildDatePicker('PURCHASE DATE', controller.purchaseDate, isDark)),
                        spaceW(width: 16),
                        Expanded(child: _buildDatePicker('WARRANTY DATE', controller.warrantyDate, isDark, isWarranty: true)),
                      ],
                    ),
                    spaceH(height: 28),
                    _buildSectionTitle('LOGISTICS & STATE', Icons.local_shipping_outlined, isDark),
                    spaceH(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildTextField('SIZE', controller.sizeController, 'XL / 500L', Icons.straighten_outlined, isDark)),
                        spaceW(width: 16),
                        Expanded(child: _buildTextField('STORE / LOCATION', controller.storeLocationController, 'Warehouse 7', Icons.store_outlined, isDark)),
                      ],
                    ),
                    spaceH(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildConditionDropdown(isDark)),
                        spaceW(width: 16),
                        Expanded(child: _buildStatusDropdown(isDark)),
                      ],
                    ),
                    spaceH(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildTextField('UNITS', controller.unitsController, '1', Icons.numbers_rounded, isDark, keyboardType: TextInputType.number)),
                        spaceW(width: 16),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                    spaceH(height: 28),
                    _buildSectionTitle('DESCRIPTION', Icons.description_outlined, isDark),
                    spaceH(height: 16),
                    _buildTextField('DESCRIPTION', controller.descriptionController, 'Describe your purchase...', Icons.description_outlined, isDark, maxLines: 4),
                  ],
                ),
              ),
            ),
          ),
          // Right Panel - Images
          Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
              border: Border(left: BorderSide(color: isDark ? AppThemeData.grey9 : AppThemeData.grey3, width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(title: 'Visual Documentation', fontSize: 18, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
                spaceH(height: 8),
                TextCustom(title: 'Drop files here to expand the visual documentation of this purchase.', fontSize: 13, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                spaceH(height: 20),
                _buildImageUploadArea(isDark),
                spaceH(height: 20),
                _buildImageGrid(isDark),
                spaceH(height: 20),
                _buildEditorialRequirement(isDark),
                spaceH(height: 24),
                _buildActionButtons(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppThemeData.primary50, AppThemeData.primary4]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.add_shopping_cart_rounded, color: Colors.white, size: 26),
        ),
        spaceW(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextCustom(
              title: 'Create a high-fidelity entry',
              fontSize: 18,
              fontFamily: FontFamily.bold,
              color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
            ),
            TextCustom(
              title: 'Every detail ensures the velocity of your editorial flow.',
              fontSize: 13,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Container(width: 28, height: 28, decoration: BoxDecoration(color: AppThemeData.primary50.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: AppThemeData.primary50, size: 16)),
        spaceW(width: 10),
        TextCustom(title: title, fontSize: 13, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey3 : AppThemeData.grey7),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint, IconData icon, bool isDark, {int maxLines = 1, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(title: label, fontSize: 11, fontFamily: FontFamily.medium, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
        spaceH(height: 8),
        Container(
          decoration: BoxDecoration(color: isDark ? AppThemeData.grey9 : AppThemeData.grey1, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? AppThemeData.grey8 : AppThemeData.grey3, width: 0.5)),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Container(margin: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppThemeData.primary50.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: AppThemeData.primary50, size: 18)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppThemeData.primary50, width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(
          title: 'CATEGORY',
          fontSize: 11,
          fontFamily: FontFamily.medium,
          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
        ),
        spaceH(height: 8),
        Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
              width: 0.5,
            ),
          ),
          child: DropdownButton<CategoryModel>(
            value: controller.selectedCategory.value,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: isDark ? AppThemeData.grey9 : AppThemeData.primaryWhite,
            hint: Text(
              'Select Category',
              style: TextStyle(
                fontSize: 14,
                fontFamily: FontFamily.regular,
                color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
              ),
            ),
            items: controller.categories.map((c) {
              return DropdownMenuItem<CategoryModel>(
                value: c,
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppThemeData.primary50.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: c.iconUrl != null && c.iconUrl!.isNotEmpty
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: NetworkImageWidget(
                          imageUrl: c.iconUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                          : Icon(
                        Icons.category_rounded,
                        color: AppThemeData.primary50,
                        size: 16,
                      ),
                    ),
                    spaceW(width: 12),
                    Expanded(
                      child: Text(
                        c.name ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: FontFamily.medium,
                          color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (v) => controller.selectedCategory.value = v,
          ),
        )),
      ],
    );
  }

  Widget _buildPaymentMethodDropdown(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(title: 'PAYMENT METHOD', fontSize: 11, fontFamily: FontFamily.medium, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
        spaceH(height: 8),
        Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: isDark ? AppThemeData.grey9 : AppThemeData.grey1, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? AppThemeData.grey8 : AppThemeData.grey3, width: 0.5)),
          child: DropdownButton<PaymentMethodModel>(
            value: controller.selectedPaymentMethod.value,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: isDark ? AppThemeData.grey9 : AppThemeData.primaryWhite,
            hint: Text('Select Method', style: TextStyle(color: isDark ? AppThemeData.grey6 : AppThemeData.grey5)),
            items: controller.paymentMethods.map((m) => DropdownMenuItem(value: m, child: Text(m.pName ?? ''))).toList(),
            onChanged: (v) => controller.selectedPaymentMethod.value = v,
          ),
        )),
      ],
    );
  }

  Widget _buildConditionDropdown(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(title: 'CONDITION', fontSize: 11, fontFamily: FontFamily.medium, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
        spaceH(height: 8),
        Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: isDark ? AppThemeData.grey9 : AppThemeData.grey1, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? AppThemeData.grey8 : AppThemeData.grey3, width: 0.5)),
          child: DropdownButton<String>(
            value: controller.selectedCondition.value,
            isExpanded: true,
            underline: const SizedBox(),
            items: controller.conditions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => controller.selectedCondition.value = v!,
          ),
        )),
      ],
    );
  }

  Widget _buildStatusDropdown(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(title: 'STATUS', fontSize: 11, fontFamily: FontFamily.medium, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
        spaceH(height: 8),
        Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: isDark ? AppThemeData.grey9 : AppThemeData.grey1, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? AppThemeData.grey8 : AppThemeData.grey3, width: 0.5)),
          child: DropdownButton<String>(
            value: controller.selectedStatus.value,
            isExpanded: true,
            underline: const SizedBox(),
            items: controller.statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => controller.selectedStatus.value = v!,
          ),
        )),
      ],
    );
  }

  Widget _buildDatePicker(String label, Rx<DateTime?> date, bool isDark, {bool isWarranty = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(title: label, fontSize: 11, fontFamily: FontFamily.medium, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
        spaceH(height: 8),
        Obx(() => GestureDetector(
          onTap: () async {
            final selected = await showDatePicker(
              context: Get.context!,
              initialDate: isWarranty ? DateTime.now().add(const Duration(days: 365)) : DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2030),
            );
            if (selected != null) {
              if (isWarranty) {
                controller.setWarrantyDate(selected);
              } else {
                controller.setPurchaseDate(selected);
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(color: isDark ? AppThemeData.grey9 : AppThemeData.grey1, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? AppThemeData.grey8 : AppThemeData.grey3, width: 0.5)),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 16, color: AppThemeData.primary50),
                spaceW(width: 12),
                TextCustom(
                  title: date.value != null ? DateFormat('MM/dd/yyyy').format(date.value!) : 'mm/dd/yyyy',
                  fontSize: 14,
                  color: date.value != null ? (isDark ? AppThemeData.grey1 : AppThemeData.grey10) : (isDark ? AppThemeData.grey6 : AppThemeData.grey5),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildImageUploadArea(bool isDark) {
    return GestureDetector(
      onTap: controller.pickImages,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppThemeData.primary50.withValues(alpha: 0.3), width: 1.5, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 52, height: 52, decoration: BoxDecoration(color: AppThemeData.primary50.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)), child: Icon(Icons.cloud_upload_outlined, size: 28, color: AppThemeData.primary50)),
            spaceH(height: 12),
            TextCustom(title: 'Browse Media', fontSize: 14, fontFamily: FontFamily.semiBold, color: AppThemeData.primary50),
            TextCustom(title: 'PNG, JPG up to 10MB', fontSize: 11, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid(bool isDark) {
    return Obx(() {
      if (controller.selectedImages.isEmpty && (controller.editingPurchase.value?.imageUrls?.isEmpty ?? true)) {
        return const SizedBox.shrink();
      }

      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          // Existing images
          if (controller.editingPurchase.value?.imageUrls != null)
            ...controller.editingPurchase.value!.imageUrls!.map((url) => _buildImageTile(isDark, networkUrl: url)),
          // New images
          ...controller.imageBytes.asMap().entries.map((entry) => _buildImageTile(isDark, memoryImage: entry.value, index: entry.key)),
        ],
      );
    });
  }

  Widget _buildImageTile(bool isDark, {Uint8List? memoryImage, String? networkUrl, int? index}) {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: isDark ? AppThemeData.grey7 : AppThemeData.grey3)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: memoryImage != null
                ? Image.memory(memoryImage, fit: BoxFit.cover)
                : networkUrl != null
                ? NetworkImageWidget(imageUrl: networkUrl, fit: BoxFit.cover)
                : const SizedBox(),
          ),
        ),
        if (index != null)
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => controller.removeImage(index),
              child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: AppThemeData.danger300, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.close, color: Colors.white, size: 12)),
            ),
          ),
      ],
    );
  }

  Widget _buildEditorialRequirement(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppThemeData.primary50.withValues(alpha: isDark ? 0.12 : 0.06), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppThemeData.primary50, size: 20),
          spaceW(width: 12),
          Expanded(
            child: TextCustom(
              title: 'At least three high-resolution images are required for this category to meet the Gallery quality standards.',
              fontSize: 12,
              color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
            ),
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
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: TextCustom(title: 'Discard', fontSize: 15, color: isDark ? AppThemeData.grey4 : AppThemeData.grey7),
          ),
        ),
        spaceW(width: 12),
        Expanded(
          child: Obx(() => ElevatedButton(
            onPressed: controller.isLoading.value ? null : controller.savePurchase,
            style: ElevatedButton.styleFrom(backgroundColor: AppThemeData.primary50, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: controller.isLoading.value
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : TextCustom(title: controller.isEditMode.value ? 'Update Purchase' : 'Complete Entry', fontSize: 15, fontFamily: FontFamily.semiBold, color: Colors.white),
          )),
        ),
      ],
    );
  }
}