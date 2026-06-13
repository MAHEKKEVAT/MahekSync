// lib/app/modules/dashboard/widgets/device_showcase_section.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:maheksync/app/models/device_model.dart';
import 'package:maheksync/app/modules/dashboard/controllers/dashboard_home_controller.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';

class DeviceShowcaseSection extends StatelessWidget {
  final DashboardHomeController controller;
  final bool isDark;
  final VoidCallback? onViewAll;

  const DeviceShowcaseSection({
    super.key,
    required this.controller,
    required this.isDark,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final devices = controller.latestDevices;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppThemeData.neonTeal, AppThemeData.neonBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.devices_rounded, size: 15, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Text(
                  'My Devices',
                  style: TextStyle(
                    fontFamily: FontFamily.bold,
                    fontSize: 16,
                    color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppThemeData.neonTeal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${controller.deviceCount.value}',
                    style: TextStyle(
                      fontFamily: FontFamily.bold,
                      fontSize: 11,
                      color: AppThemeData.neonTeal,
                    ),
                  ),
                ),
              ],
            ),
            if (onViewAll != null)
              GestureDetector(
                onTap: onViewAll,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppThemeData.neonTeal.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View All',
                        style: TextStyle(
                          fontFamily: FontFamily.medium,
                          fontSize: 11,
                          color: AppThemeData.neonTeal,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, size: 14, color: AppThemeData.neonTeal),
                    ],
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 16),

        // Device Gallery
        if (devices.isEmpty)
          _EmptyDeviceState(isDark: isDark)
        else
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: devices.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                return _DeviceCard(
                  device: devices[index],
                  isDark: isDark,
                );
              },
            ),
          ),
      ],
    );
  }
}

// ─── Device Card (Apple-style) ────────────────────────────────
class _DeviceCard extends StatelessWidget {
  final DeviceModel device;
  final bool isDark;

  const _DeviceCard({required this.device, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final hasImage = device.deviceImageUrls != null && device.deviceImageUrls!.isNotEmpty;
    final isWarrantyExpired = device.isWarrantyExpired;

    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.surfaceDeep : AppThemeData.grey1,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Watermark
          Positioned(
            right: -6,
            bottom: -6,
            child: Icon(
              _categoryIcon(device.category),
              size: 60,
              color: AppThemeData.neonTeal.withValues(alpha: 0.05),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              if (hasImage)
                SizedBox(
                  height: 110,
                  width: 220,
                  child: CachedNetworkImage(
                    imageUrl: device.deviceImageUrls!.first,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: AppThemeData.neonTeal.withValues(alpha: 0.06),
                      child: Center(
                        child: Icon(_categoryIcon(device.category), size: 28, color: AppThemeData.neonTeal.withValues(alpha: 0.2)),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: AppThemeData.neonTeal.withValues(alpha: 0.06),
                      child: Center(
                        child: Icon(_categoryIcon(device.category), size: 28, color: AppThemeData.neonTeal.withValues(alpha: 0.2)),
                      ),
                    ),
                  ),
                )
              else
                Container(
                  height: 110,
                  width: 220,
                  color: AppThemeData.neonTeal.withValues(alpha: 0.06),
                  child: Center(
                    child: Icon(_categoryIcon(device.category), size: 36, color: AppThemeData.neonTeal.withValues(alpha: 0.15)),
                  ),
                ),

              // Info
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.deviceName ?? 'Device',
                      style: TextStyle(
                        fontFamily: FontFamily.bold,
                        fontSize: 13,
                        color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        if (device.brandName != null && device.brandName!.isNotEmpty) ...[
                          Text(
                            device.brandName!,
                            style: TextStyle(
                              fontFamily: FontFamily.regular,
                              fontSize: 10,
                              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        if (device.category != null && device.category!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppThemeData.neonTeal.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              device.category!,
                              style: TextStyle(
                                fontFamily: FontFamily.medium,
                                fontSize: 8,
                                color: AppThemeData.neonTeal,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Warranty status
                    Row(
                      children: [
                        Icon(
                          isWarrantyExpired ? Icons.warning_amber_rounded : Icons.verified_rounded,
                          size: 12,
                          color: isWarrantyExpired ? AppThemeData.neonOrange : AppThemeData.neonMint,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isWarrantyExpired
                              ? 'Warranty expired'
                              : device.warrantyEndDate != null
                                  ? 'Warranty: ${device.formattedWarrantyEnd}'
                                  : 'No warranty info',
                          style: TextStyle(
                            fontFamily: FontFamily.regular,
                            fontSize: 9,
                            color: isWarrantyExpired ? AppThemeData.neonOrange : AppThemeData.neonMint,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(String? category) {
    if (category == null) return Icons.devices_rounded;
    final cat = category.toLowerCase();
    if (cat.contains('phone') || cat.contains('mobile')) return Icons.phone_android_rounded;
    if (cat.contains('laptop') || cat.contains('computer')) return Icons.laptop_mac_rounded;
    if (cat.contains('tablet') || cat.contains('ipad')) return Icons.tablet_mac_rounded;
    if (cat.contains('watch') || cat.contains('wearable')) return Icons.watch_rounded;
    if (cat.contains('audio') || cat.contains('headphone') || cat.contains('speaker')) return Icons.headphones_rounded;
    if (cat.contains('camera')) return Icons.camera_alt_rounded;
    if (cat.contains('tv') || cat.contains('monitor')) return Icons.tv_rounded;
    if (cat.contains('gaming')) return Icons.sports_esports_rounded;
    return Icons.devices_rounded;
  }
}

// ─── Empty State ──────────────────────────────────────────────
class _EmptyDeviceState extends StatelessWidget {
  final bool isDark;
  const _EmptyDeviceState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.surfaceDeep : AppThemeData.grey1,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline_rounded, size: 32, color: AppThemeData.neonTeal.withValues(alpha: 0.3)),
            const SizedBox(height: 8),
            Text(
              'No devices added yet',
              style: TextStyle(
                fontFamily: FontFamily.regular,
                fontSize: 12,
                color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
