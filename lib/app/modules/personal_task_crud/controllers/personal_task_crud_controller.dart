import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/constant/show_toast.dart';
import 'package:maheksync/app/models/personal_task_model.dart';
import 'package:maheksync/app/services/imagekit_api.dart';
import 'package:maheksync/app/utils/personal_task_firestore_utils.dart';

class PersonalTaskCrudController extends GetxController {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final notesController = TextEditingController();
  final tagController = TextEditingController();

  final selectedPriority = 'MEDIUM'.obs;
  final selectedCategory = 'GENERAL'.obs;
  final selectedStatus = 'PENDING'.obs;
  final dueDate = Rxn<DateTime>();

  final priorities = ['HIGH', 'MEDIUM', 'LOW'];
  final categories = ['GENERAL', 'WORK', 'PERSONAL', 'HEALTH', 'FINANCE', 'EDUCATION', 'OTHER'];
  final statuses = ['PENDING', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED'];

  final tags = <String>[].obs;
  final selectedIcon = Rxn<XFile>();
  final iconBytes = Rxn<Uint8List>();

  final isLoading = false.obs;
  final isEditMode = false.obs;
  final editingTask = Rxn<PersonalTaskModel>();

  @override
  void onInit() {
    super.onInit();
    final task = Get.arguments as PersonalTaskModel?;
    if (task != null) {
      isEditMode.value = true;
      editingTask.value = task;
      _populateForm(task);
    }
  }

  void _populateForm(PersonalTaskModel t) {
    titleController.text = t.title ?? '';
    descriptionController.text = t.description ?? '';
    notesController.text = t.notes ?? '';
    selectedPriority.value = t.priority ?? 'MEDIUM';
    selectedCategory.value = t.category ?? 'GENERAL';
    selectedStatus.value = t.status ?? 'PENDING';
    dueDate.value = t.dueDate;
    if (t.tags != null) tags.value = List<String>.from(t.tags!);
  }

  void addTag() {
    final tag = tagController.text.trim();
    if (tag.isNotEmpty && !tags.contains(tag)) {
      tags.add(tag);
      tagController.clear();
    }
  }

  void removeTag(String tag) => tags.remove(tag);

  Future<void> pickIcon() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85, maxWidth: 512);
      if (image != null) {
        selectedIcon.value = image;
        iconBytes.value = await image.readAsBytes();
      }
    } catch (e) {
      ShowToastDialog.showError('Failed to pick icon');
    }
  }

  Future<void> saveTask() async {
    if (titleController.text.isEmpty) {
      ShowToastDialog.showError('Task title is required');
      return;
    }

    isLoading.value = true;
    try {
      String? iconUrl = editingTask.value?.iconUrl;
      if (selectedIcon.value != null) {
        final ownerId = MahekConstant.ownerModel?.id ?? 'unknown';
        iconUrl = await ImageKitAPI.uploadImage(imageFile: selectedIcon.value!, folderName: 'tasks/$ownerId');
      }

      final task = PersonalTaskModel(
        id: editingTask.value?.id ?? MahekConstant.getUuid(),
        ownerId: MahekConstant.ownerModel?.id,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        priority: selectedPriority.value,
        category: selectedCategory.value,
        status: selectedStatus.value,
        iconUrl: iconUrl,
        tags: tags.toList(),
        isPinned: editingTask.value?.isPinned ?? false,
        isCompleted: selectedStatus.value == 'COMPLETED',
        dueDate: dueDate.value,
        notes: notesController.text.trim(),
        createdAt: editingTask.value?.createdAt,
        updatedAt: DateTime.now(),
      );

      bool success = isEditMode.value
          ? await PersonalTaskFirestoreUtils.updateTask(task)
          : await PersonalTaskFirestoreUtils.addTask(task);

      if (success) {
        ShowToastDialog.showSuccess(isEditMode.value ? 'Task updated!' : 'Task added!');
        Get.back(result: true);
      } else {
        ShowToastDialog.showError('Failed to save task');
      }
    } catch (e) {
      ShowToastDialog.showError('Error: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    notesController.dispose();
    tagController.dispose();
    super.onClose();
  }
}
