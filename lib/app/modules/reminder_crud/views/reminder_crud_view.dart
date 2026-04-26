// lib/app/modules/reminder_crud/views/reminder_crud_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/network_image_widget.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import '../controllers/reminder_crud_controller.dart';

class ReminderCrudView extends GetView<ReminderCrudController> {
  const ReminderCrudView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppThemeData.grey10 : AppThemeData.grey2,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppThemeData.primaryBlack
            : AppThemeData.primaryWhite,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
            size: 20,
          ),
        ),
        title: TextCustom(
          title: controller.isEditMode.value ? 'Edit Reminder' : 'Add Reminder',
          fontSize: 18,
          fontFamily: FontFamily.bold,
          color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
        ),
        actions: [
          TextButton(
            onPressed: controller.saveReminder,
            child: TextCustom(
              title: 'Save',
              fontSize: 14,
              fontFamily: FontFamily.semiBold,
              color: AppThemeData.primary50,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark
                ? AppThemeData.primaryBlack
                : AppThemeData.primaryWhite,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller.nameController,
                'e.g. Pay electricity bill',
                'Reminder Name',
                Icons.alarm_rounded,
                isDark,
              ),
              spaceH(height: 14),
              _buildTextField(
                controller.descriptionController,
                'Brief description...',
                'Description (1 line)',
                Icons.description_outlined,
                isDark,
                maxLines: 1,
              ),
              spaceH(height: 20),
              _buildSectionTitle('Priority', Icons.flag_rounded, isDark),
              spaceH(height: 10),
              _buildImportanceSelector(isDark),
              spaceH(height: 20),
              _buildSectionTitle('Dates', Icons.calendar_month_rounded, isDark),
              spaceH(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildDatePicker(
                      'Created Date',
                      controller.createdDate,
                      isDark,
                    ),
                  ),
                  spaceW(width: 14),
                  Expanded(
                    child: _buildDatePicker(
                      'Expiry Date',
                      controller.expiryDate,
                      isDark,
                    ),
                  ),
                ],
              ),
              spaceH(height: 20),
              _buildSectionTitle('Reminder Icon', Icons.image_rounded, isDark),
              spaceH(height: 10),
              _buildIconUploader(isDark),
              spaceH(height: 20),
              Row(
                children: [
                  TextCustom(
                    title: 'Active',
                    fontSize: 14,
                    fontFamily: FontFamily.medium,
                    color: isDark ? AppThemeData.grey3 : AppThemeData.grey7,
                  ),
                  const Spacer(),
                  Obx(
                    () => Switch(
                      value: controller.isActive.value,
                      onChanged: (v) => controller.isActive.value = v,
                      activeColor: AppThemeData.success400,
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

  Widget _buildSectionTitle(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppThemeData.primary50.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppThemeData.primary50, size: 16),
        ),
        spaceW(width: 10),
        TextCustom(
          title: title,
          fontSize: 14,
          fontFamily: FontFamily.bold,
          color: isDark ? AppThemeData.grey3 : AppThemeData.grey7,
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String hint,
    String label,
    IconData icon,
    bool isDark, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(
          title: label,
          fontSize: 11,
          fontFamily: FontFamily.medium,
          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
        ),
        spaceH(height: 6),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
              width: 0.5,
            ),
          ),
          child: TextField(
            controller: ctrl,
            maxLines: maxLines,
            style: TextStyle(
              fontFamily: FontFamily.medium,
              fontSize: 14,
              color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontFamily: FontFamily.regular,
                fontSize: 14,
                color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppThemeData.primary50.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppThemeData.primary50, size: 18),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: AppThemeData.primary50,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              filled: true,
              fillColor: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImportanceSelector(bool isDark) {
    return Obx(
      () => Row(
        children: controller.importances.map((imp) {
          final isSelected = controller.selectedImportance.value == imp;
          final color = imp == 'HIGH'
              ? AppThemeData.danger300
              : imp == 'MEDIUM'
              ? AppThemeData.pending400
              : AppThemeData.success400;
          return Expanded(
            child: GestureDetector(
              onTap: () => controller.selectedImportance.value = imp,
              child: Container(
                margin: EdgeInsets.only(
                  right: imp != controller.importances.last ? 10 : 0,
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.15)
                      : (isDark ? AppThemeData.grey9 : AppThemeData.grey1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? color
                        : (isDark ? AppThemeData.grey8 : AppThemeData.grey3),
                    width: isSelected ? 1.5 : 0.5,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      imp == 'HIGH'
                          ? Icons.priority_high_rounded
                          : imp == 'MEDIUM'
                          ? Icons.flag_rounded
                          : Icons.low_priority_rounded,
                      color: isSelected
                          ? color
                          : (isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                      size: 22,
                    ),
                    spaceH(height: 4),
                    Text(
                      imp,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: FontFamily.medium,
                        color: isSelected
                            ? color
                            : (isDark
                                  ? AppThemeData.grey5
                                  : AppThemeData.grey6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDatePicker(String label, Rx<DateTime?> date, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(
          title: label,
          fontSize: 11,
          fontFamily: FontFamily.medium,
          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
        ),
        spaceH(height: 6),
        Obx(
          () => GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: Get.context!,
                initialDate: date.value ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2035),
              );
              if (picked != null) date.value = picked;
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    color: AppThemeData.primary50,
                    size: 16,
                  ),
                  spaceW(width: 10),
                  TextCustom(
                    title: date.value != null
                        ? DateFormat('dd/MM/yyyy').format(date.value!)
                        : 'Select date',
                    fontSize: 14,
                    color: date.value != null
                        ? (isDark ? AppThemeData.grey1 : AppThemeData.grey10)
                        : (isDark ? AppThemeData.grey6 : AppThemeData.grey5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconUploader(bool isDark) {
    return Obx(() {
      if (controller.iconBytes.value != null) {
        return _buildIconPreview(isDark, bytes: controller.iconBytes.value);
      } else if (controller.editingReminder.value?.iconUrl != null &&
          controller.editingReminder.value!.iconUrl!.isNotEmpty) {
        return _buildIconPreview(
          isDark,
          networkUrl: controller.editingReminder.value!.iconUrl,
        );
      } else {
        return _buildUploadButton('Upload Icon', controller.pickIcon, isDark);
      }
    });
  }

// ✅ Change Uint8List? to dynamic
  Widget _buildIconPreview(
      bool isDark, {
        dynamic bytes, // Changed from Uint8List? to dynamic
        String? networkUrl,
      }) {
    return Container(
      height: 100,
      width: 100,
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppThemeData.primary50.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: bytes != null
                  ? Image.memory(
                bytes, // dynamic type works fine
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              )
                  : networkUrl != null
                  ? NetworkImageWidget(
                imageUrl: networkUrl,
                fit: BoxFit.cover,
                height: 80,
                width: 80,
              )
                  : Icon(
                Icons.alarm_rounded,
                color: AppThemeData.primary50,
                size: 40,
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: controller.pickIcon,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppThemeData.primary50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadButton(String label, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        width: 100,
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppThemeData.primary50.withValues(alpha: 0.3),
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              color: AppThemeData.primary50,
              size: 28,
            ),
            spaceH(height: 4),
            TextCustom(
              title: label,
              fontSize: 10,
              color: AppThemeData.primary50,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
