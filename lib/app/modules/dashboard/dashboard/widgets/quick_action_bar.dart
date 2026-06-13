// lib/app/modules/dashboard/widgets/quick_action_bar.dart
// ──────────────────────────────────────────────────────────────
//  Quick Action Bar — Scan Doc REMOVED, improved button UI
// ──────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';

class QuickActionBar extends StatelessWidget {
  final bool isDark;
  final VoidCallback? onAddTask;
  final VoidCallback? onAddReminder;
  final VoidCallback? onAddDevice;
  final VoidCallback? onAddPurchase;
  final VoidCallback? onCreateNote;

  const QuickActionBar({
    super.key,
    required this.isDark,
    this.onAddTask,
    this.onAddReminder,
    this.onAddDevice,
    this.onAddPurchase,
    this.onCreateNote,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
        title: 'Add Task',
        icon: Icons.add_task_rounded,
        gradient: LinearGradient(
          colors: [AppThemeData.neonPurple, AppThemeData.neonBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        accentColor: AppThemeData.neonPurple,
        onTap: onAddTask,
      ),
      _QuickAction(
        title: 'Reminder',
        icon: Icons.alarm_add_rounded,
        gradient: LinearGradient(
          colors: [AppThemeData.neonOrange, const Color(0xFFFF6B35)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        accentColor: AppThemeData.neonOrange,
        onTap: onAddReminder,
      ),
      _QuickAction(
        title: 'Add Device',
        icon: Icons.add_circle_rounded,
        gradient: LinearGradient(
          colors: [AppThemeData.neonTeal, AppThemeData.neonBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        accentColor: AppThemeData.neonTeal,
        onTap: onAddDevice,
      ),
      _QuickAction(
        title: 'Add Purchase',
        icon: Icons.add_shopping_cart_rounded,
        gradient: LinearGradient(
          colors: [AppThemeData.neonMint, AppThemeData.neonCyan],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        accentColor: AppThemeData.neonMint,
        onTap: onAddPurchase,
      ),
      _QuickAction(
        title: 'Create Note',
        icon: Icons.note_add_rounded,
        gradient: LinearGradient(
          colors: [AppThemeData.geminiIndigo, AppThemeData.geminiPink],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        accentColor: AppThemeData.neonLavender,
        onTap: onCreateNote,
      ),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.start,
      children: actions
          .map((action) =>
              _QuickActionButton(action: action, isDark: isDark))
          .toList(),
    );
  }
}

// ─── Quick Action Model ───────────────────────────────────────
class _QuickAction {
  final String title;
  final IconData icon;
  final Gradient gradient;
  final Color accentColor;
  final VoidCallback? onTap;

  const _QuickAction({
    required this.title,
    required this.icon,
    required this.gradient,
    required this.accentColor,
    this.onTap,
  });
}

// ─── Quick Action Button (improved UI) ──────────────────────
class _QuickActionButton extends StatefulWidget {
  final _QuickAction action;
  final bool isDark;

  const _QuickActionButton({
    required this.action,
    required this.isDark,
  });

  @override
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.action.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            gradient: _isHovered
                ? LinearGradient(
                    colors: [
                      widget.action.accentColor.withOpacity(0.2),
                      widget.action.accentColor.withOpacity(0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: _isHovered
                ? null
                : (widget.isDark
                    ? AppThemeData.surfaceElevated
                    : AppThemeData.grey2),
            borderRadius: BorderRadius.circular(14),
            border: _isHovered
                ? Border.all(
                    color: widget.action.accentColor.withOpacity(0.35))
                : Border.all(
                    color: widget.isDark
                        ? AppThemeData.surfaceBorder.withOpacity(0.3)
                        : AppThemeData.grey4.withOpacity(0.3),
                  ),
            boxShadow: _isHovered
                ? AppThemeData.neonGlow(widget.action.accentColor,
                    blur: 14, opacity: 0.12)
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.action.icon,
                size: 16,
                color: _isHovered
                    ? Colors.white
                    : widget.action.accentColor,
              ),
              const SizedBox(width: 7),
              Text(
                widget.action.title,
                style: TextStyle(
                  fontFamily: FontFamily.medium,
                  fontSize: 12,
                  color: _isHovered
                      ? widget.action.accentColor
                      : (widget.isDark
                          ? AppThemeData.grey3
                          : AppThemeData.grey8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
