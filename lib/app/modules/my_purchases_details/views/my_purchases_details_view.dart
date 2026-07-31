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
import 'package:maheksync/app/widgets/text_field_widget.dart';
import 'package:maheksync/app/constant/round_shape_button.dart';
import '../controllers/my_purchases_details_controller.dart';

// ════════════════════════════════════════════════════════════════════
//  NEON GLOW PREMIUM — Purchase Details
// ════════════════════════════════════════════════════════════════════

class MyPurchasesDetailsView extends GetView<MyPurchasesDetailsController> {
  const MyPurchasesDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDark = themeChange.isDarkTheme();

    return Scaffold(
      backgroundColor: isDark ? AppThemeData.surfaceVoid : AppThemeData.grey2,
      appBar: AppBar(
        backgroundColor: isDark ? AppThemeData.surfaceObsidian : AppThemeData.primaryWhite,
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
                  SizedBox(
                    height: 36,
                    child: RoundShapeButton(
                      title: '',
                      buttonColor: Colors.transparent,
                      buttonTextColor: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                      borderColor: isDark ? AppThemeData.surfaceBorder : AppThemeData.grey4,
                      onTap: controller.toggleEditMode,
                      borderRadius: 10,
                      titleWidget: TextCustom(title: 'Cancel', fontSize: 13, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                    ),
                  ),
                  spaceW(width: 8),
                  SizedBox(
                    height: 36,
                    child: RoundShapeButton(
                      title: '',
                      buttonColor: AppThemeData.neonPurple,
                      buttonTextColor: AppThemeData.primaryWhite,
                      onTap: controller.isSaving.value ? () {} : controller.savePurchase,
                      borderRadius: 10,
                      titleWidget: controller.isSaving.value
                          ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppThemeData.primaryWhite))
                          : TextCustom(title: 'Save', fontSize: 13, color: AppThemeData.primaryWhite),
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
                        color: AppThemeData.neonPurple.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.edit_rounded, color: AppThemeData.neonPurple, size: 20),
                    ),
                  ),
                  IconButton(
                    onPressed: controller.deletePurchase,
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppThemeData.danger300.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
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
        return _buildContent(isDark, context: context);
      }),
    );
  }

  Widget _buildContent(bool isDark, {required BuildContext context}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 1000;

    return isSmallScreen
        ? _buildSmallLayout(isDark)
        : _buildDesktopLayout(isDark);
  }

  // ════════════════════════════════════════════════════════════════════
  //  LAYOUTS
  // ════════════════════════════════════════════════════════════════════

  Widget _buildDesktopLayout(bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _buildImageGallery(isDark)),
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPremiumTitle(isDark),
                spaceH(height: 24),
                _NeonGlowContainer(
                  accentColor: AppThemeData.neonPurple,
                  isDark: isDark,
                  child: _buildQuickInfoChips(isDark),
                ),
                spaceH(height: 28),
                _NeonGlowContainer(
                  accentColor: AppThemeData.neonPurple,
                  isDark: isDark,
                  child: _buildDetailsCard(isDark),
                ),
                spaceH(height: 20),
                _NeonGlowContainer(
                  accentColor: AppThemeData.neonTeal,
                  isDark: isDark,
                  child: _buildDescriptionCard(isDark),
                ),
                spaceH(height: 40),
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
          SizedBox(height: 350, child: _buildImageGallery(isDark)),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPremiumTitle(isDark),
                spaceH(height: 16),
                _NeonGlowContainer(
                  accentColor: AppThemeData.neonPurple,
                  isDark: isDark,
                  child: _buildQuickInfoChips(isDark),
                ),
                spaceH(height: 20),
                _NeonGlowContainer(
                  accentColor: AppThemeData.neonPurple,
                  isDark: isDark,
                  child: _buildDetailsCard(isDark),
                ),
                spaceH(height: 16),
                _NeonGlowContainer(
                  accentColor: AppThemeData.neonTeal,
                  isDark: isDark,
                  child: _buildDescriptionCard(isDark),
                ),
                spaceH(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  //  IMAGE GALLERY
  // ════════════════════════════════════════════════════════════════════

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
        color: isDark ? AppThemeData.surfaceDeep : AppThemeData.grey1,
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppThemeData.surfaceDark : AppThemeData.primaryWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? AppThemeData.neonPurple.withValues(alpha: 0.2)
                        : AppThemeData.primary50.withValues(alpha: 0.15),
                  ),
                  boxShadow: isDark
                      ? [
                          BoxShadow(color: AppThemeData.neonPurple.withValues(alpha: 0.08), blurRadius: 24, spreadRadius: -4),
                          BoxShadow(color: AppThemeData.neonBlue.withValues(alpha: 0.05), blurRadius: 40, spreadRadius: -8),
                        ]
                      : [
                          BoxShadow(color: AppThemeData.primaryBlack.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 4)),
                        ],
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
                          padding: const EdgeInsets.all(32),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: InteractiveViewer(
                              child: image.networkUrl != null
                                  ? NetworkImageWidget(imageUrl: image.networkUrl!, fit: BoxFit.contain)
                                  : image.memoryImage != null
                                      ? Image.memory(image.memoryImage!, fit: BoxFit.contain)
                                      : const SizedBox(),
                            ),
                          ),
                        ),
                      ),
                      if (allImages.length > 1) ...[
                        _buildGalleryArrow(
                          left: 12,
                          onTap: controller.previousImage,
                          icon: Icons.chevron_left_rounded,
                          isDark: isDark,
                        ),
                        _buildGalleryArrow(
                          right: 12,
                          onTap: controller.nextImage,
                          icon: Icons.chevron_right_rounded,
                          isDark: isDark,
                        ),
                      ],
                      if (controller.isEditMode.value)
                        Positioned(
                          top: 16,
                          right: 16,
                          child: GestureDetector(
                            onTap: controller.pickImages,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: AppThemeData.appleIntelligenceGradientCool,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(color: AppThemeData.neonPurple.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4)),
                                ],
                              ),
                              child: Icon(Icons.add_photo_alternate_rounded, color: AppThemeData.primaryWhite, size: 22),
                            ),
                          ),
                        ),
                      if (allImages.length > 1)
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                AppThemeData.neonPurple.withValues(alpha: 0.8),
                                AppThemeData.neonBlue.withValues(alpha: 0.8),
                              ]),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(color: AppThemeData.neonPurple.withValues(alpha: 0.3), blurRadius: 8),
                              ],
                            ),
                            child: TextCustom(
                              title: '${selectedIndex + 1} / ${allImages.length}',
                              fontSize: 13,
                              fontFamily: FontFamily.semiBold,
                              color: AppThemeData.primaryWhite,
                            ),
                          ),
                        ),
                    ],
                  );
                }),
              ),
            ),
            Container(
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? AppThemeData.surfaceDark.withValues(alpha: 0.8) : AppThemeData.primaryWhite.withValues(alpha: 0.8),
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? AppThemeData.neonPurple.withValues(alpha: 0.15)
                        : AppThemeData.grey3.withValues(alpha: 0.5),
                    width: 0.5,
                  ),
                ),
              ),
              child: allImages.isEmpty
                  ? Center(
                      child: TextCustom(title: 'No images', fontSize: 13, color: isDark ? AppThemeData.grey6 : AppThemeData.grey5),
                    )
                  : Row(
                      children: [
                        TextCustom(
                          title: '${allImages.length} images',
                          fontSize: 12,
                          fontFamily: FontFamily.medium,
                          color: isDark ? AppThemeData.textNeonPurple : AppThemeData.grey6,
                        ),
                        spaceW(width: 14),
                        Expanded(
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: allImages.length,
                            separatorBuilder: (context, index) => spaceW(width: 10),
                            itemBuilder: (context, index) {
                              return _NeonThumbnail(
                                image: allImages[index],
                                isSelected: controller.selectedImageIndex.value == index,
                                isDark: isDark,
                                onTap: () => controller.selectedImageIndex.value = index,
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

  Widget _buildGalleryArrow({
    double? left,
    double? right,
    required VoidCallback onTap,
    required IconData icon,
    required bool isDark,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: 0,
      bottom: 0,
      child: Center(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? AppThemeData.surfaceLight.withValues(alpha: 0.8)
                  : AppThemeData.primaryBlack.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(25),
              boxShadow: isDark
                  ? [BoxShadow(color: AppThemeData.neonPurple.withValues(alpha: 0.2), blurRadius: 12)]
                  : null,
            ),
            child: Icon(icon, color: AppThemeData.primaryWhite, size: 28),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyImage(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? AppThemeData.neonPurple.withValues(alpha: 0.08)
                  : AppThemeData.primary50.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.image_outlined, size: 64, color: isDark ? AppThemeData.neonPurple : AppThemeData.grey5),
          ),
          spaceH(height: 16),
          TextCustom(
            title: 'No images available',
            fontSize: 16,
            color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
          ),
          if (controller.isEditMode.value) ...[
            spaceH(height: 16),
            SizedBox(
              height: 42,
              child: RoundShapeButton(
                title: '',
                buttonColor: AppThemeData.neonPurple,
                buttonTextColor: AppThemeData.primaryWhite,
                onTap: controller.pickImages,
                borderRadius: 12,
                titleWidget: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_photo_alternate_rounded, size: 18, color: AppThemeData.primaryWhite),
                    spaceW(width: 8),
                    TextCustom(title: 'Add Images', fontSize: 14, color: AppThemeData.primaryWhite),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  //  TITLE + BADGES
  // ════════════════════════════════════════════════════════════════════

  Widget _buildPremiumTitle(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(
          title: controller.purchase.value?.assetName ?? 'Unknown Product',
          fontSize: 26,
          fontFamily: FontFamily.bold,
          color: isDark ? AppThemeData.primaryWhite : AppThemeData.grey10,
          maxLine: 3,
        ),
        spaceH(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: AppThemeData.neonMint.withValues(alpha: isDark ? 0.12 : 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppThemeData.neonMint.withValues(alpha: 0.25)),
                boxShadow: isDark
                    ? [
                        BoxShadow(color: AppThemeData.neonMint.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 3)),
                      ]
                    : null,
              ),
              child: TextCustom(
                title: '₹${(controller.purchase.value?.price ?? 0).toStringAsFixed(2)}',
                fontSize: 22,
                fontFamily: FontFamily.bold,
                color: AppThemeData.neonMint,
              ),
            ),
            spaceW(width: 14),
            _buildStatusBadge(isDark),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(bool isDark) {
    final status = controller.purchase.value?.status ?? 'DELIVERED';
    final Color dotColor;
    switch (status) {
      case 'DELIVERED':
        dotColor = AppThemeData.neonCyan;
        break;
      case 'IN TRANSIT':
        dotColor = AppThemeData.neonOrange;
        break;
      case 'PRE-ORDER':
        dotColor = AppThemeData.neonPurple;
        break;
      default:
        dotColor = AppThemeData.grey5;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: dotColor.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: dotColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle, boxShadow: [
              BoxShadow(color: dotColor.withValues(alpha: 0.5), blurRadius: 6),
            ]),
          ),
          spaceW(width: 8),
          TextCustom(
            title: status,
            fontSize: 12,
            fontFamily: FontFamily.bold,
            color: dotColor,
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  //  QUICK INFO CHIPS — Each chip has its own neon color
  // ════════════════════════════════════════════════════════════════════

  Widget _buildQuickInfoChips(bool isDark) {
    return Row(
      children: [
        _buildChip(Icons.category_rounded, 'Category', controller.purchase.value?.category ?? '—', AppThemeData.neonPurple, isDark),
        _buildChipDivider(AppThemeData.neonPurple, isDark),
        _buildChip(Icons.payment_rounded, 'Payment', controller.purchase.value?.paymentMethod ?? '—', AppThemeData.neonBlue, isDark),
        _buildChipDivider(AppThemeData.neonTeal, isDark),
        _buildChip(Icons.inventory_2_outlined, 'Units', '${controller.purchase.value?.units ?? 1}', AppThemeData.neonTeal, isDark),
        _buildChipDivider(AppThemeData.neonPink, isDark),
        _buildChip(Icons.straighten_outlined, 'Size', controller.purchase.value?.size ?? '—', AppThemeData.neonPink, isDark),
      ],
    );
  }

  Widget _buildChip(IconData icon, String label, String value, Color accent, bool isDark) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: isDark ? 0.12 : 0.08),
              borderRadius: BorderRadius.circular(10),
              boxShadow: isDark
                  ? [BoxShadow(color: accent.withValues(alpha: 0.15), blurRadius: 8)]
                  : null,
            ),
            child: Icon(icon, color: accent, size: 16),
          ),
          spaceH(height: 8),
          TextCustom(
            title: label,
            fontSize: 11,
            fontFamily: FontFamily.medium,
            color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
          ),
          spaceH(height: 4),
          TextCustom(
            title: value,
            fontSize: 13,
            fontFamily: FontFamily.semiBold,
            color: isDark ? AppThemeData.primaryWhite : AppThemeData.grey10,
            maxLine: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildChipDivider(Color color, bool isDark) {
    return Container(
      width: 1,
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: isDark ? 0.3 : 0.15),
            color.withValues(alpha: 0.05),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  //  DETAILS CARD
  // ════════════════════════════════════════════════════════════════════

  Widget _buildDetailsCard(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _neonSectionHeader(
          icon: Icons.info_outline,
          title: 'Details',
          accentColor: AppThemeData.neonPurple,
          isDark: isDark,
        ),
        spaceH(height: 20),
        _buildDetailRow(icon: Icons.business_outlined, label: 'Brand', value: controller.purchase.value?.brand ?? '—', accent: AppThemeData.neonPurple, isDark: isDark),
        spaceH(height: 14),
        _buildDetailRow(icon: Icons.store_outlined, label: 'Store', value: controller.purchase.value?.storeLocation ?? '—', accent: AppThemeData.neonBlue, isDark: isDark),
        spaceH(height: 14),
        _buildDetailRow(icon: Icons.verified_outlined, label: 'Condition', value: controller.purchase.value?.condition ?? '—', accent: AppThemeData.neonMint, isDark: isDark, isCondition: true),
        spaceH(height: 14),
        _neonDivider(AppThemeData.neonPurple, isDark),
        spaceH(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildDetailRow(
                icon: Icons.calendar_today_outlined,
                label: 'Purchase Date',
                value: controller.purchaseDate.value != null ? DateFormat('MMM dd, yyyy').format(controller.purchaseDate.value!) : '—',
                accent: AppThemeData.neonTeal,
                isDark: isDark,
              ),
            ),
            spaceW(width: 20),
            Expanded(
              child: _buildDetailRow(
                icon: Icons.event_outlined,
                label: 'Warranty',
                value: controller.warrantyDate.value != null ? DateFormat('MMM dd, yyyy').format(controller.warrantyDate.value!) : '—',
                accent: AppThemeData.neonOrange,
                isDark: isDark,
              ),
            ),
          ],
        ),
        spaceH(height: 14),
        _neonDivider(AppThemeData.neonPurple, isDark),
        spaceH(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildDetailRow(
                icon: Icons.attach_money_rounded,
                label: 'Price',
                value: '₹${(controller.purchase.value?.price ?? 0).toStringAsFixed(2)}',
                accent: AppThemeData.neonMint,
                isDark: isDark,
                isHighlight: true,
              ),
            ),
            spaceW(width: 20),
            Expanded(child: _buildPaymentMethodDisplay(isDark)),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color accent,
    required bool isDark,
    bool isCondition = false,
    bool isHighlight = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: isDark ? 0.1 : 0.06),
            borderRadius: BorderRadius.circular(10),
            boxShadow: isDark
                ? [BoxShadow(color: accent.withValues(alpha: 0.1), blurRadius: 6)]
                : null,
          ),
          child: Icon(icon, color: accent, size: 16),
        ),
        spaceW(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextCustom(
                title: label,
                fontSize: 11,
                fontFamily: FontFamily.medium,
                color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
              ),
              spaceH(height: 3),
              if (isCondition && controller.isEditMode.value)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: isDark ? AppThemeData.surfaceElevated : AppThemeData.grey1,
                    borderRadius: BorderRadius.circular(8),
                  ),
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
                  color: isHighlight ? accent : (isDark ? AppThemeData.primaryWhite : AppThemeData.grey10),
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
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppThemeData.neonBlue.withValues(alpha: isDark ? 0.1 : 0.06),
            borderRadius: BorderRadius.circular(10),
            boxShadow: isDark
                ? [BoxShadow(color: AppThemeData.neonBlue.withValues(alpha: 0.1), blurRadius: 6)]
                : null,
          ),
          child: controller.selectedPaymentMethod.value?.pIcon != null && controller.selectedPaymentMethod.value!.pIcon!.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: NetworkImageWidget(imageUrl: controller.selectedPaymentMethod.value!.pIcon!, fit: BoxFit.cover),
                )
              : const Icon(Icons.payment_rounded, color: AppThemeData.neonBlue, size: 16),
        ),
        spaceW(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextCustom(
                title: 'Payment Method',
                fontSize: 11,
                fontFamily: FontFamily.medium,
                color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
              ),
              spaceH(height: 3),
              TextCustom(
                title: controller.selectedPaymentMethod.value?.pName ?? controller.purchase.value?.paymentMethod ?? '—',
                fontSize: 14,
                fontFamily: FontFamily.semiBold,
                color: isDark ? AppThemeData.primaryWhite : AppThemeData.grey10,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════
  //  DESCRIPTION CARD
  // ════════════════════════════════════════════════════════════════════

  Widget _buildDescriptionCard(bool isDark) {
    final description = controller.purchase.value?.description;
    if (description == null || description.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _neonSectionHeader(
          icon: Icons.description_outlined,
          title: 'Description',
          accentColor: AppThemeData.neonTeal,
          isDark: isDark,
        ),
        spaceH(height: 14),
        if (controller.isEditMode.value)
          TextFieldWidget(
            hintText: 'Describe your purchase...',
            controller: controller.descriptionController,
            onPress: () {},
            line: 4,
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
    );
  }

  // ════════════════════════════════════════════════════════════════════
  //  SHARED NEON HELPERS
  // ════════════════════════════════════════════════════════════════════

  Widget _neonSectionHeader({
    required IconData icon,
    required String title,
    required Color accentColor,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: isDark ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isDark
                ? [BoxShadow(color: accentColor.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 2))]
                : null,
          ),
          child: Icon(icon, color: accentColor, size: 18),
        ),
        spaceW(width: 12),
        TextCustom(
          title: title,
          fontSize: 16,
          fontFamily: FontFamily.bold,
          color: isDark ? AppThemeData.primaryWhite : AppThemeData.grey10,
        ),
      ],
    );
  }

  Widget _neonDivider(Color color, bool isDark) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: isDark ? 0.3 : 0.15),
            color.withValues(alpha: isDark ? 0.08 : 0.04),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  SHARED WIDGETS
// ════════════════════════════════════════════════════════════════════

class ImageItem {
  final String? networkUrl;
  final Uint8List? memoryImage;
  ImageItem({this.networkUrl, this.memoryImage});
}

/// Neon glow container wrapper — adds accent border + dual glow shadow
class _NeonGlowContainer extends StatefulWidget {
  final Widget child;
  final Color accentColor;
  final bool isDark;

  const _NeonGlowContainer({
    required this.child,
    required this.accentColor,
    required this.isDark,
  });

  @override
  State<_NeonGlowContainer> createState() => _NeonGlowContainerState();
}

class _NeonGlowContainerState extends State<_NeonGlowContainer> {
  bool _isHovered = false;

  void _onHover(bool v) {
    if (_isHovered == v) return;
    _isHovered = v;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedScale(
        scale: _isHovered ? 1.015 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: widget.isDark ? AppThemeData.surfaceDark : AppThemeData.primaryWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered
                  ? widget.accentColor.withValues(alpha: widget.isDark ? 0.4 : 0.25)
                  : widget.accentColor.withValues(alpha: widget.isDark ? 0.12 : 0.08),
            ),
            boxShadow: widget.isDark
                ? [
                    BoxShadow(
                      color: widget.accentColor.withValues(alpha: _isHovered ? 0.18 : 0.08),
                      blurRadius: _isHovered ? 28 : 18,
                      spreadRadius: _isHovered ? -2 : -4,
                    ),
                    BoxShadow(
                      color: widget.accentColor.withValues(alpha: _isHovered ? 0.10 : 0.04),
                      blurRadius: _isHovered ? 48 : 32,
                      spreadRadius: _isHovered ? -4 : -8,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: AppThemeData.primaryBlack.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Neon thumbnail with glow on selection/hover
class _NeonThumbnail extends StatefulWidget {
  final ImageItem image;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const _NeonThumbnail({
    required this.image,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
    this.onRemove,
  });

  @override
  State<_NeonThumbnail> createState() => _NeonThumbnailState();
}

class _NeonThumbnailState extends State<_NeonThumbnail> {
  bool _isHovered = false;

  void _onHover(bool v) {
    if (_isHovered == v) return;
    _isHovered = v;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.isSelected
                    ? AppThemeData.neonPurple
                    : (_isHovered
                        ? AppThemeData.neonPurple.withValues(alpha: 0.4)
                        : (widget.isDark ? AppThemeData.surfaceBorder : AppThemeData.grey4)),
                width: widget.isSelected ? 2.5 : 1,
              ),
              boxShadow: [
                if (widget.isSelected)
                  BoxShadow(color: AppThemeData.neonPurple.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 2)),
                if (_isHovered && !widget.isSelected)
                  BoxShadow(color: AppThemeData.neonPurple.withValues(alpha: 0.15), blurRadius: 8),
              ],
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    color: widget.isDark ? AppThemeData.surfaceElevated : AppThemeData.grey2,
                    child: widget.image.networkUrl != null
                        ? NetworkImageWidget(imageUrl: widget.image.networkUrl!, fit: BoxFit.cover, height: 80, width: 80)
                        : widget.image.memoryImage != null
                            ? Image.memory(widget.image.memoryImage!, fit: BoxFit.cover, height: 80, width: 80)
                            : const SizedBox(height: 80, width: 80),
                  ),
                ),
                if (widget.onRemove != null)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: widget.onRemove,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppThemeData.danger300,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(Icons.close_rounded, color: AppThemeData.primaryWhite, size: 14),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
