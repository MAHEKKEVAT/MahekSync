// lib/app/modules/my_purchases_details/views/my_purchases_details_view.dart
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/dark_theme_provider.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/mahek_loader.dart';
import 'package:maheksync/app/widgets/network_image_widget.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import '../../../models/category_model.dart';
import '../../../models/payment_method_model.dart';
import '../controllers/my_purchases_details_controller.dart';

class MyPurchasesDetailsView extends GetView<MyPurchasesDetailsController> {
  const MyPurchasesDetailsView({super.key});

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
        title: Obx(() => TextCustom(
          title: controller.purchase.value?.assetName ?? 'Purchase Details',
          fontSize: 20,
          fontFamily: FontFamily.bold,
          color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
        )),
        actions: [
          Obx(() {
            if (controller.isEditMode.value) {
              return Row(
                children: [
                  TextButton(
                    onPressed: controller.toggleEditMode,
                    child: TextCustom(
                      title: 'Cancel',
                      fontSize: 14,
                      color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: controller.isSaving.value ? null : controller.savePurchase,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppThemeData.primary50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
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
                      title: 'Save',
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  spaceW(width: 8),
                ],
              );
            } else {
              return Row(
                children: [
                  IconButton(
                    onPressed: controller.toggleEditMode,
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppThemeData.primary50.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.edit_rounded,
                        color: AppThemeData.primary50,
                        size: 20,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: controller.deletePurchase,
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppThemeData.danger300.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        color: AppThemeData.danger300,
                        size: 20,
                      ),
                    ),
                  ),
                  spaceW(width: 8),
                ],
              );
            }
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: MahekLoader(
              message: 'Loading...',
              size: 50,
              textSize: 16,
            ),
          );
        }
        return _buildContent(isDark);
      }),
    );
  }

  Widget _buildContent(bool isDark) {
    return Row(
      children: [
        // Left Panel - Images Gallery
        Container(
          width: 450,
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
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppThemeData.primary50.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.image_rounded,
                      color: AppThemeData.primary50,
                      size: 22,
                    ),
                  ),
                  spaceW(width: 12),
                  TextCustom(
                    title: 'Gallery',
                    fontSize: 18,
                    fontFamily: FontFamily.bold,
                    color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                  ),
                  const Spacer(),
                  if (controller.isEditMode.value)
                    TextButton.icon(
                      onPressed: controller.pickImages,
                      icon: Icon(Icons.add_photo_alternate_rounded, color: AppThemeData.primary50, size: 18),
                      label: TextCustom(
                        title: 'Add Images',
                        fontSize: 13,
                        color: AppThemeData.primary50,
                      ),
                    ),
                ],
              ),
              spaceH(height: 20),
              Expanded(
                child: _buildImageGallery(isDark),
              ),
            ],
          ),
        ),
        // Right Panel - Details
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusCard(isDark),
                spaceH(height: 24),
                _buildIdentitySection(isDark),
                spaceH(height: 24),
                _buildFinancialSection(isDark),
                spaceH(height: 24),
                _buildLogisticsSection(isDark),
                spaceH(height: 24),
                _buildDescriptionSection(isDark),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageGallery(bool isDark) {
    return Obx(() {
      final existingImages = controller.existingImages;
      final newImageBytes = controller.newImageBytes;

      if (existingImages.isEmpty && newImageBytes.isEmpty) {
        return _buildEmptyGallery(isDark);
      }

      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 180,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemCount: existingImages.length + newImageBytes.length,
        itemBuilder: (context, index) {
          if (index < existingImages.length) {
            return _buildImageTile(
              isDark,
              networkUrl: existingImages[index],
              onRemove: controller.isEditMode.value
                  ? () => controller.removeExistingImage(existingImages[index])
                  : null,
            );
          } else {
            final newIndex = index - existingImages.length;
            return _buildImageTile(
              isDark,
              memoryImage: newImageBytes[newIndex],
              onRemove: () => controller.removeNewImage(newIndex),
            );
          }
        },
      );
    });
  }

  Widget _buildEmptyGallery(bool isDark) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 64,
              color: isDark ? AppThemeData.grey7 : AppThemeData.grey4,
            ),
            spaceH(height: 16),
            TextCustom(
              title: 'No images',
              fontSize: 16,
              fontFamily: FontFamily.medium,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            ),
            if (controller.isEditMode.value) ...[
              spaceH(height: 8),
              ElevatedButton.icon(
                onPressed: controller.pickImages,
                icon: const Icon(Icons.add_photo_alternate_rounded, size: 18),
                label: TextCustom(
                  title: 'Add Images',
                  fontSize: 13,
                  color: Colors.white,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppThemeData.primary50,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImageTile(
      bool isDark, {
        Uint8List? memoryImage,
        String? networkUrl,
        VoidCallback? onRemove,
      }) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: memoryImage != null
                ? Image.memory(
              memoryImage,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            )
                : networkUrl != null
                ? NetworkImageWidget(
              imageUrl: networkUrl,
              fit: BoxFit.cover,
            )
                : const SizedBox(),
          ),
        ),
        if (onRemove != null)
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppThemeData.danger300,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusCard(bool isDark) {
    return Obx(() => Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (controller.purchase.value?.statusColor ?? Colors.grey).withValues(alpha: 0.12),
            (controller.purchase.value?.statusColor ?? Colors.grey).withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (controller.purchase.value?.statusColor ?? Colors.grey).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (controller.purchase.value?.statusColor ?? Colors.grey).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.shopping_bag_rounded,
              color: controller.purchase.value?.statusColor,
              size: 24,
            ),
          ),
          spaceW(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextCustom(
                title: 'Status',
                fontSize: 12,
                fontFamily: FontFamily.medium,
                color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
              ),
              spaceH(height: 4),
              if (controller.isEditMode.value)
                _buildStatusDropdown(isDark)
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: (controller.purchase.value?.statusColor ?? Colors.grey).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextCustom(
                    title: controller.purchase.value?.status ?? 'DELIVERED',
                    fontSize: 16,
                    fontFamily: FontFamily.bold,
                    color: controller.purchase.value?.statusColor,
                  ),
                ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextCustom(
                title: 'Total Value',
                fontSize: 12,
                fontFamily: FontFamily.medium,
                color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
              ),
              spaceH(height: 4),
              TextCustom(
                title: '₹${(controller.purchase.value?.price ?? 0).toStringAsFixed(2)}',
                fontSize: 24,
                fontFamily: FontFamily.bold,
                color: AppThemeData.primary50,
              ),
            ],
          ),
        ],
      ),
    ));
  }

  Widget _buildStatusDropdown(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
          width: 0.5,
        ),
      ),
      child: DropdownButton<String>(
        value: controller.selectedStatus.value,
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: isDark ? AppThemeData.grey9 : AppThemeData.primaryWhite,
        items: controller.statuses.map((s) {
          return DropdownMenuItem(
            value: s,
            child: Text(
              s,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              ),
            ),
          );
        }).toList(),
        onChanged: (v) => controller.selectedStatus.value = v!,
      ),
    );
  }

  Widget _buildIdentitySection(bool isDark) {
    return _buildSection(
      title: 'Identity & Origin',
      icon: Icons.inventory_2_outlined,
      isDark: isDark,
      child: Column(
        children: [
          _buildDetailRow(
            label: 'Asset Name',
            value: controller.purchase.value?.assetName ?? '—',
            textController: controller.assetNameController,
            isDark: isDark,
            isEditMode: controller.isEditMode.value,
          ),
          spaceH(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDetailRow(
                  label: 'Brand',
                  value: controller.purchase.value?.brand ?? '—',
                  textController: controller.brandController,
                  isDark: isDark,
                  isEditMode: controller.isEditMode.value,
                ),
              ),
              spaceW(width: 16),
              Expanded(
                child: _buildCategoryField(isDark),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(
          title: 'Category',
          fontSize: 12,
          fontFamily: FontFamily.medium,
          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
        ),
        spaceH(height: 8),
        if (controller.isEditMode.value)
          _buildCategoryDropdown(isDark)
        else
          Obx(() => Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppThemeData.primary50.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: controller.selectedCategory.value?.iconUrl != null &&
                    controller.selectedCategory.value!.iconUrl!.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: NetworkImageWidget(
                    imageUrl: controller.selectedCategory.value!.iconUrl!,
                    fit: BoxFit.cover,
                  ),
                )
                    : Icon(
                  Icons.category_rounded,
                  color: AppThemeData.primary50,
                  size: 18,
                ),
              ),
              spaceW(width: 10),
              TextCustom(
                title: controller.selectedCategory.value?.name ?? controller.purchase.value?.category ?? '—',
                fontSize: 15,
                fontFamily: FontFamily.semiBold,
                color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              ),
            ],
          )),
      ],
    );
  }

  Widget _buildCategoryDropdown(bool isDark) {
    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
        borderRadius: BorderRadius.circular(12),
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
            color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
          ),
        ),
        items: controller.categories.map((c) {
          return DropdownMenuItem(
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
                spaceW(width: 10),
                Text(c.name ?? 'Unknown'),
              ],
            ),
          );
        }).toList(),
        onChanged: (v) => controller.selectedCategory.value = v,
      ),
    ));
  }

  Widget _buildFinancialSection(bool isDark) {
    return _buildSection(
      title: 'Financial Data',
      icon: Icons.attach_money_rounded,
      isDark: isDark,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDetailRow(
                  label: 'Price',
                  value: '₹${controller.purchase.value?.price?.toStringAsFixed(2) ?? '0.00'}',
                  textController: controller.priceController,
                  isDark: isDark,
                  isEditMode: controller.isEditMode.value, // Add this
                  isPrice: true,
                ),
              ),

              spaceW(width: 16),
              Expanded(
                child: _buildPaymentMethodField(isDark),
              ),
            ],
          ),
          spaceH(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  label: 'Purchase Date',
                  date: controller.purchaseDate,
                  isDark: isDark,
                ),
              ),
              spaceW(width: 16),
              Expanded(
                child: _buildDateField(
                  label: 'Warranty Date',
                  date: controller.warrantyDate,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(
          title: 'Payment Method',
          fontSize: 12,
          fontFamily: FontFamily.medium,
          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
        ),
        spaceH(height: 8),
        if (controller.isEditMode.value)
          _buildPaymentMethodDropdown(isDark)
        else
          Obx(() => Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppThemeData.primary50.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: controller.selectedPaymentMethod.value?.pIcon != null &&
                    controller.selectedPaymentMethod.value!.pIcon!.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: NetworkImageWidget(
                    imageUrl: controller.selectedPaymentMethod.value!.pIcon!,
                    fit: BoxFit.cover,
                  ),
                )
                    : Icon(
                  Icons.payment_rounded,
                  color: AppThemeData.primary50,
                  size: 18,
                ),
              ),
              spaceW(width: 10),
              TextCustom(
                title: controller.selectedPaymentMethod.value?.pName ??
                    controller.purchase.value?.paymentMethod ?? '—',
                fontSize: 15,
                fontFamily: FontFamily.semiBold,
                color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              ),
            ],
          )),
      ],
    );
  }

  Widget _buildPaymentMethodDropdown(bool isDark) {
    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
          width: 0.5,
        ),
      ),
      child: DropdownButton<PaymentMethodModel>(
        value: controller.selectedPaymentMethod.value,
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: isDark ? AppThemeData.grey9 : AppThemeData.primaryWhite,
        hint: Text(
          'Select Method',
          style: TextStyle(
            color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
          ),
        ),
        items: controller.paymentMethods.map((m) {
          return DropdownMenuItem(
            value: m,
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppThemeData.primary50.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: m.pIcon != null && m.pIcon!.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: NetworkImageWidget(
                      imageUrl: m.pIcon!,
                      fit: BoxFit.cover,
                    ),
                  )
                      : Icon(
                    Icons.payment_rounded,
                    color: AppThemeData.primary50,
                    size: 16,
                  ),
                ),
                spaceW(width: 10),
                Text(m.pName ?? 'Unknown'),
              ],
            ),
          );
        }).toList(),
        onChanged: (v) => controller.selectedPaymentMethod.value = v,
      ),
    ));
  }

  Widget _buildDateField({
    required String label,
    required Rx<DateTime?> date,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(
          title: label,
          fontSize: 12,
          fontFamily: FontFamily.medium,
          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
        ),
        spaceH(height: 8),
        if (controller.isEditMode.value)
          GestureDetector(
            onTap: () async {
              final selected = await showDatePicker(
                context: Get.context!,
                initialDate: date.value ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2030),
              );
              if (selected != null) {
                if (label.contains('Warranty')) {
                  controller.setWarrantyDate(selected);
                } else {
                  controller.setPurchaseDate(selected);
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: AppThemeData.primary50,
                  ),
                  spaceW(width: 10),
                  TextCustom(
                    title: date.value != null
                        ? DateFormat('MM/dd/yyyy').format(date.value!)
                        : 'Select date',
                    fontSize: 14,
                    color: date.value != null
                        ? (isDark ? AppThemeData.grey1 : AppThemeData.grey10)
                        : (isDark ? AppThemeData.grey6 : AppThemeData.grey5),
                  ),
                ],
              ),
            ),
          )
        else
          TextCustom(
            title: date.value != null
                ? DateFormat('MM/dd/yyyy').format(date.value!)
                : '—',
            fontSize: 15,
            fontFamily: FontFamily.semiBold,
            color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
          ),
      ],
    );
  }

  Widget _buildLogisticsSection(bool isDark) {
    return _buildSection(
      title: 'Logistics & State',
      icon: Icons.local_shipping_outlined,
      isDark: isDark,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDetailRow(
                  label: 'Size',
                  value: controller.purchase.value?.size ?? '—',
                  textController: controller.sizeController,
                  isDark: isDark,
                  isEditMode: controller.isEditMode.value, // Add this
                ),
              ),
              spaceW(width: 16),
              Expanded(
                child: _buildDetailRow(
                  label: 'Store / Location',
                  value: controller.purchase.value?.storeLocation ?? '—',
                  textController: controller.storeLocationController,
                  isDark: isDark,
                  isEditMode: controller.isEditMode.value, // Add this
                ),
              ),
            ],
          ),
          spaceH(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildConditionField(isDark),
              ),
              spaceW(width: 16),
              Expanded(
                child: _buildDetailRow(
                  label: 'Units',
                  value: '${controller.purchase.value?.units ?? 1}',
                  textController: controller.unitsController,
                  isDark: isDark,
                  isEditMode: controller.isEditMode.value, // Add this
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConditionField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(
          title: 'Condition',
          fontSize: 12,
          fontFamily: FontFamily.medium,
          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
        ),
        spaceH(height: 8),
        if (controller.isEditMode.value)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
                width: 0.5,
              ),
            ),
            child: DropdownButton<String>(
              value: controller.selectedCondition.value,
              isExpanded: true,
              underline: const SizedBox(),
              items: controller.conditions.map((c) {
                return DropdownMenuItem(
                  value: c,
                  child: Text(c),
                );
              }).toList(),
              onChanged: (v) => controller.selectedCondition.value = v!,
            ),
          )
        else
          TextCustom(
            title: controller.purchase.value?.condition ?? '—',
            fontSize: 15,
            fontFamily: FontFamily.semiBold,
            color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
          ),
      ],
    );
  }

  Widget _buildDescriptionSection(bool isDark) {
    return _buildSection(
      title: 'Description',
      icon: Icons.description_outlined,
      isDark: isDark,
      child: controller.isEditMode.value
          ? TextField(
        controller: controller.descriptionController,
        maxLines: 4,
        style: TextStyle(
          fontSize: 14,
          color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
        ),
        decoration: InputDecoration(
          hintText: 'Describe your purchase...',
          hintStyle: TextStyle(
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
            borderSide: BorderSide(
              color: AppThemeData.primary50,
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.all(14),
        ),
      )
          : TextCustom(
        title: controller.purchase.value?.description ?? 'No description provided',
        fontSize: 14,
        fontFamily: FontFamily.regular,
        color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    required TextEditingController textController,
    required bool isDark,
    required bool isEditMode, // Add this parameter
    bool isPrice = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(
          title: label,
          fontSize: 12,
          fontFamily: FontFamily.medium,
          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
        ),
        spaceH(height: 8),
        if (isEditMode) // Use the parameter instead of controller.isEditMode
          TextField(
            controller: textController,
            style: TextStyle(
              fontSize: 15,
              fontFamily: FontFamily.semiBold,
              color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
            ),
            decoration: InputDecoration(
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
                borderSide: BorderSide(
                  color: AppThemeData.primary50,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            keyboardType: isPrice ? TextInputType.number : TextInputType.text,
          )
        else
          TextCustom(
            title: value,
            fontSize: 15,
            fontFamily: FontFamily.semiBold,
            color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
          ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required bool isDark,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
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
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppThemeData.primary50.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: AppThemeData.primary50,
                  size: 18,
                ),
              ),
              spaceW(width: 12),
              TextCustom(
                title: title,
                fontSize: 16,
                fontFamily: FontFamily.bold,
                color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              ),
            ],
          ),
          spaceH(height: 20),
          child,
        ],
      ),
    );
  }
}