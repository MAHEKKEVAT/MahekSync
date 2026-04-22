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

    final selectedImageIndex = 0.obs;



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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Gallery Section at Top
          _buildMainImageGallery(isDark),
          spaceH(height: 24),

          // Status Card
          _buildStatusCard(isDark),
          spaceH(height: 24),

          // Details Grid
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildIdentitySection(isDark),
              ),
              spaceW(width: 20),
              Expanded(
                child: _buildFinancialSection(isDark),
              ),
            ],
          ),
          spaceH(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildLogisticsSection(isDark),
              ),
              spaceW(width: 20),
              Expanded(
                child: _buildDescriptionSection(isDark),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainImageGallery(bool isDark) {
    return Obx(() {
      final existingImages = controller.existingImages;
      final newImageBytes = controller.newImageBytes;

      // Combine all images for display
      final allImages = <ImageItem>[];
      for (var url in existingImages) {
        allImages.add(ImageItem(networkUrl: url));
      }
      for (var bytes in newImageBytes) {
        allImages.add(ImageItem(memoryImage: bytes));
      }

      return Container(
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            // Main Image Display
            Container(
              height: 400,
              decoration: BoxDecoration(
                color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Obx(() {
                final selectedIndex = controller.selectedImageIndex.value;
                if (allImages.isEmpty) {
                  return _buildEmptyMainImage(isDark);
                }

                final selectedImage = allImages[selectedIndex.clamp(0, allImages.length - 1)];
                return Stack(
                  children: [
                    // Main Image
                    Center(
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: selectedImage.networkUrl != null
                              ? NetworkImageWidget(
                            imageUrl: selectedImage.networkUrl!,
                            fit: BoxFit.contain,
                          )
                              : selectedImage.memoryImage != null
                              ? Image.memory(
                            selectedImage.memoryImage!,
                            fit: BoxFit.contain,
                          )
                              : const SizedBox(),
                        ),
                      ),
                    ),

                    // Navigation Arrows
                    if (allImages.length > 1) ...[
                      Positioned(
                        left: 16,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: _buildNavButton(
                            icon: Icons.chevron_left_rounded,
                            onTap: () => controller.previousImage(),
                            isDark: isDark,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 16,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: _buildNavButton(
                            icon: Icons.chevron_right_rounded,
                            onTap: () => controller.nextImage(),
                            isDark: isDark,
                          ),
                        ),
                      ),
                    ],

                    // Image Counter
                    if (allImages.length > 1)
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextCustom(
                            title: '${selectedIndex + 1} / ${allImages.length}',
                            fontSize: 13,
                            fontFamily: FontFamily.medium,
                            color: Colors.white,
                          ),
                        ),
                      ),

                    // Add Image Button (Edit Mode)
                    if (controller.isEditMode.value)
                      Positioned(
                        top: 16,
                        right: 16,
                        child: GestureDetector(
                          onTap: controller.pickImages,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppThemeData.primary50,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppThemeData.primary50.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add_photo_alternate_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ),

            // Thumbnail Strip
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
                    width: 0.5,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 18,
                        decoration: BoxDecoration(
                          color: AppThemeData.primary50,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      spaceW(width: 10),
                      TextCustom(
                        title: 'Gallery (${allImages.length} images)',
                        fontSize: 14,
                        fontFamily: FontFamily.bold,
                        color: isDark ? AppThemeData.grey3 : AppThemeData.grey7,
                      ),
                      const Spacer(),
                      if (controller.isEditMode.value)
                        TextButton.icon(
                          onPressed: controller.pickImages,
                          icon: Icon(Icons.add_rounded, color: AppThemeData.primary50, size: 16),
                          label: TextCustom(
                            title: 'Add More',
                            fontSize: 12,
                            color: AppThemeData.primary50,
                          ),
                        ),
                    ],
                  ),
                  spaceH(height: 12),
                  if (allImages.isEmpty)
                    _buildEmptyThumbnails(isDark)
                  else
                    SizedBox(
                      height: 80,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: allImages.length,
                        separatorBuilder: (_, __) => spaceW(width: 10),
                        itemBuilder: (context, index) {
                          return _buildThumbnail(
                            image: allImages[index],
                            index: index,
                            isSelected: controller.selectedImageIndex.value == index,
                            isDark: isDark,
                            onRemove: controller.isEditMode.value
                                ? () {
                              if (index < existingImages.length) {
                                controller.removeExistingImage(existingImages[index]);
                              } else {
                                controller.removeNewImage(index - existingImages.length);
                              }
                              // Update selected index if needed
                              if (controller.selectedImageIndex.value >= allImages.length - 1) {
                                controller.selectedImageIndex.value = (allImages.length - 2).clamp(0, allImages.length - 1);
                              }
                            }
                                : null,
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Icon(
          icon,
          color: isDark ? Colors.white : Colors.black,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildEmptyMainImage(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 80,
            color: isDark ? AppThemeData.grey7 : AppThemeData.grey4,
          ),
          spaceH(height: 16),
          TextCustom(
            title: 'No images available',
            fontSize: 16,
            fontFamily: FontFamily.medium,
            color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
          ),
          if (controller.isEditMode.value) ...[
            spaceH(height: 12),
            ElevatedButton.icon(
              onPressed: controller.pickImages,
              icon: const Icon(Icons.add_photo_alternate_rounded),
              label: TextCustom(
                title: 'Add Images',
                fontSize: 14,
                color: Colors.white,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemeData.primary50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyThumbnails(bool isDark) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: TextCustom(
          title: 'No images uploaded yet',
          fontSize: 13,
          color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
        ),
      ),
    );
  }

  Widget _buildThumbnail({
    required ImageItem image,
    required int index,
    required bool isSelected,
    required bool isDark,
    VoidCallback? onRemove,
  }) {
    return GestureDetector(
      onTap: () => controller.selectedImageIndex.value = index,
      child: Container(
        width: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppThemeData.primary50 : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: AppThemeData.primary50.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppThemeData.grey8 : AppThemeData.grey2,
                ),
                child: image.networkUrl != null
                    ? NetworkImageWidget(
                  imageUrl: image.networkUrl!,
                  fit: BoxFit.cover,
                  height: 80,
                  width: 80,
                )
                    : image.memoryImage != null
                    ? Image.memory(
                  image.memoryImage!,
                  fit: BoxFit.cover,
                  height: 80,
                  width: 80,
                )
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
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppThemeData.danger300,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ),
            if (isSelected)
              Positioned(
                bottom: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppThemeData.primary50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (controller.purchase.value?.statusColor ?? Colors.grey).withValues(alpha: 0.2),
                  (controller.purchase.value?.statusColor ?? Colors.grey).withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.shopping_bag_rounded,
              color: controller.purchase.value?.statusColor,
              size: 28,
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
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
                fontSize: 28,
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
    return _buildSectionCard(
      title: 'Identity & Origin',
      icon: Icons.inventory_2_outlined,
      color: AppThemeData.primary50,
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
          _buildDetailRow(
            label: 'Brand',
            value: controller.purchase.value?.brand ?? '—',
            textController: controller.brandController,
            isDark: isDark,
            isEditMode: controller.isEditMode.value,
          ),
          spaceH(height: 16),
          _buildCategoryField(isDark),
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
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppThemeData.primary50.withValues(alpha: 0.15),
                      AppThemeData.primary4.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: controller.selectedCategory.value?.iconUrl != null &&
                    controller.selectedCategory.value!.iconUrl!.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: NetworkImageWidget(
                    imageUrl: controller.selectedCategory.value!.iconUrl!,
                    fit: BoxFit.cover,
                  ),
                )
                    : Icon(
                  Icons.category_rounded,
                  color: AppThemeData.primary50,
                  size: 20,
                ),
              ),
              spaceW(width: 12),
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
    return _buildSectionCard(
      title: 'Financial Data',
      icon: Icons.attach_money_rounded,
      color: AppThemeData.success400,
      isDark: isDark,
      child: Column(
        children: [
          _buildDetailRow(
            label: 'Price',
            value: '₹${controller.purchase.value?.price?.toStringAsFixed(2) ?? '0.00'}',
            textController: controller.priceController,
            isDark: isDark,
            isEditMode: controller.isEditMode.value,
            isPrice: true,
            valueColor: AppThemeData.primary50,
          ),
          spaceH(height: 16),
          _buildPaymentMethodField(isDark),
          spaceH(height: 16),
          _buildDateField(
            label: 'Purchase Date',
            date: controller.purchaseDate,
            isDark: isDark,
          ),
          spaceH(height: 16),
          _buildDateField(
            label: 'Warranty Date',
            date: controller.warrantyDate,
            isDark: isDark,
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
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppThemeData.primary50.withValues(alpha: 0.15),
                      AppThemeData.primary4.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: controller.selectedPaymentMethod.value?.pIcon != null &&
                    controller.selectedPaymentMethod.value!.pIcon!.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: NetworkImageWidget(
                    imageUrl: controller.selectedPaymentMethod.value!.pIcon!,
                    fit: BoxFit.cover,
                  ),
                )
                    : Icon(
                  Icons.payment_rounded,
                  color: AppThemeData.primary50,
                  size: 20,
                ),
              ),
              spaceW(width: 12),
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
    return _buildSectionCard(
      title: 'Logistics & State',
      icon: Icons.local_shipping_outlined,
      color: AppThemeData.pending400,
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
                  isEditMode: controller.isEditMode.value,
                ),
              ),
              spaceW(width: 16),
              Expanded(
                child: _buildDetailRow(
                  label: 'Units',
                  value: '${controller.purchase.value?.units ?? 1}',
                  textController: controller.unitsController,
                  isDark: isDark,
                  isEditMode: controller.isEditMode.value,
                ),
              ),
            ],
          ),
          spaceH(height: 16),
          _buildDetailRow(
            label: 'Store / Location',
            value: controller.purchase.value?.storeLocation ?? '—',
            textController: controller.storeLocationController,
            isDark: isDark,
            isEditMode: controller.isEditMode.value,
          ),
          spaceH(height: 16),
          _buildConditionField(isDark),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: (controller.purchase.value?.statusColor ?? Colors.grey).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextCustom(
              title: controller.purchase.value?.condition ?? '—',
              fontSize: 15,
              fontFamily: FontFamily.semiBold,
              color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
            ),
          ),
      ],
    );
  }

  Widget _buildDescriptionSection(bool isDark) {
    return _buildSectionCard(
      title: 'Description',
      icon: Icons.description_outlined,
      color: const Color(0xFF8B5CF6),
      isDark: isDark,
      child: controller.isEditMode.value
          ? TextField(
        controller: controller.descriptionController,
        maxLines: 5,
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
    required bool isEditMode,
    bool isPrice = false,
    Color? valueColor,
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
        if (isEditMode)
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
            color: valueColor ?? (isDark ? AppThemeData.grey1 : AppThemeData.grey10),
          ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
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
        border: Border.all(
          color: isDark ? AppThemeData.grey8.withValues(alpha: 0.3) : AppThemeData.grey3.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withValues(alpha: 0.15),
                      color.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
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


// Helper class for image items
class ImageItem {
  final String? networkUrl;
  final Uint8List? memoryImage;

  ImageItem({this.networkUrl, this.memoryImage});
}