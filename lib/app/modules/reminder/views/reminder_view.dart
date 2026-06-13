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
            color: Colors.white,
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
                Icon(Icons.add_rounded, color: Colors.white, size: 18),
                if (!isMobile) ...[
                  spaceW(width: 6),
                  TextCustom(
                    title: 'Add Reminder',
                    fontSize: 13,
                    fontFamily: FontFamily.semiBold,
                    color: Colors.white,
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
        _StatData(
          icon: Icons.alarm_on_rounded,
          label: 'Active',
          value: '${controller.activeCount}',
          color: AppThemeData.success400,
        ),
        _StatData(
          icon: Icons.priority_high_rounded,
          label: 'High Priority',
          value: '${controller.highCount}',
          color: AppThemeData.danger300,
        ),
        _StatData(
          icon: Icons.event_busy_rounded,
          label: 'Expired',
          value: '${controller.expiredCount}',
          color: AppThemeData.grey5,
        ),
        _StatData(
          icon: Icons.list_rounded,
          label: 'Total',
          value: '${controller.reminders.length}',
          color: AppThemeData.neonTeal,
        ),
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

  Widget _buildStatCard(_StatData stat, bool isDark) {
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextCustom(
          title: 'All Reminders',
          fontSize: isMobile ? 18 : 22,
          fontFamily: FontFamily.bold,
          color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
        ),
        Row(
          children: [
            _buildImportanceFilter(isDark),
            spaceW(width: 10),
            _buildSortDropdown(isDark),
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
        ),
      ],
    );
  }

  Widget _buildImportanceFilter(bool isDark) {
    return Obx(() {
      final isFiltered = controller.selectedImportance.value != 'ALL';
      return GestureDetector(
        onTap: () => _showImportanceMenu(isDark),
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

  void _showImportanceMenu(bool isDark) {
    final RenderBox renderBox = Get.context!.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    showMenu<String>(
      context: Get.context!,
      position: RelativeRect.fromLTRB(
        offset.dx + renderBox.size.width - 200,
        offset.dy + 300,
        offset.dx + renderBox.size.width,
        offset.dy + 400,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? AppThemeData.surfaceElevated : Colors.white,
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

  Widget _buildSortDropdown(bool isDark) {
    return Obx(() => GestureDetector(
      onTap: () => _showSortMenu(isDark),
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

  void _showSortMenu(bool isDark) {
    final RenderBox renderBox = Get.context!.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    showMenu<String>(
      context: Get.context!,
      position: RelativeRect.fromLTRB(
        offset.dx + renderBox.size.width - 240,
        offset.dy + 300,
        offset.dx + renderBox.size.width,
        offset.dy + 420,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? AppThemeData.surfaceElevated : Colors.white,
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
              ? Colors.white
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
        childAspectRatio: 1.6,
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

  Widget _buildGridCard(ReminderModel reminder, bool isDark) {
    final color = reminder.importanceColor;
    final daysLeft = reminder.daysRemaining;
    final isExpired = reminder.isExpired;
    final isActive = reminder.isActive ?? true;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => controller.goToEdit(reminder),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.surfaceDeep : AppThemeData.grey1,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? AppThemeData.surfaceBorder.withValues(alpha: 0.15)
                  : AppThemeData.grey3.withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top section: icon + name + days badge
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: Row(
                  children: [
                    // Icon with importance glow
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: color.withValues(alpha: 0.2),
                        ),
                      ),
                      child: reminder.iconUrl != null && reminder.iconUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: NetworkImageWidget(
                                imageUrl: reminder.iconUrl!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(reminder.importanceIcon, color: color, size: 20),
                    ),
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
                    // Days remaining badge
                    if (!isExpired && daysLeft > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: reminder.isExpiringSoon
                              ? AppThemeData.danger300.withValues(alpha: 0.12)
                              : AppThemeData.success400.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${daysLeft}d left',
                          style: TextStyle(
                            fontFamily: FontFamily.bold,
                            fontSize: 10,
                            color: reminder.isExpiringSoon
                                ? AppThemeData.danger300
                                : AppThemeData.success400,
                          ),
                        ),
                      )
                    else if (isExpired)
                      Container(
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
                      ),
                  ],
                ),
              ),

              spaceH(height: 8),

              // Description
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

              // Bottom: due date + toggle + actions
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
                    // Active toggle
                    GestureDetector(
                      onTap: () => controller.toggleReminder(reminder),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppThemeData.success400.withValues(alpha: 0.12)
                              : (isDark ? AppThemeData.grey8 : AppThemeData.grey3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isActive ? 'Active' : 'Off',
                          style: TextStyle(
                            fontFamily: FontFamily.bold,
                            fontSize: 10,
                            color: isActive
                                ? AppThemeData.success400
                                : (isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                          ),
                        ),
                      ),
                    ),
                    spaceW(width: 6),
                    // More actions
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
    final isActive = reminder.isActive ?? true;

    // Calculate progress for remaining time
    double progress = 0;
    if (!isExpired && daysLeft > 0) {
      progress = (daysLeft / 30).clamp(0.0, 1.0);
    } else if (isExpired) {
      progress = 0;
    } else {
      progress = 1;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => controller.goToEdit(reminder),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.surfaceDeep : AppThemeData.grey1,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? AppThemeData.surfaceBorder.withValues(alpha: 0.15)
                  : AppThemeData.grey3.withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withValues(alpha: 0.2)),
                ),
                child: reminder.iconUrl != null && reminder.iconUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: NetworkImageWidget(
                          imageUrl: reminder.iconUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(reminder.importanceIcon, color: color, size: 22),
              ),
              spaceW(width: 14),

              // Info
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
                        // Importance chip
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
                              color: reminder.isExpiringSoon
                                  ? AppThemeData.danger300.withValues(alpha: 0.12)
                                  : AppThemeData.success400.withValues(alpha: 0.12),
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
                    // Progress bar for time remaining
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

              // Actions column
              Column(
                children: [
                  // Active toggle
                  GestureDetector(
                    onTap: () => controller.toggleReminder(reminder),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppThemeData.success400.withValues(alpha: 0.12)
                            : (isDark ? AppThemeData.grey8 : AppThemeData.grey3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isActive ? 'ON' : 'OFF',
                        style: TextStyle(
                          fontFamily: FontFamily.bold,
                          fontSize: 9,
                          color: isActive
                              ? AppThemeData.success400
                              : (isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                        ),
                      ),
                    ),
                  ),
                  spaceH(height: 8),
                  _buildActionBtn(
                    Icons.more_vert_rounded,
                    isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                    () => _showReminderActions(reminder, isDark),
                    isDark,
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
          color: isDark ? AppThemeData.surfaceElevated : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit_outlined, color: AppThemeData.primary50, size: 20),
              title: Text(
                'Edit Reminder',
                style: TextStyle(
                  fontFamily: FontFamily.medium,
                  fontSize: 14,
                  color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                ),
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
              title: Text(
                (reminder.isActive ?? true) ? 'Pause Reminder' : 'Resume Reminder',
                style: TextStyle(
                  fontFamily: FontFamily.medium,
                  fontSize: 14,
                  color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                ),
              ),
              onTap: () {
                Get.back();
                controller.toggleReminder(reminder);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppThemeData.danger300, size: 20),
              title: Text(
                'Delete Reminder',
                style: TextStyle(
                  fontFamily: FontFamily.medium,
                  fontSize: 14,
                  color: AppThemeData.danger300,
                ),
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

  Widget _buildActionBtn(
    IconData icon,
    Color color,
    VoidCallback onTap,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 16),
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
                    Icon(Icons.add_rounded, color: Colors.white, size: 18),
                    spaceW(width: 6),
                    TextCustom(
                      title: 'Add Reminder',
                      fontSize: 14,
                      fontFamily: FontFamily.semiBold,
                      color: Colors.white,
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

class _StatData {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatData({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}
