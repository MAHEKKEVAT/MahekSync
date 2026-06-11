
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../controllers/dues_tracker_controller.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/dark_theme_provider.dart';
import '../../../utils/font_family.dart';
import '../../../utils/mahek_responsive.dart';
import '../../../widgets/global_widgets.dart';
import '../../../widgets/network_image_widget.dart';
import '../../../widgets/text_widget.dart';
import '../../../widgets/text_field_widget.dart';
import '../../../models/dues_tracker_model.dart';
import '../../../models/payment_method_model.dart';

class DuesTrackerView extends GetView<DuesTrackerController> {
  const DuesTrackerView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<DarkThemeProvider>(context);
    final isDark = theme.isDarkTheme();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          _AnimatedMeshBackground(isDark: isDark),
          SafeArea(
            child: Column(
              children: [
                // --- FIXED HEADER PORTION ---
                _buildHeroSection(context, isDark),
                _buildToolbar(context, isDark),
                const SizedBox(height: 12),

                // --- SCROLLABLE CONTENT PORTION ---
                Expanded(
                  child: Obx(() {
                    if (controller.filteredDues.isEmpty) {
                      return _buildEmptyState(isDark);
                    }

                    return controller.isGridView.value
                        ? GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: MahekResponsive.isMobile(context) ? 16 : 24,
                        vertical: 8,
                      ),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 500,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        childAspectRatio: 1.68,
                      ),
                      itemCount: controller.filteredDues.length,
                      itemBuilder: (context, index) =>
                          _buildDueCard(controller.filteredDues[index], isDark, context),
                    )
                        : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: MahekResponsive.isMobile(context) ? 16 : 24,
                        vertical: 8,
                      ),
                      itemCount: controller.filteredDues.length,
                      itemBuilder: (context, index) {
                        final due = controller.filteredDues[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildDueListTile(due, isDark, context),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
          if (MahekResponsive.isMobile(context))
            Positioned(
              bottom: 24,
              right: 24,
              child: _buildFloatingAddButton(isDark),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  HERO SECTION  (unchanged from original)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildHeroSection(BuildContext context, bool isDark) {
    final isMobile = MahekResponsive.isMobile(context);
    final padding = EdgeInsets.symmetric(
      horizontal: isMobile ? 16 : 24,
      vertical: 20,
    );
    return Container(
      margin: EdgeInsets.only(top: isMobile ? 12 : 20),
      padding: padding,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  isDark
                      ? AppThemeData.surfaceObsidian.withOpacity(0.65)
                      : Colors.white.withOpacity(0.75),
                  isDark
                      ? AppThemeData.surfaceDeep.withOpacity(0.8)
                      : Colors.white.withOpacity(0.55),
                ],
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: isDark
                    ? AppThemeData.primary50.withOpacity(0.25)
                    : AppThemeData.primary50.withOpacity(0.15),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppThemeData.primary50.withOpacity(
                    isDark ? 0.1 : 0.05,
                  ),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: AppThemeData.geminiGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          SolarIconsBold.wallet,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                      spaceW(width: 12),
                      Flexible(
                        child: TextCustom(
                          title: 'Dues Intelligence',
                          fontSize: isMobile ? 18 : 22,
                          fontFamily: FontFamily.bold,
                          color: isDark
                              ? AppThemeData.primaryWhite
                              : AppThemeData.primaryBlack,
                          maxLine: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Obx(() {
                    if (!isMobile) {
                      return Row(
                        children: [
                          _buildStatItem(
                            isDark, 'I Owe', controller.totalOweAmount.value,
                            SolarIconsBold.arrowUp, AppThemeData.danger300,
                            count: controller.oweCount.value,
                          ),
                          const SizedBox(width: 12),
                          _buildStatItem(
                            isDark, 'They Owe Me', controller.totalTakeAmount.value,
                            SolarIconsBold.arrowDown, AppThemeData.success300,
                            count: controller.takeCount.value,
                          ),
                          const SizedBox(width: 12),
                          _buildStatItem(
                            isDark, 'Net Balance', controller.netBalance.value.abs(),
                            controller.netBalance.value >= 0
                                ? SolarIconsBold.graphUp
                                : SolarIconsBold.graphDown,
                            controller.netBalance.value >= 0
                                ? AppThemeData.neonMint
                                : AppThemeData.danger300,
                            isNet: true,
                          ),
                          const SizedBox(width: 12),
                          _buildStatItem(
                            isDark, 'Pending', controller.pendingCount.value.toDouble(),
                            SolarIconsBold.clockCircle, AppThemeData.pending300,
                            isCount: true,
                          ),
                          const SizedBox(width: 12),
                          _buildStatItem(
                            isDark, 'Overdue', controller.overdueCount.value.toDouble(),
                            SolarIconsBold.dangerTriangle, AppThemeData.neonRed,
                            isCount: true,
                          ),
                        ],
                      );
                    } else {
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          Row(
                            children: [
                              _buildStatItem(isDark, 'I Owe', controller.totalOweAmount.value,
                                SolarIconsBold.arrowUp, AppThemeData.danger300,
                                count: controller.oweCount.value,
                              ),
                              const SizedBox(width: 12),
                              _buildStatItem(isDark, 'They Owe Me', controller.totalTakeAmount.value,
                                SolarIconsBold.arrowDown, AppThemeData.success300,
                                count: controller.takeCount.value,
                              ),
                            ],
                          ),
                          Row(children: [
                            _buildStatItem(isDark, 'Net Balance', controller.netBalance.value.abs(),
                              controller.netBalance.value >= 0
                                  ? SolarIconsBold.graphUp : SolarIconsBold.graphDown,
                              controller.netBalance.value >= 0
                                  ? AppThemeData.neonMint : AppThemeData.danger300,
                              isNet: true,
                            ),
                          ]),
                          Row(children: [
                            _buildStatItem(isDark, 'Pending', controller.pendingCount.value.toDouble(),
                              SolarIconsBold.clockCircle, AppThemeData.pending300, isCount: true,
                            ),
                            const SizedBox(width: 12),
                            _buildStatItem(isDark, 'Overdue', controller.overdueCount.value.toDouble(),
                              SolarIconsBold.dangerTriangle, AppThemeData.neonRed, isCount: true,
                            ),
                          ]),
                        ],
                      );
                    }
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(bool isDark, String label, double value,
      IconData icon, Color color, {
        int? count, bool isNet = false, bool isCount = false,
      }) {
    final displayWidget = Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark
            ? AppThemeData.surfaceElevated.withOpacity(0.4)
            : Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              spaceW(width: 6),
              TextCustom(
                title: label, fontSize: 12, fontFamily: FontFamily.medium,
                color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextCustom(
            title: isCount
                ? '${value.toInt()}'
                : (isNet && controller.netBalance.value < 0 ? '-' : '') +
                '\u20B9${value.toStringAsFixed(0)}',
            fontSize: 26,
            fontFamily: FontFamily.bold,
            color: color,
          ),
          if (count != null && !isCount)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: TextCustom(
                title: '$count active', fontSize: 11, fontFamily: FontFamily.regular,
                color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
              ),
            ),
        ],
      ),
    );
    return Expanded(child: displayWidget);
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  TOOLBAR  (unchanged from original)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildToolbar(BuildContext context, bool isDark) {
    final isMobile = MahekResponsive.isMobile(context);
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24, vertical: 12,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildSearchField(isDark)),
              if (!isMobile) spaceW(width: 16),
              if (!isMobile) _buildAddButton(isDark),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Obx(() => Row(
              children: [
                _buildFilterChip(isDark, label: 'All', icon: SolarIconsOutline.filters,
                  isActive: controller.activeFilter.value == 'ALL',
                  onTap: () => controller.clearFilters(),
                ),
                _buildFilterChip(isDark, label: 'I Owe', icon: SolarIconsBold.arrowUp,
                  isActive: controller.activeFilter.value == 'OWE',
                  onTap: () => controller.filterByDueType(DueType.owe),
                ),
                _buildFilterChip(isDark, label: 'They Owe Me', icon: SolarIconsBold.arrowDown,
                  isActive: controller.activeFilter.value == 'TAKE',
                  onTap: () => controller.filterByDueType(DueType.take),
                ),
                _buildFilterChip(isDark, label: 'Pending', icon: SolarIconsOutline.clockCircle,
                  isActive: controller.activeFilter.value == 'PENDING',
                  onTap: () => controller.filterByStatus(DueStatus.pending),
                ),
                _buildFilterChip(isDark, label: 'Settled', icon: SolarIconsBold.checkCircle,
                  isActive: controller.activeFilter.value == 'SETTLED',
                  onTap: () => controller.filterByStatus(DueStatus.settled),
                ),
                _buildFilterChip(isDark, label: 'Overdue', icon: SolarIconsBold.dangerTriangle,
                  isActive: controller.activeFilter.value == 'OVERDUE',
                  onTap: () => controller.filterByStatus('OVERDUE'),
                ),
                spaceW(width: 12),
                _buildViewToggle(isDark),
                if (isMobile) spaceW(width: 12),
                if (isMobile) _buildAddButton(isDark, compact: true),
              ],
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppThemeData.primary50.withOpacity(0.3), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: AppThemeData.primary50.withOpacity(0.1),
            blurRadius: 12, spreadRadius: 0,
          ),
        ],
      ),
      child: TextFieldWidget(
        title: '', hintText: 'Search dues...',
        controller: controller.searchController,
        onPress: () {},
        prefix: Icon(SolarIconsOutline.minimalisticMagnifier,
          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6, size: 20,
        ),
        enabled: true, validator: (_) => null,
        fillColor: isDark ? AppThemeData.surfaceElevated : AppThemeData.grey2,
      ),
    );
  }

  Widget _buildFilterChip(bool isDark, {
    required String label, required IconData icon,
    required bool isActive, required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: isActive
                ? LinearGradient(
              colors: [
                AppThemeData.primary50.withOpacity(0.2),
                AppThemeData.neonPurple.withOpacity(0.15),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : null,
            color: isActive
                ? null
                : (isDark ? AppThemeData.surfaceElevated : AppThemeData.grey2),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isActive
                  ? AppThemeData.primary50
                  : (isDark ? AppThemeData.grey8 : AppThemeData.grey3),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16,
                color: isActive
                    ? AppThemeData.primary50
                    : (isDark ? AppThemeData.grey4 : AppThemeData.grey7),
              ),
              spaceW(width: 6),
              TextCustom(title: label, fontSize: 12, fontFamily: FontFamily.medium,
                color: isActive
                    ? AppThemeData.primary50
                    : (isDark ? AppThemeData.grey4 : AppThemeData.grey7),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewToggle(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.surfaceElevated : AppThemeData.grey2,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppThemeData.grey8 : AppThemeData.grey3),
      ),
      child: Obx(() => Row(
        children: [
          _buildToggleButton(isDark, icon: SolarIconsOutline.list,
            isSelected: !controller.isGridView.value,
            onTap: () { if (controller.isGridView.value) controller.toggleView(); },
          ),
          _buildToggleButton(isDark, icon: SolarIconsOutline.filters,
            isSelected: controller.isGridView.value,
            onTap: () { if (!controller.isGridView.value) controller.toggleView(); },
          ),
        ],
      )),
    );
  }

  Widget _buildToggleButton(bool isDark, {
    required IconData icon, required bool isSelected, required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? AppThemeData.primary50 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, size: 18,
          color: isSelected ? Colors.white : (isDark ? AppThemeData.grey5 : AppThemeData.grey6),
        ),
      ),
    );
  }

  Widget _buildAddButton(bool isDark, {bool compact = false}) {
    return ElevatedButton.icon(
      onPressed: () => _showAddEditDialog(Get.context!, isDark),
      icon: Icon(SolarIconsOutline.addCircle, size: compact ? 18 : 20),
      label: TextCustom(
        title: 'Add Due', fontSize: compact ? 13 : 14,
        fontFamily: FontFamily.semiBold, color: AppThemeData.primaryWhite,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppThemeData.primary50,
        foregroundColor: AppThemeData.primaryWhite,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 16 : 24, vertical: compact ? 12 : 14,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        elevation: 0,
      ),
    );
  }

  Widget _buildFloatingAddButton(bool isDark) {
    return FloatingActionButton(
      onPressed: () => _showAddEditDialog(Get.context!, isDark),
      backgroundColor: AppThemeData.primary50, elevation: 4,
      child: const Icon(SolarIconsOutline.addCircle, color: Colors.white),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  DUE CARD  — with visible edit icon
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildDueCard(DuesTrackerModel due, bool isDark, BuildContext context) {
    final typeColor = due.dueTypeColor;
    final glowColor = due.isOverdue
        ? AppThemeData.neonRed
        : DueStatus.isSettled(due.status)
        ? AppThemeData.neonMint
        : AppThemeData.pending300;

    return RepaintBoundary(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: [
              isDark ? AppThemeData.surfaceElevated : Colors.white,
              isDark ? AppThemeData.surfaceDeep : Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: glowColor.withOpacity(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: glowColor.withOpacity(0.15),
              blurRadius: 24, spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildPaymentMethodIcon(due, isDark, size: 32),
                  const Spacer(),
                  _buildStatusBadge(due, isDark),
                  spaceW(width: 8),
                  _buildPopupMenu(due, isDark),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextCustom(
                      title: due.customerName ?? 'Unknown',
                      fontSize: 20, fontFamily: FontFamily.bold,
                      color: isDark ? AppThemeData.primaryWhite : AppThemeData.primaryBlack,
                      maxLine: 1,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        TextCustom(
                          title: due.formattedAmount,
                          fontSize: 26, fontFamily: FontFamily.bold, color: typeColor,
                        ),
                        const Spacer(),
                        Icon(SolarIconsOutline.calendar, size: 14, color: AppThemeData.grey5),
                        spaceW(width: 4),
                        TextCustom(
                          title: '${due.shortGiveDate} → ${due.shortOweDate}',
                          fontSize: 12, fontFamily: FontFamily.medium, color: AppThemeData.grey5,
                        ),
                      ],
                    ),
                    if (due.note != null && due.note!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      TextCustom(
                        title: due.note!, fontSize: 13,
                        fontFamily: FontFamily.regular, color: AppThemeData.grey5,
                        maxLine: 2,
                      ),
                    ],
                  ],
                ),
              ),
              // ── NEW: Edit icon + payment method label in bottom-right ──
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (due.paymentMethod != null && due.paymentMethod!.isNotEmpty) ...[
                    Icon(SolarIconsOutline.card, size: 12, color: AppThemeData.grey5),
                    spaceW(width: 4),
                    TextCustom(
                      title: due.paymentMethod!,
                      fontSize: 11, fontFamily: FontFamily.medium,
                      color: AppThemeData.grey5,
                    ),
                    spaceW(width: 12),
                  ],
                  // ── Visible edit icon button ──
                  Material(
                    color: AppThemeData.primary50.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () => _showAddEditDialog(context, isDark, due: due),
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          SolarIconsOutline.pen,
                          size: 16,
                          color: AppThemeData.primary50,
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
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  DUE LIST TILE  — with visible edit icon
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildDueListTile(DuesTrackerModel due, bool isDark, BuildContext context) {
    final typeColor = due.dueTypeColor;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: isDark ? AppThemeData.surfaceElevated : Colors.white,
        border: Border.all(color: isDark ? AppThemeData.grey8 : AppThemeData.grey3),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _buildPaymentMethodIcon(due, isDark, size: 40),
        title: Row(
          children: [
            Expanded(
              child: TextCustom(
                title: due.customerName ?? 'Unknown',
                fontSize: 16, fontFamily: FontFamily.semiBold, maxLine: 1,
              ),
            ),
            _buildStatusBadge(due, isDark),
            spaceW(width: 8),
            _buildPopupMenu(due, isDark),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(SolarIconsOutline.calendar, size: 12, color: AppThemeData.grey5),
                spaceW(width: 4),
                TextCustom(
                  title: '${due.shortGiveDate} — ${due.shortOweDate}',
                  fontSize: 12, color: AppThemeData.grey5,
                ),
                spaceW(width: 12),
                Icon(SolarIconsOutline.card, size: 12, color: AppThemeData.grey5),
                spaceW(width: 4),
                TextCustom(
                  title: due.paymentMethod ?? 'N/A',
                  fontSize: 12, color: AppThemeData.grey5,
                ),
              ],
            ),
            if (due.note != null && due.note!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: TextCustom(
                  title: due.note!, fontSize: 12,
                  fontFamily: FontFamily.regular, color: AppThemeData.grey5, maxLine: 1,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextCustom(
              title: due.formattedAmount, fontSize: 18,
              fontFamily: FontFamily.bold, color: typeColor,
            ),
            spaceW(width: 8),
            // ── NEW: Visible edit icon in trailing ──
            Material(
              color: AppThemeData.primary50.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: () => _showAddEditDialog(context, isDark, due: due),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(SolarIconsOutline.pen, size: 16, color: AppThemeData.primary50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  PAYMENT METHOD ICON + STATUS BADGE + POPUP MENU (unchanged)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildPaymentMethodIcon(DuesTrackerModel due, bool isDark, {double size = 24}) {
    final hasIcon = due.hasPaymentIcon;
    final borderRadius = size > 30 ? 14.0 : 12.0;
    final innerRadius = borderRadius - 4;
    if (hasIcon) {
      return Container(
        width: size + 12, height: size + 12,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.surfaceLight : AppThemeData.grey2,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(innerRadius),
          child: NetworkImageWidget(
            imageUrl: due.paymentMethodIcon!,
            height: size, width: size, fit: BoxFit.cover,
          ),
        ),
      );
    }
    return Container(
      width: size + 12, height: size + 12,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.surfaceLight : AppThemeData.grey2,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(SolarIconsOutline.card, size: size, color: AppThemeData.grey5),
    );
  }

  Widget _buildStatusBadge(DuesTrackerModel due, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            due.statusBgColor.withOpacity(0.2),
            due.statusBgColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: due.statusColor.withOpacity(0.4)),
      ),
      child: TextCustom(
        title: due.statusLabel.toUpperCase(),
        fontSize: 11, fontFamily: FontFamily.bold, color: due.statusColor,
      ),
    );
  }

  Widget _buildPopupMenu(DuesTrackerModel due, bool isDark) {
    return PopupMenuButton<String>(
      icon: Icon(SolarIconsOutline.menuDots, size: 20, color: AppThemeData.grey5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            _showAddEditDialog(Get.context!, isDark, due: due);
            break;
          case 'settle':
            controller.markAsSettled(due);
            break;
          case 'delete':
            controller.deleteDue(due);
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(children: [
            const Icon(SolarIconsOutline.pen, size: 16),
            spaceW(width: 10),
            const Text('Edit'),
          ]),
        ),
        if (!DueStatus.isSettled(due.status))
          PopupMenuItem(
            value: 'settle',
            child: Row(children: [
              Icon(SolarIconsBold.checkCircle, size: 16, color: AppThemeData.success300),
              spaceW(width: 10),
              const Text('Mark Settled'),
            ]),
          ),
        PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            Icon(SolarIconsOutline.trashBin2, size: 16, color: AppThemeData.danger300),
            spaceW(width: 10),
            const Text('Delete', style: TextStyle(color: Colors.red)),
          ]),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(SolarIconsOutline.notes, size: 64,
            color: isDark ? AppThemeData.grey6 : AppThemeData.grey4,
          ),
          const SizedBox(height: 16),
          TextCustom(
            title: 'No dues found', fontSize: 16, fontFamily: FontFamily.medium,
            color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  ADD / EDIT DIALOG  — with payment method dropdown
  // ═══════════════════════════════════════════════════════════════════════

  void _showAddEditDialog(BuildContext context, bool isDark, {DuesTrackerModel? due}) {
    final formKey = GlobalKey<FormState>();

    // Set up controller state
    if (due == null) {
      controller.startAdding();
    } else {
      controller.startEditing(due);
    }

    // Local text controllers for name/amount/note
    String initialAmount = '';
    if (due != null && due.amount != null) {
      initialAmount = due.amount!.toStringAsFixed(0);
    }

    final nameController = TextEditingController(text: due?.customerName ?? '');
    final amountController = TextEditingController(text: initialAmount);
    final noteController = TextEditingController(text: due?.note ?? '');

    // NOTE: No more paymentMethodController — we use controller.selectedPaymentMethodObj

    controller.selectedGiveDate.value = due?.giveDate ?? DateTime.now();
    controller.selectedOweDate.value =
        due?.oweDate ?? DateTime.now().add(const Duration(days: 7));

    final RxString selectedType = (due?.dueType ?? DueType.owe).obs;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              width: min(MediaQuery.of(context).size.width, 500),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    isDark
                        ? AppThemeData.surfaceObsidian.withOpacity(0.85)
                        : Colors.white.withOpacity(0.9),
                    isDark
                        ? AppThemeData.surfaceDeep.withOpacity(0.9)
                        : Colors.white.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppThemeData.primary50.withOpacity(0.2), width: 1,
                ),
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Row(
                        children: [
                          Icon(
                            due == null ? SolarIconsOutline.addCircle : SolarIconsOutline.pen,
                            color: AppThemeData.primary50, size: 24,
                          ),
                          const SizedBox(width: 10),
                          TextCustom(
                            title: due == null ? 'Add New Due' : 'Edit Due Entry',
                            fontSize: 20, fontFamily: FontFamily.bold,
                            color: isDark ? AppThemeData.primaryWhite : AppThemeData.primaryBlack,
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => Get.back(),
                            icon: Icon(Icons.close,
                              color: isDark ? AppThemeData.grey4 : AppThemeData.grey6,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24, thickness: 0.5),

                      // Due Type Toggle
                      TextCustom(
                        title: 'Transaction Type', fontSize: 13,
                        fontFamily: FontFamily.semiBold,
                        color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
                      ),
                      const SizedBox(height: 10),
                      Obx(() => Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => selectedType.value = DueType.owe,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: selectedType.value == DueType.owe
                                      ? AppThemeData.danger300.withOpacity(0.2)
                                      : (isDark ? AppThemeData.surfaceElevated : AppThemeData.grey2),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: selectedType.value == DueType.owe
                                        ? AppThemeData.danger300
                                        : Colors.transparent,
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: TextCustom(
                                    title: 'I Owe Someone', fontSize: 14, fontFamily: FontFamily.bold,
                                    color: selectedType.value == DueType.owe
                                        ? AppThemeData.danger300
                                        : (isDark ? AppThemeData.grey4 : AppThemeData.grey7),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => selectedType.value = DueType.take,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: selectedType.value == DueType.take
                                      ? AppThemeData.success300.withOpacity(0.2)
                                      : (isDark ? AppThemeData.surfaceElevated : AppThemeData.grey2),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: selectedType.value == DueType.take
                                        ? AppThemeData.success300
                                        : Colors.transparent,
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: TextCustom(
                                    title: 'They Owe Me', fontSize: 14, fontFamily: FontFamily.bold,
                                    color: selectedType.value == DueType.take
                                        ? AppThemeData.success300
                                        : (isDark ? AppThemeData.grey4 : AppThemeData.grey7),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )),
                      const SizedBox(height: 20),

                      // Name Field
                      TextFieldWidget(
                        title: 'Contact Name', hintText: 'Enter name',
                        controller: nameController, enabled: true, onPress: () {},
                        prefix: const Icon(SolarIconsOutline.user, size: 18),
                        validator: (value) =>
                        (value == null || value.trim().isEmpty)
                            ? 'Please enter a name' : null,
                      ),
                      const SizedBox(height: 16),

                      // Amount Field
                      TextFieldWidget(
                        title: 'Amount (₹)', hintText: '0',
                        controller: amountController, enabled: true, onPress: () {},
                        prefix: const Icon(SolarIconsOutline.wallet, size: 18),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Please enter an amount';
                          if (double.tryParse(value) == null || double.parse(value) <= 0)
                            return 'Enter a valid amount';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Dates
                      Row(
                        children: [
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextCustom(title: 'Given Date', fontSize: 13,
                                fontFamily: FontFamily.medium,
                                color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
                              ),
                              const SizedBox(height: 6),
                              Obx(() => InkWell(
                                onTap: () => controller.pickGiveDate(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppThemeData.surfaceElevated : AppThemeData.grey2,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(children: [
                                    Icon(SolarIconsOutline.calendar, size: 16, color: AppThemeData.primary50),
                                    const SizedBox(width: 8),
                                    Expanded(child: TextCustom(
                                      title: controller.selectedGiveDate.value != null
                                          ? DateFormat('dd MMM yyyy').format(controller.selectedGiveDate.value!)
                                          : DateFormat('dd MMM yyyy').format(DateTime.now()),
                                      fontSize: 13,
                                    )),
                                  ]),
                                ),
                              )),
                            ],
                          )),
                          const SizedBox(width: 12),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextCustom(title: 'Due Date', fontSize: 13,
                                fontFamily: FontFamily.medium,
                                color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
                              ),
                              const SizedBox(height: 6),
                              Obx(() => InkWell(
                                onTap: () => controller.pickOweDate(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppThemeData.surfaceElevated : AppThemeData.grey2,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(children: [
                                    Icon(SolarIconsOutline.calendar, size: 16, color: AppThemeData.primary50),
                                    const SizedBox(width: 8),
                                    Expanded(child: TextCustom(
                                      title: controller.selectedOweDate.value != null
                                          ? DateFormat('dd MMM yyyy').format(controller.selectedOweDate.value!)
                                          : DateFormat('dd MMM yyyy').format(DateTime.now().add(const Duration(days: 7))),
                                      fontSize: 13,
                                    )),
                                  ]),
                                ),
                              )),
                            ],
                          )),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── NEW: Payment Method Dropdown with icon + name ──
                      _buildPaymentMethodDropdown(isDark),
                      const SizedBox(height: 16),

                      // Notes
                      TextFieldWidget(
                        title: 'Remarks / Notes', hintText: 'Optional context details...',
                        controller: noteController, enabled: true, onPress: () {},
                        prefix: const Icon(SolarIconsOutline.notes, size: 18),
                      ),
                      const SizedBox(height: 28),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              // Sync text fields back to controller
                              controller.customerNameController.text = nameController.text.trim();
                              controller.amountController.text = amountController.text.trim();
                              controller.noteController.text = noteController.text.trim();
                              controller.selectedDueTypeForm.value = selectedType.value;

                              // NOTE: No more paymentMethodController sync —
                              // selectedPaymentMethodObj is already set by the dropdown

                              controller.saveDue();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppThemeData.primary50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: TextCustom(
                            title: due == null ? 'Create Due Entry' : 'Save Changes',
                            fontSize: 16, fontFamily: FontFamily.bold,
                            color: AppThemeData.primaryWhite,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  NEW: Payment Method Dropdown (icon + name, premium style)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildPaymentMethodDropdown(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(
          title: 'Payment Method',
          fontSize: 13,
          fontFamily: FontFamily.semiBold,
          color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
        ),
        const SizedBox(height: 8),
        Obx(() {
          final selected = controller.selectedPaymentMethodObj.value;
          final methods = controller.paymentMethods;

          return Container(
            decoration: BoxDecoration(
              color: isDark ? AppThemeData.surfaceElevated : AppThemeData.grey2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected != null
                    ? AppThemeData.primary50.withOpacity(0.5)
                    : (isDark ? AppThemeData.grey8 : AppThemeData.grey3),
                width: 1.2,
              ),
            ),
            child: PopupMenuButton<PaymentMethodModel>(
              offset: const Offset(0, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: isDark ? AppThemeData.surfaceElevated : Colors.white,
              onSelected: (method) {
                controller.onPaymentMethodSelected(method);
              },
              itemBuilder: (context) => methods.map((method) {
                return PopupMenuItem<PaymentMethodModel>(
                  value: method,
                  height: 48,
                  child: Row(
                    children: [
                      // Payment method icon
                      if (method.pIcon != null && method.pIcon!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: NetworkImageWidget(
                            imageUrl: method.pIcon!,
                            height: 28, width: 28, fit: BoxFit.cover,
                          ),
                        )
                      else
                        Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            color: isDark ? AppThemeData.surfaceLight : AppThemeData.grey3,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(SolarIconsOutline.card,
                            size: 16, color: AppThemeData.grey5,
                          ),
                        ),
                      spaceW(width: 10),
                      Expanded(
                        child: TextCustom(
                          title: method.pName ?? 'Unknown',
                          fontSize: 14, fontFamily: FontFamily.medium,
                          color: isDark ? AppThemeData.primaryWhite : AppThemeData.primaryBlack,
                        ),
                      ),
                      if (selected?.id == method.id)
                        Icon(SolarIconsBold.checkCircle,
                          size: 18, color: AppThemeData.primary50,
                        ),
                    ],
                  ),
                );
              }).toList(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  children: [
                    // Selected method icon
                    if (selected != null && selected.pIcon != null && selected.pIcon!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: NetworkImageWidget(
                          imageUrl: selected.pIcon!,
                          height: 28, width: 28, fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          color: isDark ? AppThemeData.surfaceLight : AppThemeData.grey3,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(SolarIconsOutline.card,
                          size: 16, color: AppThemeData.grey5,
                        ),
                      ),
                    spaceW(width: 10),
                    Expanded(
                      child: TextCustom(
                        title: selected?.pName ?? 'Select payment method',
                        fontSize: 14,
                        fontFamily: selected != null ? FontFamily.medium : FontFamily.regular,
                        color: selected != null
                            ? (isDark ? AppThemeData.primaryWhite : AppThemeData.primaryBlack)
                            : (isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                      ),
                    ),
                    Icon(
                      Icons.unfold_more_rounded,
                      size: 18,
                      color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        // Validation error text
        Obx(() {
          // Show error only after a save attempt fails validation
          if (controller.selectedPaymentMethodObj.value == null &&
              controller.isSaving.value == false) {
            // We don't show error preemptively, only during save
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  ANIMATED MESH BACKGROUND  (unchanged)
// ═══════════════════════════════════════════════════════════════════════════

class _AnimatedMeshBackground extends StatefulWidget {
  final bool isDark;
  const _AnimatedMeshBackground({required this.isDark});

  @override
  State<_AnimatedMeshBackground> createState() => _AnimatedMeshBackgroundState();
}

class _AnimatedMeshBackgroundState extends State<_AnimatedMeshBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(
                -0.2 + (_controller.value * 0.4),
                -0.3 + (_controller.value * 0.6),
              ),
              radius: 0.8,
              colors: widget.isDark
                  ? [
                AppThemeData.neonPurpleDim.withOpacity(0.3),
                AppThemeData.surfaceVoid,
              ]
                  : [AppThemeData.primary50.withOpacity(0.1), Colors.white],
            ),
          ),
        );
      },
    );
  }
}
