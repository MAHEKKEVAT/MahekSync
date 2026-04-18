// lib/app/modules/my_devices/views/my_devices_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import '../../../models/device_model.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/text_widget.dart';
import '../controllers/my_devices_controller.dart';

class MyDevicesView extends GetView<MyDevicesController> {
  const MyDevicesView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppThemeData.grey10 : const Color(0xFFF5F7FA),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
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
          spaceH(height: 24),
          _buildSearchBar(isDark),
          spaceH(height: 24),
          Expanded(child: _buildDevicesGrid(isDark)),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Devices',
              style: TextStyle(
                fontFamily: FontFamily.bold,
                fontSize: 28,
                color: isDark ? Colors.white : AppThemeData.grey10,
              ),
            ),
            spaceH(height: 4),
            Obx(() => Text(
              '${controller.filteredDevices.length} devices registered',
              style: TextStyle(
                fontFamily: FontFamily.regular,
                fontSize: 14,
                color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
              ),
            )),
          ],
        ),
        ElevatedButton.icon(
          onPressed: controller.openAddDevicePanel,
          icon: const Icon(Icons.add, size: 18),
          label: Text(
            'Register New Device',
            style: TextStyle(fontFamily: FontFamily.semiBold, fontSize: 14),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5D54F2),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return TextField(
      onChanged: controller.updateSearchQuery,
      decoration: InputDecoration(
        hintText: 'Quick search...',
        hintStyle: TextStyle(
          fontFamily: FontFamily.regular,
          fontSize: 15,
          color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
        ),
        filled: true,
        fillColor: isDark ? AppThemeData.grey9 : Colors.white,
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
          borderSide: const BorderSide(color: Color(0xFF5D54F2), width: 1.5),
        ),
        prefixIcon: Icon(Icons.search, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }

  Widget _buildDevicesGrid(bool isDark) {
    if (controller.filteredDevices.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 380,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 1.1,
      ),
      itemCount: controller.filteredDevices.length,
      itemBuilder: (context, index) {
        return _buildDeviceCard(controller.filteredDevices[index], isDark);
      },
    );
  }

  Widget _buildDeviceCard(DeviceModel device, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.primaryBlack : Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          // Status Badge
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5D54F2).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'IN USE',
                    style: TextStyle(
                      fontFamily: FontFamily.semiBold,
                      fontSize: 10,
                      color: const Color(0xFF5D54F2),
                    ),
                  ),
                ),
                if (device.warrantyEndDate != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: device.isWarrantyExpired
                          ? const Color(0xFFEF4444).withValues(alpha: 0.1)
                          : const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      device.isWarrantyExpired ? 'Expired' : 'Active',
                      style: TextStyle(
                        fontFamily: FontFamily.medium,
                        fontSize: 10,
                        color: device.isWarrantyExpired
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF10B981),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Device Image
          Container(
            height: 130,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? AppThemeData.grey9 : AppThemeData.grey2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: device.primaryImageUrl.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                device.primaryImageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholderImage(isDark),
              ),
            )
                : _buildPlaceholderImage(isDark),
          ),
          // Device Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.deviceName ?? 'Unknown Device',
                  style: TextStyle(
                    fontFamily: FontFamily.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : AppThemeData.grey10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                spaceH(height: 6),
                Text(
                  device.formattedPrice,
                  style: TextStyle(
                    fontFamily: FontFamily.semiBold,
                    fontSize: 18,
                    color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                  ),
                ),
                spaceH(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.verified_outlined,
                      size: 14,
                      color: device.isWarrantyExpired ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                    ),
                    spaceW(width: 4),
                    Text(
                      'Warranty: ${device.formattedWarrantyEnd}',
                      style: TextStyle(
                        fontFamily: FontFamily.regular,
                        fontSize: 11,
                        color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                      ),
                    ),
                  ],
                ),
                spaceH(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => Get.toNamed(Routes.VIEW_DEVICES, arguments: device),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5D54F2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        'View Details',
                        style: TextStyle(
                          fontFamily: FontFamily.medium,
                          fontSize: 12,
                          color: Colors.white,
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
    );
  }

  Widget _buildPlaceholderImage(bool isDark) {
    return Container(
      color: isDark ? AppThemeData.grey9 : AppThemeData.grey2,
      child: Center(
        child: Icon(
          Icons.devices_outlined,
          size: 48,
          color: isDark ? AppThemeData.grey7 : AppThemeData.grey4,
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF5D54F2).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.inventory_2_outlined, size: 60, color: const Color(0xFF5D54F2)),
          ),
          spaceH(height: 24),
          TextCustom(title: 'No devices found', fontSize: 20, fontFamily: FontFamily.bold, color: isDark ? Colors.white : AppThemeData.grey10),
          spaceH(height: 8),
          TextCustom(title: 'Start building your inventory', fontSize: 15, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
          spaceH(height: 4),
          TextCustom(title: 'Add your first device to get started.', fontSize: 15, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
          spaceH(height: 24),
          ElevatedButton.icon(
            onPressed: controller.openAddDevicePanel,
            icon: const Icon(Icons.add),
            label: TextCustom(title: 'Add New Device', fontSize: 14, fontFamily: FontFamily.semiBold, color: Colors.white),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5D54F2), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
          ),
        ],
      ),
    );
  }
}