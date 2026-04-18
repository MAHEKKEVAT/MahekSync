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
    final device = controller.device.value;

    if (device == null) {
      return Scaffold(
        backgroundColor: isDark ? AppThemeData.grey10 : AppThemeData.grey2,
        body: Center(
          child: CircularProgressIndicator(
            color: AppThemeData.primary50,
          ),
        ),
      );
    }

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextCustom(
              title: 'INVENTORY > ${device.category?.toUpperCase() ?? 'DEVICE'} > ${device.deviceName?.toUpperCase() ?? ''}',
              fontSize: 11,
              fontFamily: FontFamily.medium,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: OutlinedButton.icon(
              onPressed: controller.navigateToEdit,
              icon: Icon(
                Icons.edit_outlined,
                size: 18,
                color: isDark ? AppThemeData.grey3 : AppThemeData.grey7,
              ),
              label: TextCustom(
                title: 'Edit',
                fontSize: 13,
                fontFamily: FontFamily.medium,
                color: isDark ? AppThemeData.grey3 : AppThemeData.grey7,
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                side: BorderSide(
                  color: isDark ? AppThemeData.grey7 : AppThemeData.grey4,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: OutlinedButton.icon(
              onPressed: controller.confirmDelete,
              icon: const Icon(
                Icons.delete_outline,
                size: 18,
                color: AppThemeData.danger300,
              ),
              label: TextCustom(
                title: 'Remove Asset',
                fontSize: 13,
                fontFamily: FontFamily.medium,
                color: AppThemeData.danger300,
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                side: const BorderSide(color: AppThemeData.danger300),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: _buildVerticalImageGallery(device, isDark),
            ),
            spaceW(width: 24),
            Expanded(
              flex: 6,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleSection(device, isDark),
                    spaceH(height: 20),
                    _buildWarrantyCard(device, isDark),
                    spaceH(height: 20),
                    _buildAcquisitionCard(device, isDark),
                    spaceH(height: 20),
                    if (device.description != null && device.description!.isNotEmpty)
                      _buildDescriptionCard(device, isDark),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalImageGallery(DeviceModel device, bool isDark) {
    final images = device.deviceImageUrls;

    if (images == null || images.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
          borderRadius: BorderRadius.circular(20),
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
                title: 'No images',
                fontSize: 14,
                color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 85,
          height: 400,
          margin: const EdgeInsets.only(right: 16),
          child: ListView.builder(
            itemCount: images.length,
            itemBuilder: (context, index) {
              return Obx(() {
                final isSelected = controller.currentImageIndex.value == index;
                return GestureDetector(
                  onTap: () => controller.changeImage(index),
                  child: Container(
                    width: 75,
                    height: 75,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppThemeData.primary50 : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        images[index],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
                          child: Icon(
                            Icons.broken_image,
                            color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              });
            },
          ),
        ),
        Expanded(
          child: Obx(() => Container(
            height: 400,
            decoration: BoxDecoration(
              color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                images[controller.currentImageIndex.value],
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
          )),
        ),
      ],
    );
  }

  Widget _buildTitleSection(DeviceModel device, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(
          title: device.deviceName ?? 'Unknown Device',
          fontSize: 32,
          fontFamily: FontFamily.bold,
          color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
        ),
        spaceH(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppThemeData.primary50.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextCustom(
                title: device.condition ?? 'NEW',
                fontSize: 12,
                fontFamily: FontFamily.semiBold,
                color: AppThemeData.primary50,
              ),
            ),
            spaceW(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppThemeData.pending300.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextCustom(
                title: 'NEW ARRIVAL',
                fontSize: 12,
                fontFamily: FontFamily.semiBold,
                color: AppThemeData.pending400,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWarrantyCard(DeviceModel device, bool isDark) {
    final statusColor = controller.warrantyStatusColor;
    final statusText = controller.warrantyStatus;
    final days = controller.daysRemaining;
    final progress = days / 365 > 1 ? 1.0 : days / 365;
    final percent = (progress * 100).clamp(0, 100).toInt();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppThemeData.primary50.withValues(alpha: isDark ? 0.25 : 0.1),
            AppThemeData.primary4.withValues(alpha: isDark ? 0.15 : 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppThemeData.primary50.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppThemeData.primary50.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.verified_outlined,
                      color: AppThemeData.primary50,
                      size: 22,
                    ),
                  ),
                  spaceW(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextCustom(
                        title: 'WARRANTY COVERAGE',
                        fontSize: 13,
                        fontFamily: FontFamily.semiBold,
                        color: AppThemeData.primary50,
                      ),
                      TextCustom(
                        title: 'AppleCare+',
                        fontSize: 15,
                        fontFamily: FontFamily.bold,
                        color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextCustom(
                  title: statusText,
                  fontSize: 12,
                  fontFamily: FontFamily.semiBold,
                  color: statusColor,
                ),
              ),
            ],
          ),
          spaceH(height: 20),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),
              ),
              spaceW(width: 12),
              TextCustom(
                title: '$percent%',
                fontSize: 14,
                fontFamily: FontFamily.semiBold,
                color: statusColor,
              ),
            ],
          ),
          spaceH(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextCustom(
                      title: '$days',
                      fontSize: 48,
                      fontFamily: FontFamily.bold,
                      color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                    ),
                    TextCustom(
                      title: 'Days remaining',
                      fontSize: 14,
                      fontFamily: FontFamily.medium,
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
                    spaceH(height: 12),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(
          title: label,
          fontSize: 11,
          fontFamily: FontFamily.medium,
          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
        ),
        spaceH(height: 4),
        TextCustom(
          title: value,
          fontSize: 15,
          fontFamily: FontFamily.semiBold,
          color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
        ),
      ],
    );
  }

  Widget _buildAcquisitionCard(DeviceModel device, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(20),
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
          TextCustom(
            title: 'Acquisition Details',
            fontSize: 16,
            fontFamily: FontFamily.bold,
            color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
          ),
          spaceH(height: 20),
          _buildDetailRow(
            Icons.store_outlined,
            'Store',
            device.storeName?.isNotEmpty == true ? device.storeName! : 'Not specified',
            isDark,
          ),
          _buildDetailRow(
            Icons.calendar_today_outlined,
            'Purchase Date',
            device.formattedPurchaseDate,
            isDark,
          ),
          _buildDetailRow(
            Icons.attach_money,
            'Price',
            device.formattedPrice,
            isDark,
          ),
          spaceH(height: 16),
          _buildPremiumPaymentCard(device, isDark),
          spaceH(height: 8),
          _buildDetailRow(
            Icons.business_outlined,
            'Brand',
            device.brandName ?? 'Not specified',
            isDark,
          ),
          _buildDetailRow(
            Icons.category_outlined,
            'Category',
            device.category ?? 'Not specified',
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumPaymentCard(DeviceModel device, bool isDark) {
    final paymentMethod = controller.paymentMethodDisplay;
    final paymentIcon = _getPaymentIcon(paymentMethod);
    final maskedPayment = _getMaskedPayment(paymentMethod);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppThemeData.primary50.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              paymentIcon,
              color: AppThemeData.primary50,
              size: 24,
            ),
          ),
          spaceW(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(
                  title: 'Payment',
                  fontSize: 12,
                  fontFamily: FontFamily.medium,
                  color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                ),
                spaceH(height: 4),
                TextCustom(
                  title: maskedPayment,
                  fontSize: 16,
                  fontFamily: FontFamily.semiBold,
                  color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPaymentIcon(String method) {
    final lower = method.toLowerCase();
    if (lower.contains('visa')) return Icons.credit_card;
    if (lower.contains('mastercard')) return Icons.credit_card;
    if (lower.contains('paypal')) return Icons.payment;
    if (lower.contains('cash')) return Icons.money;
    if (lower.contains('upi')) return Icons.phone_android;
    return Icons.payment;
  }

  String _getMaskedPayment(String method) {
    if (method == 'Not specified') return method;
    return method.toUpperCase();
  }

  Widget _buildDetailRow(IconData icon, String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            ),
          ),
          spaceW(width: 14),
          Expanded(
            child: TextCustom(
              title: label,
              fontSize: 14,
              fontFamily: FontFamily.regular,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            ),
          ),
          TextCustom(
            title: value,
            fontSize: 15,
            fontFamily: FontFamily.semiBold,
            color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(DeviceModel device, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(20),
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
          TextCustom(
            title: 'Description',
            fontSize: 16,
            fontFamily: FontFamily.bold,
            color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
          ),
          spaceH(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextCustom(
              title: device.description ?? '',
              fontSize: 14,
              fontFamily: FontFamily.regular,
              color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
            ),
          ),
        ],
      ),
    );
  }
}