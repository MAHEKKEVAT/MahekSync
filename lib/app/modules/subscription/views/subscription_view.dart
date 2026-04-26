// lib/app/modules/subscription/views/subscription_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/utils/mahek_responsive.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/mahek_loader.dart';
import 'package:maheksync/app/widgets/network_image_widget.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import '../../../models/subscription_model.dart';
import '../controllers/subscription_controller.dart';

class SubscriptionView extends GetView<SubscriptionController> {
  const SubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppThemeData.grey10 : AppThemeData.grey2,
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: MahekLoader(message: 'Loading Subscriptions...', size: 50, textSize: 16),
          );
        }
        return _buildContent(isDark, context);
      }),
    );
  }

  Widget _buildContent(bool isDark, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isDark, context),
          spaceH(height: 20),
          _buildStatsSummary(isDark),
          spaceH(height: 20),
          _buildSearchAndFilters(isDark, context),
          spaceH(height: 20),
          Expanded(child: _buildSubscriptionsContent(isDark)),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppThemeData.primary50, AppThemeData.primary4]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: AppThemeData.primary50.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: const Icon(Icons.subscriptions_rounded, color: Colors.white, size: 26),
            ),
            spaceW(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(title: 'Subscriptions', fontSize: 24, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
                TextCustom(title: 'Track your recurring payments', fontSize: 13, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
              ],
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: controller.goToAdd,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const TextCustom(title: 'Add New', fontSize: 13, fontFamily: FontFamily.semiBold, color: Colors.white),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppThemeData.primary50,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSummary(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppThemeData.primary50.withValues(alpha: isDark ? 0.15 : 0.08), AppThemeData.primary4.withValues(alpha: isDark ? 0.08 : 0.04)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppThemeData.primary50.withValues(alpha: 0.15)),
      ),
      child: Obx(() => Row(
        children: [
          _buildStatItem(Icons.money_rounded, 'Monthly Cost', '₹${controller.totalMonthlyCost.toStringAsFixed(0)}', AppThemeData.primary50, isDark),
          Container(width: 1, height: 40, color: isDark ? AppThemeData.grey8 : AppThemeData.grey3),
          _buildStatItem(Icons.check_circle_rounded, 'Active', '${controller.activeCount}', AppThemeData.success400, isDark),
          Container(width: 1, height: 40, color: isDark ? AppThemeData.grey8 : AppThemeData.grey3),
          _buildStatItem(Icons.warning_rounded, 'Expiring', '${controller.expiringSoonCount}', AppThemeData.pending400, isDark),
          Container(width: 1, height: 40, color: isDark ? AppThemeData.grey8 : AppThemeData.grey3),
          _buildStatItem(Icons.trending_up_rounded, 'Yearly', '₹${controller.yearlyProjectedCost.toStringAsFixed(0)}', AppThemeData.primary4, isDark),
        ],
      )),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color color, bool isDark) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          spaceH(height: 6),
          TextCustom(title: value, fontSize: 18, fontFamily: FontFamily.bold, color: color),
          TextCustom(title: label, fontSize: 10, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(bool isDark, BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.02), blurRadius: 8, offset: const Offset(0, 2))],
                  border: Border.all(color: isDark ? AppThemeData.grey8 : AppThemeData.grey3, width: 0.5),
                ),
                child: TextField(
                  onChanged: controller.updateSearchQuery,
                  style: TextStyle(fontFamily: FontFamily.medium, fontSize: 14, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
                  decoration: InputDecoration(
                    hintText: 'Search subscriptions...',
                    hintStyle: TextStyle(fontFamily: FontFamily.regular, fontSize: 14, color: isDark ? AppThemeData.grey6 : AppThemeData.grey5),
                    prefixIcon: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppThemeData.primary50.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                      child: Icon(Icons.search_rounded, color: AppThemeData.primary50, size: 20),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Colors.transparent,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),
            spaceW(width: 10),
            _buildViewToggle(Icons.grid_view_rounded, controller.isGridView.value, () => controller.isGridView.value = true, isDark),
            _buildViewToggle(Icons.list_rounded, !controller.isGridView.value, () => controller.isGridView.value = false, isDark),
          ],
        ),
        spaceH(height: 12),
        // Category Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Obx(() => Row(
            children: controller.categories.where((c) => c != 'ALL').map((cat) {
              final isSelected = controller.selectedCategories.contains(cat);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => controller.toggleCategory(cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppThemeData.primary50.withValues(alpha: 0.2) : (isDark ? AppThemeData.grey9 : AppThemeData.grey1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? AppThemeData.primary50 : (isDark ? AppThemeData.grey8 : AppThemeData.grey3), width: 0.5),
                    ),
                    child: Text(cat, style: TextStyle(fontSize: 12, fontFamily: FontFamily.medium, color: isSelected ? AppThemeData.primary50 : (isDark ? AppThemeData.grey5 : AppThemeData.grey6))),
                  ),
                ),
              );
            }).toList(),
          )),
        ),
      ],
    );
  }

  Widget _buildViewToggle(IconData icon, bool isSelected, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: isSelected ? LinearGradient(colors: [AppThemeData.primary50, AppThemeData.primary4]) : null,
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? null : (isDark ? AppThemeData.grey9 : AppThemeData.grey1),
        ),
        child: Icon(icon, size: 20, color: isSelected ? Colors.white : (isDark ? AppThemeData.grey5 : AppThemeData.grey6)),
      ),
    );
  }

  Widget _buildSubscriptionsContent(bool isDark) {
    return Obx(() {
      if (controller.filteredSubscriptions.isEmpty) return _buildEmptyState(isDark);
      return controller.isGridView.value ? _buildGridView(isDark) : _buildListView(isDark);
    });
  }

  Widget _buildGridView(bool isDark) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 380,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: controller.filteredSubscriptions.length,
      itemBuilder: (context, index) => _buildGridCard(controller.filteredSubscriptions[index], isDark),
    );
  }

  Widget _buildListView(bool isDark) {
    return ListView.separated(
      itemCount: controller.filteredSubscriptions.length,
      separatorBuilder: (_, __) => spaceH(height: 12),
      itemBuilder: (context, index) => _buildListCard(controller.filteredSubscriptions[index], isDark),
    );
  }

  Widget _buildGridCard(SubscriptionModel sub, bool isDark) {
    final statusColor = sub.statusColor;
    return InkWell(
      onTap: () => controller.goToDetails(sub),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
          borderRadius: BorderRadius.circular(18),
          border: Border(left: BorderSide(color: statusColor, width: 3)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [statusColor.withValues(alpha: 0.2), statusColor.withValues(alpha: 0.05)]),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: sub.iconUrl != null && sub.iconUrl!.isNotEmpty
                            ? ClipRRect(borderRadius: BorderRadius.circular(14), child: NetworkImageWidget(imageUrl: sub.iconUrl!, fit: BoxFit.cover))
                            : Icon(Icons.subscriptions_rounded, color: statusColor, size: 22),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                        child: TextCustom(title: sub.status ?? 'ACTIVE', fontSize: 10, fontFamily: FontFamily.bold, color: statusColor),
                      ),
                    ],
                  ),
                  spaceH(height: 10),
                  TextCustom(title: sub.name ?? 'Unknown', fontSize: 16, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10, maxLine: 1),
                  spaceH(height: 4),
                  TextCustom(title: sub.formattedPrice, fontSize: 20, fontFamily: FontFamily.bold, color: AppThemeData.primary50),
                  spaceH(height: 10),
                  _buildProgressBar(sub),
                  spaceH(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoChip(Icons.calendar_today_rounded, 'Exp: ${sub.formattedExpiryDate}', isDark),
                      TextCustom(title: '${sub.daysRemaining}d left', fontSize: 12, fontFamily: FontFamily.semiBold, color: sub.isExpiringCritical ? AppThemeData.danger300 : AppThemeData.success400),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: isDark ? AppThemeData.grey8 : AppThemeData.grey3, width: 0.5))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildActionBtn(Icons.refresh_rounded, AppThemeData.success400, () => _showRenewDialog(sub), isDark),
                  spaceW(width: 8),
                  _buildActionBtn(Icons.edit_rounded, isDark ? AppThemeData.grey5 : AppThemeData.grey6, () => controller.goToEdit(sub), isDark),
                  spaceW(width: 8),
                  _buildActionBtn(Icons.delete_outline, AppThemeData.danger300, () => controller.deleteSubscription(sub), isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListCard(SubscriptionModel sub, bool isDark) {
    final statusColor = sub.statusColor;
    return InkWell(
      onTap: () => controller.goToDetails(sub),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: statusColor, width: 3)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [statusColor.withValues(alpha: 0.2), statusColor.withValues(alpha: 0.05)]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: sub.iconUrl != null && sub.iconUrl!.isNotEmpty
                  ? ClipRRect(borderRadius: BorderRadius.circular(14), child: NetworkImageWidget(imageUrl: sub.iconUrl!, fit: BoxFit.cover))
                  : Icon(Icons.subscriptions_rounded, color: statusColor, size: 26),
            ),
            spaceW(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextCustom(title: sub.name ?? 'Unknown', fontSize: 16, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
                      ),
                      TextCustom(title: sub.formattedPrice, fontSize: 16, fontFamily: FontFamily.bold, color: AppThemeData.primary50),
                    ],
                  ),
                  spaceH(height: 6),
                  Row(
                    children: [
                      _buildInfoChip(Icons.calendar_today_rounded, 'Exp: ${sub.formattedExpiryDate}', isDark),
                      spaceW(width: 10),
                      _buildInfoChip(Icons.category_rounded, sub.category ?? 'OTHER', isDark),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                        child: TextCustom(title: sub.status ?? 'ACTIVE', fontSize: 10, fontFamily: FontFamily.bold, color: statusColor),
                      ),
                    ],
                  ),
                  spaceH(height: 8),
                  _buildProgressBar(sub),
                ],
              ),
            ),
            spaceW(width: 10),
            Column(
              children: [
                _buildActionBtn(Icons.refresh_rounded, AppThemeData.success400, () => _showRenewDialog(sub), isDark),
                spaceH(height: 6),
                _buildActionBtn(Icons.edit_rounded, isDark ? AppThemeData.grey5 : AppThemeData.grey6, () => controller.goToEdit(sub), isDark),
                spaceH(height: 6),
                _buildActionBtn(Icons.delete_outline, AppThemeData.danger300, () => controller.deleteSubscription(sub), isDark),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(SubscriptionModel sub) {
    final color = sub.isExpiringCritical ? AppThemeData.danger300 : (sub.isExpiringSoon ? AppThemeData.pending400 : AppThemeData.success400);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: sub.remainingPercentage,
            minHeight: 4,
            backgroundColor: (AppThemeData.grey8).withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        spaceH(height: 4),
        TextCustom(title: '${(sub.remainingPercentage * 100).toInt()}% remaining', fontSize: 10, color: color.withValues(alpha: 0.8)),
      ],
    );
  }

  Widget _buildActionBtn(IconData icon, Color color, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 16)),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
        spaceW(width: 4),
        TextCustom(title: text, fontSize: 10, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
      ],
    );
  }

  Future<void> _showRenewDialog(SubscriptionModel sub) async {
    final selectedDate = await showDialog<DateTime>(
      context: Get.context!,
      builder: (context) {
        DateTime tempDate = DateTime.now().add(const Duration(days: 30)); // ✅ Non-nullable
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: const Color(0xFF1C1F26),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppThemeData.success400.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.refresh_rounded, color: AppThemeData.success400, size: 28),
                    ),
                    spaceH(height: 16),
                    const Text('Renew Subscription', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                    spaceH(height: 8),
                    Text(
                      'Set a new expiry date for "${sub.name}"',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    spaceH(height: 20),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: tempDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2035),
                        );
                        if (picked != null) {
                          setState(() => tempDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2E38),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          children: [
                             Icon(Icons.calendar_today_rounded, color: AppThemeData.primary50, size: 20),
                            spaceW(width: 12),
                            // ✅ tempDate is now non-nullable, so format() works fine
                            Text(
                              DateFormat('dd MMMM yyyy').format(tempDate),
                              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                            ),
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
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                            ),
                            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                          ),
                        ),
                        spaceW(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context, tempDate), // ✅ Pass non-nullable
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppThemeData.success400,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Confirm Renewal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
      final success = await controller.renewSubscriptionWithDate(sub, selectedDate);
      if (success) {
        Get.snackbar(
          'Success',
          'Subscription renewed until ${DateFormat('dd/MM/yyyy').format(selectedDate)}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppThemeData.success400,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    }
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.primaryBlack.withValues(alpha: 0.5) : AppThemeData.primaryWhite,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppThemeData.primary50.withValues(alpha: 0.15), AppThemeData.primary4.withValues(alpha: 0.08)]),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(Icons.subscriptions_outlined, size: 50, color: AppThemeData.primary50.withValues(alpha: 0.6)),
            ),
            spaceH(height: 20),
            TextCustom(title: 'No subscriptions yet', fontSize: 18, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey3 : AppThemeData.grey8),
            spaceH(height: 8),
            TextCustom(title: 'Track your recurring payments', fontSize: 14, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
            spaceH(height: 20),
            ElevatedButton.icon(
              onPressed: controller.goToAdd,
              icon: const Icon(Icons.add_rounded),
              label: const TextCustom(title: 'Add Subscription', fontSize: 14, fontFamily: FontFamily.semiBold, color: Colors.white),
              style: ElevatedButton.styleFrom(backgroundColor: AppThemeData.primary50, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            ),
          ],
        ),
      ),
    );
  }
}