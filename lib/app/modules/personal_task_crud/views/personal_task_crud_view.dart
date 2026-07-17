import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:maheksync/app/widgets/mahek_loader.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/constant/round_shape_button.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/network_image_widget.dart';
import 'package:maheksync/app/widgets/text_field_widget.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import '../controllers/personal_task_crud_controller.dart';

class PersonalTaskCrudView extends GetView<PersonalTaskCrudController> {
  const PersonalTaskCrudView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppThemeData.grey10 : AppThemeData.grey2,
      appBar: AppBar(
        backgroundColor: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(SolarIconsOutline.altArrowLeft, color: isDark ? AppThemeData.grey4 : AppThemeData.grey7, size: 20),
        ),
        title: TextCustom(
          title: controller.isEditMode.value ? 'Edit Task' : 'Add Task',
          fontSize: 18,
          fontFamily: FontFamily.bold,
          color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
        ),
        actions: [
          Obx(() => controller.isLoading.value
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: MahekLoader(size: 20, showBranding: false),
                )
              : RoundShapeButton(
                  title: 'Save',
                  buttonColor: AppThemeData.primary50,
                  buttonTextColor: AppThemeData.primaryWhite,
                  onTap: controller.saveTask,
                  borderRadius: 8,
                  height: 36,
                )),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _buildForm(isDark, context: context),
      ),
    );
  }

  Widget _buildForm(bool isDark, {required BuildContext context}) {
    return Container(
      padding:  EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Basic Information', SolarIconsOutline.infoCircle, isDark),
          spaceH(height: 12),
          TextFieldWidget(
            title: 'Task Title',
            hintText: 'e.g. Finish project report',
            controller: controller.titleController,
            onPress: () {},
            prefix: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppThemeData.primary50.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(SolarIconsOutline.checklist, color: AppThemeData.primary50, size: 18),
            ),
          ),
          spaceH(height: 14),
          TextFieldWidget(
            title: 'Description',
            hintText: 'Brief description...',
            controller: controller.descriptionController,
            onPress: () {},
            prefix: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppThemeData.primary50.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(SolarIconsOutline.notes, color: AppThemeData.primary50, size: 18),
            ),
            line: 2,
          ),
          spaceH(height: 20),
          _buildSectionTitle('Priority', SolarIconsOutline.flag, isDark),
          spaceH(height: 10),
          _buildPrioritySelector(isDark),
          spaceH(height: 20),
          _buildSectionTitle('Category', SolarIconsOutline.tag, isDark),
          spaceH(height: 10),
          _buildCategorySelector(isDark),
          spaceH(height: 20),
          _buildSectionTitle('Status', SolarIconsOutline.graphUp, isDark),
          spaceH(height: 10),
          _buildStatusSelector(isDark),
          spaceH(height: 20),
          _buildSectionTitle('Due Date', SolarIconsOutline.calendar, isDark),
          spaceH(height: 10),
          _buildDatePicker(controller.dueDate, isDark, context: context),
          spaceH(height: 20),
          _buildSectionTitle('Notes', SolarIconsOutline.notes, isDark),
          spaceH(height: 10),
          TextFieldWidget(
            title: 'Notes',
            hintText: 'Additional notes...',
            controller: controller.notesController,
            onPress: () {},
            prefix: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppThemeData.primary50.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(SolarIconsOutline.notes, color: AppThemeData.primary50, size: 18),
            ),
            line: 3,
          ),
          spaceH(height: 20),
          _buildSectionTitle('Tags', SolarIconsOutline.tag, isDark),
          spaceH(height: 10),
          _buildTagsSection(isDark),
          spaceH(height: 20),
          _buildSectionTitle('Task Icon', SolarIconsOutline.gallery, isDark),
          spaceH(height: 10),
          _buildIconUploader(isDark),
          spaceH(height: 24),
          _buildSaveButton(isDark),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(color: AppThemeData.primary50.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: AppThemeData.primary50, size: 16),
        ),
        spaceW(width: 10),
        TextCustom(title: title, fontSize: 14, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey3 : AppThemeData.grey7),
      ],
    );
  }

  Widget _buildPrioritySelector(bool isDark) {
    final priorityColors = {'HIGH': AppThemeData.danger300, 'MEDIUM': AppThemeData.pending400, 'LOW': AppThemeData.success400};
    final priorityIcons = {'HIGH': SolarIconsBold.dangerTriangle, 'MEDIUM': SolarIconsOutline.flag, 'LOW': SolarIconsOutline.arrowDown};

    return Obx(() => Row(
      children: controller.priorities.map((p) {
        final isSelected = controller.selectedPriority.value == p;
        final color = priorityColors[p] ?? AppThemeData.grey5;
        return Expanded(
          child: GestureDetector(
            onTap: () => controller.selectedPriority.value = p,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? color.withValues(alpha: 0.15) : (isDark ? AppThemeData.grey9 : AppThemeData.grey1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? color : (isDark ? AppThemeData.grey8 : AppThemeData.grey3), width: isSelected ? 1.5 : 0.5),
              ),
              child: Column(
                children: [
                  Icon(priorityIcons[p], size: 20, color: isSelected ? color : (isDark ? AppThemeData.grey6 : AppThemeData.grey5)),
                  spaceH(height: 4),
                  TextCustom(title: p, fontSize: 11, fontFamily: FontFamily.bold, color: isSelected ? color : (isDark ? AppThemeData.grey6 : AppThemeData.grey5)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    ));
  }

  Widget _buildCategorySelector(bool isDark) {
    return Obx(() => Wrap(
      spacing: 8,
      runSpacing: 8,
      children: controller.categories.map((cat) {
        final isSelected = controller.selectedCategory.value == cat;
        return GestureDetector(
          onTap: () => controller.selectedCategory.value = cat,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppThemeData.primary50.withValues(alpha: 0.15) : (isDark ? AppThemeData.grey9 : AppThemeData.grey1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isSelected ? AppThemeData.primary50 : (isDark ? AppThemeData.grey8 : AppThemeData.grey3), width: isSelected ? 1.5 : 0.5),
            ),
            child: TextCustom(
              title: cat,
              fontSize: 12,
              fontFamily: isSelected ? FontFamily.bold : FontFamily.medium,
              color: isSelected ? AppThemeData.primary50 : (isDark ? AppThemeData.grey5 : AppThemeData.grey6),
            ),
          ),
        );
      }).toList(),
    ));
  }

  Widget _buildStatusSelector(bool isDark) {
    return Obx(() => Wrap(
      spacing: 8,
      runSpacing: 8,
      children: controller.statuses.map((s) {
        final isSelected = controller.selectedStatus.value == s;
        final statusColors = {'PENDING': AppThemeData.grey5, 'IN_PROGRESS': AppThemeData.pending400, 'COMPLETED': AppThemeData.success400, 'CANCELLED': AppThemeData.danger300};
        final color = statusColors[s] ?? AppThemeData.grey5;
        return GestureDetector(
          onTap: () => controller.selectedStatus.value = s,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? color.withValues(alpha: 0.15) : (isDark ? AppThemeData.grey9 : AppThemeData.grey1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isSelected ? color : (isDark ? AppThemeData.grey8 : AppThemeData.grey3), width: isSelected ? 1.5 : 0.5),
            ),
            child: TextCustom(
              title: s.replaceAll('_', ' '),
              fontSize: 12,
              fontFamily: isSelected ? FontFamily.bold : FontFamily.medium,
              color: isSelected ? color : (isDark ? AppThemeData.grey5 : AppThemeData.grey6),
            ),
          ),
        );
      }).toList(),
    ));
  }

  Widget _buildDatePicker(Rx<DateTime?> date, bool isDark, {required BuildContext context}) {
    return Obx(() => GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
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
          border: Border.all(color: isDark ? AppThemeData.grey8 : AppThemeData.grey3, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: AppThemeData.primary50.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(SolarIconsOutline.calendar, color: AppThemeData.primary50, size: 16),
            ),
            spaceW(width: 10),
            TextCustom(
              title: date.value != null ? DateFormat('dd/MM/yyyy').format(date.value!) : 'Select due date',
              fontSize: 14,
              fontFamily: FontFamily.medium,
              color: date.value != null ? (isDark ? AppThemeData.grey1 : AppThemeData.grey10) : (isDark ? AppThemeData.grey6 : AppThemeData.grey5),
            ),
            const Spacer(),
            if (date.value != null)
              GestureDetector(
                onTap: () => date.value = null,
                child: Icon(SolarIconsOutline.closeCircle, size: 18, color: isDark ? AppThemeData.grey6 : AppThemeData.grey5),
              ),
          ],
        ),
      ),
    ));
  }

  Widget _buildTagsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? AppThemeData.grey8 : AppThemeData.grey3, width: 0.5),
                ),
                child: TextField(
                  controller: controller.tagController,
                  style: TextStyle(fontFamily: FontFamily.medium, fontSize: 14, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
                  decoration: InputDecoration(
                    hintText: 'Add tag...',
                    hintStyle: TextStyle(fontFamily: FontFamily.regular, fontSize: 14, color: isDark ? AppThemeData.grey6 : AppThemeData.grey5),
                    prefixIcon: Icon(SolarIconsOutline.tag, color: AppThemeData.primary50, size: 18),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                  onSubmitted: (_) => controller.addTag(),
                ),
              ),
            ),
            spaceW(width: 8),
            GestureDetector(
              onTap: controller.addTag,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppThemeData.primary50, borderRadius: BorderRadius.circular(12)),
                child: Icon(SolarIconsOutline.addCircle, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
        spaceH(height: 8),
        Obx(() => Wrap(
          spacing: 6,
          runSpacing: 6,
          children: controller.tags.map((tag) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: AppThemeData.primary50.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextCustom(title: '#$tag', fontSize: 12, fontFamily: FontFamily.medium, color: AppThemeData.primary50),
                spaceW(width: 4),
                GestureDetector(
                  onTap: () => controller.removeTag(tag),
                  child: Icon(SolarIconsOutline.closeCircle, size: 14, color: AppThemeData.primary50),
                ),
              ],
            ),
          )).toList(),
        )),
      ],
    );
  }

  Widget _buildIconUploader(bool isDark) {
    return Obx(() {
      if (controller.selectedIcon.value != null && controller.iconBytes.value != null) {
        return _buildIconPreview(isDark, bytes: controller.iconBytes.value);
      } else if (controller.editingTask.value?.iconUrl != null && controller.editingTask.value!.iconUrl!.isNotEmpty) {
        return _buildIconPreview(isDark, networkUrl: controller.editingTask.value!.iconUrl);
      }
      return _buildUploadButton(isDark);
    });
  }

  Widget _buildIconPreview(bool isDark, {Uint8List? bytes, String? networkUrl}) {
    return Container(
      height: 100,
      width: 100,
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppThemeData.primary50.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Stack(
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: bytes != null
                  ? Image.memory(bytes, width: 80, height: 80, fit: BoxFit.cover)
                  : networkUrl != null
                  ? NetworkImageWidget(imageUrl: networkUrl, fit: BoxFit.cover, height: 80, width: 80)
                  : Icon(SolarIconsBold.checklist, color: AppThemeData.primary50, size: 40),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: controller.pickIcon,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: AppThemeData.primary50, borderRadius: BorderRadius.circular(6)),
                child: Icon(SolarIconsOutline.pen, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadButton(bool isDark) {
    return GestureDetector(
      onTap: controller.pickIcon,
      child: Container(
        height: 100,
        width: 100,
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppThemeData.primary50.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(SolarIconsOutline.cloudUpload, color: AppThemeData.primary50, size: 28),
            spaceH(height: 4),
            TextCustom(title: 'Upload', fontSize: 10, fontFamily: FontFamily.medium, color: AppThemeData.primary50),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(bool isDark) {
    return Obx(() => SizedBox(
      width: double.infinity,
      child: RoundShapeButton(
        title: controller.isEditMode.value ? 'Update Task' : 'Create Task',
        buttonColor: controller.isLoading.value
            ? AppThemeData.primary50.withValues(alpha: 0.5)
            : AppThemeData.primary50,
        buttonTextColor: Colors.white,
        onTap: controller.isLoading.value ? () {} : controller.saveTask,
        borderRadius: 14,
        height: 52,
        titleWidget: controller.isLoading.value
            ? const MahekLoader(size: 22, showBranding: false)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(SolarIconsBold.checkCircle, color: Colors.white, size: 18),
                  spaceW(width: 8),
                  TextCustom(
                    title: controller.isEditMode.value ? 'Update Task' : 'Create Task',
                    fontSize: 15,
                    fontFamily: FontFamily.semiBold,
                    color: Colors.white,
                  ),
                ],
              ),
      ),
    ));
  }
}
