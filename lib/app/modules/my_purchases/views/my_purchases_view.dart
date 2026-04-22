// lib/app/modules/my_purchases/views/my_purchases_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:maheksync/app/models/category_model.dart';
import 'package:maheksync/app/models/payment_method_model.dart';
import 'package:maheksync/app/routes/app_pages.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
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
        return _buildContent(isDark);
      }),
    );
  }

  Widget _buildContent(bool isDark) {
    return Row(
      children: [
        // Left Panel - Filters and Search
        Container(
          width: 420,
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
              _buildSearchBar(isDark),
              spaceH(height: 24),
              _buildFilterSection(isDark),
              const Spacer(),
              _buildTotalSummary(isDark),
            ],
          ),
        ),
        // Right Panel - Purchases List/Grid
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildListHeader(isDark),
                spaceH(height: 16),
                Expanded(child: _buildPurchasesContent(isDark)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppThemeData.primary50,
                AppThemeData.primary4,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppThemeData.primary50.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.shopping_bag_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
        spaceW(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextCustom(
                title: 'My Purchases',
                fontSize: 22,
                fontFamily: FontFamily.bold,
                color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              ),
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

  Widget _buildSearchBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
        borderRadius: BorderRadius.circular(16),
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
          fontSize: 14,
          color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
        ),
        decoration: InputDecoration(
          hintText: 'Search by name, brand, category...',
          hintStyle: TextStyle(
            fontFamily: FontFamily.regular,
            fontSize: 14,
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
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppThemeData.primary50,
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection(bool isDark) {
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
                  title: 'Clear All',
                  fontSize: 13,
                  fontFamily: FontFamily.medium,
                  color: AppThemeData.danger300,
                ),
              );
            }),
          ],
        ),
        spaceH(height: 20),
        _buildCategoryFilter(isDark),
        spaceH(height: 16),
        _buildPaymentMethodFilter(isDark),
        spaceH(height: 16),
        _buildStatusFilter(isDark),
        spaceH(height: 16),
        _buildDateFilterButton(isDark),
      ],
    );
  }

  Widget _buildCategoryFilter(bool isDark) {
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
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
            borderRadius: BorderRadius.circular(14),
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
              size: 22,
            ),
            hint: Row(
              children: [
                Icon(
                  Icons.category_rounded,
                  color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
                  size: 18,
                ),
                spaceW(width: 10),
                TextCustom(
                  title: 'All Categories',
                  fontSize: 14,
                  fontFamily: FontFamily.regular,
                  color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
                ),
              ],
            ),
            items: [
              DropdownMenuItem<CategoryModel>(
                value: null,
                child: Row(
                  children: [
                    Icon(
                      Icons.all_inclusive_rounded,
                      color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                      size: 18,
                    ),
                    spaceW(width: 10),
                    TextCustom(
                      title: 'All Categories',
                      fontSize: 14,
                      color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
                    ),
                  ],
                ),
              ),
              ...controller.categories.map((c) {
                return DropdownMenuItem<CategoryModel>(
                  value: c,
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppThemeData.primary50.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: c.iconUrl != null && c.iconUrl!.isNotEmpty
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: NetworkImageWidget(
                            imageUrl: c.iconUrl!,
                            fit: BoxFit.cover,
                          ),
                        )
                            : Icon(
                          Icons.category_rounded,
                          color: AppThemeData.primary50,
                          size: 16,
                        ),
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
        )),
      ],
    );
  }

  Widget _buildPaymentMethodFilter(bool isDark) {
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
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
            borderRadius: BorderRadius.circular(14),
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
              size: 22,
            ),
            hint: Row(
              children: [
                Icon(
                  Icons.payment_rounded,
                  color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
                  size: 18,
                ),
                spaceW(width: 10),
                TextCustom(
                  title: 'All Methods',
                  fontSize: 14,
                  fontFamily: FontFamily.regular,
                  color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
                ),
              ],
            ),
            items: [
              DropdownMenuItem<PaymentMethodModel>(
                value: null,
                child: Row(
                  children: [
                    Icon(
                      Icons.all_inclusive_rounded,
                      color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                      size: 18,
                    ),
                    spaceW(width: 10),
                    TextCustom(
                      title: 'All Methods',
                      fontSize: 14,
                      color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
                    ),
                  ],
                ),
              ),
              ...controller.paymentMethods.map((m) {
                return DropdownMenuItem<PaymentMethodModel>(
                  value: m,
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppThemeData.primary50.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: m.pIcon != null && m.pIcon!.isNotEmpty
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: NetworkImageWidget(
                            imageUrl: m.pIcon!,
                            fit: BoxFit.cover,
                          ),
                        )
                            : Icon(
                          Icons.payment_rounded,
                          color: AppThemeData.primary50,
                          size: 16,
                        ),
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
        )),
      ],
    );
  }

  Widget _buildStatusFilter(bool isDark) {
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
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
            borderRadius: BorderRadius.circular(14),
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
              size: 22,
            ),
            hint: Row(
              children: [
                Icon(
                  Icons.flag_rounded,
                  color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
                  size: 18,
                ),
                spaceW(width: 10),
                TextCustom(
                  title: 'All Status',
                  fontSize: 14,
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
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _getStatusColor(s),
                        shape: BoxShape.circle,
                      ),
                    ),
                    spaceW(width: 10),
                    Text(
                      s,
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

  Widget _buildDateFilterButton(bool isDark) {
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
              borderRadius: BorderRadius.circular(14),
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
                    size: 18,
                  ),
                ),
                spaceW(width: 12),
                Expanded(
                  child: TextCustom(
                    title: controller.selectedDateRange.value != null
                        ? '${DateFormat('MM/dd/yyyy').format(controller.selectedDateRange.value!.start)} - ${DateFormat('MM/dd/yyyy').format(controller.selectedDateRange.value!.end)}'
                        : 'Select date range',
                    fontSize: 14,
                    fontFamily: FontFamily.medium,
                    color: controller.selectedDateRange.value != null
                        ? AppThemeData.primary50
                        : (isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                  size: 16,
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
                    title: 'Apply Filter',
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

  Widget _buildTotalSummary(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppThemeData.primary50.withValues(alpha: isDark ? 0.15 : 0.08),
            AppThemeData.primary4.withValues(alpha: isDark ? 0.08 : 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppThemeData.primary50.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextCustom(
            title: 'Portfolio Summary',
            fontSize: 14,
            fontFamily: FontFamily.bold,
            color: isDark ? AppThemeData.grey3 : AppThemeData.grey7,
          ),
          spaceH(height: 12),
          Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextCustom(
                title: 'Total Value',
                fontSize: 14,
                color: isDark ? AppThemeData.grey4 : AppThemeData.grey6,
              ),
              TextCustom(
                title: '₹${controller.totalPortfolioValue.toStringAsFixed(2)}',
                fontSize: 20,
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
                fontSize: 14,
                color: isDark ? AppThemeData.grey4 : AppThemeData.grey6,
              ),
              TextCustom(
                title: '${controller.totalItems}',
                fontSize: 16,
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
                fontSize: 14,
                color: isDark ? AppThemeData.grey4 : AppThemeData.grey6,
              ),
              TextCustom(
                title: '${controller.activeOrders}',
                fontSize: 16,
                fontFamily: FontFamily.bold,
                color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildListHeader(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: AppThemeData.primary50,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            spaceW(width: 10),
            TextCustom(
              title: 'Latest Acquisitions',
              fontSize: 20,
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
                borderRadius: BorderRadius.circular(12),
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
            spaceW(width: 16),
            ElevatedButton.icon(
              onPressed: controller.goToAddPurchase,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: TextCustom(
                title: 'Add Purchase',
                fontSize: 13,
                fontFamily: FontFamily.semiBold,
                color: Colors.white,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemeData.primary50,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected
              ? Colors.white
              : (isDark ? AppThemeData.grey5 : AppThemeData.grey6),
        ),
      ),
    );
  }

  Widget _buildPurchasesContent(bool isDark) {
    return Obx(() {
      if (controller.filteredPurchases.isEmpty) {
        return _buildEmptyState(isDark);
      }

      if (controller.isGridView.value) {
        return _buildGridView(isDark);
      } else {
        return _buildListView(isDark);
      }
    });
  }

  Widget _buildGridView(bool isDark) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 350,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: controller.filteredPurchases.length,
      itemBuilder: (context, index) {
        return _buildPurchaseGridCard(controller.filteredPurchases[index], isDark);
      },
    );
  }

  Widget _buildListView(bool isDark) {
    return ListView.separated(
      itemCount: controller.filteredPurchases.length,
      separatorBuilder: (_, __) => spaceH(height: 16),
      itemBuilder: (context, index) {
        return _buildPurchaseListCard(controller.filteredPurchases[index], isDark);
      },
    );
  }

  Widget _buildPurchaseGridCard(PurchaseModel purchase, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(18),
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
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
                borderRadius: BorderRadius.circular(14),
              ),
              child: purchase.primaryImageUrl.isNotEmpty
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: NetworkImageWidget(
                  imageUrl: purchase.primaryImageUrl,
                  fit: BoxFit.cover,
                ),
              )
                  : Icon(
                Icons.shopping_bag_outlined,
                size: 40,
                color: isDark ? AppThemeData.grey7 : AppThemeData.grey4,
              ),
            ),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.all(12),
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
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextCustom(
                        title: purchase.status == 'DELIVERED'
                            ? '✓'
                            : purchase.status == 'IN TRANSIT'
                            ? '🚚'
                            : '📦',
                        fontSize: 12,
                        color: purchase.statusColor,
                      ),
                    ),
                  ],
                ),
                spaceH(height: 4),
                TextCustom(
                  title: '₹${purchase.formattedPrice.replaceAll('\$', '')}',
                  fontSize: 18,
                  fontFamily: FontFamily.bold,
                  color: AppThemeData.primary50,
                ),
                spaceH(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // View Details Button
                    OutlinedButton(
                      onPressed: () => Get.toNamed(Routes.MY_PURCHASES_DETAILS, arguments: purchase),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: BorderSide(
                          color: AppThemeData.primary50.withValues(alpha: 0.5),
                        ),
                      ),
                      child: TextCustom(
                        title: 'View Details',
                        fontSize: 12,
                        fontFamily: FontFamily.semiBold,
                        color: AppThemeData.primary50,
                      ),
                    ),
                    spaceW(width: 8),
                    IconButton(
                      onPressed: () => controller.deletePurchase(purchase),
                      icon: Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: AppThemeData.danger300,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildPurchaseListCard(PurchaseModel purchase, bool isDark) {
    return InkWell(
      onTap: () => Get.toNamed(Routes.MY_PURCHASES_DETAILS, arguments: purchase),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
          borderRadius: BorderRadius.circular(18),
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
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
                borderRadius: BorderRadius.circular(14),
              ),
              child: purchase.primaryImageUrl.isNotEmpty
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
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
            spaceW(width: 16),
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
                          fontSize: 16,
                          fontFamily: FontFamily.bold,
                          color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: purchase.statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextCustom(
                          title: purchase.status ?? 'DELIVERED',
                          fontSize: 10,
                          fontFamily: FontFamily.bold,
                          color: purchase.statusColor,
                        ),
                      ),
                    ],
                  ),
                  spaceH(height: 4),
                  TextCustom(
                    title: '₹${purchase.formattedPrice.replaceAll('\$', '')}',
                    fontSize: 18,
                    fontFamily: FontFamily.bold,
                    color: AppThemeData.primary50,
                  ),
                  spaceH(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.category_rounded,
                        size: 14,
                        color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                      ),
                      spaceW(width: 4),
                      TextCustom(
                        title: purchase.category ?? 'Uncategorized',
                        fontSize: 12,
                        color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                      ),
                      spaceW(width: 12),
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 14,
                        color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                      ),
                      spaceW(width: 4),
                      TextCustom(
                        title: '${purchase.units} units',
                        fontSize: 12,
                        color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Delete Button
            IconButton(
              onPressed: () => controller.deletePurchase(purchase),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppThemeData.danger300.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: AppThemeData.danger300,
                  size: 18,
                ),
              ),
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
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.primaryBlack.withValues(alpha: 0.5) : AppThemeData.primaryWhite,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppThemeData.primary50.withValues(alpha: 0.15),
                    AppThemeData.primary4.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 64,
                color: AppThemeData.primary50.withValues(alpha: 0.6),
              ),
            ),
            spaceH(height: 24),
            TextCustom(
              title: 'No purchases found',
              fontSize: 22,
              fontFamily: FontFamily.bold,
              color: isDark ? AppThemeData.grey3 : AppThemeData.grey8,
            ),
            spaceH(height: 8),
            TextCustom(
              title: 'Start building your collection',
              fontSize: 15,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            ),
          ],
        ),
      ),
    );
  }
}