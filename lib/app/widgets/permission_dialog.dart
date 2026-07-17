// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../utils/app_colors.dart';
import '../utils/dark_theme_provider.dart';
import '../utils/font_family.dart';
import 'package:maheksync/app/constant/round_shape_button.dart';
import 'global_widgets.dart';
import 'text_widget.dart';

class PermissionDialog extends StatelessWidget {
  const PermissionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      insetPadding: const EdgeInsets.all(30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: SizedBox(
          width: 500,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Center(
              child: Image.asset(
                "assets/animation/location.gif",
                height: 120.0,
                width: 120.0,
              ),
            ),
            TextCustom(
              title: 'location permission'.tr,
              fontSize: 18,
              fontFamily: FontFamily.bold,
            ),
            spaceH(height: 5),
            TextCustom(
              title: 'Please allow location permission from your app settings and receive more accurate delivery.'.tr,
              fontSize: 14,
              maxLine: 3,
              fontFamily: FontFamily.regular,
            ),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                child: RoundShapeButton(
                  title: 'Cancel'.tr,
                  buttonColor: themeChange.isDarkTheme() ? AppThemeData.grey10 : AppThemeData.grey1,
                  buttonTextColor: themeChange.isDarkTheme() ? AppThemeData.grey1 : AppThemeData.grey10,
                  onTap: () => Navigator.pop(context),
                  borderRadius: 25,
                  height: 50,
                ),
              ),
              spaceW(width: 10),
              Expanded(
                child: RoundShapeButton(
                  title: 'Settings'.tr,
                  buttonColor: AppThemeData.primary50,
                  buttonTextColor: AppThemeData.primaryWhite,
                  onTap: () => Navigator.pop(context),
                  borderRadius: 25,
                  height: 50,
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}
