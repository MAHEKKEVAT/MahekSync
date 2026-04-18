import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../utils/app_colors.dart';
import '../utils/font_family.dart';
import '../utils/dark_theme_provider.dart';
import '../widgets/global_widgets.dart';
import 'custom_button.dart';

class LogoutDialog extends StatelessWidget {
  final VoidCallback onLogout;

  const LogoutDialog({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Consumer<DarkThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkTheme();

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
          child: Container(
            padding: const EdgeInsets.all(24),
            width: MediaQuery.of(context).size.width * 0.4,
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Icon(Icons.logout, color: Colors.red, size: 32),
                ),
                spaceH(height: 16),

                Text(
                  'Logout'.tr,
                  style: TextStyle(fontSize: 20, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.primaryWhite : AppThemeData.primaryBlack),
                ),
                spaceH(height: 8),

                Text(
                  'Are you sure you want to logout?'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey3 : AppThemeData.grey8),
                ),
                spaceH(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: CustomButtonWidget(
                        title: 'Cancel'.tr,
                        buttonColor: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
                        textColor: isDark ? AppThemeData.grey3 : AppThemeData.grey8,
                        onPress: () => Get.back(),
                      ),
                    ),
                    spaceW(width: 12),

                    Expanded(
                      child: CustomButtonWidget(
                        title: 'Logout'.tr,
                        buttonColor: Colors.red,
                        textColor: AppThemeData.primaryWhite,
                        onPress: () {
                          Get.back();
                          onLogout();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
