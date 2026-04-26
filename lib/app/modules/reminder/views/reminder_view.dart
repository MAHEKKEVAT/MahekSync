// lib/app/modules/reminder/views/reminder_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
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
          return Center(child: MahekLoader(message: 'Loading Reminders...', size: 50, textSize: 16));
        }
        return _buildContent(isDark);
      }),
    );
  }

  Widget _buildContent(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isDark),
          spaceH(height: 16),
          _buildStatsRow(isDark),
          spaceH(height: 16),
          _buildSearchAndFilters(isDark),
          spaceH(height: 16),
          Expanded(child: _buildRemindersContent(isDark)),
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
              width: 48, height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppThemeData.primary50, AppThemeData.primary4]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: AppThemeData.primary50.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: const Icon(Icons.alarm_rounded, color: Colors.white, size: 26),
            ),
            spaceW(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(title: 'Reminders', fontSize: 24, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
                TextCustom(title: 'Stay on top of your tasks', fontSize: 13, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
              ],
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: controller.goToAdd,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const TextCustom(title: 'Add Reminder', fontSize: 13, fontFamily: FontFamily.semiBold, color: Colors.white),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppThemeData.primary50,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(bool isDark) {
    return Obx(() => Row(
      children: [
        _buildStatChip('Active', '${controller.activeCount}', AppThemeData.success400, isDark),
        spaceW(width: 10),
        _buildStatChip('High Priority', '${controller.highCount}', AppThemeData.danger300, isDark),
        spaceW(width: 10),
        _buildStatChip('Expired', '${controller.expiredCount}', AppThemeData.grey5, isDark),
      ],
    ));
  }

  Widget _buildStatChip(String label, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextCustom(title: value, fontSize: 16, fontFamily: FontFamily.bold, color: color),
          spaceW(width: 6),
          TextCustom(title: label, fontSize: 11, fontFamily: FontFamily.medium, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.02), blurRadius: 8, offset: const Offset(0, 2))],
              border: Border.all(color: isDark ? AppThemeData.grey8 : AppThemeData.grey3, width: 0.5),
            ),
            child: TextField(
              onChanged: controller.updateSearchQuery,
              style: TextStyle(fontFamily: FontFamily.medium, fontSize: 14, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
              decoration: InputDecoration(
                hintText: 'Search reminders...',
                hintStyle: TextStyle(fontFamily: FontFamily.regular, fontSize: 14, color: isDark ? AppThemeData.grey6 : AppThemeData.grey5),
                prefixIcon: Container(margin: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppThemeData.primary50.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.search_rounded, color: AppThemeData.primary50, size: 20)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ),
        spaceW(width: 10),
        _buildViewToggle(Icons.grid_view_rounded, controller.isGridView.value, () => controller.isGridView.value = true, isDark),
        _buildViewToggle(Icons.list_rounded, !controller.isGridView.value, () => controller.isGridView.value = false, isDark),
      ],
    );
  }

  Widget _buildViewToggle(IconData icon, bool isSelected, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: isSelected ? LinearGradient(colors: [AppThemeData.primary50, AppThemeData.primary4]) : null,
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? null : (isDark ? AppThemeData.grey9 : AppThemeData.grey1),
        ),
        child: Icon(icon, size: 20, color: isSelected ? Colors.white : (isDark ? AppThemeData.grey5 : AppThemeData.grey6)),
      ),
    );
  }

  Widget _buildRemindersContent(bool isDark) {
    return Obx(() {
      if (controller.filteredReminders.isEmpty) return _buildEmptyState(isDark);
      return controller.isGridView.value ? _buildGridView(isDark) : _buildListView(isDark);
    });
  }

  Widget _buildGridView(bool isDark) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 340,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.8,
      ),
      itemCount: controller.filteredReminders.length,
      itemBuilder: (context, index) => _buildGridCard(controller.filteredReminders[index], isDark),
    );
  }

  Widget _buildListView(bool isDark) {
    return ListView.separated(
      itemCount: controller.filteredReminders.length,
      separatorBuilder: (_, __) => spaceH(height: 10),
      itemBuilder: (context, index) => _buildListCard(controller.filteredReminders[index], isDark),
    );
  }

  Widget _buildGridCard(ReminderModel reminder, bool isDark) {
    final color = reminder.importanceColor;
    return InkWell(
        onTap: () => controller.goToEdit(reminder),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border(left: BorderSide(color: color, width: 3)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Top: Icon + Name + Toggle ───
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: reminder.iconUrl != null && reminder.iconUrl!.isNotEmpty
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: NetworkImageWidget(imageUrl: reminder.iconUrl!, fit: BoxFit.cover),
                      )
                          : Icon(reminder.importanceIcon, color: color, size: 20),
                    ),
                    spaceW(width: 8),
                    Expanded(
                      child: TextCustom(
                        title: reminder.name ?? 'Unknown',
                        fontSize: 13,
                        fontFamily: FontFamily.bold,
                        color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                        maxLine: 1,
                      ),
                    ),
                    Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: reminder.isActive ?? true,
                        onChanged: (_) => controller.toggleReminder(reminder),
                        activeColor: AppThemeData.success400,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),

              // ─── Middle: Description ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TextCustom(
                  title: reminder.description ?? 'No description',
                  fontSize: 11,
                  fontFamily: FontFamily.regular,
                  color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                  maxLine: 1,
                ),
              ),

              const Spacer(),

              // ─── Bottom: Date + Actions ───
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextCustom(
                      title: reminder.formattedExpiryDate != 'N/A'
                          ? 'Due: ${reminder.formattedExpiryDate}'
                          : 'No expiry',
                      fontSize: 13,
                      fontFamily: FontFamily.medium,
                      color: reminder.isExpiringSoon
                          ? AppThemeData.danger300
                          : (isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                    ),
                    Row(
                      children: [
                        _buildActionBtn(Icons.edit_rounded, isDark ? AppThemeData.grey5 : AppThemeData.grey6, () => controller.goToEdit(reminder), isDark),
                        spaceW(width: 4),
                        _buildActionBtn(Icons.delete_outline, AppThemeData.danger300, () => controller.deleteReminder(reminder), isDark),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
    );
  }

  Widget _buildListCard(ReminderModel reminder, bool isDark) {
    final color = reminder.importanceColor;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: color, width: 3)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: reminder.iconUrl != null && reminder.iconUrl!.isNotEmpty
                ? ClipRRect(borderRadius: BorderRadius.circular(12), child: NetworkImageWidget(imageUrl: reminder.iconUrl!, fit: BoxFit.cover))
                : Icon(reminder.importanceIcon, color: color, size: 22),
          ),
          spaceW(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: TextCustom(title: reminder.name ?? 'Unknown', fontSize: 15, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10)),
                    TextCustom(title: reminder.importanceLabel, fontSize: 11, fontFamily: FontFamily.medium, color: color),
                  ],
                ),
                spaceH(height: 4),
                TextCustom(title: reminder.description ?? 'No description', fontSize: 12, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6, maxLine: 1),
                spaceH(height: 4),
                TextCustom(title: reminder.formattedExpiryDate != 'N/A' ? 'Due: ${reminder.formattedExpiryDate}' : 'No expiry', fontSize: 10, color: reminder.isExpiringSoon ? AppThemeData.danger300 : (isDark ? AppThemeData.grey5 : AppThemeData.grey6)),
              ],
            ),
          ),
          Switch(value: reminder.isActive ?? true, onChanged: (_) => controller.toggleReminder(reminder), activeColor: AppThemeData.success400, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
          Column(
            children: [
              _buildActionBtn(Icons.edit_rounded, isDark ? AppThemeData.grey5 : AppThemeData.grey6, () => controller.goToEdit(reminder), isDark),
              spaceH(height: 4),
              _buildActionBtn(Icons.delete_outline, AppThemeData.danger300, () => controller.deleteReminder(reminder), isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, Color color, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 16)),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.primaryBlack.withValues(alpha: 0.5) : AppThemeData.primaryWhite,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppThemeData.primary50.withValues(alpha: 0.15), AppThemeData.primary4.withValues(alpha: 0.08)]),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(Icons.alarm_off_outlined, size: 50, color: AppThemeData.primary50.withValues(alpha: 0.6)),
            ),
            spaceH(height: 20),
            TextCustom(title: 'No reminders yet', fontSize: 18, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey3 : AppThemeData.grey8),
            spaceH(height: 8),
            TextCustom(title: 'Create your first reminder', fontSize: 14, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
            spaceH(height: 20),
            ElevatedButton.icon(
              onPressed: controller.goToAdd,
              icon: const Icon(Icons.add_rounded),
              label: const TextCustom(title: 'Add Reminder', fontSize: 14, fontFamily: FontFamily.semiBold, color: Colors.white),
              style: ElevatedButton.styleFrom(backgroundColor: AppThemeData.primary50, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            ),
          ],
        ),
      ),
    );
  }
}