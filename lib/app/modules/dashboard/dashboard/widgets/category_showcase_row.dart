// lib/app/modules/dashboard/widgets/category_showcase_row.dart
// ──────────────────────────────────────────────────────────────
//  4-card row: My Devices, My Purchases, Subscriptions, Dues
//  Each card shows only the LATEST 1 item with image + detail
//  Replaces old DeviceShowcaseSection + separate stat cards
// ──────────────────────────────────────────────────────────────
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:maheksync/app/models/dues_tracker_model.dart';
import 'package:maheksync/app/modules/dashboard/controllers/dashboard_home_controller.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';

class CategoryShowcaseRow extends StatelessWidget {
  final DashboardHomeController controller;
  final bool isDark;
  final VoidCallback? onViewDevices;
  final VoidCallback? onViewPurchases;
  final VoidCallback? onViewSubscriptions;
  final VoidCallback? onViewDues;

  const CategoryShowcaseRow({
    super.key,
    required this.controller,
    required this.isDark,
    this.onViewDevices,
    this.onViewPurchases,
    this.onViewSubscriptions,
    this.onViewDues,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardCount = constraints.maxWidth > 1000
            ? 4
            : constraints.maxWidth > 600
                ? 2
                : 1;
        final spacing = 14.0;
        final cardWidth =
            (constraints.maxWidth - (spacing * (cardCount - 1))) / cardCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: cardWidth,
              child: _CategoryCard(
                title: 'My Devices',
                count: controller.deviceCount.value,
                subtitle: 'Active',
                accentColor: AppThemeData.neonTeal,
                icon: Icons.devices_rounded,
                latestImageUrl: _latestDeviceImage(),
                latestName: _latestDeviceName(),
                latestDetail: _latestDeviceDetail(),
                onViewAll: onViewDevices,
                isDark: isDark,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _CategoryCard(
                title: 'My Purchases',
                count: controller.purchaseCount.value,
                subtitle: 'Total',
                accentColor: AppThemeData.neonMint,
                icon: Icons.shopping_bag_rounded,
                latestImageUrl: _latestPurchaseImage(),
                latestName: _latestPurchaseName(),
                latestDetail: _latestPurchaseDetail(),
                onViewAll: onViewPurchases,
                isDark: isDark,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _CategoryCard(
                title: 'Subscriptions',
                count: controller.subscriptionCount.value,
                subtitle: 'Active',
                accentColor: AppThemeData.neonPurple,
                icon: Icons.subscriptions_rounded,
                latestImageUrl: null,
                latestName: _latestSubscriptionName(),
                latestDetail: 'Service',
                onViewAll: onViewSubscriptions,
                isDark: isDark,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _CategoryCard(
                title: 'Dues Tracker',
                count: controller.duesCount.value,
                subtitle:
                    controller.duesCount.value > 0 ? 'Pending' : 'Clear',
                accentColor: controller.duesCount.value > 0
                    ? AppThemeData.neonPink
                    : AppThemeData.neonMint,
                icon: Icons.account_balance_wallet_rounded,
                latestImageUrl: null,
                latestName: _latestDueName(),
                latestDetail: _latestDueDetail(),
                onViewAll: onViewDues,
                isDark: isDark,
                isWarning: controller.duesCount.value > 0,
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Latest item helpers (only 1 item) ──────────────────────
  String? _latestDeviceImage() {
    if (controller.latestDevices.isEmpty) return null;
    final d = controller.latestDevices.first;
    if (d.deviceImageUrls != null && d.deviceImageUrls!.isNotEmpty) {
      return d.deviceImageUrls!.first;
    }
    return null;
  }

  String _latestDeviceName() {
    if (controller.latestDevices.isEmpty) return 'No devices';
    return controller.latestDevices.first.deviceName ?? 'Device';
  }

  String _latestDeviceDetail() {
    if (controller.latestDevices.isEmpty) return '';
    final d = controller.latestDevices.first;
    return '${d.brandName ?? ''} ${d.category ?? ''}'.trim();
  }

  String? _latestPurchaseImage() {
    if (controller.latestPurchases.isEmpty) return null;
    final p = controller.latestPurchases.first;
    if (p.imageUrls != null && p.imageUrls!.isNotEmpty) {
      return p.imageUrls!.first;
    }
    return null;
  }

  String _latestPurchaseName() {
    if (controller.latestPurchases.isEmpty) return 'No purchases';
    return controller.latestPurchases.first.assetName ?? 'Purchase';
  }

  String _latestPurchaseDetail() {
    if (controller.latestPurchases.isEmpty) return '';
    return controller.latestPurchases.first.formattedPrice;
  }

  String _latestSubscriptionName() {
    if (controller.latestSubscriptions.isEmpty) return 'No subscriptions';
    return controller.latestSubscriptions.first.name ?? 'Subscription';
  }

  String _latestDueName() {
    if (controller.latestDues.isEmpty) return 'No dues';
    return controller.latestDues.first.customerName ?? 'Payment';
  }

  String _latestDueDetail() {
    if (controller.latestDues.isEmpty) return '';
    final d = controller.latestDues.first;
    return '${d.dueTypeLabel} ${d.shortFormattedAmount}';
  }
}

// ─── Category Card ──────────────────────────────────────────
class _CategoryCard extends StatefulWidget {
  final String title;
  final int count;
  final String subtitle;
  final Color accentColor;
  final IconData icon;
  final String? latestImageUrl;
  final String latestName;
  final String latestDetail;
  final VoidCallback? onViewAll;
  final bool isDark;
  final bool isWarning;

  const _CategoryCard({
    required this.title,
    required this.count,
    required this.subtitle,
    required this.accentColor,
    required this.icon,
    this.latestImageUrl,
    required this.latestName,
    required this.latestDetail,
    this.onViewAll,
    required this.isDark,
    this.isWarning = false,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onViewAll,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: _hovered
                ? (widget.isDark
                    ? AppThemeData.surfaceElevated
                    : AppThemeData.grey2)
                : (widget.isDark
                    ? AppThemeData.surfaceDeep
                    : AppThemeData.grey1),
            borderRadius: BorderRadius.circular(20),
            border: _hovered
                ? Border.all(
                    color: widget.accentColor.withValues(alpha: 0.2), width: 1)
                : null,
            boxShadow: [
              BoxShadow(
                color: _hovered
                    ? widget.accentColor.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: widget.isDark ? 0.12 : 0.03),
                blurRadius: _hovered ? 20 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Watermark icon
              Positioned(
                right: -10,
                bottom: -10,
                child: Icon(widget.icon,
                    size: 80,
                    color: widget.accentColor.withValues(alpha: 0.05)),
              ),

              // Warning badge for dues
              if (widget.isWarning)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppThemeData.neonPink.withValues(alpha: 0.15),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            size: 10, color: AppThemeData.neonPink),
                        const SizedBox(width: 3),
                        Text(
                          'Pending',
                          style: TextStyle(
                            fontFamily: FontFamily.bold,
                            fontSize: 8,
                            color: AppThemeData.neonPink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Content
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: Icon + View All
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                widget.accentColor,
                                widget.accentColor.withValues(alpha: 0.7)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: AppThemeData.neonGlow(
                                widget.accentColor,
                                blur: 10,
                                opacity: 0.15),
                          ),
                          child:
                              Icon(widget.icon, size: 18, color: Colors.white),
                        ),
                        if (widget.onViewAll != null)
                          GestureDetector(
                            onTap: widget.onViewAll,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color:
                                    widget.accentColor.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'View All',
                                    style: TextStyle(
                                      fontFamily: FontFamily.medium,
                                      fontSize: 9,
                                      color: widget.accentColor,
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 8,
                                      color: widget.accentColor),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Count
                    Text(
                      widget.count.toString(),
                      style: TextStyle(
                        fontFamily: FontFamily.bold,
                        fontSize: 28,
                        color: widget.isDark
                            ? AppThemeData.grey1
                            : AppThemeData.grey10,
                        letterSpacing: -1,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Title + subtitle
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.title,
                            style: TextStyle(
                              fontFamily: FontFamily.medium,
                              fontSize: 13,
                              color: widget.isDark
                                  ? AppThemeData.grey3
                                  : AppThemeData.grey8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: widget.accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            widget.subtitle,
                            style: TextStyle(
                              fontFamily: FontFamily.medium,
                              fontSize: 9,
                              color: widget.accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Latest item row with image
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: widget.isDark
                            ? AppThemeData.surfaceMid.withValues(alpha: 0.4)
                            : AppThemeData.grey2.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: widget.isDark
                              ? AppThemeData.surfaceBorder
                                  .withValues(alpha: 0.2)
                              : AppThemeData.grey3.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Image or icon
                          if (widget.latestImageUrl != null &&
                              widget.latestImageUrl!.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: widget.latestImageUrl!,
                                width: 38,
                                height: 38,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color:
                                        widget.accentColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(widget.icon,
                                      size: 16,
                                      color: widget.accentColor
                                          .withValues(alpha: 0.5)),
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color:
                                        widget.accentColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(widget.icon,
                                      size: 16,
                                      color: widget.accentColor
                                          .withValues(alpha: 0.5)),
                                ),
                              ),
                            )
                          else
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: widget.accentColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(widget.icon,
                                  size: 16,
                                  color:
                                      widget.accentColor.withValues(alpha: 0.6)),
                            ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.latestName,
                                  style: TextStyle(
                                    fontFamily: FontFamily.medium,
                                    fontSize: 11,
                                    color: widget.isDark
                                        ? AppThemeData.grey2
                                        : AppThemeData.grey9,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (widget.latestDetail.isNotEmpty)
                                  Text(
                                    widget.latestDetail,
                                    style: TextStyle(
                                      fontFamily: FontFamily.regular,
                                      fontSize: 9,
                                      color: widget.isDark
                                          ? AppThemeData.grey5
                                          : AppThemeData.grey6,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
}
