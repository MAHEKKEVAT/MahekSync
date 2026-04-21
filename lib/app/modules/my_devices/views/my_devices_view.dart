// lib/app/modules/my_devices/views/my_devices_view.dart
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
import '../../../models/device_model.dart';
import '../../../routes/app_pages.dart';
import '../controllers/my_devices_controller.dart';

class MyDevicesView extends GetView<MyDevicesController> {
  const MyDevicesView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppThemeData.grey10 : AppThemeData.grey2,
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: MahekLoader(
              message: 'Loading Devices...',
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
    return Column(
      children: [
        // Main Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isDark),
                spaceH(height: 24),
                _buildFilterBar(isDark),
                spaceH(height: 20),
                _buildSearchAndViewToggle(isDark),
                spaceH(height: 20),
                Expanded(child: _buildDevicesContent(isDark)),
              ],
            ),
          ),
        ),
        // Bottom Stats Bar
        _buildBottomStatsBar(isDark),
      ],
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
                Icons.devices_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
            spaceW(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(
                  title: 'My Devices',
                  fontSize: 28,
                  fontFamily: FontFamily.bold,
                  color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                ),
                spaceH(height: 4),
                Obx(() => TextCustom(
                  title: '${controller.filteredDevices.length} devices registered',
                  fontSize: 14,
                  fontFamily: FontFamily.regular,
                  color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                )),
              ],
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: controller.openAddDevicePanel,
          icon: const Icon(Icons.add_rounded, size: 20),
          label: TextCustom(
            title: 'Register New Device',
            fontSize: 14,
            fontFamily: FontFamily.semiBold,
            color: Colors.white,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppThemeData.primary50,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 2,
            shadowColor: AppThemeData.primary50.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Category Filter
          Expanded(
            child: _buildCategoryFilter(isDark),
          ),
          spaceW(width: 16),
          // Payment Method Filter
          Expanded(
            child: _buildPaymentMethodFilter(isDark),
          ),
          spaceW(width: 12),
          // Clear Filters Button
          Obx(() {
            final hasFilters = controller.selectedCategory.value != null ||
                controller.selectedPaymentMethod.value != null ||
                controller.searchQuery.isNotEmpty;

            if (!hasFilters) return const SizedBox.shrink();

            return IconButton(
              onPressed: controller.clearFilters,
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppThemeData.danger300.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: AppThemeData.danger300,
                  size: 20,
                ),
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
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppThemeData.primary50.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.category_rounded,
                color: AppThemeData.primary50,
                size: 14,
              ),
            ),
            spaceW(width: 8),
            TextCustom(
              title: 'Category',
              fontSize: 12,
              fontFamily: FontFamily.medium,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            ),
          ],
        ),
        spaceH(height: 8),
        Obx(() => Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
              width: 0.5,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<CategoryModel>(
              value: controller.selectedCategory.value,
              isExpanded: true,
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
                    fontSize: 13,
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
                        size: 16,
                      ),
                      spaceW(width: 8),
                      TextCustom(
                        title: 'All Categories',
                        fontSize: 13,
                        fontFamily: FontFamily.medium,
                        color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
                      ),
                    ],
                  ),
                ),
                ...controller.categories.map((category) {
                  return DropdownMenuItem<CategoryModel>(
                    value: category,
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppThemeData.primary50.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: category.iconUrl != null && category.iconUrl!.isNotEmpty
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: NetworkImageWidget(
                              imageUrl: category.iconUrl!,
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
                            category.name ?? 'Unknown',
                            style: TextStyle(
                              fontFamily: FontFamily.medium,
                              fontSize: 13,
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
              onChanged: (value) => controller.filterByCategory(value),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildPaymentMethodFilter(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppThemeData.primary50.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.payment_rounded,
                color: AppThemeData.primary50,
                size: 14,
              ),
            ),
            spaceW(width: 8),
            TextCustom(
              title: 'Payment',
              fontSize: 12,
              fontFamily: FontFamily.medium,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            ),
          ],
        ),
        spaceH(height: 8),
        Obx(() => Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
              width: 0.5,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<PaymentMethodModel>(
              value: controller.selectedPaymentMethod.value,
              isExpanded: true,
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
                    fontSize: 13,
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
                        size: 16,
                      ),
                      spaceW(width: 8),
                      TextCustom(
                        title: 'All Methods',
                        fontSize: 13,
                        fontFamily: FontFamily.medium,
                        color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
                      ),
                    ],
                  ),
                ),
                ...controller.paymentMethods.map((method) {
                  return DropdownMenuItem<PaymentMethodModel>(
                    value: method,
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppThemeData.primary50.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: method.pIcon != null && method.pIcon!.isNotEmpty
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: NetworkImageWidget(
                              imageUrl: method.pIcon!,
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
                            method.pName ?? 'Unknown',
                            style: TextStyle(
                              fontFamily: FontFamily.medium,
                              fontSize: 13,
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
              onChanged: (value) => controller.filterByPaymentMethod(value),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildSearchAndViewToggle(bool isDark) {
    return Row(
      children: [
        // Search Bar
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              onChanged: controller.updateSearchQuery,
              style: TextStyle(
                fontFamily: FontFamily.medium,
                fontSize: 14,
                color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              ),
              decoration: InputDecoration(
                hintText: 'Quick search by name, brand, store...',
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
          ),
        ),
        spaceW(width: 12),
        // View Toggle
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
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
        padding: const EdgeInsets.all(10),
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
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 22,
          color: isSelected
              ? Colors.white
              : (isDark ? AppThemeData.grey5 : AppThemeData.grey6),
        ),
      ),
    );
  }

  Widget _buildDevicesContent(bool isDark) {
    if (controller.filteredDevices.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return Obx(() {
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
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 0.85,
      ),
      itemCount: controller.filteredDevices.length,
      itemBuilder: (context, index) {
        return _buildDeviceGridCard(controller.filteredDevices[index], isDark);
      },
    );
  }

  Widget _buildListView(bool isDark) {
    return ListView.separated(
      itemCount: controller.filteredDevices.length,
      separatorBuilder: (_, __) => spaceH(height: 16),
      itemBuilder: (context, index) {
        return _buildDeviceListCard(controller.filteredDevices[index], isDark);
      },
    );
  }

  Widget _buildDeviceGridCard(DeviceModel device, bool isDark) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Badges
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppThemeData.primary50.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextCustom(
                    title: device.condition ?? 'NEW',
                    fontSize: 11,
                    fontFamily: FontFamily.bold,
                    color: AppThemeData.primary50,
                  ),
                ),
                if (device.warrantyEndDate != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: device.isWarrantyExpired
                          ? AppThemeData.danger300.withValues(alpha: 0.12)
                          : AppThemeData.success400.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextCustom(
                      title: device.isWarrantyExpired ? 'Expired' : 'Active',
                      fontSize: 11,
                      fontFamily: FontFamily.bold,
                      color: device.isWarrantyExpired
                          ? AppThemeData.danger300
                          : AppThemeData.success400,
                    ),
                  ),
              ],
            ),
          ),
          // Device Image
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
                borderRadius: BorderRadius.circular(16),
              ),
              child: device.primaryImageUrl.isNotEmpty
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  device.primaryImageUrl,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => _buildPlaceholderImage(isDark),
                ),
              )
                  : _buildPlaceholderImage(isDark),
            ),
          ),
          // Device Info
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(
                  title: device.deviceName ?? 'Unknown Device',
                  fontSize: 16,
                  fontFamily: FontFamily.bold,
                  color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                  maxLine: 1,
                ),
                spaceH(height: 4),
                TextCustom(
                  title: device.formattedPrice,
                  fontSize: 20,
                  fontFamily: FontFamily.bold,
                  color: AppThemeData.primary50,
                ),
                spaceH(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Get.toNamed(Routes.VIEW_DEVICES, arguments: device),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceListCard(DeviceModel device, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
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
        children: [
          // Image
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
              borderRadius: BorderRadius.circular(16),
            ),
            child: device.primaryImageUrl.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                device.primaryImageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _buildPlaceholderImage(isDark),
              ),
            )
                : _buildPlaceholderImage(isDark),
          ),
          spaceW(width: 18),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppThemeData.primary50.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextCustom(
                        title: device.condition ?? 'NEW',
                        fontSize: 10,
                        fontFamily: FontFamily.bold,
                        color: AppThemeData.primary50,
                      ),
                    ),
                    spaceW(width: 8),
                    if (device.warrantyEndDate != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: device.isWarrantyExpired
                              ? AppThemeData.danger300.withValues(alpha: 0.12)
                              : AppThemeData.success400.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextCustom(
                          title: device.isWarrantyExpired ? 'Expired' : 'Active',
                          fontSize: 10,
                          fontFamily: FontFamily.bold,
                          color: device.isWarrantyExpired
                              ? AppThemeData.danger300
                              : AppThemeData.success400,
                        ),
                      ),
                  ],
                ),
                spaceH(height: 8),
                TextCustom(
                  title: device.deviceName ?? 'Unknown Device',
                  fontSize: 17,
                  fontFamily: FontFamily.bold,
                  color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                ),
                spaceH(height: 4),
                TextCustom(
                  title: device.formattedPrice,
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
                      title: device.category ?? 'Uncategorized',
                      fontSize: 12,
                      fontFamily: FontFamily.regular,
                      color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                    ),
                    spaceW(width: 16),
                    Icon(
                      Icons.payment_rounded,
                      size: 14,
                      color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                    ),
                    spaceW(width: 4),
                    TextCustom(
                      title: device.paymentMethod ?? 'N/A',
                      fontSize: 12,
                      fontFamily: FontFamily.regular,
                      color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Actions
          Column(
            children: [
              OutlinedButton(
                onPressed: () => Get.toNamed(Routes.VIEW_DEVICES, arguments: device),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(
                    color: AppThemeData.primary50.withValues(alpha: 0.5),
                  ),
                ),
                child: TextCustom(
                  title: 'View',
                  fontSize: 13,
                  fontFamily: FontFamily.semiBold,
                  color: AppThemeData.primary50,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage(bool isDark) {
    return Container(
      color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
      child: Center(
        child: Icon(
          Icons.devices_outlined,
          size: 40,
          color: isDark ? AppThemeData.grey7 : AppThemeData.grey4,
        ),
      ),
    );
  }

  Widget _buildBottomStatsBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
        border: Border(
          top: BorderSide(
            color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Obx(() => Row(
        children: [
          // Total Items
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppThemeData.primary50.withValues(alpha: 0.12),
                  AppThemeData.primary4.withValues(alpha: 0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  color: AppThemeData.primary50,
                  size: 20,
                ),
                spaceW(width: 10),
                TextCustom(
                  title: '${controller.totalItems}',
                  fontSize: 18,
                  fontFamily: FontFamily.bold,
                  color: AppThemeData.primary50,
                ),
                spaceW(width: 6),
                TextCustom(
                  title: 'Items',
                  fontSize: 13,
                  fontFamily: FontFamily.medium,
                  color: isDark ? AppThemeData.grey4 : AppThemeData.grey6,
                ),
              ],
            ),
          ),
          spaceW(width: 16),
          // Total Price
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppThemeData.success400.withValues(alpha: 0.12),
                  AppThemeData.success400.withValues(alpha: 0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.attach_money_rounded,
                  color: AppThemeData.success400,
                  size: 20,
                ),
                spaceW(width: 10),
                TextCustom(
                  title: '\$${controller.totalPrice.toStringAsFixed(2)}',
                  fontSize: 18,
                  fontFamily: FontFamily.bold,
                  color: AppThemeData.success400,
                ),
                spaceW(width: 6),
                TextCustom(
                  title: 'Total',
                  fontSize: 13,
                  fontFamily: FontFamily.medium,
                  color: isDark ? AppThemeData.grey4 : AppThemeData.grey6,
                ),
              ],
            ),
          ),
          const Spacer(),
          // Category Chips
          ...controller.categoryItemCount.entries.take(3).map((entry) {
            return Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextCustom(
                    title: entry.key,
                    fontSize: 12,
                    fontFamily: FontFamily.medium,
                    color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
                  ),
                  spaceW(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppThemeData.primary50.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextCustom(
                      title: '${entry.value}',
                      fontSize: 11,
                      fontFamily: FontFamily.bold,
                      color: AppThemeData.primary50,
                    ),
                  ),
                ],
              ),
            );
          }),
          if (controller.categoryItemCount.length > 3)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextCustom(
                title: '+${controller.categoryItemCount.length - 3} more',
                fontSize: 12,
                fontFamily: FontFamily.medium,
                color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
              ),
            ),
        ],
      )),
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
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppThemeData.primary50.withValues(alpha: 0.15),
                    AppThemeData.primary4.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                Icons.devices_outlined,
                size: 64,
                color: AppThemeData.primary50.withValues(alpha: 0.6),
              ),
            ),
            spaceH(height: 24),
            TextCustom(
              title: 'No devices found',
              fontSize: 22,
              fontFamily: FontFamily.bold,
              color: isDark ? AppThemeData.grey3 : AppThemeData.grey8,
            ),
            spaceH(height: 8),
            TextCustom(
              title: 'Start building your inventory',
              fontSize: 15,
              fontFamily: FontFamily.regular,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            ),
            spaceH(height: 4),
            TextCustom(
              title: 'Add your first device to get started.',
              fontSize: 15,
              fontFamily: FontFamily.regular,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            ),
            spaceH(height: 28),
            ElevatedButton.icon(
              onPressed: controller.openAddDevicePanel,
              icon: const Icon(Icons.add_rounded),
              label: TextCustom(
                title: 'Add New Device',
                fontSize: 15,
                fontFamily: FontFamily.semiBold,
                color: Colors.white,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemeData.primary50,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}