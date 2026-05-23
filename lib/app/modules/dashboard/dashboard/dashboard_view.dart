import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'package:solar_icons/solar_icons.dart';

import 'dashboard_controller.dart';
import 'dashboard_widgets.dart';

class DashboardHomeView extends GetView<DashboardHomeController> {
  const DashboardHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppThemeData.surfaceVoid,
      child: Stack(
        children: [
          DashboardBackground(glowCtrl: controller.glowCtrl),
          Positioned.fill(
            child: DashboardScrollView(ctrl: controller),
          ),
        ],
      ),
    );
  }
}
