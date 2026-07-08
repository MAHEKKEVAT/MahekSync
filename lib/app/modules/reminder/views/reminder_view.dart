import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/utils/mahek_responsive.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/mahek_loader.dart';
import 'package:maheksync/app/widgets/network_image_widget.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import '../../../models/reminder_model.dart';
import '../controllers/reminder_controller.dart';

class ReminderView extends GetView<ReminderController> {
  const ReminderView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppThemeData.grey10 : AppThemeData.grey2,
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: MahekLoader(
              message: 'Loading Reminders...',
              size: 50,
              textSize: 16,
            ),
          );
        }
        return _buildContent(isDark, context);
      }),
    );
  }

  Widget _buildContent(bool isDark, BuildContext context) {
    final isMobile = context.isMobile;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isDark, context),
          spaceH(height: isMobile ? 16 : 24),
          _buildStatsRow(isDark, context),
          spaceH(height: isMobile ? 16 : 20),
          _buildSectionHeader(isDark, context),
          spaceH(height: isMobile ? 12 : 16),
          _buildRemindersContent(isDark, context),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark, BuildContext context) {
    final isMobile = context.isMobile;

    return Row(
      children: [
        Container(
          width: isMobile ? 44 : 50,
          height: isMobile ? 44 : 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppThemeData.neonOrange, AppThemeData.neonPink],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppThemeData.neonOrange.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(
            Icons.alarm_rounded,
            color: AppThemeData.primaryWhite,
            size: isMobile ? 24 : 28,
          ),
        ),
        spaceW(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextCustom(
                title: 'Reminders',
                fontSize: isMobile ? 22 : 28,
                fontFamily: FontFamily.bold,
                color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              ),
              spaceH(height: 2),
              TextCustom(
                title: 'Stay on top of your tasks',
                fontSize: 13,
                fontFamily: FontFamily.regular,
                color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: controller.goToAdd,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppThemeData.primary50, AppThemeData.primary4],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppThemeData.primary50.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, color: AppThemeData.primaryWhite, size: 18),
                if (!isMobile) ...[
                  spaceW(width: 6),
                  TextCustom(
                    title: 'Add Reminder',
                    fontSize: 13,
                    fontFamily: FontFamily.semiBold,
                    color: AppThemeData.primaryWhite,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(bool isDark, BuildContext context) {
    final isMobile = context.isMobile;

    return Obx(() {
      final stats = [
        (icon: Icons.alarm_on_rounded, label: 'Active', value: '${controller.activeCount}', color: AppThemeData.success400),
        (icon: Icons.priority_high_rounded, label: 'High Priority', value: '${controller.highCount}', color: AppThemeData.danger300),
        (icon: Icons.event_busy_rounded, label: 'Expired', value: '${controller.expiredCount}', color: AppThemeData.grey5),
        (icon: Icons.list_rounded, label: 'Total', value: '${controller.reminders.length}', color: AppThemeData.neonTeal),
      ];

      if (isMobile) {
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildStatCard(stats[0], isDark)),
                spaceW(width: 10),
                Expanded(child: _buildStatCard(stats[1], isDark)),
              ],
            ),
            spaceH(height: 10),
            Row(
              children: [
                Expanded(child: _buildStatCard(stats[2], isDark)),
                spaceW(width: 10),
                Expanded(child: _buildStatCard(stats[3], isDark)),
              ],
            ),
          ],
        );
      }

      return Row(
        children: stats
            .map((s) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: _buildStatCard(s, isDark),
                  ),
                ))
            .toList(),
      );
    });
  }

  Widget _buildStatCard(({IconData icon, String label, String value, Color color}) stat, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.surfaceDeep : AppThemeData.grey1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? AppThemeData.surfaceBorder.withValues(alpha: 0.15)
              : AppThemeData.grey3,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: stat.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(stat.icon, size: 18, color: stat.color),
          ),
          spaceW(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextCustom(
                title: stat.value,
                fontSize: 18,
                fontFamily: FontFamily.bold,
                color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              ),
              TextCustom(
                title: stat.label,
                fontSize: 10,
                fontFamily: FontFamily.medium,
                color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(bool isDark, BuildContext context) {
    final isMobile = context.isMobile;

    return Row(
      children: [
        TextCustom(
          title: 'All Reminders',
          fontSize: isMobile ? 18 : 22,
          fontFamily: FontFamily.bold,
          color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
        ),
        const Spacer(),
        if (!isMobile) ...[
          _buildSearchBar(isDark),
          spaceW(width: 12),
        ],
        _buildImportanceFilter(isDark, context: context),
        spaceW(width: 10),
        _buildSortDropdown(isDark, context: context),
        spaceW(width: 10),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.surfaceDeep : AppThemeData.grey1,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark
                  ? AppThemeData.surfaceBorder.withValues(alpha: 0.3)
                  : AppThemeData.grey3,
            ),
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
                icon: Icons.view_list_rounded,
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

  Widget _buildSearchBar(bool isDark) {
    return Container(
      height: 36,
      constraints: const BoxConstraints(maxWidth: 260),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.surfaceDeep : AppThemeData.grey1,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? AppThemeData.surfaceBorder.withValues(alpha: 0.3)
              : AppThemeData.grey3,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, size: 16, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
          spaceW(width: 8),
          Expanded(
            child: Obx(() => TextField(
              controller: controller.searchController,
              onChanged: controller.updateSearchQuery,
              style: TextStyle(
                fontFamily: FontFamily.medium,
                fontSize: 12,
                color: isDark ? AppThemeData.grey3 : AppThemeData.grey8,
              ),
              decoration: InputDecoration(
                hintText: 'Search reminders...',
                hintStyle: TextStyle(
                  fontFamily: FontFamily.medium,
                  fontSize: 12,
                  color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                isDense: true,
                suffixIcon: controller.searchQuery.value.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          controller.searchController.clear();
                          controller.updateSearchQuery('');
                        },
                        child: Icon(Icons.close_rounded, size: 14, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                      )
                    : null,
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildImportanceFilter(bool isDark, {required BuildContext context}) {
    return Obx(() {
      final isFiltered = controller.selectedImportance.value != 'ALL';
      return GestureDetector(
        onTap: () => _showImportanceMenu(isDark, context: context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isFiltered
                ? AppThemeData.neonOrange.withValues(alpha: 0.1)
                : (isDark ? AppThemeData.surfaceDeep : AppThemeData.grey1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isFiltered
                  ? AppThemeData.neonOrange.withValues(alpha: 0.3)
                  : (isDark
                      ? AppThemeData.surfaceBorder.withValues(alpha: 0.3)
                      : AppThemeData.grey3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isFiltered)
                Icon(Icons.filter_alt_rounded, size: 14, color: AppThemeData.neonOrange)
              else
                Icon(Icons.filter_list_rounded, size: 14, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
              spaceW(width: 4),
              Text(
                controller.selectedImportance.value == 'ALL'
                    ? 'All'
                    : controller.selectedImportance.value,
                style: TextStyle(
                  fontFamily: FontFamily.medium,
                  fontSize: 12,
                  color: isFiltered
                      ? AppThemeData.neonOrange
                      : (isDark ? AppThemeData.grey4 : AppThemeData.grey7),
                ),
              ),
              spaceW(width: 2),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 14,
                color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showImportanceMenu(bool isDark, {required BuildContext context}) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx + renderBox.size.width - 200,
        offset.dy + 300,
        offset.dx + renderBox.size.width,
        offset.dy + 400,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? AppThemeData.surfaceElevated : AppThemeData.primaryWhite,
      elevation: 8,
      items: ['ALL', 'HIGH', 'MEDIUM', 'LOW'].map((option) {
        final isSelected = controller.selectedImportance.value == option;
        final color = option == 'ALL'
            ? AppThemeData.grey5
            : option == 'HIGH'
                ? AppThemeData.danger300
                : option == 'MEDIUM'
                    ? AppThemeData.pending400
                    : AppThemeData.success400;
        return PopupMenuItem<String>(
          value: option,
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              spaceW(width: 10),
              Expanded(
                child: Text(
                  option == 'ALL' ? 'All Priorities' : option,
                  style: TextStyle(
                    fontFamily: isSelected ? FontFamily.semiBold : FontFamily.medium,
                    fontSize: 13,
                    color: isSelected
                        ? AppThemeData.primary50
                        : (isDark ? AppThemeData.grey1 : AppThemeData.grey10),
                  ),
                ),
              ),
              if (isSelected)
                Icon(Icons.check_rounded, size: 16, color: AppThemeData.primary50),
            ],
          ),
        );
      }).toList(),
    ).then((value) {
      if (value != null) controller.filterByImportance(value);
    });
  }

  Widget _buildSortDropdown(bool isDark, {required BuildContext context}) {
    return Obx(() => GestureDetector(
      onTap: () => _showSortMenu(isDark, context: context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.surfaceDeep : AppThemeData.grey1,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark
                ? AppThemeData.surfaceBorder.withValues(alpha: 0.3)
                : AppThemeData.grey3,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sort: ${controller.selectedSortOption.value}',
              style: TextStyle(
                fontFamily: FontFamily.medium,
                fontSize: 12,
                color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
              ),
            ),
            spaceW(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 14,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            ),
          ],
        ),
      ),
    ));
  }

  void _showSortMenu(bool isDark, {required BuildContext context}) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx + renderBox.size.width - 240,
        offset.dy + 300,
        offset.dx + renderBox.size.width,
        offset.dy + 420,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? AppThemeData.surfaceElevated : AppThemeData.primaryWhite,
      elevation: 8,
      items: controller.sortOptions.map((option) {
        final isSelected = controller.selectedSortOption.value == option;
        return PopupMenuItem<String>(
          value: option,
          child: Row(
            children: [
              if (isSelected)
                Icon(Icons.check_rounded, size: 16, color: AppThemeData.primary50)
              else
                spaceW(width: 16),
              spaceW(width: 8),
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    fontFamily: isSelected ? FontFamily.semiBold : FontFamily.medium,
                    fontSize: 13,
                    color: isSelected
                        ? AppThemeData.primary50
                        : (isDark ? AppThemeData.grey1 : AppThemeData.grey10),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    ).then((value) {
      if (value != null) controller.sortBy(value);
    });
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
          color: isSelected ? AppThemeData.primary50 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isSelected
              ? AppThemeData.primaryWhite
              : (isDark ? AppThemeData.grey5 : AppThemeData.grey6),
        ),
      ),
    );
  }

  Widget _buildRemindersContent(bool isDark, BuildContext context) {
    return Obx(() {
      if (controller.filteredReminders.isEmpty) return _buildEmptyState(isDark);
      return controller.isGridView.value
          ? _buildGridView(isDark)
          : _buildListView(isDark);
    });
  }

  Widget _buildGridView(bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 380,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: controller.filteredReminders.length,
      itemBuilder: (context, index) =>
          _buildGridCard(controller.filteredReminders[index], isDark),
    );
  }

  Widget _buildListView(bool isDark) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.filteredReminders.length,
      separatorBuilder: (context, index) => spaceH(height: 10),
      itemBuilder: (context, index) =>
          _buildListCard(controller.filteredReminders[index], isDark),
    );
  }

  BoxDecoration _cardDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? AppThemeData.surfaceDeep : AppThemeData.grey1,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDark
            ? AppThemeData.surfaceBorder.withValues(alpha: 0.15)
            : AppThemeData.grey3.withValues(alpha: 0.5),
      ),
      boxShadow: [
        BoxShadow(
          color: AppThemeData.primaryBlack.withValues(alpha: isDark ? 0.15 : 0.04),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  Widget _buildReminderIcon(ReminderModel reminder, Color color, double size, double radius) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: reminder.iconUrl != null && reminder.iconUrl!.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: NetworkImageWidget(
                imageUrl: reminder.iconUrl!,
                fit: BoxFit.cover,
              ),
            )
          : Icon(reminder.importanceIcon, color: color, size: size * 0.5),
    );
  }

  Widget _buildStatusBadge(ReminderModel reminder) {
    final daysLeft = reminder.daysRemaining;
    final isExpired = reminder.isExpired;

    if (!isExpired && daysLeft > 0) {
      final isUrgent = reminder.isExpiringSoon;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: (isUrgent ? AppThemeData.danger300 : AppThemeData.success400).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '${daysLeft}d left',
          style: TextStyle(
            fontFamily: FontFamily.bold,
            fontSize: 10,
            color: isUrgent ? AppThemeData.danger300 : AppThemeData.success400,
          ),
        ),
      );
    }
    if (isExpired) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppThemeData.danger300.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Expired',
          style: TextStyle(
            fontFamily: FontFamily.bold,
            fontSize: 10,
            color: AppThemeData.danger300,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildActiveToggle(ReminderModel reminder, bool isDark, {bool compact = false}) {
    final isActive = reminder.isActive ?? true;
    return GestureDetector(
      onTap: () => controller.toggleReminder(reminder),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 8, vertical: compact ? 3 : 4),
        decoration: BoxDecoration(
          color: isActive
              ? AppThemeData.success400.withValues(alpha: 0.12)
              : (isDark ? AppThemeData.grey8 : AppThemeData.grey3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          isActive ? (compact ? 'ON' : 'Active') : 'Off',
          style: TextStyle(
            fontFamily: FontFamily.bold,
            fontSize: compact ? 9 : 10,
            color: isActive
                ? AppThemeData.success400
                : (isDark ? AppThemeData.grey5 : AppThemeData.grey6),
          ),
        ),
      ),
    );
  }

  Widget _buildGridCard(ReminderModel reminder, bool isDark) {
    final color = reminder.importanceColor;
    final isExpired = reminder.isExpired;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => controller.goToEdit(reminder),
        child: Container(
          decoration: _cardDecoration(isDark),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: Row(
                  children: [
                    _buildReminderIcon(reminder, color, 40, 12),
                    spaceW(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextCustom(
                            title: reminder.name ?? 'Unknown',
                            fontSize: 14,
                            fontFamily: FontFamily.bold,
                            color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                            maxLine: 1,
                          ),
                          spaceH(height: 2),
                          TextCustom(
                            title: reminder.importanceLabel,
                            fontSize: 10,
                            fontFamily: FontFamily.semiBold,
                            color: color,
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(reminder),
                  ],
                ),
              ),
              spaceH(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextCustom(
                  title: reminder.description ?? 'No description',
                  fontSize: 11,
                  fontFamily: FontFamily.regular,
                  color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                  maxLine: 2,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 12,
                      color: isExpired
                          ? AppThemeData.danger300
                          : (isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                    ),
                    spaceW(width: 4),
                    Expanded(
                      child: TextCustom(
                        title: reminder.formattedExpiryDate != 'N/A'
                            ? 'Due: ${reminder.formattedExpiryDate}'
                            : 'No expiry',
                        fontSize: 11,
                        fontFamily: FontFamily.medium,
                        color: isExpired
                            ? AppThemeData.danger300
                            : (isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                      ),
                    ),
                    _buildActiveToggle(reminder, isDark),
                    spaceW(width: 6),
                    GestureDetector(
                      onTap: () => _showReminderActions(reminder, isDark),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: isDark ? AppThemeData.surfaceMid : AppThemeData.grey2,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.more_vert_rounded,
                          size: 14,
                          color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
                        ),
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

  Widget _buildListCard(ReminderModel reminder, bool isDark) {
    final color = reminder.importanceColor;
    final daysLeft = reminder.daysRemaining;
    final isExpired = reminder.isExpired;

    double progress = 0;
    if (!isExpired && daysLeft > 0) {
      progress = (daysLeft / 30).clamp(0.0, 1.0);
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => controller.goToEdit(reminder),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: _cardDecoration(isDark),
          child: Row(
            children: [
              _buildReminderIcon(reminder, color, 48, 14),
              spaceW(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextCustom(
                            title: reminder.name ?? 'Unknown',
                            fontSize: 15,
                            fontFamily: FontFamily.bold,
                            color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            reminder.importanceLabel,
                            style: TextStyle(
                              fontFamily: FontFamily.bold,
                              fontSize: 9,
                              color: color,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    spaceH(height: 4),
                    TextCustom(
                      title: reminder.description ?? 'No description',
                      fontSize: 12,
                      fontFamily: FontFamily.regular,
                      color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                      maxLine: 1,
                    ),
                    spaceH(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 12,
                          color: isExpired
                              ? AppThemeData.danger300
                              : (isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                        ),
                        spaceW(width: 4),
                        TextCustom(
                          title: reminder.formattedExpiryDate != 'N/A'
                              ? 'Due: ${reminder.formattedExpiryDate}'
                              : 'No expiry',
                          fontSize: 11,
                          fontFamily: FontFamily.medium,
                          color: isExpired
                              ? AppThemeData.danger300
                              : (isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                        ),
                        if (!isExpired && daysLeft > 0) ...[
                          spaceW(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: (reminder.isExpiringSoon
                                      ? AppThemeData.danger300
                                      : AppThemeData.success400)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${daysLeft}d left',
                              style: TextStyle(
                                fontFamily: FontFamily.bold,
                                fontSize: 9,
                                color: reminder.isExpiringSoon
                                    ? AppThemeData.danger300
                                    : AppThemeData.success400,
                              ),
                            ),
                          ),
                        ] else if (isExpired) ...[
                          spaceW(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppThemeData.danger300.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Expired',
                              style: TextStyle(
                                fontFamily: FontFamily.bold,
                                fontSize: 9,
                                color: AppThemeData.danger300,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (!isExpired && daysLeft > 0) ...[
                      spaceH(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 3,
                          backgroundColor: (isDark ? AppThemeData.grey8 : AppThemeData.grey3).withValues(alpha: 0.5),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            reminder.isExpiringSoon ? AppThemeData.danger300 : color,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              spaceW(width: 12),
              Column(
                children: [
                  _buildActiveToggle(reminder, isDark, compact: true),
                  spaceH(height: 8),
                  GestureDetector(
                    onTap: () => _showReminderActions(reminder, isDark),
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: (isDark ? AppThemeData.grey5 : AppThemeData.grey6).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.more_vert_rounded,
                        size: 16,
                        color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
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

  void _showReminderActions(ReminderModel reminder, bool isDark) {
    Get.bottomSheet(
      Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.surfaceElevated : AppThemeData.primaryWhite,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit_outlined, color: AppThemeData.primary50, size: 20),
              title: TextCustom(
                title: 'Edit Reminder',
                fontSize: 14,
                fontFamily: FontFamily.medium,
                color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              ),
              onTap: () {
                Get.back();
                controller.goToEdit(reminder);
              },
            ),
            ListTile(
              leading: Icon(
                (reminder.isActive ?? true) ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: (reminder.isActive ?? true) ? AppThemeData.pending400 : AppThemeData.success400,
                size: 20,
              ),
              title: TextCustom(
                title: (reminder.isActive ?? true) ? 'Pause Reminder' : 'Resume Reminder',
                fontSize: 14,
                fontFamily: FontFamily.medium,
                color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              ),
              onTap: () {
                Get.back();
                controller.toggleReminder(reminder);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: AppThemeData.danger300, size: 20),
              title: TextCustom(
                title: 'Delete Reminder',
                fontSize: 14,
                fontFamily: FontFamily.medium,
                color: AppThemeData.danger300,
              ),
              onTap: () {
                Get.back();
                controller.deleteReminder(reminder);
              },
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppThemeData.neonOrange.withValues(alpha: 0.15),
                    AppThemeData.neonPink.withValues(alpha: 0.08),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.alarm_off_outlined,
                size: 50,
                color: AppThemeData.neonOrange.withValues(alpha: 0.5),
              ),
            ),
            spaceH(height: 20),
            TextCustom(
              title: 'No reminders yet',
              fontSize: 18,
              fontFamily: FontFamily.bold,
              color: isDark ? AppThemeData.grey3 : AppThemeData.grey8,
            ),
            spaceH(height: 8),
            TextCustom(
              title: 'Create your first reminder to stay organized',
              fontSize: 14,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            ),
            spaceH(height: 24),
            GestureDetector(
              onTap: controller.goToAdd,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppThemeData.neonOrange, AppThemeData.neonPink],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppThemeData.neonOrange.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, color: AppThemeData.primaryWhite, size: 18),
                    spaceW(width: 6),
                    TextCustom(
                      title: 'Add Reminder',
                      fontSize: 14,
                      fontFamily: FontFamily.semiBold,
                      color: AppThemeData.primaryWhite,
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
}
