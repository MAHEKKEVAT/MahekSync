import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:maheksync/app/models/category_model.dart';
import 'package:maheksync/app/models/payment_method_model.dart';
import 'package:maheksync/app/routes/app_pages.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/utils/mahek_responsive.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/mahek_loader.dart';
import 'package:maheksync/app/widgets/network_image_widget.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import '../../../models/purchase_model.dart';
import '../controllers/my_purchases_controller.dart';

class MyPurchasesView extends GetView<MyPurchasesController> {
  const MyPurchasesView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppThemeData.grey10 : AppThemeData.grey2,
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: MahekLoader(
              message: 'Loading Purchases...',
              size: 50,
              textSize: 16,
            ),
          );
        }
        return _buildLayout(isDark, context);
      }),
    );
  }

  Widget _buildLayout(bool isDark, BuildContext context) {
    final isMobile = context.isMobile;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isDark, context),
              spaceH(height: isMobile ? 16 : 24),
              _buildStatsRow(isDark, context),
              spaceH(height: isMobile ? 20 : 28),
              _buildSectionHeader(isDark, context),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: spaceH(height: isMobile ? 12 : 16),
                ),
                controller.isGridView.value
                    ? _buildPurchaseGrid(isDark, context)
                    : _buildPurchaseList(isDark, context),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      spaceH(height: 20),
                      _buildLoadMore(isDark),
                      spaceH(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(bool isDark, BuildContext context) {
    final isMobile = context.isMobile;

    return Row(
      children: [
        Expanded(
          flex: isMobile ? 3 : 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextCustom(
                title: 'My Purchases',
                fontSize: isMobile ? 22 : 28,
                fontFamily: FontFamily.bold,
                color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              ),
              spaceH(height: 4),
              TextCustom(
                title: 'A curated gallery of your acquisitions',
                fontSize: 13,
                fontFamily: FontFamily.regular,
                color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
              ),
            ],
          ),
        ),
        spaceW(width: isMobile ? 12 : 20),
        if (!isMobile)
          Expanded(
            flex: 3,
            child: _buildSearchBar(isDark, context),
          ),
        if (!isMobile) spaceW(width: 12),
        _buildFiltersButton(isDark, context),
        spaceW(width: 10),
        _buildAddButton(isDark, context),
      ],
    );
  }

  Widget _buildSearchBar(bool isDark, BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.surfaceDeep : AppThemeData.grey1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? AppThemeData.surfaceBorder.withValues(alpha: 0.3)
              : AppThemeData.grey3,
        ),
      ),
      child: TextField(
        onChanged: controller.updateSearchQuery,
        style: TextStyle(
          fontFamily: FontFamily.medium,
          fontSize: 14,
          color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
        ),
        decoration: InputDecoration(
          hintText: 'Search your purchases...',
          hintStyle: TextStyle(
            fontFamily: FontFamily.regular,
            fontSize: 14,
            color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            size: 20,
          ),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppThemeData.primary50, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFiltersButton(bool isDark, BuildContext context) {
    return Obx(() {
      final hasFilters = controller.selectedCategory.value != null ||
          controller.selectedPaymentMethod.value != null ||
          controller.selectedStatus.value != 'ALL' ||
          controller.selectedDateRange.value != null;

      return GestureDetector(
        onTap: () => _showFilterSheet(isDark, context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: hasFilters
                ? AppThemeData.primary50.withValues(alpha: 0.12)
                : (isDark ? AppThemeData.surfaceDeep : AppThemeData.grey1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasFilters
                  ? AppThemeData.primary50.withValues(alpha: 0.3)
                  : (isDark
                      ? AppThemeData.surfaceBorder.withValues(alpha: 0.3)
                      : AppThemeData.grey3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.tune_rounded,
                size: 18,
                color: hasFilters
                    ? AppThemeData.primary50
                    : (isDark ? AppThemeData.grey4 : AppThemeData.grey7),
              ),
              spaceW(width: 6),
              Text(
                'Filters',
                style: TextStyle(
                  fontFamily: FontFamily.semiBold,
                  fontSize: 13,
                  color: hasFilters
                      ? AppThemeData.primary50
                      : (isDark ? AppThemeData.grey4 : AppThemeData.grey7),
                ),
              ),
              if (hasFilters) ...[
                spaceW(width: 6),
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppThemeData.primary50,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${_activeFilterCount()}',
                      style: const TextStyle(
                        fontFamily: FontFamily.bold,
                        fontSize: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  int _activeFilterCount() {
    int count = 0;
    if (controller.selectedCategory.value != null) count++;
    if (controller.selectedPaymentMethod.value != null) count++;
    if (controller.selectedStatus.value != 'ALL') count++;
    if (controller.selectedDateRange.value != null) count++;
    return count;
  }

  Widget _buildAddButton(bool isDark, BuildContext context) {
    final isMobile = context.isMobile;

    return GestureDetector(
      onTap: controller.goToAddPurchase,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 14 : 18,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppThemeData.primary50, AppThemeData.primary4],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppThemeData.primary50.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: Colors.white, size: 18),
            if (!isMobile) ...[
              spaceW(width: 6),
              Text(
                'Add Purchase',
                style: TextStyle(
                  fontFamily: FontFamily.semiBold,
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(bool isDark, BuildContext context) {
    final isMobile = context.isMobile;

    final stats = [
      _StatData(
        icon: Icons.shopping_bag_rounded,
        label: 'Total Purchases',
        value: '${controller.filteredPurchases.length}',
        sub: '+${controller.filteredPurchases.length} this month',
        color: AppThemeData.neonPurple,
      ),
      _StatData(
        icon: Icons.currency_rupee_rounded,
        label: 'Total Spent',
        value: '₹${controller.totalPortfolioValue.toStringAsFixed(0)}',
        sub: '+8% vs last month',
        color: AppThemeData.pending400,
      ),
      _StatData(
        icon: Icons.grid_view_rounded,
        label: 'Categories',
        value: '${controller.categoryItemCount.length}',
        sub: 'All categories',
        color: AppThemeData.neonTeal,
      ),
      _StatData(
        icon: Icons.calendar_month_rounded,
        label: 'This Month',
        value: '${controller.filteredPurchases.length}',
        sub: 'Purchases',
        color: AppThemeData.neonMint,
      ),
    ];

    return isMobile
        ? Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildStatCard(stats[0], isDark)),
                  spaceW(width: 12),
                  Expanded(child: _buildStatCard(stats[1], isDark)),
                ],
              ),
              spaceH(height: 12),
              Row(
                children: [
                  Expanded(child: _buildStatCard(stats[2], isDark)),
                  spaceW(width: 12),
                  Expanded(child: _buildStatCard(stats[3], isDark)),
                ],
              ),
            ],
          )
        : Row(
            children: stats
                .map((s) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: _buildStatCard(s, isDark),
                      ),
                    ))
                .toList(),
          );
  }

  Widget _buildStatCard(_StatData stat, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            stat.color.withValues(alpha: isDark ? 0.2 : 0.12),
            stat.color.withValues(alpha: isDark ? 0.08 : 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: stat.color.withValues(alpha: isDark ? 0.25 : 0.18),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  stat.color.withValues(alpha: 0.9),
                  stat.color,
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: stat.color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(stat.icon, size: 20, color: Colors.white),
          ),
          spaceW(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.label,
                  style: TextStyle(
                    fontFamily: FontFamily.medium,
                    fontSize: 11,
                    color: isDark ? AppThemeData.grey4 : AppThemeData.grey6,
                  ),
                ),
                spaceH(height: 3),
                Text(
                  stat.value,
                  style: TextStyle(
                    fontFamily: FontFamily.bold,
                    fontSize: 22,
                    color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                    letterSpacing: -0.5,
                  ),
                ),
                spaceH(height: 2),
                Text(
                  stat.sub,
                  style: TextStyle(
                    fontFamily: FontFamily.medium,
                    fontSize: 10,
                    color: stat.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(bool isDark, BuildContext context) {
    final isMobile = context.isMobile;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextCustom(
          title: 'Recent Purchases',
          fontSize: isMobile ? 18 : 22,
          fontFamily: FontFamily.bold,
          color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
        ),
        Row(
          children: [
            _buildSortDropdown(isDark, context: context),
            spaceW(width: 10),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppThemeData.surfaceDeep : AppThemeData.grey1,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark
                      ? AppThemeData.surfaceBorder.withValues(alpha: 0.3)
                      : AppThemeData.grey3,
                ),
              ),
              child: Row(
                children: [
                  _buildViewToggle(
                    icon: Icons.grid_view_rounded,
                    isSelected: controller.isGridView.value,
                    onTap: () => controller.isGridView.value = true,
                    isDark: isDark,
                  ),
                  _buildViewToggle(
                    icon: Icons.view_list_rounded,
                    isSelected: !controller.isGridView.value,
                    onTap: () => controller.isGridView.value = false,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSortDropdown(bool isDark, {required BuildContext context}) {
    return Obx(() => GestureDetector(
      onTap: () {
        _showSortMenu(isDark, context: context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.surfaceDeep : AppThemeData.grey1,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark
                ? AppThemeData.surfaceBorder.withValues(alpha: 0.3)
                : AppThemeData.grey3,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sort by: ${controller.selectedSortOption.value}',
              style: TextStyle(
                fontFamily: FontFamily.medium,
                fontSize: 12,
                color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
              ),
            ),
            spaceW(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            ),
          ],
        ),
      ),
    ));
  }

  void _showSortMenu(bool isDark, {required BuildContext context}) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx + renderBox.size.width - 220,
        offset.dy + 280,
        offset.dx + renderBox.size.width,
        offset.dy + 380,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? AppThemeData.surfaceElevated : Colors.white,
      elevation: 8,
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
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    fontFamily: isSelected ? FontFamily.semiBold : FontFamily.medium,
                    fontSize: 13,
                    color: isSelected
                        ? AppThemeData.primary50
                        : (isDark ? AppThemeData.grey1 : AppThemeData.grey10),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    ).then((value) {
      if (value != null) {
        controller.sortBy(value);
      }
    });
  }

  Widget _buildViewToggle({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? AppThemeData.primary50 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isSelected
              ? Colors.white
              : (isDark ? AppThemeData.grey5 : AppThemeData.grey6),
        ),
      ),
    );
  }

  Widget _buildPurchaseGrid(bool isDark, BuildContext context) {
    final isMobile = context.isMobile;

    if (controller.filteredPurchases.isEmpty) {
      return SliverToBoxAdapter(child: _buildEmptyState(isDark));
    }

    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 10),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: isMobile ? 400 : 300,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.85,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return _buildPurchaseCard(
              controller.filteredPurchases[index],
              isDark,
              context,
            );
          },
          childCount: controller.filteredPurchases.length,
        ),
      ),
    );
  }

  Widget _buildPurchaseList(bool isDark, BuildContext context) {
    if (controller.filteredPurchases.isEmpty) {
      return SliverToBoxAdapter(child: _buildEmptyState(isDark));
    }

    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 10),
      sliver: SliverList.separated(
        itemCount: controller.filteredPurchases.length,
        separatorBuilder: (_, _) => spaceH(height: 10),
        itemBuilder: (context, index) {
          return _buildPurchaseListTile(
            controller.filteredPurchases[index],
            isDark,
            context,
          );
        },
      ),
    );
  }

  Widget _buildPurchaseListTile(PurchaseModel purchase, bool isDark, BuildContext context) {
    final statusColor = _getStatusBgColor(purchase.status);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Get.toNamed(Routes.MY_PURCHASES_DETAILS, arguments: purchase),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.surfaceDeep : AppThemeData.grey1,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? AppThemeData.surfaceBorder.withValues(alpha: 0.15)
                  : AppThemeData.grey3.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isDark ? AppThemeData.grey9 : AppThemeData.grey2,
                  borderRadius: BorderRadius.circular(10),
                ),
                clipBehavior: Clip.antiAlias,
                child: purchase.primaryImageUrl.isNotEmpty
                    ? NetworkImageWidget(
                        imageUrl: purchase.primaryImageUrl,
                        fit: BoxFit.cover,
                      )
                    : Center(
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          size: 28,
                          color: isDark ? AppThemeData.grey7 : AppThemeData.grey4,
                        ),
                      ),
              ),
              spaceW(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        spaceW(width: 8),
                        Expanded(
                          child: Text(
                            purchase.assetName ?? 'Unknown',
                            style: TextStyle(
                              fontFamily: FontFamily.bold,
                              fontSize: 14,
                              color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    spaceH(height: 4),
                    Text(
                      purchase.category ?? 'Uncategorized',
                      style: TextStyle(
                        fontFamily: FontFamily.regular,
                        fontSize: 12,
                        color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                      ),
                    ),
                    spaceH(height: 6),
                    Row(
                      children: [
                        Text(
                          '₹${(purchase.price ?? 0).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontFamily: FontFamily.bold,
                            fontSize: 15,
                            color: AppThemeData.primary50,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          purchase.purchaseDate != null
                              ? DateFormat('dd MMM yyyy').format(purchase.purchaseDate!)
                              : '',
                          style: TextStyle(
                            fontFamily: FontFamily.medium,
                            fontSize: 11,
                            color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 12),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  (purchase.status ?? 'DELIVERED').toUpperCase(),
                  style: TextStyle(
                    fontFamily: FontFamily.bold,
                    fontSize: 9,
                    color: statusColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _showCardActions(purchase, isDark),
                child: Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isDark ? AppThemeData.surfaceMid : AppThemeData.grey2,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.more_vert_rounded,
                    size: 16,
                    color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPurchaseCard(PurchaseModel purchase, bool isDark, BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Get.toNamed(Routes.MY_PURCHASES_DETAILS, arguments: purchase),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.surfaceDeep : AppThemeData.grey1,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? AppThemeData.surfaceBorder.withValues(alpha: 0.15)
                  : AppThemeData.grey3.withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 260,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? AppThemeData.grey9 : AppThemeData.grey2,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: purchase.primaryImageUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: NetworkImageWidget(
                                height: 260,
                                imageUrl: purchase.primaryImageUrl,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Center(
                              child: Icon(
                                Icons.shopping_bag_outlined,
                                size: 36,
                                color: isDark ? AppThemeData.grey7 : AppThemeData.grey4,
                              ),
                            ),
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusBgColor(purchase.status),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          purchase.status ?? 'DELIVERED',
                          style: TextStyle(
                            fontFamily: FontFamily.bold,
                            fontSize: 9,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          purchase.purchaseDate != null
                              ? DateFormat('dd MMM yyyy').format(purchase.purchaseDate!)
                              : '',
                          style: TextStyle(
                            fontFamily: FontFamily.medium,
                            fontSize: 9,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      purchase.assetName ?? 'Unknown',
                      style: TextStyle(
                        fontFamily: FontFamily.bold,
                        fontSize: 13,
                        color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    spaceH(height: 2),
                    Text(
                      purchase.category ?? 'Uncategorized',
                      style: TextStyle(
                        fontFamily: FontFamily.regular,
                        fontSize: 11,
                        color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                      ),
                    ),
                    spaceH(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹${(purchase.price ?? 0).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontFamily: FontFamily.bold,
                            fontSize: 15,
                            color: AppThemeData.primary50,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showCardActions(purchase, isDark),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isDark ? AppThemeData.surfaceMid : AppThemeData.grey2,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.more_vert_rounded,
                              size: 16,
                              color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusBgColor(String? status) {
    switch (status) {
      case 'DELIVERED':
        return const Color(0xFF10B981);
      case 'IN TRANSIT':
        return const Color(0xFFF59E0B);
      case 'PRE-ORDER':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFF10B981);
    }
  }

  void _showCardActions(PurchaseModel purchase, bool isDark) {
    Get.bottomSheet(
      Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.surfaceElevated : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit_outlined, color: AppThemeData.primary50, size: 20),
              title: Text(
                'Edit Purchase',
                style: TextStyle(
                  fontFamily: FontFamily.medium,
                  fontSize: 14,
                  color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                ),
              ),
              onTap: () {
                Get.back();
                controller.goToEditPurchase(purchase);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppThemeData.danger300, size: 20),
              title: Text(
                'Delete Purchase',
                style: TextStyle(
                  fontFamily: FontFamily.medium,
                  fontSize: 14,
                  color: AppThemeData.danger300,
                ),
              ),
              onTap: () {
                Get.back();
                controller.deletePurchase(purchase);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppThemeData.primary50.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 36,
                color: AppThemeData.primary50.withValues(alpha: 0.5),
              ),
            ),
            spaceH(height: 16),
            Text(
              'No purchases found',
              style: TextStyle(
                fontFamily: FontFamily.bold,
                fontSize: 16,
                color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
              ),
            ),
            spaceH(height: 6),
            Text(
              'Start building your collection',
              style: TextStyle(
                fontFamily: FontFamily.regular,
                fontSize: 13,
                color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMore(bool isDark) {
    return Center(
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.surfaceDeep : AppThemeData.grey1,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? AppThemeData.surfaceBorder.withValues(alpha: 0.3)
                  : AppThemeData.grey3,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Load More',
                style: TextStyle(
                  fontFamily: FontFamily.semiBold,
                  fontSize: 13,
                  color: isDark ? AppThemeData.grey3 : AppThemeData.grey7,
                ),
              ),
              spaceW(width: 6),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: isDark ? AppThemeData.grey4 : AppThemeData.grey6,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterSheet(bool isDark, BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 20),
            decoration: BoxDecoration(
              color: isDark
                  ? AppThemeData.surfaceDeep.withValues(alpha: 0.85)
                  : Colors.white.withValues(alpha: 0.85),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(
                color: isDark
                    ? AppThemeData.surfaceBorder.withValues(alpha: 0.3)
                    : AppThemeData.grey3.withValues(alpha: 0.5),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? AppThemeData.grey7 : AppThemeData.grey4,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  spaceH(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextCustom(
                        title: 'Filters',
                        fontSize: 18,
                        fontFamily: FontFamily.bold,
                        color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                      ),
                      Obx(() {
                        final hasFilters = controller.selectedCategory.value != null ||
                            controller.selectedPaymentMethod.value != null ||
                            controller.selectedStatus.value != 'ALL' ||
                            controller.selectedDateRange.value != null;
                        if (!hasFilters) return const SizedBox.shrink();
                        return TextButton(
                          onPressed: () => controller.clearFilters(),
                          child: TextCustom(
                            title: 'Clear All',
                            fontSize: 13,
                            color: AppThemeData.danger300,
                          ),
                        );
                      }),
                    ],
                  ),
                  spaceH(height: 16),
                  _buildFilterLabel('Category', isDark),
                  spaceH(height: 8),
                  _buildCategoryDropdown(isDark),
                  spaceH(height: 16),
                  _buildFilterLabel('Payment Method', isDark),
                  spaceH(height: 8),
                  _buildPaymentDropdown(isDark),
                  spaceH(height: 16),
                  _buildFilterLabel('Status', isDark),
                  spaceH(height: 8),
                  _buildStatusDropdown(isDark),
                  spaceH(height: 16),
                  _buildFilterLabel('Date Range', isDark),
                  spaceH(height: 8),
                  _buildDateRangeButton(isDark, context),
                  spaceH(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppThemeData.primary50, AppThemeData.primary4],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppThemeData.primary50.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Apply Filters',
                            style: TextStyle(
                              fontFamily: FontFamily.semiBold,
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterLabel(String label, bool isDark) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: FontFamily.semiBold,
        fontSize: 13,
        color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
      ),
    );
  }

  Widget _buildCategoryDropdown(bool isDark) {
    return Obx(() => Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.surfaceMid : AppThemeData.grey2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppThemeData.surfaceBorder : AppThemeData.grey3,
        ),
      ),
      child: DropdownButton<CategoryModel>(
        value: controller.selectedCategory.value,
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: isDark ? AppThemeData.surfaceElevated : Colors.white,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
        ),
        hint: Row(
          children: [
            Icon(Icons.category_rounded, size: 18, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
            spaceW(width: 10),
            Text(
              'All Categories',
              style: TextStyle(
                fontFamily: FontFamily.regular,
                fontSize: 14,
                color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
              ),
            ),
          ],
        ),
        items: [
          DropdownMenuItem<CategoryModel>(
            value: null,
            child: Row(
              children: [
                Icon(Icons.all_inclusive_rounded, size: 18, color: AppThemeData.primary50),
                spaceW(width: 10),
                Text(
                  'All Categories',
                  style: TextStyle(
                    fontFamily: FontFamily.medium,
                    fontSize: 14,
                    color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                  ),
                ),
              ],
            ),
          ),
          ...controller.categories.map((c) {
            return DropdownMenuItem<CategoryModel>(
              value: c,
              child: Row(
                children: [
                  if (c.iconUrl != null && c.iconUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: NetworkImageWidget(
                        imageUrl: c.iconUrl!,
                        height: 22,
                        width: 22,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: AppThemeData.primary50.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(Icons.category_rounded, size: 14, color: AppThemeData.primary50),
                    ),
                  spaceW(width: 10),
                  Expanded(
                    child: Text(
                      c.name ?? 'Unknown',
                      style: TextStyle(
                        fontFamily: FontFamily.medium,
                        fontSize: 14,
                        color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
        onChanged: (v) => controller.filterByCategory(v),
      ),
    ));
  }

  Widget _buildPaymentDropdown(bool isDark) {
    return Obx(() => Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.surfaceMid : AppThemeData.grey2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppThemeData.surfaceBorder : AppThemeData.grey3,
        ),
      ),
      child: DropdownButton<PaymentMethodModel>(
        value: controller.selectedPaymentMethod.value,
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: isDark ? AppThemeData.surfaceElevated : Colors.white,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
        ),
        hint: Row(
          children: [
            Icon(Icons.payment_rounded, size: 18, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
            spaceW(width: 10),
            Text(
              'All Methods',
              style: TextStyle(
                fontFamily: FontFamily.regular,
                fontSize: 14,
                color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
              ),
            ),
          ],
        ),
        items: [
          DropdownMenuItem<PaymentMethodModel>(
            value: null,
            child: Row(
              children: [
                Icon(Icons.all_inclusive_rounded, size: 18, color: AppThemeData.primary50),
                spaceW(width: 10),
                Text(
                  'All Methods',
                  style: TextStyle(
                    fontFamily: FontFamily.medium,
                    fontSize: 14,
                    color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                  ),
                ),
              ],
            ),
          ),
          ...controller.paymentMethods.map((m) {
            return DropdownMenuItem<PaymentMethodModel>(
              value: m,
              child: Row(
                children: [
                  if (m.pIcon != null && m.pIcon!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: NetworkImageWidget(
                        imageUrl: m.pIcon!,
                        height: 22,
                        width: 22,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: AppThemeData.neonMint.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(Icons.payment_rounded, size: 14, color: AppThemeData.neonMint),
                    ),
                  spaceW(width: 10),
                  Expanded(
                    child: Text(
                      m.pName ?? 'Unknown',
                      style: TextStyle(
                        fontFamily: FontFamily.medium,
                        fontSize: 14,
                        color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
        onChanged: (v) => controller.filterByPaymentMethod(v),
      ),
    ));
  }

  Widget _buildStatusDropdown(bool isDark) {
    return Obx(() => Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.surfaceMid : AppThemeData.grey2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppThemeData.surfaceBorder : AppThemeData.grey3,
        ),
      ),
      child: DropdownButton<String>(
        value: controller.selectedStatus.value,
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: isDark ? AppThemeData.surfaceElevated : Colors.white,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
        ),
        items: controller.statusOptions.map((s) {
          final color = _getStatusBgColor(s);
          return DropdownMenuItem<String>(
            value: s,
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: s == 'ALL' ? AppThemeData.grey5 : color,
                    shape: BoxShape.circle,
                  ),
                ),
                spaceW(width: 10),
                Text(
                  s == 'ALL' ? 'All Status' : s,
                  style: TextStyle(
                    fontFamily: FontFamily.medium,
                    fontSize: 14,
                    color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (v) => controller.filterByStatus(v!),
      ),
    ));
  }

  Widget _buildDateRangeButton(bool isDark, BuildContext context) {
    return Obx(() => GestureDetector(
      onTap: () => _showDateRangeDialog(isDark, context: context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.surfaceMid : AppThemeData.grey2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: controller.selectedDateRange.value != null
                ? AppThemeData.primary50
                : (isDark ? AppThemeData.surfaceBorder : AppThemeData.grey3),
            width: controller.selectedDateRange.value != null ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month_rounded,
              size: 18,
              color: controller.selectedDateRange.value != null
                  ? AppThemeData.primary50
                  : (isDark ? AppThemeData.grey5 : AppThemeData.grey6),
            ),
            spaceW(width: 10),
            Expanded(
              child: Text(
                controller.selectedDateRange.value != null
                    ? '${DateFormat('dd MMM yyyy').format(controller.selectedDateRange.value!.start)} - ${DateFormat('dd MMM yyyy').format(controller.selectedDateRange.value!.end)}'
                    : 'Select date range',
                style: TextStyle(
                  fontFamily: FontFamily.medium,
                  fontSize: 13,
                  color: controller.selectedDateRange.value != null
                      ? AppThemeData.primary50
                      : (isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            ),
          ],
        ),
      ),
    ));
  }

  void _showDateRangeDialog(bool isDark, {required BuildContext context}) async {
    DateTime? start = controller.selectedDateRange.value?.start;
    DateTime? end = controller.selectedDateRange.value?.end;

    final result = await showDialog<Map<String, DateTime>>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Dialog(
                backgroundColor: isDark
                    ? AppThemeData.surfaceElevated.withValues(alpha: 0.95)
                    : Colors.white.withValues(alpha: 0.95),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Container(
                  width: 380,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.date_range_rounded, color: AppThemeData.primary50, size: 22),
                          spaceW(width: 10),
                          Text(
                            'Select Date Range',
                            style: TextStyle(
                              fontFamily: FontFamily.bold,
                              fontSize: 16,
                              color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                            ),
                          ),
                        ],
                      ),
                      spaceH(height: 20),
                      _buildDateField(
                        label: 'Start Date',
                        date: start,
                        isDark: isDark,
                        onTap: () async {
                          final d = await showDatePicker(
                            context: ctx,
                            initialDate: start ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                            builder: (c, child) => Theme(
                              data: Theme.of(c).copyWith(
                                colorScheme: ColorScheme.dark(
                                  primary: AppThemeData.primary50,
                                  onPrimary: Colors.white,
                                  surface: isDark ? AppThemeData.surfaceElevated : Colors.white,
                                  onSurface: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                                ),
                              ),
                              child: child!,
                            ),
                          );
                          if (d != null) setState(() => start = d);
                        },
                      ),
                      spaceH(height: 12),
                      _buildDateField(
                        label: 'End Date',
                        date: end,
                        isDark: isDark,
                        onTap: () async {
                          final d = await showDatePicker(
                            context: ctx,
                            initialDate: end ?? start ?? DateTime.now(),
                            firstDate: start ?? DateTime(2020),
                            lastDate: DateTime(2030),
                            builder: (c, child) => Theme(
                              data: Theme.of(c).copyWith(
                                colorScheme: ColorScheme.dark(
                                  primary: AppThemeData.primary50,
                                  onPrimary: Colors.white,
                                  surface: isDark ? AppThemeData.surfaceElevated : Colors.white,
                                  onSurface: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                                ),
                              ),
                              child: child!,
                            ),
                          );
                          if (d != null) setState(() => end = d);
                        },
                      ),
                      spaceH(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.pop(ctx),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: isDark ? AppThemeData.surfaceMid : AppThemeData.grey2,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontFamily: FontFamily.semiBold,
                                      fontSize: 14,
                                      color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          spaceW(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (start != null && end != null) {
                                  Navigator.pop(ctx, {'start': start!, 'end': end!});
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [AppThemeData.primary50, AppThemeData.primary4],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    'Apply',
                                    style: TextStyle(
                                      fontFamily: FontFamily.semiBold,
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (result != null) {
      controller.filterByDateRange(
        DateTimeRange(start: result['start']!, end: result['end']!),
      );
    }
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.surfaceMid : AppThemeData.grey2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: date != null
                ? AppThemeData.primary50.withValues(alpha: 0.5)
                : (isDark ? AppThemeData.surfaceBorder : AppThemeData.grey3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: date != null
                  ? AppThemeData.primary50
                  : (isDark ? AppThemeData.grey5 : AppThemeData.grey6),
            ),
            spaceW(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: FontFamily.regular,
                      fontSize: 11,
                      color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                    ),
                  ),
                  spaceH(height: 2),
                  Text(
                    date != null ? DateFormat('dd MMM yyyy').format(date) : 'Tap to select',
                    style: TextStyle(
                      fontFamily: FontFamily.medium,
                      fontSize: 14,
                      color: date != null
                          ? (isDark ? AppThemeData.grey1 : AppThemeData.grey10)
                          : (isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatData {
  final IconData icon;
  final String label;
  final String value;
  final String sub;
  final Color color;

  const _StatData({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
  });
}
