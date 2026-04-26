// lib/app/modules/subscription_crud/views/subscription_crud_view.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/network_image_widget.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import '../controllers/subscription_crud_controller.dart';

class SubscriptionCrudView extends GetView<SubscriptionCrudController> {
  const SubscriptionCrudView({super.key});

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
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? AppThemeData.grey4 : AppThemeData.grey7, size: 20),
        ),
        title: TextCustom(
          title: controller.isEditMode.value ? 'Edit Subscription' : 'Add Subscription',
          fontSize: 18,
          fontFamily: FontFamily.bold,
          color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
        ),
        actions: [
          TextButton(
            onPressed: controller.saveSubscription,
            child: TextCustom(title: 'Save', fontSize: 14, fontFamily: FontFamily.semiBold, color: AppThemeData.primary50),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04), blurRadius: 20, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Subscription Icon', Icons.image_rounded, isDark),
              spaceH(height: 10),
              _buildIconUploader(isDark),
              spaceH(height: 20),
              _buildSectionTitle('Basic Information', Icons.info_outline, isDark),
              spaceH(height: 12),
              _buildTextField(controller.nameController, 'Netflix, Spotify, Jio...', 'Subscription Name', Icons.subscriptions_rounded, isDark),
              spaceH(height: 14),
              _buildTextField(controller.descriptionController, 'Brief description...', 'Description', Icons.description_outlined, isDark, maxLines: 2),
              spaceH(height: 14),
              _buildTextField(controller.priceController, '0.00', 'Price (₹)', Icons.money_rounded, isDark, keyboardType: TextInputType.number),
              spaceH(height: 20),
              _buildSectionTitle('Category & Billing', Icons.category_rounded, isDark),
              spaceH(height: 12),
              Row(
                children: [
                  Expanded(child: _buildDropdown('Category', controller.selectedCategory, controller.categories, isDark)),
                  spaceW(width: 14),
                  Expanded(child: _buildDropdown('Billing Cycle', controller.selectedBillingCycle, controller.billingCycles, isDark)),
                ],
              ),
              spaceH(height: 14),
              _buildDropdown('Status', controller.selectedStatus, controller.statuses, isDark),
              spaceH(height: 20),
              _buildSectionTitle('Dates', Icons.calendar_month_rounded, isDark),
              spaceH(height: 12),
              Row(
                children: [
                  Expanded(child: _buildDatePicker('Start Date', controller.startDate, isDark)),
                  spaceW(width: 14),
                  Expanded(child: _buildDatePicker('Expiry Date', controller.expiryDate, isDark)),
                ],
              ),
              spaceH(height: 20),
              _buildSectionTitle('Gallery Images', Icons.photo_library_rounded, isDark),
              spaceH(height: 12),
              _buildImageUploadSection(isDark),
              spaceH(height: 20),
              _buildTextField(controller.notesController, 'Additional notes...', 'Notes', Icons.notes_rounded, isDark, maxLines: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(color: AppThemeData.primary50.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: AppThemeData.primary50, size: 16),
        ),
        spaceW(width: 10),
        TextCustom(title: title, fontSize: 14, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey3 : AppThemeData.grey7),
      ],
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, String label, IconData icon, bool isDark, {int maxLines = 1, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(title: label, fontSize: 11, fontFamily: FontFamily.medium, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
        spaceH(height: 6),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.02), blurRadius: 8, offset: const Offset(0, 2))],
            border: Border.all(color: isDark ? AppThemeData.grey8 : AppThemeData.grey3, width: 0.5),
          ),
          child: TextField(
            controller: ctrl,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: TextStyle(fontFamily: FontFamily.medium, fontSize: 14, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(fontFamily: FontFamily.regular, fontSize: 14, color: isDark ? AppThemeData.grey6 : AppThemeData.grey5),
              prefixIcon: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppThemeData.primary50.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: AppThemeData.primary50, size: 18),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide:  BorderSide(color: AppThemeData.primary50, width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              filled: true,
              fillColor: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, RxString selected, List<String> items, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(title: label, fontSize: 11, fontFamily: FontFamily.medium, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
        spaceH(height: 6),
        Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? AppThemeData.grey8 : AppThemeData.grey3, width: 0.5),
          ),
          child: DropdownButton<String>(
            value: selected.value,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: isDark ? AppThemeData.grey9 : AppThemeData.primaryWhite,
            style: TextStyle(fontFamily: FontFamily.medium, fontSize: 14, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => selected.value = v!,
          ),
        )),
      ],
    );
  }

  Widget _buildDatePicker(String label, Rx<DateTime?> date, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(title: label, fontSize: 11, fontFamily: FontFamily.medium, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
        spaceH(height: 6),
        Obx(() => GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(context: Get.context!, initialDate: date.value ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2035));
            if (picked != null) date.value = picked;
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? AppThemeData.grey8 : AppThemeData.grey3, width: 0.5),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded, color: AppThemeData.primary50, size: 16),
                spaceW(width: 10),
                TextCustom(
                  title: date.value != null ? DateFormat('dd/MM/yyyy').format(date.value!) : 'Select date',
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

  Widget _buildIconUploader(bool isDark) {
    return Obx(() {
      if (controller.selectedIcon.value != null && controller.iconBytes.value != null) {
        return _buildIconPreview(isDark, bytes: controller.iconBytes.value);
      } else if (controller.editingSubscription.value?.iconUrl != null && controller.editingSubscription.value!.iconUrl!.isNotEmpty) {
        return _buildIconPreview(isDark, networkUrl: controller.editingSubscription.value!.iconUrl);
      } else {
        return _buildUploadButton('Upload Icon', controller.pickIcon, isDark);
      }
    });
  }

  Widget _buildIconPreview(bool isDark, {Uint8List? bytes, String? networkUrl}) {
    return Container(
      height: 100,
      width: 100,
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
                  ? Image.memory(bytes, width: 80, height: 80, fit: BoxFit.cover)
                  : networkUrl != null
                  ? NetworkImageWidget(imageUrl: networkUrl, fit: BoxFit.cover, height: 80, width: 80)
                  : Icon(Icons.subscriptions_rounded, color: AppThemeData.primary50, size: 40),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: controller.pickIcon,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: AppThemeData.primary50, borderRadius: BorderRadius.circular(6)),
                child: const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadButton(String label, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        width: 100,
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppThemeData.primary50.withValues(alpha: 0.3), width: 1.5, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_upload_outlined, color: AppThemeData.primary50, size: 28),
            spaceH(height: 4),
            TextCustom(title: label, fontSize: 10, color: AppThemeData.primary50, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadSection(bool isDark) {
    return Column(
      children: [
        if (controller.existingImages.isNotEmpty)
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: controller.existingImages.map((url) => _buildImageTile(isDark, networkUrl: url, onRemove: () => controller.removeExistingImage(url))).toList(),
          ),
        Obx(() => Wrap(
          spacing: 10,
          runSpacing: 10,
          children: controller.imageBytes.asMap().entries.map((e) => _buildImageTile(isDark, bytes: e.value, onRemove: () => controller.removeNewImage(e.key))).toList(),
        )),
        spaceH(height: 10),
        _buildUploadButton('Add Images', controller.pickImages, isDark),
      ],
    );
  }

  Widget _buildImageTile(bool isDark, {Uint8List? bytes, String? networkUrl, VoidCallback? onRemove}) {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? AppThemeData.grey7 : AppThemeData.grey3),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: bytes != null
                ? Image.memory(bytes, fit: BoxFit.cover)
                : networkUrl != null
                ? NetworkImageWidget(imageUrl: networkUrl, fit: BoxFit.cover)
                : const SizedBox(),
          ),
        ),
        if (onRemove != null)
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(color: AppThemeData.danger300, borderRadius: BorderRadius.circular(4)),
                child: const Icon(Icons.close_rounded, color: Colors.white, size: 12),
              ),
            ),
          ),
      ],
    );
  }
}