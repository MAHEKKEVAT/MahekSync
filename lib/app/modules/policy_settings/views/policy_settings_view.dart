import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/constant/round_shape_button.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/mahek_loader.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import '../controllers/policy_settings_controller.dart';

class PolicySettingsView extends GetView<PolicySettingsController> {
  const PolicySettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<PolicySettingsController>()) {
      Get.put(PolicySettingsController());
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppThemeData.grey10 : AppThemeData.grey2,
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: MahekLoader(
              message: 'Loading Policies...',
              size: 44,
              textSize: 13,
              style: MahekLoaderStyle.ring,
            ),
          );
        }
        return _buildContent(isDark);
      }),
    );
  }

  Widget _buildContent(bool isDark) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
            border: Border(
              bottom: BorderSide(
                color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppThemeData.primary50,
                          AppThemeData.primary4,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppThemeData.primary50.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.gavel_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  spaceW(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextCustom(
                        title: 'Policy Settings',
                        fontSize: 24,
                        fontFamily: FontFamily.bold,
                        color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                      ),
                      spaceH(height: 2),
                      TextCustom(
                        title: 'Manage Terms, Privacy Policy & About info',
                        fontSize: 13,
                        fontFamily: FontFamily.regular,
                        color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                      ),
                    ],
                  ),
                ],
              ),
              // Save Button
              Obx(() => RoundShapeButton(
                title: controller.isSaving.value ? 'Saving...' : 'Save All',
                buttonColor: AppThemeData.primary50,
                buttonTextColor: Colors.white,
                onTap: controller.isSaving.value ? () {} : controller.savePolicies,
                borderRadius: 14,
                height: 48,
                titleWidget: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (controller.isSaving.value)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    else
                      const Icon(Icons.save_rounded, size: 20, color: Colors.white),
                    const SizedBox(width: 8),
                    TextCustom(
                      title: controller.isSaving.value ? 'Saving...' : 'Save All',
                      fontSize: 14,
                      fontFamily: FontFamily.semiBold,
                      color: Colors.white,
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),

        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildPolicyCard(
                  index: 0,
                  title: 'Terms & Conditions',
                  subtitle: 'Terms of service for using MahekSync',
                  icon: Icons.description_rounded,
                  color: AppThemeData.neonBlue,
                  textController: controller.termsController,
                  isDark: isDark,
                ),
                spaceH(height: 20),
                _buildPolicyCard(
                  index: 1,
                  title: 'Privacy Policy',
                  subtitle: 'How we collect, use, and protect your data',
                  icon: Icons.privacy_tip_rounded,
                  color: AppThemeData.neonTeal,
                  textController: controller.privacyController,
                  isDark: isDark,
                ),
                spaceH(height: 20),
                _buildPolicyCard(
                  index: 2,
                  title: 'About App',
                  subtitle: 'Application description and features',
                  icon: Icons.info_outline_rounded,
                  color: AppThemeData.neonPurple,
                  textController: controller.aboutController,
                  isDark: isDark,
                ),
                spaceH(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPolicyCard({
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required TextEditingController textController,
    required bool isDark,
  }) {
    return Obx(() {
      final expanded = controller.isExpanded[index];
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: expanded
                ? color.withValues(alpha: 0.3)
                : (isDark ? AppThemeData.grey8 : AppThemeData.grey3),
            width: expanded ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          children: [
            // Header
            GestureDetector(
              onTap: () => controller.toggleSection(index),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: color, size: 22),
                    ),
                    spaceW(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextCustom(
                            title: title,
                            fontSize: 16,
                            fontFamily: FontFamily.bold,
                            color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                          ),
                          spaceH(height: 2),
                          TextCustom(
                            title: subtitle,
                            fontSize: 12,
                            fontFamily: FontFamily.regular,
                            color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
                      width: 0.5,
                    ),
                  ),
                  child: TextField(
                    controller: textController,
                    maxLines: null,
                    minLines: 12,
                    style: TextStyle(
                      fontFamily: FontFamily.regular,
                      fontSize: 13,
                      color: isDark ? AppThemeData.grey2 : AppThemeData.grey9,
                      height: 1.7,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter $title here...',
                      hintStyle: TextStyle(
                        fontFamily: FontFamily.regular,
                        fontSize: 13,
                        color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: color.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ),
              crossFadeState: expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      );
    });
  }
}
