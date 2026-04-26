// lib/app/modules/subscription_details/views/subscription_details_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:maheksync/app/models/subscription_model.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/utils/mahek_responsive.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/network_image_widget.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'package:maheksync/app/widgets/water_bubble_progress.dart';
import '../controllers/subscription_details_controller.dart';

class SubscriptionDetailsView extends GetView<SubscriptionDetailsController> {
  SubscriptionDetailsView({super.key});

  final selectedImageIndex = 0.obs;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sub = controller.subscription.value;
    if (sub == null) return const SizedBox();

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 900;

    return Scaffold(
      backgroundColor: isDark ? AppThemeData.grey10 : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: isDark ? AppThemeData.primaryBlack : Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? AppThemeData.grey4 : AppThemeData.grey7, size: 20),
        ),
        title: TextCustom(title: sub.name ?? 'Details', fontSize: 18, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
        actions: [
          TextButton.icon(
            onPressed: () => _showRenewDialog(sub),
            icon: const Icon(Icons.refresh_rounded, size: 18, color: AppThemeData.success400),
            label: TextCustom(title: 'Renew', fontSize: 14, fontFamily: FontFamily.semiBold, color: AppThemeData.success400),
          ),
        ],
      ),
      body: isSmallScreen
          ? _buildSmallLayout(sub, isDark, context)
          : _buildDesktopLayout(sub, isDark, context),
    );
  }

  // ═══════════════════════════════════════
  // DESKTOP LAYOUT - Side by Side
  // ═══════════════════════════════════════
  Widget _buildDesktopLayout(SubscriptionModel sub, bool isDark, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── LEFT - Image Gallery (50% width) ───
        Expanded(
          flex: 5,
          child: _buildImageGallery(sub, isDark),
        ),
        // ─── RIGHT - Details (50% width) ───
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(sub, isDark),
                spaceH(height: 24),
                _buildWaterBubbleSection(sub, isDark),
                spaceH(height: 24),
                _buildDetailCard(sub, isDark),
                spaceH(height: 14),
                _buildDatesCard(sub, isDark),
                spaceH(height: 14),
                _buildPaymentCard(sub, isDark),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════
  // SMALL LAYOUT - Stacked
  // ═══════════════════════════════════════
  Widget _buildSmallLayout(SubscriptionModel sub, bool isDark, BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // ─── Image Gallery on top ───
          SizedBox(
            height: 300,
            child: _buildImageGallery(sub, isDark),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(sub, isDark),
                spaceH(height: 20),
                _buildWaterBubbleSection(sub, isDark),
                spaceH(height: 20),
                _buildDetailCard(sub, isDark),
                spaceH(height: 12),
                _buildDatesCard(sub, isDark),
                spaceH(height: 12),
                _buildPaymentCard(sub, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // IMAGE GALLERY
  // ═══════════════════════════════════════
  Widget _buildImageGallery(SubscriptionModel sub, bool isDark) {
    final images = sub.imageUrls ?? [];

    if (images.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppThemeData.primary50.withValues(alpha: isDark ? 0.15 : 0.08),
              AppThemeData.primary4.withValues(alpha: isDark ? 0.05 : 0.02),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppThemeData.primary50.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(Icons.image_outlined, size: 40, color: AppThemeData.primary50.withValues(alpha: 0.5)),
              ),
              spaceH(height: 16),
              TextCustom(title: 'No images available', fontSize: 15, fontFamily: FontFamily.medium, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // ─── Main Image - FULL SIZE ───
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? AppThemeData.grey9 : const Color(0xFFF1F5F9),
            ),
            child: Obx(() {
              final index = selectedImageIndex.value.clamp(0, images.length - 1);
              return Stack(
                fit: StackFit.expand,
                children: [
                  // Main Image - Fill the entire container
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: NetworkImageWidget(
                          imageUrl: images[index],
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  // Navigation Arrows
                  if (images.length > 1) ...[
                    Positioned(
                      left: 8,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: () => selectedImageIndex.value = (selectedImageIndex.value - 1 + images.length) % images.length,
                          child: Container(
                            padding: const EdgeInsets.all(10),
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
                      right: 8,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: () => selectedImageIndex.value = (selectedImageIndex.value + 1) % images.length,
                          child: Container(
                            padding: const EdgeInsets.all(10),
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
                  // Image Counter
                  if (images.length > 1)
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextCustom(
                          title: '${selectedImageIndex.value + 1} / ${images.length}',
                          fontSize: 12,
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

        // ─── Thumbnail Strip ───
        if (images.length > 1)
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppThemeData.primaryBlack : Colors.white,
              border: Border(top: BorderSide(color: isDark ? AppThemeData.grey8 : AppThemeData.grey3, width: 0.5)),
            ),
            child: Row(
              children: [
                TextCustom(title: '${images.length} images', fontSize: 11, fontFamily: FontFamily.medium, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                spaceW(width: 12),
                Expanded(
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: images.length,
                    separatorBuilder: (_, __) => spaceW(width: 8),
                    itemBuilder: (context, index) {
                      final isSelected = selectedImageIndex.value == index;
                      return GestureDetector(
                        onTap: () => selectedImageIndex.value = index,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? AppThemeData.primary50 : (isDark ? AppThemeData.grey7 : AppThemeData.grey4),
                              width: isSelected ? 2.5 : 1,
                            ),
                            boxShadow: isSelected ? [BoxShadow(color: AppThemeData.primary50.withValues(alpha: 0.3), blurRadius: 6)] : null,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: NetworkImageWidget(imageUrl: images[index], fit: BoxFit.cover),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ═══════════════════════════════════════
  // HEADER SECTION
  // ═══════════════════════════════════════
  Widget _buildHeaderSection(SubscriptionModel sub, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.primaryBlack : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [sub.statusColor.withValues(alpha: 0.2), sub.statusColor.withValues(alpha: 0.05)]),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: sub.statusColor.withValues(alpha: 0.3), width: 1.5),
            ),
            child: sub.hasIcon
                ? ClipRRect(borderRadius: BorderRadius.circular(18), child: NetworkImageWidget(imageUrl: sub.iconUrl!, fit: BoxFit.cover))
                : Icon(sub.statusIcon, color: sub.statusColor, size: 32),
          ),
          spaceW(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(title: sub.name ?? 'Unknown', fontSize: 20, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
                spaceH(height: 4),
                TextCustom(title: sub.category ?? 'OTHER', fontSize: 13, fontFamily: FontFamily.medium, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextCustom(title: sub.formattedPrice, fontSize: 26, fontFamily: FontFamily.bold, color: AppThemeData.primary50),
              spaceH(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: sub.statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                child: TextCustom(title: sub.status ?? 'ACTIVE', fontSize: 12, fontFamily: FontFamily.bold, color: sub.statusColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // WATER BUBBLE PROGRESS SECTION
  // ═══════════════════════════════════════
  Widget _buildWaterBubbleSection(SubscriptionModel sub, bool isDark) {
    final color = sub.isExpiringCritical ? AppThemeData.danger300 : (sub.isExpiringSoon ? AppThemeData.pending400 : AppThemeData.success400);
    final screenWidth = MediaQuery.of(Get.context!).size.width;
    final bubbleSize = screenWidth < 900 ? 140.0 : 160.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withValues(alpha: 0.12), color.withValues(alpha: 0.04)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextCustom(title: 'Subscription Progress', fontSize: 14, fontFamily: FontFamily.semiBold, color: isDark ? AppThemeData.grey3 : AppThemeData.grey7),
              TextCustom(title: '${sub.daysRemaining} days remaining', fontSize: 14, fontFamily: FontFamily.bold, color: color),
            ],
          ),
          spaceH(height: 20),
          // THE WATER BUBBLE
          Center(
            child: WaterBubbleProgress(
              progress: sub.remainingPercentage,
              size: bubbleSize,
              color: color,
              backgroundColor: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
              label: '${sub.daysRemaining}d',
              subLabel: 'remaining',
              isExpiring: sub.isExpiringSoon,
              animationDuration: 4,
            ),
          ),
          spaceH(height: 20),
          // Date Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextCustom(title: 'Start Date', fontSize: 11, fontFamily: FontFamily.medium, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                  TextCustom(title: sub.formattedStartDate, fontSize: 13, fontFamily: FontFamily.semiBold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextCustom(title: '${(sub.remainingPercentage * 100).toInt()}% used', fontSize: 13, fontFamily: FontFamily.bold, color: color),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextCustom(title: 'Expiry Date', fontSize: 11, fontFamily: FontFamily.medium, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                  TextCustom(title: sub.formattedExpiryDate, fontSize: 13, fontFamily: FontFamily.semiBold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // DETAILS CARD
  // ═══════════════════════════════════════
  Widget _buildDetailCard(SubscriptionModel sub, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.primaryBlack : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Details', Icons.info_outline, AppThemeData.primary50, isDark),
          spaceH(height: 16),
          _buildDetailRow('Name', sub.name ?? '—', isDark),
          _buildDetailRow('Category', sub.category ?? '—', isDark),
          _buildDetailRow('Status', sub.status ?? '—', isDark, valueColor: sub.statusColor),
          _buildDetailRow('Price', sub.formattedPrice, isDark, valueColor: AppThemeData.primary50),
          _buildDetailRow('Billing', sub.billingCycleDisplay, isDark),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // DATES CARD
  // ═══════════════════════════════════════
  Widget _buildDatesCard(SubscriptionModel sub, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.primaryBlack : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Dates', Icons.calendar_month_rounded, AppThemeData.pending400, isDark),
          spaceH(height: 16),
          _buildDetailRow('Start Date', sub.formattedStartDate, isDark),
          _buildDetailRow('Expiry Date', sub.formattedExpiryDate, isDark, valueColor: sub.isExpiringSoon ? AppThemeData.danger300 : null),
          _buildDetailRow('Days Left', '${sub.daysRemaining} days', isDark, valueColor: sub.isExpiringCritical ? AppThemeData.danger300 : AppThemeData.success400),
          _buildDetailRow('Auto Renew', sub.autoRenew == true ? 'Yes' : 'No', isDark),
          _buildDetailRow('Reminder', '${sub.reminderDays ?? 3} days before', isDark),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // PAYMENT CARD
  // ═══════════════════════════════════════
  Widget _buildPaymentCard(SubscriptionModel sub, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.primaryBlack : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Payment & Notes', Icons.payment_rounded, AppThemeData.primary50, isDark),
          spaceH(height: 16),
          _buildDetailRow('Payment Method', sub.paymentMethodDisplay, isDark),
          _buildDetailRow('Monthly Cost', '₹${sub.monthlyPrice.toStringAsFixed(0)}', isDark),
          _buildDetailRow('Yearly Cost', '₹${sub.yearlyPrice.toStringAsFixed(0)}', isDark, valueColor: AppThemeData.primary50),
          if (sub.notes != null && sub.notes!.isNotEmpty) ...[
            spaceH(height: 12),
            Container(height: 1, color: isDark ? AppThemeData.grey8 : AppThemeData.grey3),
            spaceH(height: 12),
            TextCustom(title: sub.notes!, fontSize: 13, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey4 : AppThemeData.grey7, maxLine: 5),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // REUSABLE COMPONENTS
  // ═══════════════════════════════════════
  Widget _buildSectionHeader(String title, IconData icon, Color color, bool isDark) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18),
        ),
        spaceW(width: 10),
        TextCustom(title: title, fontSize: 15, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextCustom(title: label, fontSize: 13, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
          TextCustom(title: value, fontSize: 13, fontFamily: FontFamily.semiBold, color: valueColor ?? (isDark ? AppThemeData.grey1 : AppThemeData.grey10)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // RENEW DIALOG
  // ═══════════════════════════════════════
  Future<void> _showRenewDialog(SubscriptionModel sub) async {
    final selectedDate = await showDialog<DateTime>(
      context: Get.context!,
      builder: (context) {
        DateTime tempDate = DateTime.now().add(const Duration(days: 30));
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: AppThemeData.primaryBlack,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(color: AppThemeData.success400.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                      child: const Icon(Icons.refresh_rounded, color: AppThemeData.success400, size: 28),
                    ),
                    spaceH(height: 16),
                    TextCustom(title: 'Renew Subscription', fontSize: 18, fontFamily: FontFamily.bold, color: Colors.white),
                    spaceH(height: 8),
                    TextCustom(title: 'Set a new expiry date for "${sub.name}"', fontSize: 14, fontFamily: FontFamily.regular, color: AppThemeData.grey4, textAlign: TextAlign.center),
                    spaceH(height: 20),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(context: context, initialDate: tempDate, firstDate: DateTime.now(), lastDate: DateTime(2035));
                        if (picked != null) setState(() => tempDate = picked);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(color: AppThemeData.grey9, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppThemeData.grey7)),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_rounded, color: AppThemeData.primary50, size: 20),
                            spaceW(width: 12),
                            Text(DateFormat('dd MMMM yyyy').format(tempDate), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                    spaceH(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), side: BorderSide(color: AppThemeData.grey7)),
                            child: TextCustom(title: 'Cancel', fontSize: 14, color: AppThemeData.grey4),
                          ),
                        ),
                        spaceW(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context, tempDate),
                            style: ElevatedButton.styleFrom(backgroundColor: AppThemeData.success400, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            child: TextCustom(title: 'Confirm Renewal', fontSize: 14, fontFamily: FontFamily.semiBold, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (selectedDate != null) {
      await controller.renewSubscriptionWithCustomDate(selectedDate);
    }
  }
}