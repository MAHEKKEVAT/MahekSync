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
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? AppThemeData.grey4 : AppThemeData.grey7, size: 20),
        ),
        title: TextCustom(
          title: 'Purchase Details',
          fontSize: 18,
          fontFamily: FontFamily.bold,
          color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
        ),
        actions: [
          Obx(() {
            if (controller.isEditMode.value) {
              return Row(
                children: [
                  TextButton(
                    onPressed: controller.toggleEditMode,
                    child: TextCustom(title: 'Cancel', fontSize: 13, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                  ),
                  ElevatedButton(
                    onPressed: controller.isSaving.value ? null : controller.savePurchase,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppThemeData.primary50,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: controller.isSaving.value
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const TextCustom(title: 'Save', fontSize: 13, color: Colors.white),
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
                      decoration: BoxDecoration(color: AppThemeData.primary50.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                      child: Icon(Icons.edit_rounded, color: AppThemeData.primary50, size: 20),
                    ),
                  ),
                  IconButton(
                    onPressed: controller.deletePurchase,
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppThemeData.danger300.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.delete_outline, color: AppThemeData.danger300, size: 20),
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
          return Center(child: MahekLoader(message: 'Loading...', size: 50, textSize: 16));
        }
        return _buildContent(isDark);
      }),
    );
  }

  Widget _buildContent(bool isDark) {
    final screenWidth = MediaQuery.of(Get.context!).size.width;
    final isSmallScreen = screenWidth < 1000;

    return isSmallScreen
        ? _buildSmallLayout(isDark)
        : _buildDesktopLayout(isDark);
  }

  Widget _buildDesktopLayout(bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // LEFT SIDE - Large Image Gallery
        Expanded(
          flex: 3,
          child: _buildImageGallery(isDark),
        ),
        // RIGHT SIDE - Details
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPremiumTitle(isDark),
                spaceH(height: 24),
                _buildQuickInfoChips(isDark),
                spaceH(height: 28),
                _buildDetailsCard(isDark),
                spaceH(height: 20),
                _buildDescriptionCard(isDark),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSmallLayout(bool isDark) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 350,
            child: _buildImageGallery(isDark),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPremiumTitle(isDark),
                spaceH(height: 16),
                _buildQuickInfoChips(isDark),
                spaceH(height: 20),
                _buildDetailsCard(isDark),
                spaceH(height: 16),
                _buildDescriptionCard(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== IMAGE GALLERY (UNCHANGED) ====================
  Widget _buildImageGallery(bool isDark) {
    return Obx(() {
      final existingImages = controller.existingImages;
      final newImageBytes = controller.newImageBytes;

      final allImages = <ImageItem>[];
      for (var url in existingImages) {
        allImages.add(ImageItem(networkUrl: url));
      }
      for (var bytes in newImageBytes) {
        allImages.add(ImageItem(memoryImage: bytes));
      }

      return Container(
        color: isDark ? AppThemeData.grey9 : AppThemeData.grey2,
        child: Column(
          children: [
            // Main Image Display
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Obx(() {
                  final selectedIndex = controller.selectedImageIndex.value;
                  if (allImages.isEmpty) {
                    return _buildEmptyImage(isDark);
                  }
                  final image = allImages[selectedIndex.clamp(0, allImages.length - 1)];
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: image.networkUrl != null
                                ? NetworkImageWidget(
                              imageUrl: image.networkUrl!,
                              fit: BoxFit.contain,
                            )
                                : image.memoryImage != null
                                ? Image.memory(
                              image.memoryImage!,
                              fit: BoxFit.contain,
                            )
                                : const SizedBox(),
                          ),
                        ),
                      ),
                      // Navigation Arrows
                      if (allImages.length > 1) ...[
                        Positioned(
                          left: 12,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: GestureDetector(
                              onTap: controller.previousImage,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 28),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 12,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: GestureDetector(
                              onTap: controller.nextImage,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 28),
                              ),
                            ),
                          ),
                        ),
                      ],
                      // Add Image Button (Edit Mode)
                      if (controller.isEditMode.value)
                        Positioned(
                          top: 16,
                          right: 16,
                          child: GestureDetector(
                            onTap: controller.pickImages,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppThemeData.primary50,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [BoxShadow(color: AppThemeData.primary50.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 3))],
                              ),
                              child: const Icon(Icons.add_photo_alternate_rounded, color: Colors.white, size: 22),
                            ),
                          ),
                        ),
                      // Image Counter
                      if (allImages.length > 1)
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: TextCustom(
                              title: '${selectedIndex + 1} / ${allImages.length}',
                              fontSize: 13,
                              fontFamily: FontFamily.semiBold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  );
                }),
              ),
            ),
            // Thumbnail Strip
            Container(
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? AppThemeData.primaryBlack.withValues(alpha: 0.8) : AppThemeData.primaryWhite.withValues(alpha: 0.8),
                border: Border(
                  top: BorderSide(color: isDark ? AppThemeData.grey8 : AppThemeData.grey3, width: 0.5),
                ),
              ),
              child: allImages.isEmpty
                  ? Center(
                child: TextCustom(title: 'No images', fontSize: 13, color: isDark ? AppThemeData.grey6 : AppThemeData.grey5),
              )
                  : Row(
                children: [
                  TextCustom(title: '${allImages.length} images', fontSize: 12, fontFamily: FontFamily.medium, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                  spaceW(width: 14),
                  Expanded(
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

  Widget _buildEmptyImage(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 80, color: isDark ? AppThemeData.grey7 : AppThemeData.grey4),
          spaceH(height: 16),
          TextCustom(title: 'No images available', fontSize: 16, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
          if (controller.isEditMode.value) ...[
            spaceH(height: 12),
            ElevatedButton.icon(
              onPressed: controller.pickImages,
              icon: const Icon(Icons.add_photo_alternate_rounded, size: 18),
              label: const TextCustom(title: 'Add Images', fontSize: 14, color: Colors.white),
              style: ElevatedButton.styleFrom(backgroundColor: AppThemeData.primary50, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
            ),
          ],
        ],
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
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppThemeData.primary50 : (isDark ? AppThemeData.grey7 : AppThemeData.grey4), width: isSelected ? 2.5 : 1),
          boxShadow: isSelected ? [BoxShadow(color: AppThemeData.primary50.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))] : null,
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                color: isDark ? AppThemeData.grey8 : AppThemeData.grey2,
                child: image.networkUrl != null
                    ? NetworkImageWidget(imageUrl: image.networkUrl!, fit: BoxFit.cover, height: 80, width: 80)
                    : image.memoryImage != null
                    ? Image.memory(image.memoryImage!, fit: BoxFit.cover, height: 80, width: 80)
                    : const SizedBox(height: 80, width: 80),
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
                    decoration: BoxDecoration(color: AppThemeData.danger300, borderRadius: BorderRadius.circular(6)),
                    child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ==================== REDESIGNED DETAILS PANEL ====================

  Widget _buildPremiumTitle(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(
          title: controller.purchase.value?.assetName ?? 'Unknown Product',
          fontSize: 26,
          fontFamily: FontFamily.bold,
          color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
          maxLine: 3,
        ),
        spaceH(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppThemeData.primary50.withValues(alpha: 0.15),
                    AppThemeData.primary4.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextCustom(
                title: '₹${(controller.purchase.value?.price ?? 0).toStringAsFixed(2)}',
                fontSize: 28,
                fontFamily: FontFamily.bold,
                color: AppThemeData.primary50,
              ),
            ),
            spaceW(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: (controller.purchase.value?.statusColor ?? Colors.grey).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: (controller.purchase.value?.statusColor ?? Colors.grey).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: controller.purchase.value?.statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  spaceW(width: 8),
                  TextCustom(
                    title: controller.purchase.value?.status ?? 'DELIVERED',
                    fontSize: 12,
                    fontFamily: FontFamily.bold,
                    color: controller.purchase.value?.statusColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickInfoChips(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.primaryBlack.withValues(alpha: 0.5) : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppThemeData.grey8.withValues(alpha: 0.3) : AppThemeData.grey3.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          _buildChip(Icons.category_rounded, 'Category', controller.purchase.value?.category ?? '—', isDark),
          _buildChipDivider(isDark),
          _buildChip(Icons.payment_rounded, 'Payment', controller.purchase.value?.paymentMethod ?? '—', isDark),
          _buildChipDivider(isDark),
          _buildChip(Icons.inventory_2_outlined, 'Units', '${controller.purchase.value?.units ?? 1}', isDark),
          _buildChipDivider(isDark),
          _buildChip(Icons.straighten_outlined, 'Size', controller.purchase.value?.size ?? '—', isDark),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, String value, bool isDark) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppThemeData.primary50, size: 20),
          spaceH(height: 6),
          TextCustom(title: label, fontSize: 9, fontFamily: FontFamily.medium, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
          spaceH(height: 4),
          TextCustom(title: value, fontSize: 13, fontFamily: FontFamily.semiBold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10, maxLine: 1),
        ],
      ),
    );
  }

  Widget _buildChipDivider(bool isDark) {
    return Container(
      width: 1,
      height: 40,
      color: isDark ? AppThemeData.grey8.withValues(alpha: 0.3) : AppThemeData.grey3.withValues(alpha: 0.3),
    );
  }

  Widget _buildDetailsCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.primaryBlack.withValues(alpha: 0.3) : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppThemeData.grey8.withValues(alpha: 0.2) : AppThemeData.grey3.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.03),
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
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    AppThemeData.primary50.withValues(alpha: 0.15),
                    AppThemeData.primary4.withValues(alpha: 0.08),
                  ]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:  Icon(Icons.info_outline, color: AppThemeData.primary50, size: 18),
              ),
              spaceW(width: 12),
              TextCustom(title: 'Details', fontSize: 16, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
            ],
          ),
          spaceH(height: 20),
          _buildDetailRowModern(icon: Icons.business_outlined, label: 'Brand', value: controller.purchase.value?.brand ?? '—', isDark: isDark),
          spaceH(height: 14),
          _buildDetailRowModern(icon: Icons.store_outlined, label: 'Store', value: controller.purchase.value?.storeLocation ?? '—', isDark: isDark),
          spaceH(height: 14),
          _buildDetailRowModern(icon: Icons.verified_outlined, label: 'Condition', value: controller.purchase.value?.condition ?? '—', isDark: isDark, isCondition: true),
          spaceH(height: 14),
          Container(height: 1, color: isDark ? AppThemeData.grey8.withValues(alpha: 0.2) : AppThemeData.grey3.withValues(alpha: 0.2)),
          spaceH(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildDetailRowModern(
                  icon: Icons.calendar_today_outlined,
                  label: 'Purchase Date',
                  value: controller.purchaseDate.value != null ? DateFormat('MMM dd, yyyy').format(controller.purchaseDate.value!) : '—',
                  isDark: isDark,
                ),
              ),
              spaceW(width: 20),
              Expanded(
                child: _buildDetailRowModern(
                  icon: Icons.event_outlined,
                  label: 'Warranty',
                  value: controller.warrantyDate.value != null ? DateFormat('MMM dd, yyyy').format(controller.warrantyDate.value!) : '—',
                  isDark: isDark,
                ),
              ),
            ],
          ),
          spaceH(height: 14),
          Container(height: 1, color: isDark ? AppThemeData.grey8.withValues(alpha: 0.2) : AppThemeData.grey3.withValues(alpha: 0.2)),
          spaceH(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildDetailRowModern(
                  icon: Icons.attach_money_rounded,
                  label: 'Price',
                  value: '₹${(controller.purchase.value?.price ?? 0).toStringAsFixed(2)}',
                  isDark: isDark,
                  isHighlight: true,
                ),
              ),
              spaceW(width: 20),
              Expanded(
                child: _buildPaymentMethodDisplay(isDark),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRowModern({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    bool isCondition = false,
    bool isHighlight = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppThemeData.primary50.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppThemeData.primary50, size: 16),
        ),
        spaceW(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextCustom(title: label, fontSize: 11, fontFamily: FontFamily.medium, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
              spaceH(height: 3),
              if (isCondition && controller.isEditMode.value)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(color: isDark ? AppThemeData.grey9 : AppThemeData.grey1, borderRadius: BorderRadius.circular(8)),
                  child: DropdownButton<String>(
                    value: controller.selectedCondition.value,
                    isExpanded: true,
                    underline: const SizedBox(),
                    style: TextStyle(fontSize: 13, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
                    items: controller.conditions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => controller.selectedCondition.value = v!,
                  ),
                )
              else
                TextCustom(
                  title: value,
                  fontSize: 14,
                  fontFamily: FontFamily.semiBold,
                  color: isHighlight ? AppThemeData.primary50 : (isDark ? AppThemeData.grey1 : AppThemeData.grey10),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodDisplay(bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppThemeData.primary50.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: controller.selectedPaymentMethod.value?.pIcon != null && controller.selectedPaymentMethod.value!.pIcon!.isNotEmpty
              ? ClipRRect(borderRadius: BorderRadius.circular(8), child: NetworkImageWidget(imageUrl: controller.selectedPaymentMethod.value!.pIcon!, fit: BoxFit.cover))
              :  Icon(Icons.payment_rounded, color: AppThemeData.primary50, size: 16),
        ),
        spaceW(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextCustom(title: 'Payment Method', fontSize: 11, fontFamily: FontFamily.medium, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
              spaceH(height: 3),
              TextCustom(
                title: controller.selectedPaymentMethod.value?.pName ?? controller.purchase.value?.paymentMethod ?? '—',
                fontSize: 14,
                fontFamily: FontFamily.semiBold,
                color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionCard(bool isDark) {
    final description = controller.purchase.value?.description;
    if (description == null || description.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF8B5CF6).withValues(alpha: isDark ? 0.08 : 0.04),
            const Color(0xFF6D28D9).withValues(alpha: isDark ? 0.04 : 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.15)),
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
                  gradient: LinearGradient(colors: [
                    const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                    const Color(0xFF6D28D9).withValues(alpha: 0.08),
                  ]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.description_outlined, color: Color(0xFF8B5CF6), size: 18),
              ),
              spaceW(width: 12),
              TextCustom(title: 'Description', fontSize: 16, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
            ],
          ),
          spaceH(height: 14),
          if (controller.isEditMode.value)
            TextField(
              controller: controller.descriptionController,
              maxLines: 4,
              style: TextStyle(fontSize: 14, height: 1.5, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
              decoration: InputDecoration(
                hintText: 'Describe your purchase...',
                hintStyle: TextStyle(color: isDark ? AppThemeData.grey6 : AppThemeData.grey5),
                filled: true,
                fillColor: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.all(14),
              ),
            )
          else
            TextCustom(
              title: description,
              fontSize: 14,
              fontFamily: FontFamily.regular,
              color: isDark ? AppThemeData.grey3 : AppThemeData.grey7,
              maxLine: 10,
            ),
        ],
      ),
    );
  }
}

// Helper class
class ImageItem {
  final String? networkUrl;
  final Uint8List? memoryImage;
  ImageItem({this.networkUrl, this.memoryImage});
}