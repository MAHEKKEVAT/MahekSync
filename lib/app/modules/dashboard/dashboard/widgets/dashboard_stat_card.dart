// lib/app/modules/dashboard/widgets/dashboard_stat_card.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/text_widget.dart';

class DashboardStatCard extends StatefulWidget {
  final String title;
  final int count;
  final String subtitle;
  final IconData icon;
  final Gradient iconGradient;
  final Color accentColor;
  final Color dimColor;
  final List<String> previewItems;
  final List<String?>? previewImageUrls;
  final VoidCallback? onViewAll;
  final VoidCallback? onTap;
  final bool isDark;

  const DashboardStatCard({
    super.key,
    required this.title,
    required this.count,
    this.subtitle = '',
    required this.icon,
    required this.iconGradient,
    required this.accentColor,
    required this.dimColor,
    this.previewItems = const [],
    this.previewImageUrls,
    this.onViewAll,
    this.onTap,
    required this.isDark,
  });

  @override
  State<DashboardStatCard> createState() => _DashboardStatCardState();
}

class _DashboardStatCardState extends State<DashboardStatCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  bool get _hasImages =>
      widget.previewImageUrls != null &&
      widget.previewImageUrls!.any((url) => url != null && url.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _animController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _animController.reverse();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          height: 170,
          decoration: BoxDecoration(
            color: _isHovered
                ? (widget.isDark
                    ? AppThemeData.surfaceElevated
                    : AppThemeData.grey2)
                : (widget.isDark
                    ? AppThemeData.surfaceDeep
                    : AppThemeData.grey1),
            borderRadius: BorderRadius.circular(20),
            border: _isHovered
                ? Border.all(
                    color: widget.accentColor.withValues(alpha: 0.15),
                    width: 1,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? widget.accentColor.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: widget.isDark ? 0.12 : 0.03),
                blurRadius: _isHovered ? 20 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: _hasImages
              ? _buildImageLayout()
              : _buildCompactLayout(),
        ),
      ),
    );
  }

  // ─── Blurry Icon Watermark ────────────────────────────────
  Widget _buildWatermarkIcon() {
    return Positioned(
      right: -8,
      bottom: -8,
      child: Icon(
        widget.icon,
        size: 80,
        color: widget.accentColor.withValues(alpha: 0.06),
      ),
    );
  }

  // ─── Layout with Images on Left Side ──────────────────────
  Widget _buildImageLayout() {
    final images = widget.previewImageUrls!
        .where((url) => url != null && url.isNotEmpty)
        .take(3)
        .toList();

    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        Row(
          children: [
            // ── Left: Image Panel ──────────────────
            SizedBox(
              width: 110,
              height: 170,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background image (first item, dimmed)
                  if (images.isNotEmpty)
                    Opacity(
                      opacity: 0.35,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: images[0]!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: widget.accentColor.withValues(alpha: 0.08),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: widget.accentColor.withValues(alpha: 0.08),
                            child: Icon(widget.icon, color: widget.accentColor.withValues(alpha: 0.3), size: 28),
                          ),
                        ),
                      ),
                    ),
                  // Foreground stacked thumbnails
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (int i = 0; i < images.length; i++)
                          Transform.translate(
                            offset: Offset(i * 10.0, i == 0 ? 0.0 : -6.0),
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: widget.isDark
                                      ? AppThemeData.surfaceBorder.withValues(alpha: 0.5)
                                      : Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: images[i]!,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(
                                    color: widget.accentColor.withValues(alpha: 0.12),
                                    child: Icon(
                                      widget.icon,
                                      color: widget.accentColor.withValues(alpha: 0.5),
                                      size: 18,
                                    ),
                                  ),
                                  errorWidget: (_, __, ___) => Container(
                                    color: widget.accentColor.withValues(alpha: 0.12),
                                    child: Icon(
                                      widget.icon,
                                      color: widget.accentColor.withValues(alpha: 0.5),
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Divider ───────────────────────────
            Container(
              width: 1,
              color: widget.isDark
                  ? AppThemeData.surfaceBorder.withValues(alpha: 0.2)
                  : AppThemeData.grey3.withValues(alpha: 0.6),
            ),

            // ── Right: Content ────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Top Row: Icon + View All ───────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: widget.iconGradient,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Icon(widget.icon, size: 15, color: Colors.white),
                        ),
                        if (widget.onViewAll != null)
                          GestureDetector(
                            onTap: widget.onViewAll,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: widget.accentColor.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(7),
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
                                    size: 7,
                                    color: widget.accentColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ── Count ───────────────────────────
                    Text(
                      widget.count.toString(),
                      style: TextStyle(
                        fontFamily: FontFamily.bold,
                        fontSize: 26,
                        color: widget.isDark
                            ? AppThemeData.grey1
                            : AppThemeData.grey10,
                        letterSpacing: -0.8,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 3),

                    // ── Title + Subtitle ────────────────
                    Row(
                      children: [
                        Flexible(
                          child: TextCustom(
                            title: widget.title,
                            fontSize: 12,
                            fontFamily: FontFamily.medium,
                            color: widget.isDark
                                ? AppThemeData.grey3
                                : AppThemeData.grey8,
                          ),
                        ),
                        if (widget.subtitle.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                      ],
                    ),

                    // ── Preview Item Names ──────────────
                    if (widget.previewItems.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: widget.previewItems.take(2).map((item) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: widget.isDark
                                  ? AppThemeData.surfaceMid.withValues(alpha: 0.5)
                                  : AppThemeData.grey3.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              item.length > 14 ? '${item.substring(0, 14)}...' : item,
                              style: TextStyle(
                                fontFamily: FontFamily.regular,
                                fontSize: 9,
                                color: widget.isDark ? AppThemeData.grey4 : AppThemeData.grey7,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
        // Blurry icon watermark
        _buildWatermarkIcon(),
      ],
    );
  }

  // ─── Compact Layout (No Images) ───────────────────────────
  Widget _buildCompactLayout() {
    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Row: Icon + View All ───────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: widget.iconGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: AppThemeData.neonGlow(
                        widget.accentColor,
                        blur: 12,
                        opacity: 0.2,
                      ),
                    ),
                    child: Icon(widget.icon, size: 20, color: Colors.white),
                  ),
                  if (widget.onViewAll != null)
                    GestureDetector(
                      onTap: widget.onViewAll,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.accentColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(7),
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
                              color: widget.accentColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Count ──────────────────────────────
              Text(
                widget.count.toString(),
                style: TextStyle(
                  fontFamily: FontFamily.bold,
                  fontSize: 28,
                  color: widget.isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                  letterSpacing: -1,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),

              // ── Title + Subtitle ───────────────────
              Row(
                children: [
                  Flexible(
                    child: TextCustom(
                      title: widget.title,
                      fontSize: 13,
                      fontFamily: FontFamily.medium,
                      color: widget.isDark ? AppThemeData.grey3 : AppThemeData.grey8,
                    ),
                  ),
                  if (widget.subtitle.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: widget.accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
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
                ],
              ),

              // ── Preview Items ──────────────────────
              if (widget.previewItems.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: widget.previewItems.take(3).map((item) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: widget.isDark
                            ? AppThemeData.surfaceMid.withValues(alpha: 0.5)
                            : AppThemeData.grey3,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        item.length > 12 ? '${item.substring(0, 12)}...' : item,
                        style: TextStyle(
                          fontFamily: FontFamily.regular,
                          fontSize: 9,
                          color: widget.isDark ? AppThemeData.grey4 : AppThemeData.grey7,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
        // Blurry icon watermark
        _buildWatermarkIcon(),
      ],
    );
  }
}
