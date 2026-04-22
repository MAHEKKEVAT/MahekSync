// lib/app/modules/my_purchases/views/my_purchases_view.dart
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

        // Use different layout based on screen size
        if (context.isMobile) {
          return _buildMobileLayout(isDark, context);
        } else {
          return _buildDesktopLayout(isDark, context);
        }
      }),
    );
  }

  // Mobile/Tablet Layout (Stacked)
  Widget _buildMobileLayout(bool isDark, BuildContext context) {
    return Column(
      children: [
        // Header with toggle button
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(child: _buildHeader(isDark, context)),
              IconButton(
                onPressed: controller.toggleFilterPanel,
                icon: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.filter_list_rounded,
                    color: AppThemeData.primary50,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Filter Panel (Collapsible)
        Obx(() => controller.showFilterPanel.value
            ? Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
            border: Border(
              bottom: BorderSide(
                color: isDark ? AppThemeData.grey9 : AppThemeData.grey3,
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              _buildSearchBar(isDark, context),
              spaceH(height: 16),
              _buildFilterSection(isDark, context),
            ],
          ),
        )
            : const SizedBox.shrink(),
        ),
        // Purchases List
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildListHeader(isDark, context),
                spaceH(height: 12),
                Expanded(child: _buildPurchasesContent(isDark, context)),
              ],
            ),
          ),
        ),
        // Bottom Summary
        _buildFooterSummary(isDark, context),
      ],
    );
  }

  // Desktop/Laptop Layout (Side by Side)
  Widget _buildDesktopLayout(bool isDark, BuildContext context) {
    final filterWidth = context.filterPanelWidth;

    return Row(
      children: [
        // Left Panel - Filters and Search
        Container(
          width: filterWidth,
          padding: EdgeInsets.all(context.responsivePadding.left),
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
              _buildHeader(isDark, context),
              spaceH(height: 20),
              _buildSearchBar(isDark, context),
              spaceH(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildFilterSection(isDark, context),
                ),
              ),
              _buildTotalSummary(isDark, context),
            ],
          ),
        ),
        // Right Panel - Purchases List/Grid
        Expanded(
          child: Container(
            padding: EdgeInsets.all(context.responsivePadding.left),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildListHeader(isDark, context),
                spaceH(height: 16),
                Expanded(child: _buildPurchasesContent(isDark, context)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Footer Summary for Mobile/Tablet
  Widget _buildFooterSummary(bool isDark, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
        border: Border(
          top: BorderSide(
            color: isDark ? AppThemeData.grey9 : AppThemeData.grey3,
            width: 1,
          ),
        ),
      ),
      child: Obx(() => Row(
        children: [
          Expanded(
            child: _buildSummaryItem(
              icon: Icons.account_balance_wallet_rounded,
              label: 'Total',
              value: '₹${controller.totalPortfolioValue.toStringAsFixed(0)}',
              isDark: isDark,
            ),
          ),
          Container(
            width: 1,
            height: 30,
            color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
          ),
          Expanded(
            child: _buildSummaryItem(
              icon: Icons.inventory_2_outlined,
              label: 'Items',
              value: '${controller.totalItems}',
              isDark: isDark,
            ),
          ),
          Container(
            width: 1,
            height: 30,
            color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
          ),
          Expanded(
            child: _buildSummaryItem(
              icon: Icons.local_shipping_outlined,
              label: 'Active',
              value: '${controller.activeOrders}',
              isDark: isDark,
            ),
          ),
        ],
      )),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: AppThemeData.primary50, size: 18),
        spaceW(width: 8),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextCustom(
              title: label,
              fontSize: 10,
              fontFamily: FontFamily.regular,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            ),
            TextCustom(
              title: value,
              fontSize: 14,
              fontFamily: FontFamily.bold,
              color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader(bool isDark, BuildContext context) {
    final iconSize = context.isMobile ? 40.0 : 48.0;
    final titleSize = context.isMobile ? 18.0 : 22.0;

    return Row(
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppThemeData.primary50,
                AppThemeData.primary4,
              ],
            ),
            borderRadius: BorderRadius.circular(iconSize * 0.33),
            boxShadow: [
              BoxShadow(
                color: AppThemeData.primary50.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.shopping_bag_rounded,
            color: Colors.white,
            size: iconSize * 0.54,
          ),
        ),
        spaceW(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextCustom(
                title: 'My Purchases',
                fontSize: titleSize,
                fontFamily: FontFamily.bold,
                color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              ),
              if (!context.isMobile)
                TextCustom(
                  title: 'A curated gallery of your acquisitions',
                  fontSize: 12,
                  fontFamily: FontFamily.regular,
                  color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(bool isDark, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
          width: 0.5,
        ),
      ),
      child: TextField(
        onChanged: controller.updateSearchQuery,
        style: TextStyle(
          fontFamily: FontFamily.medium,
          fontSize: context.isMobile ? 13 : 14,
          color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
        ),
        decoration: InputDecoration(
          hintText: 'Search...',
          hintStyle: TextStyle(
            fontFamily: FontFamily.regular,
            fontSize: context.isMobile ? 13 : 14,
            color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppThemeData.primary50.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.search_rounded,
              color: AppThemeData.primary50,
              size: 20,
            ),
          ),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: AppThemeData.primary50,
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection(bool isDark, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: AppThemeData.primary50,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            spaceW(width: 10),
            TextCustom(
              title: 'Filters',
              fontSize: 16,
              fontFamily: FontFamily.bold,
              color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
            ),
            const Spacer(),
            Obx(() {
              final hasFilters = controller.selectedCategory.value != null ||
                  controller.selectedPaymentMethod.value != null ||
                  controller.selectedStatus.value != 'ALL' ||
                  controller.selectedDateRange.value != null;
              if (!hasFilters) return const SizedBox.shrink();
              return TextButton(
                onPressed: controller.clearFilters,
                child: TextCustom(
                  title: 'Clear',
                  fontSize: 12,
                  fontFamily: FontFamily.medium,
                  color: AppThemeData.danger300,
                ),
              );
            }),
          ],
        ),
        spaceH(height: 16),
        _buildCategoryFilter(isDark, context),
        spaceH(height: 14),
        _buildPaymentMethodFilter(isDark, context),
        spaceH(height: 14),
        _buildStatusFilter(isDark, context),
        spaceH(height: 14),
        _buildDateFilterButton(isDark, context),
      ],
    );
  }

  Widget _buildCategoryFilter(bool isDark, BuildContext context) {
    final fontSize = context.isMobile ? 12.0 : 14.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(
          title: 'Category',
          fontSize: 12,
          fontFamily: FontFamily.semiBold,
          color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
        ),
        spaceH(height: 8),
        Obx(() => Container(
          width: double.infinity,
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
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
              size: 20,
            ),
            hint: Row(
              children: [
                Icon(
                  Icons.category_rounded,
                  color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
                  size: 16,
                ),
                spaceW(width: 8),
                TextCustom(
                  title: 'All Categories',
                  fontSize: fontSize,
                  fontFamily: FontFamily.regular,
                  color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
                ),
              ],
            ),
            items: [
              DropdownMenuItem<CategoryModel>(
                value: null,
                child: TextCustom(
                  title: 'All Categories',
                  fontSize: fontSize,
                  color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
                ),
              ),
              ...controller.categories.map((c) {
                return DropdownMenuItem<CategoryModel>(
                  value: c,
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppThemeData.primary50.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: c.iconUrl != null && c.iconUrl!.isNotEmpty
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: NetworkImageWidget(
                            imageUrl: c.iconUrl!,
                            fit: BoxFit.cover,
                          ),
                        )
                            : Icon(
                          Icons.category_rounded,
                          color: AppThemeData.primary50,
                          size: 14,
                        ),
                      ),
                      spaceW(width: 8),
                      Expanded(
                        child: Text(
                          c.name ?? 'Unknown',
                          style: TextStyle(
                            fontFamily: FontFamily.medium,
                            fontSize: fontSize,
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
        )),
      ],
    );
  }

  Widget _buildPaymentMethodFilter(bool isDark, BuildContext context) {
    final fontSize = context.isMobile ? 12.0 : 14.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(
          title: 'Payment Method',
          fontSize: 12,
          fontFamily: FontFamily.semiBold,
          color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
        ),
        spaceH(height: 8),
        Obx(() => Container(
          width: double.infinity,
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
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
              size: 20,
            ),
            hint: Row(
              children: [
                Icon(
                  Icons.payment_rounded,
                  color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
                  size: 16,
                ),
                spaceW(width: 8),
                TextCustom(
                  title: 'All Methods',
                  fontSize: fontSize,
                  fontFamily: FontFamily.regular,
                  color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
                ),
              ],
            ),
            items: [
              DropdownMenuItem<PaymentMethodModel>(
                value: null,
                child: TextCustom(
                  title: 'All Methods',
                  fontSize: fontSize,
                  color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
                ),
              ),
              ...controller.paymentMethods.map((m) {
                return DropdownMenuItem<PaymentMethodModel>(
                  value: m,
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppThemeData.primary50.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: m.pIcon != null && m.pIcon!.isNotEmpty
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: NetworkImageWidget(
                            imageUrl: m.pIcon!,
                            fit: BoxFit.cover,
                          ),
                        )
                            : Icon(
                          Icons.payment_rounded,
                          color: AppThemeData.primary50,
                          size: 14,
                        ),
                      ),
                      spaceW(width: 8),
                      Expanded(
                        child: Text(
                          m.pName ?? 'Unknown',
                          style: TextStyle(
                            fontFamily: FontFamily.medium,
                            fontSize: fontSize,
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
        )),
      ],
    );
  }

  Widget _buildStatusFilter(bool isDark, BuildContext context) {
    final fontSize = context.isMobile ? 12.0 : 14.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(
          title: 'Status',
          fontSize: 12,
          fontFamily: FontFamily.semiBold,
          color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
        ),
        spaceH(height: 8),
        Obx(() => Container(
          width: double.infinity,
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
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
              size: 20,
            ),
            hint: Row(
              children: [
                Icon(
                  Icons.flag_rounded,
                  color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
                  size: 16,
                ),
                spaceW(width: 8),
                TextCustom(
                  title: 'All Status',
                  fontSize: fontSize,
                  fontFamily: FontFamily.regular,
                  color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
                ),
              ],
            ),
            items: controller.statusOptions.map((s) {
              return DropdownMenuItem<String>(
                value: s,
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getStatusColor(s),
                        shape: BoxShape.circle,
                      ),
                    ),
                    spaceW(width: 8),
                    Text(
                      s,
                      style: TextStyle(
                        fontFamily: FontFamily.medium,
                        fontSize: fontSize,
                        color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (v) => controller.filterByStatus(v!),
          ),
        )),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'DELIVERED':
        return const Color(0xFF10B981);
      case 'IN TRANSIT':
        return const Color(0xFFF59E0B);
      case 'PRE-ORDER':
        return const Color(0xFF3B82F6);
      default:
        return Colors.grey;
    }
  }

  Widget _buildDateFilterButton(bool isDark, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(
          title: 'Date Range',
          fontSize: 12,
          fontFamily: FontFamily.semiBold,
          color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
        ),
        spaceH(height: 8),
        Obx(() => GestureDetector(
          onTap: () => _showDateFilterDialog(isDark),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: controller.selectedDateRange.value != null
                    ? AppThemeData.primary50
                    : (isDark ? AppThemeData.grey8 : AppThemeData.grey3),
                width: controller.selectedDateRange.value != null ? 1.5 : 0.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppThemeData.primary50.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.calendar_month_rounded,
                    color: AppThemeData.primary50,
                    size: 16,
                  ),
                ),
                spaceW(width: 10),
                Expanded(
                  child: TextCustom(
                    title: controller.selectedDateRange.value != null
                        ? '${DateFormat('MM/dd/yy').format(controller.selectedDateRange.value!.start)} - ${DateFormat('MM/dd/yy').format(controller.selectedDateRange.value!.end)}'
                        : 'Select date range',
                    fontSize: context.isMobile ? 12 : 13,
                    fontFamily: FontFamily.medium,
                    color: controller.selectedDateRange.value != null
                        ? AppThemeData.primary50
                        : (isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                  size: 14,
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Future<void> _showDateFilterDialog(bool isDark) async {
    DateTimeRange? initialRange = controller.selectedDateRange.value ??
        DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 30)),
          end: DateTime.now(),
        );

    final selectedRange = await showDialog<DateTimeRange>(
      context: Get.context!,
      builder: (context) {
        DateTimeRange? tempRange = initialRange;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.calendar_month_rounded,
                    color: AppThemeData.primary50,
                    size: 24,
                  ),
                  spaceW(width: 10),
                  TextCustom(
                    title: 'Select Date Range',
                    fontSize: 18,
                    fontFamily: FontFamily.bold,
                  ),
                ],
              ),
              content: SizedBox(
                width: 350,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _buildDateField(
                            label: 'Start Date',
                            date: tempRange?.start,
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: tempRange?.start ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2030),
                              );
                              if (date != null) {
                                setState(() {
                                  tempRange = DateTimeRange(
                                    start: date,
                                    end: tempRange?.end ?? date,
                                  );
                                });
                              }
                            },
                            isDark: isDark,
                          ),
                          spaceH(height: 12),
                          _buildDateField(
                            label: 'End Date',
                            date: tempRange?.end,
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: tempRange?.end ?? DateTime.now(),
                                firstDate: tempRange?.start ?? DateTime(2000),
                                lastDate: DateTime(2030),
                              );
                              if (date != null) {
                                setState(() {
                                  tempRange = DateTimeRange(
                                    start: tempRange?.start ?? date,
                                    end: date,
                                  );
                                });
                              }
                            },
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: TextCustom(
                    title: 'Cancel',
                    fontSize: 14,
                    color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      tempRange = null;
                    });
                  },
                  child: TextCustom(
                    title: 'Reset',
                    fontSize: 14,
                    color: AppThemeData.danger300,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, tempRange),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppThemeData.primary50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: TextCustom(
                    title: 'Apply',
                    fontSize: 14,
                    fontFamily: FontFamily.semiBold,
                    color: Colors.white,
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    controller.filterByDateRange(selectedRange);
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.grey8 : AppThemeData.grey2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppThemeData.grey7 : AppThemeData.grey4,
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextCustom(
              title: label,
              fontSize: 13,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            ),
            TextCustom(
              title: date != null
                  ? DateFormat('MM/dd/yyyy').format(date)
                  : 'Select date',
              fontSize: 14,
              fontFamily: FontFamily.medium,
              color: date != null
                  ? (isDark ? AppThemeData.grey1 : AppThemeData.grey10)
                  : (isDark ? AppThemeData.grey6 : AppThemeData.grey5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalSummary(bool isDark, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppThemeData.primary50.withValues(alpha: isDark ? 0.15 : 0.08),
            AppThemeData.primary4.withValues(alpha: isDark ? 0.08 : 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppThemeData.primary50.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextCustom(
            title: 'Portfolio Summary',
            fontSize: 13,
            fontFamily: FontFamily.bold,
            color: isDark ? AppThemeData.grey3 : AppThemeData.grey7,
          ),
          spaceH(height: 12),
          Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextCustom(
                title: 'Total Value',
                fontSize: 13,
                color: isDark ? AppThemeData.grey4 : AppThemeData.grey6,
              ),
              TextCustom(
                title: '₹${controller.totalPortfolioValue.toStringAsFixed(0)}',
                fontSize: 18,
                fontFamily: FontFamily.bold,
                color: AppThemeData.primary50,
              ),
            ],
          )),
          spaceH(height: 8),
          Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextCustom(
                title: 'Total Items',
                fontSize: 13,
                color: isDark ? AppThemeData.grey4 : AppThemeData.grey6,
              ),
              TextCustom(
                title: '${controller.totalItems}',
                fontSize: 15,
                fontFamily: FontFamily.bold,
                color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              ),
            ],
          )),
          spaceH(height: 8),
          Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextCustom(
                title: 'Active Orders',
                fontSize: 13,
                color: isDark ? AppThemeData.grey4 : AppThemeData.grey6,
              ),
              TextCustom(
                title: '${controller.activeOrders}',
                fontSize: 15,
                fontFamily: FontFamily.bold,
                color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildListHeader(bool isDark, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: AppThemeData.primary50,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            spaceW(width: 8),
            TextCustom(
              title: context.isMobile ? 'Acquisitions' : 'Latest Acquisitions',
              fontSize: context.isMobile ? 16 : 18,
              fontFamily: FontFamily.bold,
              color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
            ),
          ],
        ),
        Row(
          children: [
            // View Toggle
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
                borderRadius: BorderRadius.circular(10),
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
                    icon: Icons.list_rounded,
                    isSelected: !controller.isGridView.value,
                    onTap: () => controller.isGridView.value = false,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            spaceW(width: 12),
            ElevatedButton.icon(
              onPressed: controller.goToAddPurchase,
              icon: Icon(Icons.add_rounded, size: context.isMobile ? 16 : 18),
              label: TextCustom(
                title: context.isMobile ? 'Add' : 'Add Purchase',
                fontSize: context.isMobile ? 11 : 13,
                fontFamily: FontFamily.semiBold,
                color: Colors.white,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemeData.primary50,
                padding: EdgeInsets.symmetric(
                  horizontal: context.isMobile ? 12 : 16,
                  vertical: context.isMobile ? 8 : 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ],
    );
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
          gradient: isSelected
              ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppThemeData.primary50,
              AppThemeData.primary4,
            ],
          )
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected
              ? Colors.white
              : (isDark ? AppThemeData.grey5 : AppThemeData.grey6),
        ),
      ),
    );
  }

  Widget _buildPurchasesContent(bool isDark, BuildContext context) {
    return Obx(() {
      if (controller.filteredPurchases.isEmpty) {
        return _buildEmptyState(isDark, context);
      }

      if (controller.isGridView.value) {
        return _buildGridView(isDark, context);
      } else {
        return _buildListView(isDark, context);
      }
    });
  }

  Widget _buildGridView(bool isDark, BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: MahekResponsive.maxCrossAxisExtent(context),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: MahekResponsive.cardAspectRatio(context),
      ),
      itemCount: controller.filteredPurchases.length,
      itemBuilder: (context, index) {
        return _buildPurchaseGridCard(controller.filteredPurchases[index], isDark, context);
      },
    );
  }

  Widget _buildListView(bool isDark, BuildContext context) {
    return ListView.separated(
      itemCount: controller.filteredPurchases.length,
      separatorBuilder: (_, __) => spaceH(height: 12),
      itemBuilder: (context, index) {
        return _buildPurchaseListCard(controller.filteredPurchases[index], isDark, context);
      },
    );
  }

  Widget _buildPurchaseGridCard(PurchaseModel purchase, bool isDark, BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Get.toNamed(Routes.MY_PURCHASES_DETAILS, arguments: purchase),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: purchase.primaryImageUrl.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: NetworkImageWidget(
                      imageUrl: purchase.primaryImageUrl,
                      fit: BoxFit.cover,
                    ),
                  )
                      : Icon(
                    Icons.shopping_bag_outlined,
                    size: 36,
                    color: isDark ? AppThemeData.grey7 : AppThemeData.grey4,
                  ),
                ),
              ),
              // Info
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextCustom(
                            title: purchase.assetName ?? 'Unknown',
                            fontSize: context.isMobile ? 13 : 14,
                            fontFamily: FontFamily.bold,
                            color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                            maxLine: 1,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: purchase.statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextCustom(
                            title: purchase.status == 'DELIVERED'
                                ? '✓'
                                : purchase.status == 'IN TRANSIT'
                                ? '🚚'
                                : '📦',
                            fontSize: 10,
                            color: purchase.statusColor,
                          ),
                        ),
                      ],
                    ),
                    spaceH(height: 4),
                    TextCustom(
                      title: '₹${purchase.formattedPrice.replaceAll('\$', '')}',
                      fontSize: context.isMobile ? 16 : 18,
                      fontFamily: FontFamily.bold,
                      color: AppThemeData.primary50,
                    ),
                    spaceH(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Edit Button
                        _buildHoverButton(
                          icon: Icons.edit_outlined,
                          color: AppThemeData.primary50,
                          onTap: () => controller.goToEditPurchase(purchase),
                          isDark: isDark,
                        ),
                        spaceW(width: 6),
                        // Delete Button
                        _buildHoverButton(
                          icon: Icons.delete_outline,
                          color: AppThemeData.danger300,
                          onTap: () => controller.deletePurchase(purchase),
                          isDark: isDark,
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

  Widget _buildPurchaseListCard(PurchaseModel purchase, bool isDark, BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Get.toNamed(Routes.MY_PURCHASES_DETAILS, arguments: purchase),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: purchase.primaryImageUrl.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: NetworkImageWidget(
                    imageUrl: purchase.primaryImageUrl,
                    fit: BoxFit.cover,
                  ),
                )
                    : Icon(
                  Icons.shopping_bag_outlined,
                  size: 32,
                  color: isDark ? AppThemeData.grey7 : AppThemeData.grey4,
                ),
              ),
              spaceW(width: 14),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextCustom(
                            title: purchase.assetName ?? 'Unknown',
                            fontSize: 15,
                            fontFamily: FontFamily.bold,
                            color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                            maxLine: 1,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: purchase.statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextCustom(
                            title: purchase.status ?? 'DELIVERED',
                            fontSize: 9,
                            fontFamily: FontFamily.bold,
                            color: purchase.statusColor,
                          ),
                        ),
                      ],
                    ),
                    spaceH(height: 4),
                    TextCustom(
                      title: '₹${purchase.formattedPrice.replaceAll('\$', '')}',
                      fontSize: 16,
                      fontFamily: FontFamily.bold,
                      color: AppThemeData.primary50,
                    ),
                    spaceH(height: 4),
                    Row(
                      children: [
                        Icon(Icons.category_rounded, size: 12, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                        spaceW(width: 4),
                        TextCustom(
                          title: purchase.category ?? 'Uncategorized',
                          fontSize: 11,
                          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                        ),
                        spaceW(width: 10),
                        Icon(Icons.inventory_2_outlined, size: 12, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                        spaceW(width: 4),
                        TextCustom(
                          title: '${purchase.units} units',
                          fontSize: 11,
                          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Action Buttons
              Column(
                children: [
                  _buildHoverButton(
                    icon: Icons.edit_outlined,
                    color: AppThemeData.primary50,
                    onTap: () => controller.goToEditPurchase(purchase),
                    isDark: isDark,
                  ),
                  spaceH(height: 4),
                  _buildHoverButton(
                    icon: Icons.delete_outline,
                    color: AppThemeData.danger300,
                    onTap: () => controller.deletePurchase(purchase),
                    isDark: isDark,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHoverButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.primaryBlack.withValues(alpha: 0.5) : AppThemeData.primaryWhite,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppThemeData.primary50.withValues(alpha: 0.15),
                    AppThemeData.primary4.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 50,
                color: AppThemeData.primary50.withValues(alpha: 0.6),
              ),
            ),
            spaceH(height: 20),
            TextCustom(
              title: 'No purchases found',
              fontSize: 18,
              fontFamily: FontFamily.bold,
              color: isDark ? AppThemeData.grey3 : AppThemeData.grey8,
            ),
            spaceH(height: 6),
            TextCustom(
              title: 'Start building your collection',
              fontSize: 13,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            ),
          ],
        ),
      ),
    );
  }
}