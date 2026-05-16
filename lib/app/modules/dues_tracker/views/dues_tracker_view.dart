import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/dark_theme_provider.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/utils/mahek_responsive.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/network_image_widget.dart';
import 'package:maheksync/app/widgets/text_field_widget.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'package:provider/provider.dart';
import '../controllers/dues_tracker_controller.dart';
import 'package:maheksync/app/models/dues_tracker_model.dart';

class DuesTrackerView extends GetView<DuesTrackerController> {
  const DuesTrackerView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<DarkThemeProvider>(context);
    final isDark = theme.isDarkTheme();

    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(
            color: AppThemeData.primary50,
            strokeWidth: 3,
          ),
        );
      }

      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MahekResponsive.isMobile(context) ? 12 : 24,
          vertical: 12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildToolbar(context, isDark),
            spaceH(height: 20),
            _buildStatsRow(context, isDark),
            spaceH(height: 20),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: controller.isGridView.value
                    ? _buildGridView(context, isDark)
                    : _buildListView(context, isDark),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildToolbar(BuildContext context, bool isDark) {
    final isMobile = MahekResponsive.isMobile(context);

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildSearchField(isDark)),
              spaceW(width: 10),
              _buildAddButton(isDark, compact: true),
            ],
          ),
          spaceH(height: 12),
          Row(
            children: [
              Obx(() => _buildFilterChip(
                isDark,
                label: controller.selectedDueType.value == 'ALL'
                    ? 'All Type'
                    : controller.selectedDueType.value == DueType.owe
                        ? 'I Owe'
                        : 'They Owe Me',
                isActive: controller.selectedDueType.value != 'ALL',
                onTap: () => _showDueTypeFilter(context, isDark),
              )),
              spaceW(width: 8),
              Obx(() => _buildFilterChip(
                isDark,
                label: controller.selectedStatus.value == 'ALL'
                    ? 'All Status'
                    : DueStatus.label(controller.selectedStatus.value),
                isActive: controller.selectedStatus.value != 'ALL',
                onTap: () => _showStatusFilter(context, isDark),
              )),
              if (controller.hasActiveFilters) ...[
                spaceW(width: 6),
                _buildClearFilterButton(isDark),
              ],
              const Spacer(),
              _buildViewToggle(isDark),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        Flexible(child: _buildSearchField(isDark)),
        spaceW(width: 12),
        Obx(() => _buildFilterChip(
          isDark,
          label: controller.selectedDueType.value == 'ALL'
              ? 'All Type'
              : controller.selectedDueType.value == DueType.owe
                  ? 'I Owe'
                  : 'They Owe Me',
          isActive: controller.selectedDueType.value != 'ALL',
          onTap: () => _showDueTypeFilter(context, isDark),
        )),
        spaceW(width: 8),
        Obx(() => _buildFilterChip(
          isDark,
          label: controller.selectedStatus.value == 'ALL'
              ? 'All Status'
              : DueStatus.label(controller.selectedStatus.value),
          isActive: controller.selectedStatus.value != 'ALL',
          onTap: () => _showStatusFilter(context, isDark),
        )),
        if (controller.hasActiveFilters) ...[
          spaceW(width: 6),
          _buildClearFilterButton(isDark),
        ],
        spaceW(width: 12),
        _buildViewToggle(isDark),
        spaceW(width: 16),
        _buildAddButton(isDark),
      ],
    );
  }

  Widget _buildSearchField(bool isDark) {
    return SizedBox(
      width: 260,
      child: TextFieldWidget(
        title: '',
        hintText: 'Search dues...',
        controller: controller.searchController,
        onPress: () {},
        prefix: Icon(
          SolarIconsOutline.minimalisticMagnifier,
          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
          size: 20,
        ),
        enabled: true,
        validator: (_) => null,
      ),
    );
  }

  Widget _buildAddButton(bool isDark, {bool compact = false}) {
    return ElevatedButton.icon(
      onPressed: () => _showAddEditDialog(Get.context!, isDark),
      icon: Icon(SolarIconsOutline.addCircle, size: compact ? 18 : 20),
      label: TextCustom(
        title: 'Add Due',
        fontSize: compact ? 13 : 14,
        fontFamily: FontFamily.semiBold,
        color: AppThemeData.primaryWhite,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppThemeData.primary50,
        foregroundColor: AppThemeData.primaryWhite,
        padding: paddingEdgeInsets(
          horizontal: compact ? 16 : 24,
          vertical: compact ? 12 : 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 0,
      ),
    );
  }

  Widget _buildViewToggle(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey9 : AppThemeData.grey2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
          width: 0.5,
        ),
      ),
      child: Obx(() => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleItem(
            isDark,
            icon: SolarIconsOutline.list,
            isSelected: !controller.isGridView.value,
            tooltip: 'List View',
            onTap: () {
              if (controller.isGridView.value) controller.toggleView();
            },
          ),
          _buildToggleItem(
            isDark,
            icon: SolarIconsOutline.filters,
            isSelected: controller.isGridView.value,
            tooltip: 'Grid View',
            onTap: () {
              if (!controller.isGridView.value) controller.toggleView();
            },
          ),
        ],
      )),
    );
  }

  Widget _buildToggleItem(
    bool isDark, {
    required IconData icon,
    required bool isSelected,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppThemeData.primary50
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected
              ? AppThemeData.primaryWhite
              : (isDark ? AppThemeData.grey5 : AppThemeData.grey6),
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    bool isDark, {
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: paddingEdgeInsets(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? AppThemeData.primary50.withValues(alpha: 0.08)
              : (isDark ? AppThemeData.grey9 : AppThemeData.grey2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive
                ? AppThemeData.primary50.withValues(alpha: 0.3)
                : (isDark ? AppThemeData.grey8 : AppThemeData.grey3),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              SolarIconsOutline.filter,
              size: 14,
              color: isActive
                  ? AppThemeData.primary50
                  : (isDark ? AppThemeData.grey5 : AppThemeData.grey6),
            ),
            spaceW(width: 6),
            TextCustom(
              title: label,
              fontSize: 12,
              fontFamily: FontFamily.medium,
              color: isActive
                  ? AppThemeData.primary50
                  : (isDark ? AppThemeData.grey5 : AppThemeData.grey6),
            ),
            spaceW(width: 4),
            Icon(
              SolarIconsOutline.altArrowDown,
              size: 14,
              color: isActive
                  ? AppThemeData.primary50
                  : (isDark ? AppThemeData.grey5 : AppThemeData.grey6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClearFilterButton(bool isDark) {
    return GestureDetector(
      onTap: controller.clearFilters,
      child: Container(
        padding: paddingEdgeInsets(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppThemeData.danger300.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          SolarIconsOutline.closeCircle,
          size: 16,
          color: AppThemeData.danger300,
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, bool isDark) {
    return Row(
      children: [
        _buildStatCard(
          isDark,
          title: 'I Owe',
          amount: controller.totalOweAmount,
          count: controller.oweCount,
          icon: SolarIconsBold.arrowUp,
          color: AppThemeData.danger300,
        ),
        spaceW(width: 12),
        _buildStatCard(
          isDark,
          title: 'They Owe Me',
          amount: controller.totalTakeAmount,
          count: controller.takeCount,
          icon: SolarIconsBold.arrowDown,
          color: AppThemeData.success300,
        ),
        spaceW(width: 12),
        _buildStatCard(
          isDark,
          title: 'Net Balance',
          amount: controller.netBalance.abs(),
          count: controller.totalActiveCount,
          icon: controller.netBalance >= 0
              ? SolarIconsBold.graphUp
              : SolarIconsBold.graphDown,
          color: controller.netBalance >= 0
              ? AppThemeData.success300
              : AppThemeData.danger300,
          isNet: true,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    bool isDark, {
    required String title,
    required double amount,
    required int count,
    required IconData icon,
    required Color color,
    bool isNet = false,
  }) {
    return Expanded(
      child: Container(
        padding: paddingEdgeInsets(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: isDark
              ? color.withValues(alpha: 0.06)
              : color.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: isDark ? 0.15 : 0.10),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            spaceH(height: 14),
            TextCustom(
              title: (isNet && controller.netBalance < 0 ? '-' : '') +
                  '\u20B9${amount.toStringAsFixed(2)}',
              fontSize: 22,
              fontFamily: FontFamily.bold,
              color: color,
            ),
            spaceH(height: 4),
            Row(
              children: [
                TextCustom(
                  title: title,
                  fontSize: 11,
                  fontFamily: FontFamily.medium,
                  color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                ),
                if (!isNet && count > 0) ...[
                  spaceW(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextCustom(
                      title: '$count',
                      fontSize: 10,
                      fontFamily: FontFamily.bold,
                      color: color,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView(BuildContext context, bool isDark) {
    return Obx(() {
      if (controller.filteredDues.isEmpty) {
        return _buildEmptyState(isDark);
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          int crossAxisCount;
          if (screenWidth >= 1400) {
            crossAxisCount = 4;
          } else if (screenWidth >= 1000) {
            crossAxisCount = 3;
          } else if (screenWidth >= 600) {
            crossAxisCount = 2;
          } else {
            crossAxisCount = 1;
          }

          final cardWidth =
              (screenWidth - (crossAxisCount - 1) * 14) / crossAxisCount;
          final cardHeight = 210.0;

          return GridView.builder(
            key: const ValueKey('grid'),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: cardWidth / cardHeight,
            ),
            itemCount: controller.filteredDues.length,
            padding: const EdgeInsets.only(bottom: 24),
            itemBuilder: (context, index) {
              final due = controller.filteredDues[index];
              return _buildDueCard(due, isDark);
            },
          );
        },
      );
    });
  }

  Widget _buildListView(BuildContext context, bool isDark) {
    return Obx(() {
      if (controller.filteredDues.isEmpty) {
        return _buildEmptyState(isDark);
      }

      return ListView.separated(
        key: const ValueKey('list'),
        itemCount: controller.filteredDues.length,
        padding: const EdgeInsets.only(bottom: 24),
        separatorBuilder: (_, __) => spaceH(height: 10),
        itemBuilder: (context, index) {
          final due = controller.filteredDues[index];
          return _buildDueListTile(due, isDark);
        },
      );
    });
  }

  Widget _buildDueCard(DuesTrackerModel due, bool isDark) {
    final typeColor = due.dueTypeColor;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey9 : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.10 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Container(
              width: 4,
              color: typeColor,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 14, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: typeColor.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: TextCustom(
                            title: due.dueTypeShortLabel,
                            fontSize: 10,
                            fontFamily: FontFamily.bold,
                            color: typeColor,
                          ),
                        ),
                        const Spacer(),
                        if (due.isOverdue)
                          Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  SolarIconsBold.dangerTriangle,
                                  size: 10,
                                  color: const Color(0xFFF59E0B),
                                ),
                                spaceW(width: 3),
                                TextCustom(
                                  title: 'OVERDUE',
                                  fontSize: 9,
                                  fontFamily: FontFamily.bold,
                                  color: const Color(0xFFF59E0B),
                                ),
                              ],
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: due.statusBgColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: TextCustom(
                            title: due.statusLabel.toUpperCase(),
                            fontSize: 9,
                            fontFamily: FontFamily.bold,
                            color: due.statusColor,
                          ),
                        ),
                        spaceW(width: 2),
                        _buildPopupMenu(due, isDark),
                      ],
                    ),
                    spaceH(height: 12),
                    TextCustom(
                      title: due.customerName ?? 'Unknown',
                      fontSize: 15,
                      fontFamily: FontFamily.semiBold,
                      color: isDark
                          ? AppThemeData.primaryWhite
                          : AppThemeData.primaryBlack,
                      maxLine: 1,
                    ),
                    spaceH(height: 6),
                    TextCustom(
                      title: due.formattedAmount,
                      fontSize: 22,
                      fontFamily: FontFamily.bold,
                      color: typeColor,
                    ),
                    spaceH(height: 12),
                    Row(
                      children: [
                        _buildPaymentMethodBadge(due, isDark),
                        const Spacer(),
                        Icon(
                          SolarIconsOutline.calendar,
                          size: 12,
                          color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
                        ),
                        spaceW(width: 4),
                        TextCustom(
                          title: '${due.shortGiveDate} — ${due.shortOweDate}',
                          fontSize: 11,
                          fontFamily: FontFamily.regular,
                          color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDueListTile(DuesTrackerModel due, bool isDark) {
    final typeColor = due.dueTypeColor;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey9 : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 80,
              color: typeColor,
            ),
            Expanded(
              child: Padding(
                padding: paddingEdgeInsets(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    _buildPaymentMethodIcon(due, isDark, size: 32),
                    spaceW(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextCustom(
                                  title: due.customerName ?? 'Unknown',
                                  fontSize: 14,
                                  fontFamily: FontFamily.semiBold,
                                  color: isDark
                                      ? AppThemeData.primaryWhite
                                      : AppThemeData.primaryBlack,
                                  maxLine: 1,
                                ),
                              ),
                              if (due.isOverdue)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF59E0B)
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: TextCustom(
                                    title: 'OVERDUE',
                                    fontSize: 8,
                                    fontFamily: FontFamily.bold,
                                    color: const Color(0xFFF59E0B),
                                  ),
                                ),
                            ],
                          ),
                          spaceH(height: 4),
                          Row(
                            children: [
                              TextCustom(
                                title: due.paymentMethod ?? 'N/A',
                                fontSize: 12,
                                fontFamily: FontFamily.medium,
                                color: isDark
                                    ? AppThemeData.grey5
                                    : AppThemeData.grey6,
                              ),
                              TextCustom(
                                title: '  \u2022  ',
                                fontSize: 12,
                                color: isDark
                                    ? AppThemeData.grey7
                                    : AppThemeData.grey4,
                              ),
                              Flexible(
                                child: TextCustom(
                                  title: '${due.shortGiveDate} — ${due.shortOweDate}',
                                  fontSize: 12,
                                  fontFamily: FontFamily.regular,
                                  color: isDark
                                      ? AppThemeData.grey5
                                      : AppThemeData.grey6,
                                  maxLine: 1,
                                ),
                              ),
                            ],
                          ),
                          spaceH(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: due.statusBgColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: TextCustom(
                              title: due.statusLabel.toUpperCase(),
                              fontSize: 9,
                              fontFamily: FontFamily.bold,
                              color: due.statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    spaceW(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TextCustom(
                          title: due.formattedAmount,
                          fontSize: 17,
                          fontFamily: FontFamily.bold,
                          color: typeColor,
                        ),
                        spaceH(height: 2),
                        _buildPopupMenu(due, isDark),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodIcon(
    DuesTrackerModel due,
    bool isDark, {
    double size = 20,
  }) {
    final hasIcon = due.hasPaymentIcon;
    final borderRadius = size > 24 ? 12.0 : 8.0;
    final innerRadius = size > 24 ? 8.0 : 5.0;
    final padding = size > 24 ? 6.0 : 4.0;

    if (hasIcon) {
      return Container(
        width: size + 12,
        height: size + 12,
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: isDark
              ? AppThemeData.grey8.withValues(alpha: 0.4)
              : AppThemeData.grey2,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(innerRadius),
          child: NetworkImageWidget(
            imageUrl: due.paymentMethodIcon!,
            height: size,
            width: size,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Container(
      width: size + 12,
      height: size + 12,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: isDark
            ? AppThemeData.grey8.withValues(alpha: 0.4)
            : AppThemeData.grey2,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(
        SolarIconsOutline.card,
        size: size - 2,
        color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
      ),
    );
  }

  Widget _buildPaymentMethodBadge(DuesTrackerModel due, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (due.hasPaymentIcon)
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: NetworkImageWidget(
              imageUrl: due.paymentMethodIcon!,
              height: 14,
              width: 14,
              fit: BoxFit.cover,
            ),
          )
        else
          Icon(
            SolarIconsOutline.card,
            size: 12,
            color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
          ),
        spaceW(width: 4),
        TextCustom(
          title: due.paymentMethod ?? 'N/A',
          fontSize: 11,
          fontFamily: FontFamily.medium,
          color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
        ),
      ],
    );
  }

  Widget _buildPopupMenu(DuesTrackerModel due, bool isDark) {
    return PopupMenuButton<String>(
      icon: Icon(
        SolarIconsOutline.menuDots,
        size: 18,
        color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      offset: const Offset(0, 4),
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
          child: Row(
            children: [
              Icon(
                SolarIconsOutline.pen,
                size: 16,
                color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
              ),
              spaceW(width: 10),
              const Text('Edit'),
            ],
          ),
        ),
        if (!DueStatus.isSettled(due.status))
          PopupMenuItem(
            value: 'settle',
            child: Row(
              children: [
                Icon(
                  SolarIconsBold.checkCircle,
                  size: 16,
                  color: AppThemeData.success300,
                ),
                spaceW(width: 10),
                const Text('Mark Settled'),
              ],
            ),
          ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(
                SolarIconsOutline.trashBin2,
                size: 16,
                color: AppThemeData.danger300,
              ),
              spaceW(width: 10),
              const Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppThemeData.primary50.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                SolarIconsOutline.wallet,
                size: 48,
                color: AppThemeData.primary50.withValues(alpha: 0.5),
              ),
            ),
            spaceH(height: 24),
            TextCustom(
              title: 'No dues found',
              fontSize: 18,
              fontFamily: FontFamily.semiBold,
              color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
            ),
            spaceH(height: 8),
            TextCustom(
              title: 'Tap "Add Due" to start tracking your dues',
              fontSize: 13,
              fontFamily: FontFamily.regular,
              color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEditDialog(
    BuildContext context,
    bool isDark, {
    DuesTrackerModel? due,
  }) {
    if (due != null) {
      controller.startEditing(due);
    } else {
      controller.startAdding();
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: isDark ? AppThemeData.grey10 : AppThemeData.primaryWhite,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MahekResponsive.isMobile(context)
                ? MediaQuery.of(context).size.width * 0.92
                : 520,
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogHeader(isDark, isEditing: due != null),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() => _buildTypeSegmentedControl(isDark)),
                      spaceH(height: 20),
                      TextFieldWidget(
                        title: 'Customer Name',
                        hintText: 'Enter customer name',
                        controller: controller.customerNameController,
                        onPress: () {},
                        prefix: Icon(
                          SolarIconsOutline.userCheckRounded,
                          size: 18,
                          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                        ),
                        enabled: true,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      spaceH(height: 16),
                      TextFieldWidget(
                        title: 'Amount',
                        hintText: 'Enter amount',
                        controller: controller.amountController,
                        onPress: () {},
                        prefix: Icon(
                          SolarIconsBold.banknote,
                          size: 18,
                          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                        ),
                        enabled: true,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      spaceH(height: 16),
                      Obx(() => _buildPaymentMethodDropdown(isDark)),
                      spaceH(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Obx(
                              () => _buildDatePicker(
                                isDark,
                                label: 'Give Date',
                                date: controller.selectedGiveDate.value,
                                onTap: () => controller.pickGiveDate(context),
                              ),
                            ),
                          ),
                          spaceW(width: 12),
                          Expanded(
                            child: Obx(
                              () => _buildDatePicker(
                                isDark,
                                label: 'Due Date',
                                date: controller.selectedOweDate.value,
                                onTap: () => controller.pickOweDate(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                      spaceH(height: 16),
                      Obx(() => _buildStatusDropdown(isDark)),
                      spaceH(height: 16),
                      TextFieldWidget(
                        title: 'Note (Optional)',
                        hintText: 'Add a note...',
                        controller: controller.noteController,
                        onPress: () {},
                        prefix: Icon(
                          SolarIconsOutline.notes,
                          size: 18,
                          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                        ),
                        enabled: true,
                        validator: (_) => null,
                      ),
                      spaceH(height: 24),
                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: controller.isSaving.value
                                ? null
                                : controller.saveDue,
                            icon: controller.isSaving.value
                                ? SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppThemeData.primaryWhite,
                                    ),
                                  )
                                : const Icon(
                                    SolarIconsBold.checkCircle,
                                    size: 20,
                                  ),
                            label: TextCustom(
                              title: controller.isSaving.value
                                  ? 'Saving...'
                                  : 'Save Due',
                              fontSize: 15,
                              fontFamily: FontFamily.semiBold,
                              color: AppThemeData.primaryWhite,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppThemeData.primary50,
                              foregroundColor: AppThemeData.primaryWhite,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogHeader(bool isDark, {required bool isEditing}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 12, 16),
      decoration: BoxDecoration(
        color: isDark
            ? AppThemeData.grey9
            : AppThemeData.grey2.withValues(alpha: 0.5),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppThemeData.primary50.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isEditing
                  ? SolarIconsOutline.penNewRound
                  : SolarIconsOutline.addCircle,
              size: 20,
              color: AppThemeData.primary50,
            ),
          ),
          spaceW(width: 12),
          TextCustom(
            title: isEditing ? 'Edit Due' : 'Add Due',
            fontSize: 18,
            fontFamily: FontFamily.bold,
            color: isDark
                ? AppThemeData.primaryWhite
                : AppThemeData.primaryBlack,
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              SolarIconsOutline.closeCircle,
              size: 22,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            ),
            splashRadius: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSegmentedControl(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey9 : AppThemeData.grey2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          _buildSegmentItem(
            isDark,
            label: 'I Owe',
            icon: SolarIconsBold.arrowUp,
            isSelected: controller.selectedDueTypeForm.value == DueType.owe,
            color: AppThemeData.danger300,
            onTap: () => controller.selectedDueTypeForm.value = DueType.owe,
          ),
          _buildSegmentItem(
            isDark,
            label: 'They Owe Me',
            icon: SolarIconsBold.arrowDown,
            isSelected: controller.selectedDueTypeForm.value == DueType.take,
            color: AppThemeData.success300,
            onTap: () => controller.selectedDueTypeForm.value = DueType.take,
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentItem(
    bool isDark, {
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: paddingEdgeInsets(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? color
                    : (isDark ? AppThemeData.grey5 : AppThemeData.grey6),
              ),
              spaceW(width: 6),
              TextCustom(
                title: label,
                fontSize: 12,
                fontFamily: isSelected ? FontFamily.bold : FontFamily.medium,
                color: isSelected
                    ? color
                    : (isDark ? AppThemeData.grey5 : AppThemeData.grey6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodDropdown(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(
          title: 'Payment Method',
          fontSize: 12,
          fontFamily: FontFamily.medium,
          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
        ),
        spaceH(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.grey9 : AppThemeData.grey2,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
              width: 0.5,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: controller.selectedPaymentMethodForm.value,
              hint: Row(
                children: [
                  Icon(
                    SolarIconsOutline.card,
                    size: 18,
                    color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                  ),
                  spaceW(width: 8),
                  TextCustom(
                    title: 'Select payment method',
                    fontSize: 14,
                    fontFamily: FontFamily.regular,
                    color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                  ),
                ],
              ),
              isExpanded: true,
              icon: Icon(
                SolarIconsOutline.altArrowDown,
                size: 18,
                color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
              ),
              items: controller.paymentMethods.map((method) {
                return DropdownMenuItem<String>(
                  value: method.pName,
                  child: Row(
                    children: [
                      if (method.pIcon != null && method.pIcon!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: NetworkImageWidget(
                              imageUrl: method.pIcon!,
                              height: 18,
                              width: 18,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(
                            SolarIconsOutline.card,
                            size: 16,
                            color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                          ),
                        ),
                      Text(method.pName ?? ''),
                    ],
                  ),
                );
              }).toList(),
              onChanged: controller.onPaymentMethodSelected,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDropdown(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(
          title: 'Status',
          fontSize: 12,
          fontFamily: FontFamily.medium,
          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
        ),
        spaceH(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.grey9 : AppThemeData.grey2,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
              width: 0.5,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: controller.selectedStatusForm.value,
              isExpanded: true,
              icon: Icon(
                SolarIconsOutline.altArrowDown,
                size: 18,
                color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
              ),
              items: DueStatus.values.map((status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(DueStatus.label(status)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) controller.selectedStatusForm.value = val;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(
    bool isDark, {
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextCustom(
            title: label,
            fontSize: 12,
            fontFamily: FontFamily.medium,
            color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
          ),
          spaceH(height: 6),
          Container(
            padding: paddingEdgeInsets(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? AppThemeData.grey9 : AppThemeData.grey2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  SolarIconsOutline.calendar,
                  size: 18,
                  color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                ),
                spaceW(width: 10),
                Expanded(
                  child: TextCustom(
                    title: date != null
                        ? DateFormat('dd MMM yyyy').format(date)
                        : 'Select date',
                    fontSize: 14,
                    fontFamily:
                        date != null ? FontFamily.medium : FontFamily.regular,
                    color: date != null
                        ? (isDark
                            ? AppThemeData.primaryWhite
                            : AppThemeData.primaryBlack)
                        : (isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                  ),
                ),
                Icon(
                  SolarIconsOutline.altArrowDown,
                  size: 16,
                  color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDueTypeFilter(BuildContext context, bool isDark) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.grey10 : AppThemeData.primaryWhite,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppThemeData.grey7 : AppThemeData.grey4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppThemeData.primary50.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    SolarIconsOutline.filter,
                    size: 18,
                    color: AppThemeData.primary50,
                  ),
                ),
                spaceW(width: 10),
                TextCustom(
                  title: 'Filter by Type',
                  fontSize: 16,
                  fontFamily: FontFamily.bold,
                  color: isDark
                      ? AppThemeData.primaryWhite
                      : AppThemeData.primaryBlack,
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Icon(
                    SolarIconsOutline.closeCircle,
                    size: 22,
                    color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                  ),
                ),
              ],
            ),
            spaceH(height: 16),
            ...controller.dueTypeOptions.map(
              (type) => Obx(() => _buildFilterOption(
                isDark,
                label: type == 'ALL'
                    ? 'All Types'
                    : type == DueType.owe
                        ? 'I Owe'
                        : 'They Owe Me',
                icon: type == 'ALL'
                    ? SolarIconsOutline.filters
                    : type == DueType.owe
                        ? SolarIconsBold.arrowUp
                        : SolarIconsBold.arrowDown,
                iconColor: type == DueType.owe
                    ? AppThemeData.danger300
                    : type == DueType.take
                        ? AppThemeData.success300
                        : AppThemeData.primary50,
                isSelected: controller.selectedDueType.value == type,
                onTap: () {
                  controller.filterByDueType(type);
                  Get.back();
                },
              )),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusFilter(BuildContext context, bool isDark) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.grey10 : AppThemeData.primaryWhite,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppThemeData.grey7 : AppThemeData.grey4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppThemeData.primary50.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    SolarIconsOutline.filter,
                    size: 18,
                    color: AppThemeData.primary50,
                  ),
                ),
                spaceW(width: 10),
                TextCustom(
                  title: 'Filter by Status',
                  fontSize: 16,
                  fontFamily: FontFamily.bold,
                  color: isDark
                      ? AppThemeData.primaryWhite
                      : AppThemeData.primaryBlack,
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Icon(
                    SolarIconsOutline.closeCircle,
                    size: 22,
                    color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                  ),
                ),
              ],
            ),
            spaceH(height: 16),
            ...controller.statusOptions.map(
              (status) => Obx(() => _buildFilterOption(
                isDark,
                label: status == 'ALL' ? 'All Statuses' : DueStatus.label(status),
                icon: status == 'ALL'
                    ? SolarIconsOutline.filters
                    : status == DueStatus.pending
                        ? SolarIconsOutline.clockCircle
                        : status == DueStatus.partial
                            ? SolarIconsOutline.notes
                            : SolarIconsBold.checkCircle,
                iconColor: status == DueStatus.pending
                    ? AppThemeData.danger300
                    : status == DueStatus.partial
                        ? const Color(0xFFF59E0B)
                        : status == DueStatus.settled
                            ? AppThemeData.success300
                            : AppThemeData.primary50,
                isSelected: controller.selectedStatus.value == status,
                onTap: () {
                  controller.filterByStatus(status);
                  Get.back();
                },
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(
    bool isDark, {
    required String label,
    required IconData icon,
    required Color iconColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 6),
        padding: paddingEdgeInsets(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppThemeData.primary50.withValues(alpha: 0.06)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(
                  color: AppThemeData.primary50.withValues(alpha: 0.2),
                  width: 0.5,
                )
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: iconColor),
            ),
            spaceW(width: 12),
            Expanded(
              child: TextCustom(
                title: label,
                fontSize: 14,
                fontFamily:
                    isSelected ? FontFamily.semiBold : FontFamily.regular,
                color: isSelected
                    ? AppThemeData.primary50
                    : (isDark
                        ? AppThemeData.primaryWhite
                        : AppThemeData.primaryBlack),
              ),
            ),
            if (isSelected)
              Icon(
                SolarIconsBold.checkCircle,
                size: 20,
                color: AppThemeData.primary50,
              ),
          ],
        ),
      ),
    );
  }
}
