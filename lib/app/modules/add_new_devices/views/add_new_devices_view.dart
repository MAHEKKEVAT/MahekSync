// lib/app/modules/add_new_devices/views/add_new_devices_view.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import '../controllers/add_new_devices_controller.dart';

class AddNewDevicesView extends GetView<AddNewDevicesController> {
  const AddNewDevicesView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppThemeData.grey10 : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: isDark ? AppThemeData.primaryBlack : Colors.white,
        elevation: 0,
        title: Text(
          'Register New Device',
          style: TextStyle(
            fontFamily: FontFamily.bold,
            fontSize: 20,
            color: isDark ? Colors.white : AppThemeData.grey10,
          ),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.close,
            color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Catalog your technology.',
                style: TextStyle(
                  fontFamily: FontFamily.bold,
                  fontSize: 28,
                  color: isDark ? Colors.white : AppThemeData.grey10,
                ),
              ),
              spaceH(height: 24),
              _buildDeviceNameField(isDark),
              spaceH(height: 24),
              _buildImageUpload(isDark),
              spaceH(height: 24),
              Row(
                children: [
                  Expanded(child: _buildCategoryDropdown(isDark)),
                  spaceW(width: 16),
                  Expanded(child: _buildConditionSelector(isDark)),
                ],
              ),
              spaceH(height: 24),
              Row(
                children: [
                  Expanded(child: _buildPriceField(isDark)),
                  spaceW(width: 16),
                  Expanded(child: _buildStoreField(isDark)),
                ],
              ),
              spaceH(height: 24),
              _buildExpertTip(isDark),
              spaceH(height: 24),
              Row(
                children: [
                  Expanded(child: _buildDatePicker(isDark, 'DATE OF PURCHASE', controller.purchaseDate, controller.setPurchaseDate)),
                  spaceW(width: 16),
                  Expanded(child: _buildDatePicker(isDark, 'WARRANTY ENDS', controller.warrantyEndDate, controller.setWarrantyEndDate)),
                ],
              ),
              spaceH(height: 24),
              _buildPaymentMethodSelector(isDark),
              spaceH(height: 32),
              _buildActionButtons(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceNameField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DEVICE NAME',
          style: TextStyle(
            fontFamily: FontFamily.medium,
            fontSize: 12,
            letterSpacing: 1.2,
            color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
          ),
        ),
        spaceH(height: 8),
        TextField(
          controller: controller.deviceNameController,
          style: TextStyle(
            fontFamily: FontFamily.regular,
            fontSize: 16,
            color: isDark ? Colors.white : AppThemeData.grey10,
          ),
          decoration: InputDecoration(
            hintText: 'e.g. MacBook Pro M3 Max 16-inch',
            hintStyle: TextStyle(
              fontFamily: FontFamily.regular,
              fontSize: 15,
              color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
            ),
            filled: true,
            fillColor: isDark ? AppThemeData.grey9 : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF5D54F2), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildImageUpload(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'UPLOAD DEVICE PHOTO',
          style: TextStyle(
            fontFamily: FontFamily.medium,
            fontSize: 12,
            letterSpacing: 1.2,
            color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
          ),
        ),
        spaceH(height: 8),
        Obx(() {
          final image = controller.deviceImage.value;
          return GestureDetector(
            onTap: controller.pickImage,
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                color: isDark ? AppThemeData.grey9 : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
                  width: 1,
                  style: BorderStyle.solid,
                ),
              ),
              child: image != null
                  ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(image.path),
                      width: double.infinity,
                      height: 160,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: controller.removeImage,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 40,
                    color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                  ),
                  spaceH(height: 8),
                  Text(
                    'Drag and drop high-resolution JPG or PNG',
                    style: TextStyle(
                      fontFamily: FontFamily.regular,
                      fontSize: 13,
                      color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                    ),
                  ),
                  Text(
                    '(Max 10MB)',
                    style: TextStyle(
                      fontFamily: FontFamily.regular,
                      fontSize: 12,
                      color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCategoryDropdown(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CATEGORY',
          style: TextStyle(
            fontFamily: FontFamily.medium,
            fontSize: 12,
            letterSpacing: 1.2,
            color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
          ),
        ),
        spaceH(height: 8),
        Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.grey9 : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: controller.selectedCategory.value,
              isExpanded: true,
              dropdownColor: isDark ? AppThemeData.grey9 : Colors.white,
              style: TextStyle(
                fontFamily: FontFamily.regular,
                fontSize: 15,
                color: isDark ? Colors.white : AppThemeData.grey10,
              ),
              items: controller.categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) controller.selectedCategory.value = value;
              },
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildConditionSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CONDITION',
          style: TextStyle(
            fontFamily: FontFamily.medium,
            fontSize: 12,
            letterSpacing: 1.2,
            color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
          ),
        ),
        spaceH(height: 8),
        Obx(() => Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.grey9 : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: controller.conditions.map((condition) {
              final isSelected = controller.selectedCondition.value == condition;
              return Expanded(
                child: GestureDetector(
                  onTap: () => controller.selectedCondition.value = condition,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF5D54F2) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      condition,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: FontFamily.medium,
                        fontSize: 13,
                        color: isSelected ? Colors.white : (isDark ? AppThemeData.grey4 : AppThemeData.grey7),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        )),
      ],
    );
  }

  Widget _buildPriceField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PRICE',
          style: TextStyle(
            fontFamily: FontFamily.medium,
            fontSize: 12,
            letterSpacing: 1.2,
            color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
          ),
        ),
        spaceH(height: 8),
        TextField(
          controller: controller.priceController,
          keyboardType: TextInputType.number,
          style: TextStyle(
            fontFamily: FontFamily.regular,
            fontSize: 15,
            color: isDark ? Colors.white : AppThemeData.grey10,
          ),
          decoration: InputDecoration(
            hintText: '\$ 0.00',
            hintStyle: TextStyle(
              fontFamily: FontFamily.regular,
              fontSize: 15,
              color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
            ),
            prefixIcon: Icon(Icons.attach_money, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
            filled: true,
            fillColor: isDark ? AppThemeData.grey9 : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF5D54F2), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStoreField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'STORE / RETAILER',
          style: TextStyle(
            fontFamily: FontFamily.medium,
            fontSize: 12,
            letterSpacing: 1.2,
            color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
          ),
        ),
        spaceH(height: 8),
        TextField(
          controller: controller.storeNameController,
          style: TextStyle(
            fontFamily: FontFamily.regular,
            fontSize: 15,
            color: isDark ? Colors.white : AppThemeData.grey10,
          ),
          decoration: InputDecoration(
            hintText: 'Apple Store, Amazon, etc.',
            hintStyle: TextStyle(
              fontFamily: FontFamily.regular,
              fontSize: 15,
              color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
            ),
            filled: true,
            fillColor: isDark ? AppThemeData.grey9 : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF5D54F2), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpertTip(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF5D54F2).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF5D54F2).withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF5D54F2).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.lightbulb_outline, color: Color(0xFF5D54F2)),
          ),
          spaceW(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Expert Tip',
                  style: TextStyle(
                    fontFamily: FontFamily.semiBold,
                    fontSize: 14,
                    color: const Color(0xFF5D54F2),
                  ),
                ),
                spaceH(height: 4),
                Text(
                  'Registering devices with purchase dates helps us automate your warranty tracking and renewal alerts.',
                  style: TextStyle(
                    fontFamily: FontFamily.regular,
                    fontSize: 13,
                    color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(bool isDark, String label, Rxn<DateTime> date, Function(DateTime) onDateSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: FontFamily.medium,
            fontSize: 12,
            letterSpacing: 1.2,
            color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
          ),
        ),
        spaceH(height: 8),
        Obx(() => GestureDetector(
          onTap: () async {
            final selected = await showDatePicker(
              context: Get.context!,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2030),
            );
            if (selected != null) onDateSelected(selected);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? AppThemeData.grey9 : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 20, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                spaceW(width: 12),
                Text(
                  date.value != null ? DateFormat('MM/dd/yyyy').format(date.value!) : 'mm/dd/yyyy',
                  style: TextStyle(
                    fontFamily: FontFamily.regular,
                    fontSize: 15,
                    color: date.value != null
                        ? (isDark ? Colors.white : AppThemeData.grey10)
                        : (isDark ? AppThemeData.grey6 : AppThemeData.grey5),
                  ),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildPaymentMethodSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PAYMENT METHOD',
          style: TextStyle(
            fontFamily: FontFamily.medium,
            fontSize: 12,
            letterSpacing: 1.2,
            color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
          ),
        ),
        spaceH(height: 12),
        Obx(() => Wrap(
          spacing: 12,
          runSpacing: 8,
          children: controller.paymentMethods.map((method) {
            final isSelected = controller.selectedPaymentMethod.value == method;
            return GestureDetector(
              onTap: () => controller.selectedPaymentMethod.value = method,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF5D54F2) : (isDark ? AppThemeData.grey9 : Colors.white),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF5D54F2) : (isDark ? AppThemeData.grey8 : AppThemeData.grey3),
                  ),
                ),
                child: Text(
                  method,
                  style: TextStyle(
                    fontFamily: FontFamily.medium,
                    fontSize: 13,
                    color: isSelected ? Colors.white : (isDark ? AppThemeData.grey4 : AppThemeData.grey7),
                  ),
                ),
              ),
            );
          }).toList(),
        )),
      ],
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: controller.discardChanges,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            'Discard Changes',
            style: TextStyle(
              fontFamily: FontFamily.medium,
              fontSize: 15,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            ),
          ),
        ),
        spaceW(width: 16),
        Obx(() => ElevatedButton(
          onPressed: controller.isLoading.value ? null : controller.registerDevice,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5D54F2),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: controller.isLoading.value
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
              : Text(
            'Register Device',
            style: TextStyle(fontFamily: FontFamily.semiBold, fontSize: 15, color: Colors.white),
          ),
        )),
      ],
    );
  }
}