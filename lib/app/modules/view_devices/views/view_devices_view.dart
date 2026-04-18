// lib/app/modules/view_devices/views/view_devices_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/dark_theme_provider.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import '../../../models/device_model.dart';
import '../controllers/view_devices_controller.dart';

class ViewDevicesView extends GetView<ViewDevicesController> {
  const ViewDevicesView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDark = themeChange.isDarkTheme();
    final device = controller.device;

    // Return loading if device is null
    if (device == null) {
      return Scaffold(
        backgroundColor: isDark ? AppThemeData.grey10 : const Color(0xFFF6F8FC),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppThemeData.grey10 : const Color(0xFFF6F8FC),
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextCustom(
              title: 'INVENTORY > ${device.category?.toUpperCase() ?? 'DEVICE'}',
              fontSize: 11,
              fontFamily: FontFamily.medium,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            ),
            TextCustom(
              title: device.deviceName ?? 'Device Details',
              fontSize: 16,
              fontFamily: FontFamily.bold,
              color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
            ),
          ],
        ),
        centerTitle: false,
        titleSpacing: 8,
        actions: [
          IconButton(
            onPressed: controller.navigateToEdit,
            icon: Icon(
              Icons.edit_outlined,
              color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
            ),
            tooltip: 'Edit',
          ),
          IconButton(
            onPressed: controller.confirmDelete,
            icon: Icon(
              Icons.delete_outline,
              color: const Color(0xFFEF4444),
            ),
            tooltip: 'Delete',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Gallery
            _buildImageGallery(device, isDark),
            spaceH(height: 24),

            // Device Title Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextCustom(
                        title: device.deviceName ?? 'Unknown Device',
                        fontSize: 28,
                        fontFamily: FontFamily.bold,
                        color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                      ),
                      spaceH(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF5D54F2).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: TextCustom(
                              title: device.condition ?? 'NEW',
                              fontSize: 11,
                              fontFamily: FontFamily.semiBold,
                              color: const Color(0xFF5D54F2),
                            ),
                          ),
                          spaceW(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: TextCustom(
                              title: 'NEW ARRIVAL',
                              fontSize: 11,
                              fontFamily: FontFamily.semiBold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            spaceH(height: 24),

            // Warranty Card
            _buildWarrantyCard(device, isDark),
            spaceH(height: 24),

            // Acquisition Details
            _buildSectionTitle('Acquisition Details', isDark),
            spaceH(height: 16),
            _buildDetailsCard(device, isDark),
            spaceH(height: 24),

            // Description
            if (device.description != null && device.description!.isNotEmpty) ...[
              _buildSectionTitle('Description', isDark),
              spaceH(height: 16),
              _buildDescriptionCard(device, isDark),
              spaceH(height: 24),
            ],

            // Image Thumbnails
            if (device.deviceImageUrls != null && device.deviceImageUrls!.isNotEmpty) ...[
              _buildSectionTitle('All Images', isDark),
              spaceH(height: 16),
              _buildThumbnailStrip(device, isDark),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery(DeviceModel device, bool isDark) {
    final images = device.deviceImageUrls;

    if (images == null || images.isEmpty) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.grey9 : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_outlined,
                size: 64,
                color: isDark ? AppThemeData.grey7 : AppThemeData.grey4,
              ),
              spaceH(height: 12),
              TextCustom(
                title: 'No images available',
                fontSize: 14,
                fontFamily: FontFamily.regular,
                color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Main Image
        Container(
          height: 350,
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.grey9 : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              images[controller.currentImageIndex.value],
              width: double.infinity,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  size: 64,
                  color: isDark ? AppThemeData.grey7 : AppThemeData.grey4,
                ),
              ),
            ),
          ),
        ),
        // Image Counter
        if (images.length > 1) ...[
          spaceH(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              images.length,
                  (index) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: controller.currentImageIndex.value == index
                      ? const Color(0xFF5D54F2)
                      : (isDark ? AppThemeData.grey6 : AppThemeData.grey4),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildThumbnailStrip(DeviceModel device, bool isDark) {
    final images = device.deviceImageUrls;
    if (images == null) return const SizedBox.shrink();

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => controller.changeImage(index),
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: controller.currentImageIndex.value == index
                      ? const Color(0xFF5D54F2)
                      : Colors.transparent,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  images[index],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: isDark ? AppThemeData.grey9 : AppThemeData.grey2,
                    child: Icon(Icons.broken_image, color: isDark ? AppThemeData.grey7 : AppThemeData.grey4),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWarrantyCard(DeviceModel device, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF5D54F2).withValues(alpha: isDark ? 0.2 : 0.08),
            const Color(0xFF8B7EFF).withValues(alpha: isDark ? 0.1 : 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF5D54F2).withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.verified_outlined, color: const Color(0xFF5D54F2), size: 20),
                  spaceW(width: 8),
                  TextCustom(
                    title: 'WARRANTY COVERAGE',
                    fontSize: 13,
                    fontFamily: FontFamily.semiBold,
                    color: const Color(0xFF5D54F2),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: controller.warrantyStatusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextCustom(
                  title: controller.warrantyStatus,
                  fontSize: 11,
                  fontFamily: FontFamily.semiBold,
                  color: controller.warrantyStatusColor,
                ),
              ),
            ],
          ),
          spaceH(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextCustom(
                      title: '${controller.daysRemaining}',
                      fontSize: 42,
                      fontFamily: FontFamily.bold,
                      color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                    ),
                    TextCustom(
                      title: 'Days remaining',
                      fontSize: 13,
                      fontFamily: FontFamily.regular,
                      color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWarrantyRow('PLAN START', device.formattedPurchaseDate, isDark),
                    spaceH(height: 8),
                    _buildWarrantyRow('EXPIRES', device.formattedWarrantyEnd, isDark),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWarrantyRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextCustom(
          title: label,
          fontSize: 11,
          fontFamily: FontFamily.medium,
          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
        ),
        TextCustom(
          title: value,
          fontSize: 13,
          fontFamily: FontFamily.semiBold,
          color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return TextCustom(
      title: title,
      fontSize: 14,
      fontFamily: FontFamily.semiBold,
      color: isDark ? AppThemeData.grey3 : AppThemeData.grey8,
    );
  }

  Widget _buildDetailsCard(DeviceModel device, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.primaryBlack : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDetailRow('Store', device.storeName?.isNotEmpty == true ? device.storeName! : 'Not specified', isDark),
          _buildDetailRow('Purchase Date', device.formattedPurchaseDate, isDark),
          _buildDetailRow('Price', device.formattedPrice, isDark),
          _buildDetailRow('Payment Method', controller.paymentMethodDisplay, isDark),
          _buildDetailRow('Brand', device.brandName ?? 'Not specified', isDark),
          _buildDetailRow('Category', device.category ?? 'Not specified', isDark),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextCustom(
            title: label,
            fontSize: 14,
            fontFamily: FontFamily.regular,
            color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
          ),
          TextCustom(
            title: value,
            fontSize: 14,
            fontFamily: FontFamily.semiBold,
            color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(DeviceModel device, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.primaryBlack : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextCustom(
        title: device.description ?? '',
        fontSize: 14,
        fontFamily: FontFamily.regular,
        color: isDark ? AppThemeData.grey3 : AppThemeData.grey7,
      ),
    );
  }
}