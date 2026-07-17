// lib/app/modules/subscription/views/subscription_view.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/mahek_loader.dart';
import 'package:maheksync/app/widgets/network_image_widget.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'package:maheksync/app/constant/round_shape_button.dart';
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isDark, context),
          spaceH(height: 20),
          _buildStatsRow(isDark),
          spaceH(height: 20),
          _buildSearchBar(isDark),
          spaceH(height: 14),
          _buildCategoryChips(isDark),
          spaceH(height: 14),
          _buildSortAndToggleRow(isDark, context: context),
          spaceH(height: 16),
          _buildSubscriptionsContent(isDark),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════
  Widget _buildHeader(bool isDark, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextCustom(title: 'Subscriptions', fontSize: 26, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
            spaceH(height: 4),
            TextCustom(title: 'Manage and track all your recurring payments', fontSize: 13, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
          ],
        ),
        RoundShapeButton(
          title: 'Add New',
          buttonColor: AppThemeData.primary50,
          buttonTextColor: Colors.white,
          onTap: controller.goToAdd,
          height: 48,
          width: 150,
          borderRadius: 14,
          titleWidget: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_rounded, size: 18, color: Colors.white),
              spaceW(width: 6),
              const TextCustom(title: 'Add New', fontSize: 13, fontFamily: FontFamily.semiBold, color: Colors.white),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════
  // STATS ROW - 4 separate glass cards
  // ═══════════════════════════════════════
  Widget _buildStatsRow(bool isDark) {
    return Obx(() => Row(
      children: [
        _buildStatCard(Icons.account_balance_wallet_rounded, 'TOTAL SUBSCRIPTIONS', '${controller.totalCount}', 'Active subscriptions', AppThemeData.neonPurple, isDark),
        spaceW(width: 12),
        _buildStatCard(Icons.payments_rounded, 'TOTAL SPEND', '₹${controller.totalMonthlyCost.toStringAsFixed(0)}', 'Across all subscriptions', AppThemeData.neonMint, isDark),
        spaceW(width: 12),
        _buildStatCard(Icons.event_rounded, 'NEXT BILLING', controller.formattedNextBilling, 'Upcoming payment', AppThemeData.neonOrange, isDark),
        spaceW(width: 12),
        _buildStatCard(Icons.pie_chart_rounded, 'CATEGORY BREAKDOWN', '${controller.categoryCount}', 'Total categories', AppThemeData.neonBlue, isDark),
      ],
    ));
  }

  Widget _buildStatCard(IconData icon, String label, String value, String sub, Color color, bool isDark) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.surfaceElevated : AppThemeData.primaryWhite,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.15), width: 1),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: isDark ? 0.08 : 0.05), blurRadius: 16, offset: const Offset(0, 4)),
            BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.03), blurRadius: 10, offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.3)]),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [color.withValues(alpha: 0.25), color.withValues(alpha: 0.08)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  spaceW(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextCustom(title: label, fontSize: 9, fontFamily: FontFamily.medium, color: color.withValues(alpha: 0.7)),
                        spaceH(height: 4),
                        TextCustom(title: value, fontSize: 20, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
                        spaceH(height: 2),
                        TextCustom(title: sub, fontSize: 10, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey6 : AppThemeData.grey5),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    height: 30,
                    child: CustomPaint(painter: _SparklinePainter(color: color)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // SEARCH BAR
  // ═══════════════════════════════════════
  Widget _buildSearchBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.surfaceElevated : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppThemeData.primary50.withValues(alpha: isDark ? 0.04 : 0.03), blurRadius: 12, offset: const Offset(0, 2)),
          BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
        border: Border.all(color: isDark ? AppThemeData.surfaceBorder : AppThemeData.grey3, width: 0.5),
      ),
      child: TextField(
        onChanged: controller.updateSearchQuery,
        style: TextStyle(fontFamily: FontFamily.medium, fontSize: 14, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
        decoration: InputDecoration(
          hintText: 'Search subscriptions...',
          hintStyle: TextStyle(fontFamily: FontFamily.regular, fontSize: 14, color: isDark ? AppThemeData.grey6 : AppThemeData.grey5),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppThemeData.primary50.withValues(alpha: 0.2), AppThemeData.primary50.withValues(alpha: 0.08)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.search_rounded, color: AppThemeData.primary50, size: 20),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // CATEGORY CHIPS
  // ═══════════════════════════════════════
  Widget _buildCategoryChips(bool isDark) {
    return SizedBox(
      height: 40,
      child: Obx(() {
        final selectedCount = controller.selectedCategories.length;
        final selectedSnapshot = List<String>.from(controller.selectedCategories);
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: controller.categories.length,
          separatorBuilder: (context, index) => spaceW(width: 8),
          itemBuilder: (context, index) {
            final cat = controller.categories[index];
            final isAll = cat == 'ALL';
            final isSelected = isAll
                ? selectedCount == 0
                : selectedSnapshot.contains(cat);
            return GestureDetector(
              onTap: () {
                if (isAll) {
                  controller.selectedCategories.clear();
                  controller.sortBy(controller.selectedSortOption.value);
                } else {
                  controller.toggleCategory(cat);
                }
              },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppThemeData.primary50
                    : (isDark ? AppThemeData.surfaceElevated : AppThemeData.grey1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppThemeData.primary50
                      : (isDark ? AppThemeData.surfaceBorder : AppThemeData.grey3),
                  width: isSelected ? 1 : 0.5,
                ),
                boxShadow: isSelected
                    ? [BoxShadow(color: AppThemeData.primary50.withValues(alpha: 0.3), blurRadius: 10)]
                    : null,
              ),
              child: Text(
                cat,
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: FontFamily.medium,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? AppThemeData.grey4 : AppThemeData.grey6),
                ),
              ),
            ),
          );
        },
      );
      }),
    );
  }

  // ═══════════════════════════════════════
  // SORT + VIEW TOGGLE ROW
  // ═══════════════════════════════════════
  Widget _buildSortAndToggleRow(bool isDark, {required BuildContext context}) {
    return Row(
      children: [
        // Sort dropdown
        GestureDetector(
          onTap: () => _showSortMenu(isDark, context: context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? AppThemeData.grey8 : AppThemeData.grey3, width: 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.sort_rounded, size: 18, color: isDark ? AppThemeData.grey4 : AppThemeData.grey7),
                spaceW(width: 6),
                Obx(() => TextCustom(
                  title: controller.selectedSortOption.value,
                  fontSize: 12,
                  fontFamily: FontFamily.medium,
                  color: isDark ? AppThemeData.grey3 : AppThemeData.grey8,
                )),
                spaceW(width: 4),
                Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
              ],
            ),
          ),
        ),
        const Spacer(),
        // View toggle
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? AppThemeData.grey8 : AppThemeData.grey3, width: 0.5),
          ),
          child: Row(
            children: [
              _buildViewToggle(Icons.grid_view_rounded, controller.isGridView.value, () => controller.isGridView.value = true, isDark),
              _buildViewToggle(Icons.list_rounded, !controller.isGridView.value, () => controller.isGridView.value = false, isDark),
            ],
          ),
        ),
      ],
    );
  }

  void _showSortMenu(bool isDark, {required BuildContext context}) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      color: isDark ? AppThemeData.grey9 : AppThemeData.primaryWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      position: position,
      items: controller.sortOptions.map((option) {
        final isSelected = controller.selectedSortOption.value == option;
        return PopupMenuItem<String>(
          value: option,
          child: Row(
            children: [
              if (isSelected)
                Icon(Icons.check_rounded, size: 16, color: AppThemeData.primary50)
              else
                spaceW(width: 16),
              spaceW(width: 8),
              TextCustom(
                title: option,
                fontSize: 13,
                fontFamily: isSelected ? FontFamily.bold : FontFamily.regular,
                color: isSelected ? AppThemeData.primary50 : (isDark ? AppThemeData.grey3 : AppThemeData.grey10),
              ),
            ],
          ),
        );
      }).toList(),
    ).then((value) {
      if (value != null) controller.sortBy(value);
    });
  }

  Widget _buildViewToggle(IconData icon, bool isSelected, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: isSelected ? LinearGradient(colors: [AppThemeData.primary50, AppThemeData.primary4]) : null,
          borderRadius: BorderRadius.circular(10),
          color: isSelected ? null : Colors.transparent,
          boxShadow: isSelected ? [BoxShadow(color: AppThemeData.primary50.withValues(alpha: 0.3), blurRadius: 8)] : null,
        ),
        child: Icon(icon, size: 18, color: isSelected ? Colors.white : (isDark ? AppThemeData.grey5 : AppThemeData.grey6)),
      ),
    );
  }

  // ═══════════════════════════════════════
  // CONTENT
  // ═══════════════════════════════════════
  Widget _buildSubscriptionsContent(bool isDark) {
    return Obx(() {
      if (controller.filteredSubscriptions.isEmpty) return _buildEmptyState(isDark);
      return controller.isGridView.value ? _buildGridView(isDark) : _buildListView(isDark);
    });
  }

  Widget _buildGridView(bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 420,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.1,
      ),
      itemCount: controller.filteredSubscriptions.length,
      itemBuilder: (context, index) => _buildGridCard(controller.filteredSubscriptions[index], isDark, context: context),
    );
  }

  Widget _buildListView(bool isDark) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.filteredSubscriptions.length,
      separatorBuilder: (context, index) => spaceH(height: 14),
      itemBuilder: (context, index) => _buildListCard(controller.filteredSubscriptions[index], isDark, context: context),
    );
  }

  // ═══════════════════════════════════════
  // GRID CARD (matches screenshot)
  // ═══════════════════════════════════════
  Widget _buildGridCard(SubscriptionModel sub, bool isDark, {required BuildContext context}) {
    final statusColor = sub.statusColor;
    final usedPercent = ((1 - sub.remainingPercentage) * 100).toInt();
    final usedColor = sub.isExpiringCritical ? AppThemeData.danger300 : (sub.isExpiringSoon ? AppThemeData.pending400 : AppThemeData.primary50);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.surfaceElevated : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: statusColor.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(color: statusColor.withValues(alpha: isDark ? 0.06 : 0.04), blurRadius: 16, offset: const Offset(0, 4)),
          BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [statusColor, statusColor.withValues(alpha: 0.2)]),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
          ),
          // ─── TOP SECTION ───
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon + Name + Status + Menu
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [statusColor.withValues(alpha: 0.15), statusColor.withValues(alpha: 0.05)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: sub.hasIcon
                            ? ClipRRect(borderRadius: BorderRadius.circular(14), child: NetworkImageWidget(imageUrl: sub.iconUrl!, fit: BoxFit.cover, height: 48, width: 48))
                            : Icon(Icons.subscriptions_rounded, color: statusColor, size: 24),
                      ),
                      spaceW(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextCustom(title: sub.name ?? 'Unknown', fontSize: 16, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10, maxLine: 1),
                            spaceH(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                              child: TextCustom(title: sub.formattedCategory, fontSize: 10, fontFamily: FontFamily.medium, color: statusColor),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [statusColor.withValues(alpha: 0.18), statusColor.withValues(alpha: 0.08)]),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextCustom(title: sub.status ?? 'ACTIVE', fontSize: 10, fontFamily: FontFamily.bold, color: statusColor),
                      ),
                      spaceW(width: 6),
                      GestureDetector(
                        onTap: () => _showCardMenu(sub, isDark, context: context),
                        child: Icon(Icons.more_vert_rounded, size: 18, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                      ),
                    ],
                  ),
                  spaceH(height: 14),
                  // Price + Progress bar
                  TextCustom(title: sub.formattedPrice, fontSize: 22, fontFamily: FontFamily.bold, color: statusColor),
                  spaceH(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [BoxShadow(color: usedColor.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 1))],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: sub.remainingPercentage,
                        minHeight: 6,
                        backgroundColor: (isDark ? AppThemeData.grey8 : AppThemeData.grey3).withValues(alpha: 0.4),
                        valueColor: AlwaysStoppedAnimation<Color>(usedColor),
                      ),
                    ),
                  ),
                  spaceH(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextCustom(title: '$usedPercent% used', fontSize: 11, fontFamily: FontFamily.medium, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                      TextCustom(title: '${sub.daysRemaining} days left', fontSize: 11, fontFamily: FontFamily.semiBold, color: sub.isExpiringCritical ? AppThemeData.danger300 : AppThemeData.success400),
                    ],
                  ),
                  spaceH(height: 4),
                  TextCustom(title: 'Renews on ${sub.formattedNextBillingDate}', fontSize: 11, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey6 : AppThemeData.grey5),
                ],
              ),
            ),
          ),
          // ─── BILLING ROW ───
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: isDark ? 0.04 : 0.03),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(18), bottomRight: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Icon(Icons.replay_rounded, size: 14, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                spaceW(width: 6),
                TextCustom(title: 'Billing Cycle', fontSize: 10, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                spaceW(width: 4),
                TextCustom(title: sub.billingCycleDisplay, fontSize: 11, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey3 : AppThemeData.grey8),
                const Spacer(),
                Icon(Icons.event_rounded, size: 14, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                spaceW(width: 6),
                TextCustom(title: 'Next Billing', fontSize: 10, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                spaceW(width: 4),
                TextCustom(title: sub.formattedNextBillingDate, fontSize: 11, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey3 : AppThemeData.grey8),
              ],
            ),
          ),
          // ─── ACTION BUTTONS ───
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: isDark ? AppThemeData.surfaceBorder : AppThemeData.grey3, width: 0.5)),
            ),
            child: Row(
              children: [
                Expanded(child: _buildActionChip(Icons.visibility_rounded, 'View Details', AppThemeData.primary50, () => controller.goToDetails(sub), isDark, isPrimary: true)),
                spaceW(width: 8),
                Expanded(child: _buildActionChip(Icons.edit_rounded, 'Edit', isDark ? AppThemeData.grey4 : AppThemeData.grey7, () => controller.goToEdit(sub), isDark)),
                spaceW(width: 8),
                Expanded(child: _buildActionChip(Icons.cancel_outlined, 'Cancel', AppThemeData.danger300, () => controller.deleteSubscription(sub), isDark)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // LIST CARD (matches screenshot)
  // ═══════════════════════════════════════
  Widget _buildListCard(SubscriptionModel sub, bool isDark, {required BuildContext context}) {
    final statusColor = sub.statusColor;
    final usedPercent = ((1 - sub.remainingPercentage) * 100).toInt();
    final usedColor = sub.isExpiringCritical ? AppThemeData.danger300 : (sub.isExpiringSoon ? AppThemeData.pending400 : AppThemeData.primary50);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.surfaceElevated : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: statusColor.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(color: statusColor.withValues(alpha: isDark ? 0.06 : 0.04), blurRadius: 16, offset: const Offset(0, 4)),
          BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [statusColor, statusColor.withValues(alpha: 0.2)]),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [statusColor.withValues(alpha: 0.15), statusColor.withValues(alpha: 0.05)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: sub.hasIcon
                      ? ClipRRect(borderRadius: BorderRadius.circular(14), child: NetworkImageWidget(imageUrl: sub.iconUrl!, fit: BoxFit.cover, height: 52, width: 52))
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [statusColor.withValues(alpha: 0.18), statusColor.withValues(alpha: 0.08)]),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextCustom(title: sub.status ?? 'ACTIVE', fontSize: 10, fontFamily: FontFamily.bold, color: statusColor),
                          ),
                          spaceW(width: 6),
                          GestureDetector(
                            onTap: () => _showCardMenu(sub, isDark, context: context),
                            child: Icon(Icons.more_vert_rounded, size: 18, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                          ),
                        ],
                      ),
                      spaceH(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                        child: TextCustom(title: sub.formattedCategory, fontSize: 10, fontFamily: FontFamily.medium, color: statusColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Price + Progress
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                TextCustom(title: sub.formattedPrice, fontSize: 20, fontFamily: FontFamily.bold, color: statusColor),
                spaceW(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [BoxShadow(color: usedColor.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 1))],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: sub.remainingPercentage,
                            minHeight: 6,
                            backgroundColor: (isDark ? AppThemeData.grey8 : AppThemeData.grey3).withValues(alpha: 0.4),
                            valueColor: AlwaysStoppedAnimation<Color>(usedColor),
                          ),
                        ),
                      ),
                      spaceH(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextCustom(title: '$usedPercent% used', fontSize: 11, fontFamily: FontFamily.medium, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                          TextCustom(title: '${sub.daysRemaining} days left', fontSize: 11, fontFamily: FontFamily.semiBold, color: sub.isExpiringCritical ? AppThemeData.danger300 : AppThemeData.success400),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          spaceH(height: 8),
          // Billing row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: isDark ? 0.04 : 0.03),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(18), bottomRight: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Icon(Icons.replay_rounded, size: 14, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                spaceW(width: 6),
                TextCustom(title: 'Billing Cycle', fontSize: 10, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                spaceW(width: 4),
                TextCustom(title: sub.billingCycleDisplay, fontSize: 11, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey3 : AppThemeData.grey8),
                const Spacer(),
                Icon(Icons.event_rounded, size: 14, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                spaceW(width: 6),
                TextCustom(title: 'Next Billing', fontSize: 10, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                spaceW(width: 4),
                TextCustom(title: sub.formattedNextBillingDate, fontSize: 11, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey3 : AppThemeData.grey8),
              ],
            ),
          ),
          // Action buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: isDark ? AppThemeData.surfaceBorder : AppThemeData.grey3, width: 0.5)),
            ),
            child: Row(
              children: [
                Expanded(child: _buildActionChip(Icons.visibility_rounded, 'View Details', AppThemeData.primary50, () => controller.goToDetails(sub), isDark, isPrimary: true)),
                spaceW(width: 8),
                Expanded(child: _buildActionChip(Icons.edit_rounded, 'Edit', isDark ? AppThemeData.grey4 : AppThemeData.grey7, () => controller.goToEdit(sub), isDark)),
                spaceW(width: 8),
                Expanded(child: _buildActionChip(Icons.cancel_outlined, 'Cancel', AppThemeData.danger300, () => controller.deleteSubscription(sub), isDark)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // SHARED WIDGETS
  // ═══════════════════════════════════════
  Widget _buildActionChip(IconData icon, String label, Color color, VoidCallback onTap, bool isDark, {bool isPrimary = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: isPrimary
            ? BoxDecoration(
                gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 2))],
              )
            : BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withValues(alpha: 0.15), width: 0.5),
              ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: isPrimary ? Colors.white : color),
            spaceW(width: 6),
            TextCustom(title: label, fontSize: 11, fontFamily: FontFamily.medium, color: isPrimary ? Colors.white : color),
          ],
        ),
      ),
    );
  }

  void _showCardMenu(SubscriptionModel sub, bool isDark, {required BuildContext context}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: (isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite).withValues(alpha: 0.95),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border.all(color: isDark ? AppThemeData.grey8 : AppThemeData.grey3, width: 0.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: isDark ? AppThemeData.grey7 : AppThemeData.grey4, borderRadius: BorderRadius.circular(2))),
                spaceH(height: 16),
                _buildMenuOption(Icons.visibility_rounded, 'View Details', AppThemeData.primary50, () { Get.back(); controller.goToDetails(sub); }, isDark),
                _buildMenuOption(Icons.edit_rounded, 'Edit', isDark ? AppThemeData.grey4 : AppThemeData.grey7, () { Get.back(); controller.goToEdit(sub); }, isDark),
                _buildMenuOption(Icons.refresh_rounded, 'Renew', AppThemeData.success400, () { Get.back(); _showRenewDialog(sub, context: context); }, isDark),
                _buildMenuOption(Icons.delete_outline, 'Delete', AppThemeData.danger300, () { Get.back(); controller.deleteSubscription(sub); }, isDark),
                spaceH(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuOption(IconData icon, String label, Color color, VoidCallback onTap, bool isDark) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: TextCustom(title: label, fontSize: 14, fontFamily: FontFamily.medium, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Future<void> _showRenewDialog(SubscriptionModel sub, {required BuildContext context}) async {
    final selectedDate = await showDialog<DateTime>(
      context: context,
      builder: (context) {
        DateTime tempDate = DateTime.now().add(const Duration(days: 30));
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
                      width: 56, height: 56,
                      decoration: BoxDecoration(color: AppThemeData.success400.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                      child: const Icon(Icons.refresh_rounded, color: AppThemeData.success400, size: 28),
                    ),
                    spaceH(height: 16),
                    const Text('Renew Subscription', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                    spaceH(height: 8),
                    Text('Set a new expiry date for "${sub.name}"', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14), textAlign: TextAlign.center),
                    spaceH(height: 20),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(context: context, initialDate: tempDate, firstDate: DateTime.now(), lastDate: DateTime(2035));
                        if (picked != null) setState(() => tempDate = picked);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(color: const Color(0xFF2A2E38), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, color: AppThemeData.success400, size: 20),
                            spaceW(width: 12),
                            Text(DateFormat('dd MMMM yyyy').format(tempDate), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                    spaceH(height: 24),
                    Row(
                      children: [
                        Expanded(child: RoundShapeButton(title: 'Cancel', buttonColor: Colors.transparent, buttonTextColor: Colors.white70, borderColor: Colors.white.withValues(alpha: 0.2), onTap: () => Navigator.pop(context), height: 48, borderRadius: 12)),
                        spaceW(width: 12),
                        Expanded(child: RoundShapeButton(title: 'Confirm Renewal', buttonColor: AppThemeData.success400, buttonTextColor: Colors.white, onTap: () => Navigator.pop(context, tempDate), height: 48, borderRadius: 12)),
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
        Get.snackbar('Success', 'Subscription renewed until ${DateFormat('dd/MM/yyyy').format(selectedDate)}', snackPosition: SnackPosition.BOTTOM, backgroundColor: AppThemeData.success400, colorText: Colors.white, margin: const EdgeInsets.all(16), borderRadius: 12);
      }
    }
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.primaryBlack.withValues(alpha: 0.5) : AppThemeData.primaryWhite,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100, height: 100,
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
            spaceH(height: 24),
            RoundShapeButton(
              title: 'Add Subscription',
              buttonColor: AppThemeData.primary50,
              buttonTextColor: Colors.white,
              onTap: controller.goToAdd,
              height: 48,
              borderRadius: 14,
              titleWidget: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                  spaceW(width: 8),
                  const TextCustom(title: 'Add Subscription', fontSize: 14, fontFamily: FontFamily.semiBold, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════
// SPARKLINE PAINTER (for stat cards)
// ═══════════════════════════════════════
class _SparklinePainter extends CustomPainter {
  final Color color;
  _SparklinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final points = [
      Offset(0, size.height * 0.7),
      Offset(size.width * 0.2, size.height * 0.4),
      Offset(size.width * 0.4, size.height * 0.6),
      Offset(size.width * 0.6, size.height * 0.2),
      Offset(size.width * 0.8, size.height * 0.5),
      Offset(size.width, size.height * 0.1),
    ];

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);

    // Glow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(path, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) => oldDelegate.color != color;
}

// ═══════════════════════════════════════
// FORMATTED CATEGORY ON MODEL
// ═══════════════════════════════════════
extension _SubscriptionModelExt on SubscriptionModel {
  String get formattedCategory {
    switch (category) {
      case 'ENTERTAINMENT': return 'Entertainment';
      case 'UTILITIES': return 'Utilities';
      case 'PRODUCTIVITY': return 'Productivity';
      case 'CLOUD': return 'Cloud';
      case 'MUSIC': return 'Music';
      case 'VIDEO': return 'Video';
      default: return category ?? 'Other';
    }
  }
}
