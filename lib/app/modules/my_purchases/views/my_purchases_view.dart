// lib/app/modules/my_purchases/views/my_purchases_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/models/category_model.dart';
import 'package:maheksync/app/models/payment_method_model.dart';
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isDark),
          spaceH(height: 16),
          _buildHeroSection(isDark),
          spaceH(height: 24),
          _buildFilterBar(isDark),
          spaceH(height: 20),
          _buildSearchBar(isDark),
          spaceH(height: 24),
          _buildSectionTitle('Latest Acquisitions', isDark),
          spaceH(height: 16),
          Expanded(child: _buildPurchasesList(isDark)),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppThemeData.primary50,
                    AppThemeData.primary4,
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
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
                size: 30,
              ),
            ),
            spaceW(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(
                  title: 'My Purchases',
                  fontSize: 28,
                  fontFamily: FontFamily.bold,
                  color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                ),
                TextCustom(
                  title: 'A curated gallery of your acquisitions',
                  fontSize: 14,
                  fontFamily: FontFamily.regular,
                  color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                ),
              ],
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: controller.goToAddPurchase,
          icon: const Icon(Icons.add_rounded, size: 20),
          label: TextCustom(
            title: 'Add Purchase',
            fontSize: 14,
            fontFamily: FontFamily.semiBold,
            color: Colors.white,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppThemeData.primary50,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
            isDark ? AppThemeData.grey9.withValues(alpha: 0.8) : AppThemeData.grey1,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextCustom(
                title: 'Total Portfolio Value',
                fontSize: 14,
                fontFamily: FontFamily.medium,
                color: isDark ? AppThemeData.grey4 : AppThemeData.grey6,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppThemeData.success400.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.trending_up, color: AppThemeData.success400, size: 14),
                    spaceW(width: 4),
                    TextCustom(
                      title: '+${controller.growthRate}%',
                      fontSize: 12,
                      fontFamily: FontFamily.bold,
                      color: AppThemeData.success400,
                    ),
                  ],
                ),
              ),
            ],
          ),
          spaceH(height: 8),
          Obx(() => TextCustom(
            title: '\$${controller.totalPortfolioValue.toStringAsFixed(2)}',
            fontSize: 36,
            fontFamily: FontFamily.bold,
            color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
          )),
          spaceH(height: 20),
          Row(
            children: [
              _buildStatChip(
                icon: Icons.inventory_2_outlined,
                label: 'Total Items',
                value: '${controller.totalItems}',
                isDark: isDark,
              ),
              spaceW(width: 16),
              _buildStatChip(
                icon: Icons.local_shipping_outlined,
                label: 'Active Orders',
                value: '${controller.activeOrders}',
                isDark: isDark,
              ),
              spaceW(width: 16),
              Obx(() {
                final arrivingToday = controller.filteredPurchases
                    .where((p) => p.status == 'IN TRANSIT').length;
                return _buildStatChip(
                  icon: Icons.today_outlined,
                  label: 'Arriving Today',
                  value: '$arrivingToday items',
                  isDark: isDark,
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({required IconData icon, required String label, required String value, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppThemeData.primary50, size: 18),
          spaceW(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextCustom(
                title: value,
                fontSize: 16,
                fontFamily: FontFamily.bold,
                color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              ),
              TextCustom(
                title: label,
                fontSize: 11,
                fontFamily: FontFamily.regular,
                color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(child: _buildCategoryFilter(isDark)),
          spaceW(width: 16),
          Expanded(child: _buildPaymentMethodFilter(isDark)),
          spaceW(width: 16),
          Expanded(child: _buildStatusFilter(isDark)),
          spaceW(width: 12),
          Obx(() {
            final hasFilters = controller.selectedCategory.value != null ||
                controller.selectedPaymentMethod.value != null ||
                controller.selectedStatus.value != 'ALL';
            if (!hasFilters) return const SizedBox.shrink();
            return IconButton(
              onPressed: controller.clearFilters,
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppThemeData.danger300.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.close_rounded, color: AppThemeData.danger300, size: 20),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(title: 'Category', fontSize: 11, fontFamily: FontFamily.medium, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
        spaceH(height: 6),
        Obx(() => Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? AppThemeData.grey8 : AppThemeData.grey3, width: 0.5),
          ),
          child: DropdownButton<CategoryModel>(
            value: controller.selectedCategory.value,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: isDark ? AppThemeData.grey9 : AppThemeData.primaryWhite,
            hint: TextCustom(title: 'All Categories', fontSize: 13, color: isDark ? AppThemeData.grey6 : AppThemeData.grey5),
            items: [
              DropdownMenuItem<CategoryModel>(value: null, child: TextCustom(title: 'All Categories', fontSize: 13, color: isDark ? AppThemeData.grey4 : AppThemeData.grey7)),
              ...controller.categories.map((c) => DropdownMenuItem<CategoryModel>(value: c, child: Text(c.name ?? '', style: TextStyle(fontSize: 13, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10)))),
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
        TextCustom(title: 'Payment', fontSize: 11, fontFamily: FontFamily.medium, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
        spaceH(height: 6),
        Obx(() => Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? AppThemeData.grey8 : AppThemeData.grey3, width: 0.5),
          ),
          child: DropdownButton<PaymentMethodModel>(
            value: controller.selectedPaymentMethod.value,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: isDark ? AppThemeData.grey9 : AppThemeData.primaryWhite,
            hint: TextCustom(title: 'All Methods', fontSize: 13, color: isDark ? AppThemeData.grey6 : AppThemeData.grey5),
            items: [
              DropdownMenuItem<PaymentMethodModel>(value: null, child: TextCustom(title: 'All Methods', fontSize: 13, color: isDark ? AppThemeData.grey4 : AppThemeData.grey7)),
              ...controller.paymentMethods.map((m) => DropdownMenuItem<PaymentMethodModel>(value: m, child: Text(m.pName ?? '', style: TextStyle(fontSize: 13, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10)))),
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
        TextCustom(title: 'Status', fontSize: 11, fontFamily: FontFamily.medium, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
        spaceH(height: 6),
        Obx(() => Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? AppThemeData.grey8 : AppThemeData.grey3, width: 0.5),
          ),
          child: DropdownButton<String>(
            value: controller.selectedStatus.value,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: isDark ? AppThemeData.grey9 : AppThemeData.primaryWhite,
            items: controller.statusOptions.map((s) => DropdownMenuItem<String>(value: s, child: Text(s, style: TextStyle(fontSize: 13, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10)))).toList(),
            onChanged: (v) => controller.filterByStatus(v!),
          ),
        )),
      ],
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        onChanged: controller.updateSearchQuery,
        decoration: InputDecoration(
          hintText: 'Search by name, brand, category...',
          hintStyle: TextStyle(color: isDark ? AppThemeData.grey6 : AppThemeData.grey5),
          prefixIcon: Icon(Icons.search_rounded, color: AppThemeData.primary50),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Row(
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
          title: title,
          fontSize: 18,
          fontFamily: FontFamily.bold,
          color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
        ),
        const Spacer(),
        TextButton(
          onPressed: () {},
          child: TextCustom(title: 'View All', fontSize: 13, color: AppThemeData.primary50),
        ),
      ],
    );
  }

  Widget _buildPurchasesList(bool isDark) {
    return Obx(() {
      if (controller.filteredPurchases.isEmpty) {
        return _buildEmptyState(isDark);
      }

      return ListView.separated(
        itemCount: controller.filteredPurchases.length,
        separatorBuilder: (_, __) => spaceH(height: 16),
        itemBuilder: (context, index) {
          return _buildPurchaseCard(controller.filteredPurchases[index], isDark);
        },
      );
    });
  }

  Widget _buildPurchaseCard(PurchaseModel purchase, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
            isDark ? AppThemeData.grey9.withValues(alpha: 0.5) : AppThemeData.grey1,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
              borderRadius: BorderRadius.circular(16),
            ),
            child: purchase.primaryImageUrl.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: NetworkImageWidget(
                imageUrl: purchase.primaryImageUrl,
                fit: BoxFit.cover,
              ),
            )
                : Icon(Icons.shopping_bag_outlined, size: 40, color: isDark ? AppThemeData.grey7 : AppThemeData.grey4),
          ),
          spaceW(width: 20),
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
                        fontSize: 18,
                        fontFamily: FontFamily.bold,
                        color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: purchase.statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextCustom(
                        title: purchase.status ?? 'DELIVERED',
                        fontSize: 11,
                        fontFamily: FontFamily.bold,
                        color: purchase.statusColor,
                      ),
                    ),
                  ],
                ),
                spaceH(height: 6),
                TextCustom(
                  title: purchase.description ?? '',
                  fontSize: 13,
                  fontFamily: FontFamily.regular,
                  color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                  maxLine: 2,
                ),
                spaceH(height: 12),
                TextCustom(
                  title: purchase.formattedPrice,
                  fontSize: 22,
                  fontFamily: FontFamily.bold,
                  color: AppThemeData.primary50,
                ),
                spaceH(height: 12),
                Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                    spaceW(width: 4),
                    TextCustom(title: '${purchase.units} Units', fontSize: 12, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                    spaceW(width: 16),
                    Icon(Icons.store_outlined, size: 18, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                    spaceW(width: 4),
                    TextCustom(title: purchase.storeLocation ?? 'N/A', fontSize: 12, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                  ],
                ),
              ],
            ),
          ),
          // Actions
          Column(
            children: [
              IconButton(
                onPressed: () => controller.goToEditPurchase(purchase),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppThemeData.primary50.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.edit_rounded, color: AppThemeData.primary50, size: 20),
                ),
              ),
              spaceH(height: 8),
              IconButton(
                onPressed: () => controller.deletePurchase(purchase),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppThemeData.danger300.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.delete_outline, color: AppThemeData.danger300, size: 20),
                ),
              ),
            ],
          ),
        ],
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
                  colors: [AppThemeData.primary50.withValues(alpha: 0.15), AppThemeData.primary4.withValues(alpha: 0.08)],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(Icons.shopping_bag_outlined, size: 64, color: AppThemeData.primary50.withValues(alpha: 0.6)),
            ),
            spaceH(height: 24),
            TextCustom(title: 'No purchases found', fontSize: 22, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey3 : AppThemeData.grey8),
            spaceH(height: 8),
            TextCustom(title: 'Start building your collection', fontSize: 15, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
            spaceH(height: 28),
            ElevatedButton.icon(
              onPressed: controller.goToAddPurchase,
              icon: const Icon(Icons.add_rounded),
              label: TextCustom(title: 'Add Purchase', fontSize: 15, fontFamily: FontFamily.semiBold, color: Colors.white),
              style: ElevatedButton.styleFrom(backgroundColor: AppThemeData.primary50, padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            ),
          ],
        ),
      ),
    );
  }
}