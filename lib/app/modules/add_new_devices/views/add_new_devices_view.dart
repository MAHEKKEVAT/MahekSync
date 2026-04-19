// lib/app/modules/add_new_devices/views/add_new_devices_view.dart
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
import '../controllers/add_new_devices_controller.dart';

class AddNewDevicesView extends GetView<AddNewDevicesController> {
  const AddNewDevicesView({super.key});

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
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
            size: 20,
          ),
        ),
        title: TextCustom(
          title: 'Add New Device',
          fontSize: 22,
          fontFamily: FontFamily.bold,
          color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
        ),
        centerTitle: false,
      ),
      body: Row(
        children: [
          // Left Panel - Form
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
                  borderRadius: BorderRadius.circular(24),
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
                                AppThemeData.primary50,
                                AppThemeData.primary4,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        spaceW(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextCustom(
                              title: 'Register New Device',
                              fontSize: 20,
                              fontFamily: FontFamily.bold,
                              color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                            ),
                            TextCustom(
                              title: 'Add a new device to your inventory',
                              fontSize: 13,
                              fontFamily: FontFamily.regular,
                              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                            ),
                          ],
                        ),
                      ],
                    ),
                    spaceH(height: 28),

                    // Product Identity
                    _buildSectionTitle('PRODUCT IDENTITY', Icons.inventory_2_outlined, isDark),
                    spaceH(height: 16),
                    _buildTextField(
                      label: 'DEVICE NAME',
                      controller: controller.deviceNameController,
                      hint: 'e.g. iPhone 15 Pro',
                      icon: Icons.devices_rounded,
                      isDark: isDark,
                    ),
                    spaceH(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'BRAND NAME',
                            controller: controller.brandNameController,
                            hint: 'e.g. Apple',
                            icon: Icons.business_outlined,
                            isDark: isDark,
                          ),
                        ),
                        spaceW(width: 16),
                        Expanded(
                          child: _buildCategoryDropdown(isDark),
                        ),
                      ],
                    ),
                    spaceH(height: 16),
                    _buildTextField(
                      label: 'DESCRIPTION',
                      controller: controller.descriptionController,
                      hint: 'Describe the device...',
                      icon: Icons.description_outlined,
                      isDark: isDark,
                      maxLines: 3,
                    ),
                    spaceH(height: 28),

                    // Purchase Details
                    _buildSectionTitle('PURCHASE DETAILS', Icons.shopping_bag_outlined, isDark),
                    spaceH(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'DEVICE NAME (DISPLAY)',
                            controller: controller.deviceNameController,
                            hint: 'iPhone 15 Pro',
                            icon: Icons.phone_android_rounded,
                            isDark: isDark,
                          ),
                        ),
                        spaceW(width: 16),
                        Expanded(
                          child: _buildTextField(
                            label: 'PRICE (\$)',
                            controller: controller.priceController,
                            hint: '0.00',
                            icon: Icons.attach_money_rounded,
                            isDark: isDark,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    spaceH(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'STORE NAME',
                            controller: controller.storeNameController,
                            hint: 'e.g. Apple Store',
                            icon: Icons.store_outlined,
                            isDark: isDark,
                          ),
                        ),
                        spaceW(width: 16),
                        Expanded(
                          child: _buildConditionDropdown(isDark),
                        ),
                      ],
                    ),
                    spaceH(height: 16),
                    _buildPaymentMethodDropdown(isDark),
                    spaceH(height: 28),

                    // Warranty & Dates
                    _buildSectionTitle('WARRANTY & DATES', Icons.calendar_month_outlined, isDark),
                    spaceH(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildDatePicker(isDark)),
                        spaceW(width: 16),
                        Expanded(child: _buildWarrantyDatePicker(isDark)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Right Panel
          Container(
            width: 380,
            decoration: BoxDecoration(
              color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
              border: Border(
                left: BorderSide(
                  color: isDark ? AppThemeData.grey9 : AppThemeData.grey3,
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
                  _buildImageUploadSection(isDark),
                  spaceH(height: 24),
                  _buildQuickStats(isDark),
                  spaceH(height: 24),
                  _buildActionButtons(isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppThemeData.primary50.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppThemeData.primary50,
            size: 16,
          ),
        ),
        spaceW(width: 10),
        TextCustom(
          title: title,
          fontSize: 13,
          fontFamily: FontFamily.bold,
          color: isDark ? AppThemeData.grey3 : AppThemeData.grey7,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(
          title: label,
          fontSize: 11,
          fontFamily: FontFamily.medium,
          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
        ),
        spaceH(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
              width: 0.5,
            ),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: TextStyle(
              fontFamily: FontFamily.medium,
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
              prefixIcon: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppThemeData.primary50.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: AppThemeData.primary50,
                  size: 18,
                ),
              ),
              filled: true,
              fillColor: Colors.transparent,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppThemeData.primary50,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
              width: 0.5,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<CategoryModel>(
              value: controller.selectedCategory.value,
              isExpanded: true,
              dropdownColor: isDark ? AppThemeData.grey9 : AppThemeData.primaryWhite,
              icon: Container(
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppThemeData.primary50.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppThemeData.primary50,
                  size: 18,
                ),
              ),
              style: TextStyle(
                fontFamily: FontFamily.medium,
                fontSize: 14,
                color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              ),
              hint: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppThemeData.primary50.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.category_rounded,
                      color: AppThemeData.primary50,
                      size: 16,
                    ),
                  ),
                  spaceW(width: 12),
                  TextCustom(
                    title: 'Select Category',
                    fontSize: 14,
                    fontFamily: FontFamily.regular,
                    color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
                  ),
                ],
              ),
              items: controller.categories.map((category) {
                return DropdownMenuItem<CategoryModel>(
                  value: category,
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppThemeData.primary50.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: category.iconUrl != null && category.iconUrl!.isNotEmpty
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: NetworkImageWidget(
                            imageUrl: category.iconUrl!,
                            fit: BoxFit.cover,
                          ),
                        )
                            : Icon(
                          Icons.category_rounded,
                          color: AppThemeData.primary50,
                          size: 18,
                        ),
                      ),
                      spaceW(width: 12),
                      Expanded(
                        child: Text(
                          category.name ?? 'Unknown',
                          style: TextStyle(
                            fontFamily: FontFamily.medium,
                            fontSize: 14,
                            color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                controller.selectedCategory.value = value;
              },
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildConditionDropdown(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(
          title: 'CONDITION',
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
              width: 0.5,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: controller.selectedCondition.value,
              isExpanded: true,
              dropdownColor: isDark ? AppThemeData.grey9 : AppThemeData.primaryWhite,
              icon: Container(
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppThemeData.primary50.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppThemeData.primary50,
                  size: 18,
                ),
              ),
              style: TextStyle(
                fontFamily: FontFamily.medium,
                fontSize: 14,
                color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              ),
              items: controller.conditions.map((condition) {
                return DropdownMenuItem<String>(
                  value: condition,
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getConditionColor(condition),
                          shape: BoxShape.circle,
                        ),
                      ),
                      spaceW(width: 12),
                      Text(condition),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                controller.selectedCondition.value = value!;
              },
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildPaymentMethodDropdown(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(
          title: 'PAYMENT METHOD',
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
              width: 0.5,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<PaymentMethodModel>(
              value: controller.selectedPaymentMethod.value,
              isExpanded: true,
              dropdownColor: isDark ? AppThemeData.grey9 : AppThemeData.primaryWhite,
              icon: Container(
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppThemeData.primary50.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppThemeData.primary50,
                  size: 18,
                ),
              ),
              style: TextStyle(
                fontFamily: FontFamily.medium,
                fontSize: 14,
                color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              ),
              hint: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppThemeData.primary50.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.payment_rounded,
                      color: AppThemeData.primary50,
                      size: 16,
                    ),
                  ),
                  spaceW(width: 12),
                  TextCustom(
                    title: 'Select Payment Method',
                    fontSize: 14,
                    fontFamily: FontFamily.regular,
                    color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
                  ),
                ],
              ),
              items: controller.paymentMethods.map((method) {
                return DropdownMenuItem<PaymentMethodModel>(
                  value: method,
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppThemeData.primary50.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: method.pIcon != null && method.pIcon!.isNotEmpty
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: NetworkImageWidget(
                            imageUrl: method.pIcon!,
                            fit: BoxFit.cover,
                          ),
                        )
                            : Icon(
                          Icons.payment_rounded,
                          color: AppThemeData.primary50,
                          size: 18,
                        ),
                      ),
                      spaceW(width: 12),
                      Expanded(
                        child: Text(
                          method.pName ?? 'Unknown',
                          style: TextStyle(
                            fontFamily: FontFamily.medium,
                            fontSize: 14,
                            color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                controller.selectedPaymentMethod.value = value;
              },
            ),
          ),
        )),
      ],
    );
  }

  Color _getConditionColor(String condition) {
    switch (condition) {
      case 'NEW':
        return AppThemeData.success400;
      case 'USED':
        return AppThemeData.pending400;
      case 'REFURB':
        return AppThemeData.primary50;
      case 'MINT':
        return const Color(0xFF10B981);
      case 'FACTORY NEW':
        return const Color(0xFF3B82F6);
      default:
        return Colors.grey;
    }
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
        spaceH(height: 8),
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
              color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppThemeData.primary50.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: AppThemeData.primary50,
                  ),
                ),
                spaceW(width: 12),
                TextCustom(
                  title: controller.purchaseDate.value != null
                      ? DateFormat('MM/dd/yyyy').format(controller.purchaseDate.value!)
                      : 'Select date',
                  fontSize: 14,
                  fontFamily: FontFamily.medium,
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

  Widget _buildWarrantyDatePicker(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(
          title: 'WARRANTY ENDS',
          fontSize: 11,
          fontFamily: FontFamily.medium,
          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
        ),
        spaceH(height: 8),
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
              color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppThemeData.primary50.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.verified_outlined,
                    size: 16,
                    color: AppThemeData.primary50,
                  ),
                ),
                spaceW(width: 12),
                TextCustom(
                  title: controller.warrantyEndDate.value != null
                      ? DateFormat('MM/dd/yyyy').format(controller.warrantyEndDate.value!)
                      : 'Select date',
                  fontSize: 14,
                  fontFamily: FontFamily.medium,
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

  Widget _buildHeroImageCard(bool isDark) {
    return GestureDetector(
      onTap: controller.pickImages,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppThemeData.primary50.withValues(alpha: isDark ? 0.2 : 0.08),
              AppThemeData.primary4.withValues(alpha: isDark ? 0.1 : 0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppThemeData.primary50.withValues(alpha: 0.15),
          ),
        ),
        child: Stack(
          children: [
            // Background hint image with low opacity
            Positioned.fill(
              child: Opacity(
                opacity: 0.15,
                child: Image.asset(
                  'assets/images/add.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppThemeData.primary50.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 32,
                      color: AppThemeData.primary50,
                    ),
                  ),
                  spaceH(height: 16),
                  TextCustom(
                    title: 'Add Visual Reference',
                    fontSize: 16,
                    fontFamily: FontFamily.bold,
                    color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                  ),
                  spaceH(height: 4),
                  TextCustom(
                    title: 'Upload product images',
                    fontSize: 13,
                    fontFamily: FontFamily.regular,
                    color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadSection(bool isDark) {
    return Obx(() {
      if (controller.deviceImages.isEmpty) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextCustom(
                  title: 'SELECTED IMAGES',
                  fontSize: 12,
                  fontFamily: FontFamily.bold,
                  color: isDark ? AppThemeData.grey4 : AppThemeData.grey6,
                ),
                TextButton(
                  onPressed: controller.pickImages,
                  child: TextCustom(
                    title: 'Add More',
                    fontSize: 12,
                    fontFamily: FontFamily.semiBold,
                    color: AppThemeData.primary50,
                  ),
                ),
              ],
            ),
            spaceH(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(controller.deviceImages.length, (index) {
                return Stack(
                  children: [
                    Container(
                      width: 85,
                      height: 85,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? AppThemeData.grey7 : AppThemeData.grey3,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.memory(
                          controller.imageBytes[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => controller.removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppThemeData.danger300,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildQuickStats(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppThemeData.primary50.withValues(alpha: isDark ? 0.12 : 0.06),
            AppThemeData.primary4.withValues(alpha: isDark ? 0.06 : 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppThemeData.primary50.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextCustom(
            title: 'QUICK SUMMARY',
            fontSize: 12,
            fontFamily: FontFamily.bold,
            color: isDark ? AppThemeData.grey4 : AppThemeData.grey6,
          ),
          spaceH(height: 14),
          // Single Obx for all stats
          Obx(() => Column(
            children: [
              _buildStatRow(
                'Category',
                controller.selectedCategory.value?.name ?? '—',
                isDark,
              ),
              _buildStatRow(
                'Condition',
                controller.selectedCondition.value,
                isDark,
              ),
              _buildStatRow(
                'Payment',
                controller.selectedPaymentMethod.value?.pName ?? '—',
                isDark,
              ),
              _buildStatRow(
                'Price',
                controller.priceController.text.isNotEmpty
                    ? '\$${controller.priceController.text}'
                    : '—',
                isDark,
              ),
            ],
          )),
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
          TextCustom(
            title: label,
            fontSize: 13,
            fontFamily: FontFamily.regular,
            color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
          ),
          TextCustom(
            title: value,
            fontSize: 13,
            fontFamily: FontFamily.semiBold,
            color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              side: BorderSide(
                color: isDark ? AppThemeData.grey7 : AppThemeData.grey4,
              ),
            ),
            child: TextCustom(
              title: 'Discard',
              fontSize: 15,
              fontFamily: FontFamily.semiBold,
              color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
            ),
          ),
        ),
        spaceW(width: 12),
        Expanded(
          child: Obx(() => ElevatedButton(
            onPressed: controller.isLoading.value ? null : controller.registerDevice,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemeData.primary50,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 2,
              shadowColor: AppThemeData.primary50.withValues(alpha: 0.4),
            ),
            child: controller.isLoading.value
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_rounded, color: Colors.white, size: 18),
                spaceW(width: 8),
                TextCustom(
                  title: 'Save Device',
                  fontSize: 15,
                  fontFamily: FontFamily.bold,
                  color: Colors.white,
                ),
              ],
            ),
          )),
        ),
      ],
    );
  }
}