import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'package:maheksync/app/models/personal_task_model.dart';

class PersonalTaskCard extends StatelessWidget {
  final PersonalTaskModel task;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onPin;
  final VoidCallback onDelete;

  const PersonalTaskCard({
    super.key,
    required this.task,
    required this.isDark,
    required this.onTap,
    required this.onToggle,
    required this.onEdit,
    required this.onPin,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final priorityColor = task.priorityColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: task.isCompleted == true
            ? (isDark ? AppThemeData.grey9 : AppThemeData.grey1)
                .withValues(alpha: 0.6)
            : (isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: task.isPinned == true
              ? AppThemeData.primary50.withValues(alpha: 0.4)
              : (isDark ? AppThemeData.grey8 : AppThemeData.grey3)
                  .withValues(alpha: 0.5),
          width: task.isPinned == true ? 1.5 : 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 5,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: priorityColor),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopRow(),
                      if (task.description != null &&
                          task.description!.isNotEmpty) ...[
                        spaceH(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 36),
                          child: TextCustom(
                            title: task.description ?? '',
                            fontSize: 13,
                            fontFamily: FontFamily.regular,
                            color: isDark
                                ? AppThemeData.grey5
                                : AppThemeData.grey6,
                            maxLine: 2,
                          ),
                        ),
                      ],
                      spaceH(height: 12),
                      Padding(
                        padding: const EdgeInsets.only(left: 36),
                        child: _buildBadgeRow(),
                      ),
                      if (task.tags != null && task.tags!.isNotEmpty) ...[
                        spaceH(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 36),
                          child: Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: task.tags!
                                .take(3)
                                .map(
                                  (tag) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppThemeData.primary50
                                          .withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: TextCustom(
                                      title: '#$tag',
                                      fontSize: 10,
                                      fontFamily: FontFamily.medium,
                                      color: AppThemeData.primary50,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopRow() {
    return Row(
      children: [
        GestureDetector(
          onTap: onToggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: task.isCompleted == true
                  ? AppThemeData.success400
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: task.isCompleted == true
                  ? null
                  : Border.all(
                      color: isDark
                          ? AppThemeData.grey6
                          : AppThemeData.grey5,
                      width: 1.5,
                    ),
            ),
            child: task.isCompleted == true
                ? const Icon(
                    SolarIconsBold.checkCircle,
                    color: Colors.white,
                    size: 16,
                  )
                : null,
          ),
        ),
        spaceW(width: 12),
        if (task.iconUrl != null && task.iconUrl!.isNotEmpty) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              task.iconUrl!,
              width: 52,
              height: 52,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppThemeData.primary50.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(SolarIconsOutline.gallery,
                    size: 16, color: AppThemeData.primary50),
              ),
            ),
          ),
          spaceW(width: 8),
        ],
        Expanded(
          child: TextCustom(
            title: task.title ?? '',
            fontSize: 16,
            fontFamily: FontFamily.semiBold,
            color: task.isCompleted == true
                ? (isDark ? AppThemeData.grey6 : AppThemeData.grey5)
                : (isDark ? AppThemeData.grey1 : AppThemeData.grey10),
            maxLine: 1,
          ),
        ),
        if (task.isPinned == true)
          Icon(
            SolarIconsBold.pin,
            size: 16,
            color: AppThemeData.primary50,
          ),
        spaceW(width: 8),
        _buildMenuButton(),
      ],
    );
  }

  Widget _buildMenuButton() {
    return GestureDetector(
      onTap: () => _showMenu(),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: (isDark ? AppThemeData.grey9 : AppThemeData.grey1)
              .withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          SolarIconsOutline.menuDots,
          size: 16,
          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
        ),
      ),
    );
  }

  Widget _buildBadgeRow() {
    return Row(
      children: [
        _buildBadge(task.priorityLabel, task.priorityColor),
        spaceW(width: 6),
        _buildBadge(task.statusLabel, task.statusColor),
        const Spacer(),
        if (task.isOverdue)
          _buildBadge('Overdue', AppThemeData.danger300)
        else if (task.isDueSoon)
          _buildBadge('${task.daysUntilDue}d left', AppThemeData.pending400)
        else if (task.dueDate != null)
          Row(
            children: [
              Icon(
                SolarIconsOutline.calendar,
                size: 14,
                color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
              ),
              spaceW(width: 4),
              TextCustom(
                title: task.formattedDueDate,
                fontSize: 11,
                fontFamily: FontFamily.medium,
                color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: TextCustom(
        title: label,
        fontSize: 10,
        fontFamily: FontFamily.bold,
        color: color,
      ),
    );
  }

  void _showMenu() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.grey10 : AppThemeData.primaryWhite,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            spaceH(height: 16),
            TextCustom(
              title: task.title ?? '',
              fontSize: 16,
              fontFamily: FontFamily.bold,
              color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              maxLine: 1,
            ),
            spaceH(height: 16),
            _buildMenuItem(
              SolarIconsOutline.penNewRound,
              'Edit',
              () {
                Get.back();
                onEdit();
              },
            ),
            _buildMenuItem(
              task.isCompleted == true
                  ? SolarIconsOutline.undoLeftRound
                  : SolarIconsBold.checkCircle,
              task.isCompleted == true ? 'Reopen' : 'Mark Complete',
              () {
                Get.back();
                onToggle();
              },
              color: AppThemeData.success400,
            ),
            _buildMenuItem(
              task.isPinned == true
                  ? SolarIconsOutline.pin
                  : SolarIconsBold.pin,
              task.isPinned == true ? 'Unpin' : 'Pin',
              () {
                Get.back();
                onPin();
              },
              color: AppThemeData.primary50,
            ),
            _buildMenuItem(
              SolarIconsOutline.trashBin2,
              'Delete',
              () {
                Get.back();
                onDelete();
              },
              color: AppThemeData.danger300,
            ),
            spaceH(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? color,
  }) {
    final itemColor =
        color ?? (isDark ? AppThemeData.grey3 : AppThemeData.grey7);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: (isDark ? AppThemeData.grey9 : AppThemeData.grey1)
              .withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: itemColor),
            spaceW(width: 12),
            TextCustom(
              title: title,
              fontSize: 14,
              fontFamily: FontFamily.medium,
              color: itemColor,
            ),
          ],
        ),
      ),
    );
  }
}
