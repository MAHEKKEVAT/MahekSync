import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:maheksync/app/models/category_model.dart';
import 'package:maheksync/app/models/payment_method_model.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/utils/mahek_responsive.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/network_image_widget.dart';
import 'package:maheksync/app/widgets/text_field_widget.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import '../controllers/add_edit_purchase_controller.dart';

class AddEditPurchaseView extends GetView<AddEditPurchaseController> {
  const AddEditPurchaseView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = context.isMobile;

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
        title: Obx(
          () => TextCustom(
            title: controller.isEditMode.value ? 'Edit Purchase' : 'Add Purchase',
            fontSize: isMobile ? 18 : 22,
            fontFamily: FontFamily.bold,
            color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
          ),
        ),
        actions: [
          Obx(() {
            if (controller.isLoading.value) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppThemeData.primary50),
                ),
              );
            }
            return TextButton(
              onPressed: controller.savePurchase,
              child: TextCustom(
                title: 'Save',
                fontSize: 15,
                fontFamily: FontFamily.semiBold,
                color: AppThemeData.primary50,
              ),
            );
          }),
        ],
      ),
      body: isMobile ? _buildMobileLayout(isDark, context) : _buildDesktopLayout(isDark, context),
    );
  }

  Widget _buildDesktopLayout(bool isDark, BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _buildFormPanel(isDark, context: context),
        ),
        _buildImagePanel(isDark),
      ],
    );
  }

  Widget _buildMobileLayout(bool isDark, BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFormCard(isDark, context: context),
          spaceH(height: 16),
          _buildMobileImageSection(isDark),
          spaceH(height: 20),
          _buildMobileActionButtons(isDark),
        ],
      ),
    );
  }

  Widget _buildFormPanel(bool isDark, {required BuildContext context}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: _buildFormCard(isDark, context: context),
    );
  }

  Widget _buildFormCard(bool isDark, {required BuildContext context}) {
    return Container(
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
          _buildHeader(isDark),
          spaceH(height: 28),
          _buildSectionTitle('IDENTITY & ORIGIN', Icons.inventory_2_outlined, isDark),
          spaceH(height: 16),
          TextFieldWidget(
            title: 'ASSET NAME',
            controller: controller.assetNameController,
            hintText: 'e.g. Minimalist Aluminum Structure',
            onPress: () {},
            prefix: _buildIconBox(Icons.shopping_bag_rounded),
          ),
          spaceH(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFieldWidget(
                  title: 'BRAND',
                  controller: controller.brandController,
                  hintText: 'Studio Kinetic',
                  onPress: () {},
                  prefix: _buildIconBox(Icons.business_outlined),
                ),
              ),
              spaceW(width: 16),
              Expanded(child: _buildCategoryDropdown(isDark)),
            ],
          ),
          spaceH(height: 28),
          _buildSectionTitle('FINANCIAL DATA', Icons.attach_money_rounded, isDark),
          spaceH(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFieldWidget(
                  title: 'PRICE (USD)',
                  controller: controller.priceController,
                  hintText: '0.00',
                  onPress: () {},
                  textInputType: TextInputType.number,
                  prefix: _buildIconBox(Icons.attach_money_rounded),
                ),
              ),
              spaceW(width: 16),
              Expanded(child: _buildPaymentMethodDropdown(isDark)),
            ],
          ),
          spaceH(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDatePicker('PURCHASE DATE', controller.purchaseDate, isDark, context: context),
              ),
              spaceW(width: 16),
              Expanded(
                child: _buildDatePicker('WARRANTY DATE', controller.warrantyDate, isDark, isWarranty: true, context: context),
              ),
            ],
          ),
          spaceH(height: 28),
          _buildSectionTitle('LOGISTICS & STATE', Icons.local_shipping_outlined, isDark),
          spaceH(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFieldWidget(
                  title: 'SIZE',
                  controller: controller.sizeController,
                  hintText: 'XL / 500L',
                  onPress: () {},
                  prefix: _buildIconBox(Icons.straighten_outlined),
                ),
              ),
              spaceW(width: 16),
              Expanded(
                child: TextFieldWidget(
                  title: 'STORE / LOCATION',
                  controller: controller.storeLocationController,
                  hintText: 'Warehouse 7',
                  onPress: () {},
                  prefix: _buildIconBox(Icons.store_outlined),
                ),
              ),
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
              Expanded(
                child: TextFieldWidget(
                  title: 'UNITS',
                  controller: controller.unitsController,
                  hintText: '1',
                  onPress: () {},
                  textInputType: TextInputType.number,
                  prefix: _buildIconBox(Icons.numbers_rounded),
                ),
              ),
              spaceW(width: 16),
              const Expanded(child: SizedBox()),
            ],
          ),
          spaceH(height: 28),
          _buildSectionTitle('DESCRIPTION', Icons.description_outlined, isDark),
          spaceH(height: 16),
          TextFieldWidget(
            title: 'DESCRIPTION',
            controller: controller.descriptionController,
            hintText: 'Describe your purchase...',
            onPress: () {},
            line: 4,
            prefix: _buildIconBox(Icons.description_outlined),
          ),
        ],
      ),
    );
  }

  Widget _buildIconBox(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: AppThemeData.primary50.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: AppThemeData.primary50, size: 18),
    );
  }

  Widget _buildImagePanel(bool isDark) {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
        border: Border(
          left: BorderSide(
            color: isDark ? AppThemeData.grey9 : AppThemeData.grey3,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextCustom(
            title: 'Visual Documentation',
            fontSize: 18,
            fontFamily: FontFamily.bold,
            color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
          ),
          spaceH(height: 8),
          TextCustom(
            title: 'Upload images to document this purchase.',
            fontSize: 13,
            color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
          ),
          spaceH(height: 20),
          _buildImageUploadArea(isDark),
          spaceH(height: 20),
          _buildImageGrid(isDark),
          spaceH(height: 20),
          _buildEditorialRequirement(isDark),
          const Spacer(),
          spaceH(height: 24),
          _buildDesktopActionButtons(isDark),
        ],
      ),
    );
  }

  Widget _buildMobileImageSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          _buildSectionTitle('VISUAL DOCUMENTATION', Icons.photo_library_outlined, isDark),
          spaceH(height: 16),
          _buildImageUploadArea(isDark),
          spaceH(height: 16),
          _buildImageGrid(isDark),
          spaceH(height: 16),
          _buildEditorialRequirement(isDark),
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
            gradient: LinearGradient(
              colors: [AppThemeData.primary50, AppThemeData.primary4],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.add_shopping_cart_rounded, color: Colors.white, size: 26),
        ),
        spaceW(width: 14),
        Expanded(
          child: Column(
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
        ),
      ],
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
          child: Icon(icon, color: AppThemeData.primary50, size: 16),
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
          decoration: _dropdownDecoration(isDark),
          child: DropdownButton<CategoryModel>(
            value: controller.selectedCategory.value,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: isDark ? AppThemeData.grey9 : AppThemeData.primaryWhite,
            hint: _dropdownHint('Select Category', isDark),
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
                              child: NetworkImageWidget(imageUrl: c.iconUrl!, fit: BoxFit.cover),
                            )
                          : Icon(Icons.category_rounded, color: AppThemeData.primary50, size: 16),
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
        TextCustom(
          title: 'PAYMENT METHOD',
          fontSize: 11,
          fontFamily: FontFamily.medium,
          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
        ),
        spaceH(height: 8),
        Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: _dropdownDecoration(isDark),
          child: DropdownButton<PaymentMethodModel>(
            value: controller.selectedPaymentMethod.value,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: isDark ? AppThemeData.grey9 : AppThemeData.primaryWhite,
            hint: _dropdownHint('Select Method', isDark),
            items: controller.paymentMethods.map((m) {
              return DropdownMenuItem<PaymentMethodModel>(
                value: m,
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppThemeData.neonMint.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: m.pIcon != null && m.pIcon!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: NetworkImageWidget(imageUrl: m.pIcon!, fit: BoxFit.cover),
                            )
                          : Icon(Icons.payment_rounded, color: AppThemeData.neonMint, size: 16),
                    ),
                    spaceW(width: 12),
                    Expanded(
                      child: Text(
                        m.pName ?? 'Unknown',
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
        TextCustom(
          title: 'CONDITION',
          fontSize: 11,
          fontFamily: FontFamily.medium,
          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
        ),
        spaceH(height: 8),
        Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: _dropdownDecoration(isDark),
          child: DropdownButton<String>(
            value: controller.selectedCondition.value,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: isDark ? AppThemeData.grey9 : AppThemeData.primaryWhite,
            items: controller.conditions.map((c) {
              return DropdownMenuItem<String>(
                value: c,
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: _getConditionColor(c).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(_getConditionIcon(c), color: _getConditionColor(c), size: 16),
                    ),
                    spaceW(width: 12),
                    Text(
                      c,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: FontFamily.medium,
                        color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
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
        TextCustom(
          title: 'STATUS',
          fontSize: 11,
          fontFamily: FontFamily.medium,
          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
        ),
        spaceH(height: 8),
        Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: _dropdownDecoration(isDark),
          child: DropdownButton<String>(
            value: controller.selectedStatus.value,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: isDark ? AppThemeData.grey9 : AppThemeData.primaryWhite,
            items: controller.statuses.map((s) {
              final color = _getStatusColor(s);
              return DropdownMenuItem<String>(
                value: s,
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(_getStatusIcon(s), color: color, size: 16),
                    ),
                    spaceW(width: 12),
                    Text(
                      s,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: FontFamily.medium,
                        color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (v) => controller.selectedStatus.value = v!,
          ),
        )),
      ],
    );
  }

  Widget _buildDatePicker(String label, Rxn<DateTime> date, bool isDark, {bool isWarranty = false, required BuildContext context}) {
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
        Obx(() => GestureDetector(
          onTap: () async {
            final selected = await showDatePicker(
              context: context,
              initialDate: isWarranty ? DateTime.now().add(const Duration(days: 365)) : (date.value ?? DateTime.now()),
              firstDate: DateTime(2000),
              lastDate: DateTime(2030),
              builder: (c, child) => Theme(
                data: Theme.of(c).copyWith(
                  colorScheme: ColorScheme.dark(
                    primary: AppThemeData.primary50,
                    onPrimary: Colors.white,
                    surface: isDark ? AppThemeData.grey9 : Colors.white,
                    onSurface: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                  ),
                ),
                child: child!,
              ),
            );
            if (selected != null) {
              isWarranty ? controller.setWarrantyDate(selected) : controller.setPurchaseDate(selected);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: _dropdownDecoration(isDark),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 16, color: AppThemeData.primary50),
                spaceW(width: 12),
                Expanded(
                  child: Text(
                    date.value != null ? DateFormat('dd MMM yyyy').format(date.value!) : 'Select date',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: FontFamily.medium,
                      color: date.value != null
                          ? (isDark ? AppThemeData.grey1 : AppThemeData.grey10)
                          : (isDark ? AppThemeData.grey6 : AppThemeData.grey5),
                    ),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
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
        height: 130,
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppThemeData.primary50.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppThemeData.primary50.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.cloud_upload_outlined, size: 26, color: AppThemeData.primary50),
            ),
            spaceH(height: 10),
            TextCustom(
              title: 'Browse Media',
              fontSize: 14,
              fontFamily: FontFamily.semiBold,
              color: AppThemeData.primary50,
            ),
            TextCustom(
              title: 'PNG, JPG up to 10MB',
              fontSize: 11,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid(bool isDark) {
    return Obx(() {
      final existingUrls = controller.editingPurchase.value?.imageUrls ?? [];
      final newImages = controller.imageBytes;

      if (existingUrls.isEmpty && newImages.isEmpty) {
        return const SizedBox.shrink();
      }

      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          ...existingUrls.asMap().entries.map(
            (entry) => _buildImageTile(
              isDark,
              networkUrl: entry.value,
              existingIndex: entry.key,
            ),
          ),
          ...newImages.asMap().entries.map(
            (entry) => _buildImageTile(
              isDark,
              memoryImage: entry.value,
              newIndex: entry.key,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildImageTile(
    bool isDark, {
    Uint8List? memoryImage,
    String? networkUrl,
    int? existingIndex,
    int? newIndex,
  }) {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppThemeData.grey7 : AppThemeData.grey3,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: memoryImage != null
                ? Image.memory(memoryImage, fit: BoxFit.cover)
                : networkUrl != null
                    ? NetworkImageWidget(imageUrl: networkUrl, fit: BoxFit.cover)
                    : const SizedBox(),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () {
              if (newIndex != null) {
                controller.removeImage(newIndex);
              } else if (existingIndex != null) {
                controller.removeExistingImage(existingIndex);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppThemeData.danger300,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditorialRequirement(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeData.primary50.withValues(alpha: isDark ? 0.12 : 0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppThemeData.primary50, size: 20),
          spaceW(width: 12),
          Expanded(
            child: TextCustom(
              title: 'At least three images are required for new purchases. One image minimum for edits.',
              fontSize: 12,
              color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopActionButtons(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: controller.discardChanges,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              side: BorderSide(
                color: isDark ? AppThemeData.grey7 : AppThemeData.grey3,
              ),
            ),
            child: TextCustom(
              title: 'Discard',
              fontSize: 15,
              color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
            ),
          ),
        ),
        spaceW(width: 12),
        Expanded(
          child: Obx(() => GestureDetector(
            onTap: controller.isLoading.value ? null : controller.savePurchase,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppThemeData.primary50, AppThemeData.primary4],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppThemeData.primary50.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : TextCustom(
                        title: controller.isEditMode.value ? 'Update Purchase' : 'Complete Entry',
                        fontSize: 15,
                        fontFamily: FontFamily.semiBold,
                        color: Colors.white,
                      ),
              ),
            ),
          )),
        ),
      ],
    );
  }

  Widget _buildMobileActionButtons(bool isDark) {
    return Obx(() => GestureDetector(
      onTap: controller.isLoading.value ? null : controller.savePurchase,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppThemeData.primary50, AppThemeData.primary4],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppThemeData.primary50.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
        child: controller.isLoading.value
            ? const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : TextCustom(
                title: controller.isEditMode.value ? 'Update Purchase' : 'Complete Entry',
                fontSize: 15,
                fontFamily: FontFamily.semiBold,
                color: Colors.white,
              ),
        ),
      ),
    ));
  }

  BoxDecoration _dropdownDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
        width: 0.5,
      ),
    );
  }

  Widget _dropdownHint(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontFamily: FontFamily.regular,
        color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
      ),
    );
  }

  Color _getConditionColor(String condition) {
    switch (condition) {
      case 'Pristine':
        return const Color(0xFF10B981);
      case 'Excellent':
        return const Color(0xFF3B82F6);
      case 'Good':
        return const Color(0xFFF59E0B);
      case 'Fair':
        return const Color(0xFFEF4444);
      default:
        return AppThemeData.grey5;
    }
  }

  IconData _getConditionIcon(String condition) {
    switch (condition) {
      case 'Pristine':
        return Icons.auto_awesome;
      case 'Excellent':
        return Icons.star_rounded;
      case 'Good':
        return Icons.thumb_up_outlined;
      case 'Fair':
        return Icons.warning_amber_rounded;
      default:
        return Icons.help_outline;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'DELIVERED':
        return const Color(0xFF10B981);
      case 'IN TRANSIT':
        return const Color(0xFFF59E0B);
      case 'PRE-ORDER':
        return const Color(0xFF3B82F6);
      default:
        return AppThemeData.grey5;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'DELIVERED':
        return Icons.check_circle_outline;
      case 'IN TRANSIT':
        return Icons.local_shipping_outlined;
      case 'PRE-ORDER':
        return Icons.schedule;
      default:
        return Icons.help_outline;
    }
  }
}
