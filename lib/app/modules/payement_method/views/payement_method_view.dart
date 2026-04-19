// lib/app/modules/payment_methods/views/payment_methods_view.dart
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/models/payment_method_model.dart';
import 'package:maheksync/app/modules/payement_method/controllers/payement_method_controller.dart';
import 'package:provider/provider.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/dark_theme_provider.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/network_image_widget.dart';
import 'package:maheksync/app/widgets/text_widget.dart';

class PaymentMethodsView extends GetView<PaymentMethodsController> {
  const PaymentMethodsView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDark = themeChange.isDarkTheme();

    return Scaffold(
      backgroundColor: isDark ? AppThemeData.grey10 : AppThemeData.grey2,
      body: Row(
        children: [
          // Left Panel - Add/Edit Form
          Container(
            width: 380,
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
                _buildHeader(isDark),
                spaceH(height: 24),
                _buildForm(isDark),
                const Spacer(),
                _buildActionButtons(isDark),
              ],
            ),
          ),

          // Right Panel - List View
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextCustom(
                    title: 'Payment Methods',
                    fontSize: 20,
                    fontFamily: FontFamily.bold,
                    color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                  ),
                  spaceH(height: 8),
                  Obx(() => TextCustom(
                    title: '${controller.paymentMethods.length} methods configured',
                    fontSize: 14,
                    fontFamily: FontFamily.regular,
                    color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                  )),
                  spaceH(height: 20),
                  Expanded(
                    child: _buildPaymentMethodsList(isDark),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Obx(() => Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppThemeData.primary50.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.payment_rounded,
            color: AppThemeData.primary50,
            size: 22,
          ),
        ),
        spaceW(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextCustom(
              title: controller.editingMethod.value == null
                  ? 'Add Payment Method'
                  : 'Edit Payment Method',
              fontSize: 18,
              fontFamily: FontFamily.bold,
              color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
            ),
            TextCustom(
              title: controller.editingMethod.value == null
                  ? 'Create a new payment option'
                  : 'Update existing payment option',
              fontSize: 13,
              fontFamily: FontFamily.regular,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            ),
          ],
        ),
      ],
    ));
  }

  Widget _buildForm(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon Upload
        TextCustom(
          title: 'ICON',
          fontSize: 11,
          fontFamily: FontFamily.medium,
          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
        ),
        spaceH(height: 8),
        _buildIconUploader(isDark),
        spaceH(height: 20),

        // Name Field
        TextCustom(
          title: 'PAYMENT METHOD NAME',
          fontSize: 11,
          fontFamily: FontFamily.medium,
          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
        ),
        spaceH(height: 8),
        TextField(
          controller: controller.nameController,
          style: TextStyle(
            fontFamily: FontFamily.regular,
            fontSize: 14,
            color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
          ),
          decoration: InputDecoration(
            hintText: 'e.g. Credit Card, PayPal, UPI',
            hintStyle: TextStyle(
              fontFamily: FontFamily.regular,
              fontSize: 14,
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
              borderSide: const BorderSide(
                color: Color(0xFF5D54F2),
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconUploader(bool isDark) {
    return Obx(() {
      final editingMethod = controller.editingMethod.value;
      final selectedIcon = controller.selectedIcon.value;
      final iconBytes = controller.iconBytes.value;

      String? displayUrl;
      if (selectedIcon != null && iconBytes != null) {
        // Show newly selected image
        return _buildIconPreview(isDark, memoryImage: iconBytes);
      } else if (editingMethod != null && editingMethod.pIcon != null && editingMethod.pIcon!.isNotEmpty) {
        // Show existing image from URL
        return _buildIconPreview(isDark, networkUrl: editingMethod.pIcon);
      } else {
        // Show upload button
        return _buildUploadButton(isDark);
      }
    });
  }

  Widget _buildUploadButton(bool isDark) {
    return GestureDetector(
      onTap: controller.pickIcon,
      child: Container(
        width: 350,
        height: 200,
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppThemeData.grey7 : AppThemeData.grey4,
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 32,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            ),
            spaceH(height: 8),
            TextCustom(
              title: 'Click to upload icon',
              fontSize: 12,
              fontFamily: FontFamily.medium,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            ),
            TextCustom(
              title: 'PNG, JPG (max 512x512)',
              fontSize: 10,
              fontFamily: FontFamily.regular,
              color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconPreview(bool isDark, {Uint8List? memoryImage, String? networkUrl}) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppThemeData.grey7 : AppThemeData.grey4,
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                color: isDark ? AppThemeData.grey8 : AppThemeData.grey2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: memoryImage != null
                    ? Image.memory(memoryImage, fit: BoxFit.contain)
                    : networkUrl != null
                    ? NetworkImageWidget(
                  imageUrl: networkUrl,
                  fit: BoxFit.contain,
                )
                    : const SizedBox(),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              children: [
                GestureDetector(
                  onTap: controller.pickIcon,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppThemeData.primary50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
                spaceW(width: 4),
                GestureDetector(
                  onTap: controller.removeIcon,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppThemeData.danger300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Obx(() {
      final isEditing = controller.editingMethod.value != null;

      return Row(
        children: [
          if (isEditing)
            Expanded(
              child: OutlinedButton(
                onPressed: controller.cancelEditing,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(
                    color: isDark ? AppThemeData.grey7 : AppThemeData.grey4,
                  ),
                ),
                child: TextCustom(
                  title: 'Cancel',
                  fontSize: 14,
                  fontFamily: FontFamily.medium,
                  color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
                ),
              ),
            ),
          if (isEditing) spaceW(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: controller.isSaving.value ? null : controller.savePaymentMethod,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemeData.primary50,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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
                title: isEditing ? 'Update Method' : 'Add Method',
                fontSize: 14,
                fontFamily: FontFamily.semiBold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildPaymentMethodsList(bool isDark) {
    return Obx(() {
      if (controller.paymentMethods.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.payment_outlined,
                size: 64,
                color: isDark ? AppThemeData.grey7 : AppThemeData.grey4,
              ),
              spaceH(height: 16),
              TextCustom(
                title: 'No payment methods yet',
                fontSize: 16,
                fontFamily: FontFamily.medium,
                color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
              ),
              spaceH(height: 8),
              TextCustom(
                title: 'Add your first payment method using the form',
                fontSize: 14,
                fontFamily: FontFamily.regular,
                color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        itemCount: controller.paymentMethods.length,
        separatorBuilder: (_, __) => spaceH(height: 12),
        itemBuilder: (context, index) {
          final method = controller.paymentMethods[index];
          return _buildPaymentMethodCard(method, isDark);
        },
      );
    });
  }

  Widget _buildPaymentMethodCard(PaymentMethodModel method, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
              borderRadius: BorderRadius.circular(12),
            ),
            child: method.pIcon != null && method.pIcon!.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: NetworkImageWidget(
                imageUrl: method.pIcon!,
                fit: BoxFit.contain,
              ),
            )
                : Icon(
              Icons.payment,
              color: AppThemeData.primary50,
              size: 28,
            ),
          ),
          spaceW(width: 16),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(
                  title: method.pName ?? 'Unknown',
                  fontSize: 16,
                  fontFamily: FontFamily.semiBold,
                  color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                ),
                spaceH(height: 4),
                TextCustom(
                  title: 'Added: ${method.formattedDate}',
                  fontSize: 12,
                  fontFamily: FontFamily.regular,
                  color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                ),
              ],
            ),
          ),

          // Actions
          Row(
            children: [
              IconButton(
                onPressed: () => controller.startEditing(method),
                icon: Icon(
                  Icons.edit_outlined,
                  color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
                  size: 20,
                ),
              ),
              IconButton(
                onPressed: () => controller.deletePaymentMethod(method),
                icon: Icon(
                  Icons.delete_outline,
                  color: AppThemeData.danger300,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}