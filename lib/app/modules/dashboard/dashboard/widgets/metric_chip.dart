// lib/app/modules/dashboard/widgets/metric_chip.dart
import 'package:flutter/material.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';

class MetricChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color accentColor;
  final bool isDark;

  const MetricChip({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.accentColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? AppThemeData.surfaceDeep
            : AppThemeData.grey1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? AppThemeData.surfaceBorder.withOpacity(0.4)
              : AppThemeData.grey3,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 14, color: accentColor),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontFamily: FontFamily.bold,
                  fontSize: 14,
                  color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                  height: 1.2,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontFamily: FontFamily.regular,
                  fontSize: 10,
                  color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
