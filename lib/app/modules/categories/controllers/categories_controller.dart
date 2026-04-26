// lib/app/modules/categories/controllers/categories_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/models/category_model.dart';
import 'package:maheksync/app/services/imagekit_api.dart';
import 'package:maheksync/app/utils/category_firestore_utils.dart';
import '../../../constant/show_toast.dart';

class CategoriesController extends GetxController {
  final categories = <CategoryModel>[].obs;
  final filteredCategories = <CategoryModel>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final searchQuery = ''.obs;
  final selectedCategory = Rxn<CategoryModel>();
  final iconBytes = Rxn<dynamic>();

  // Form controllers
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final selectedIcon = Rxn<XFile>();
  final editingCategory = Rxn<CategoryModel>();

  // Stats
  final totalItems = 0.obs;
  final topCategory = Rxn<CategoryModel>();

  // Add this to CategoriesController
  final isGridView = true.obs; // Default to grid view

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  void loadCategories() {
    CategoryFirestoreUtils.getCategories().listen((cats) {
      categories.value = cats;
      filteredCategories.value = cats;
      _updateStats();
    });
  }

  void _updateStats() {
    totalItems.value = categories.fold(0, (sum, cat) => sum + (cat.itemCount ?? 0));
    if (categories.isNotEmpty) {
      categories.sort((a, b) => (b.itemCount ?? 0).compareTo(a.itemCount ?? 0));
      topCategory.value = categories.first;
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredCategories.value = categories;
    } else {
      filteredCategories.value = categories.where((cat) {
        return (cat.name ?? '').toLowerCase().contains(query.toLowerCase()) ||
            (cat.description ?? '').toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
  }

  void selectCategory(CategoryModel category) {
    selectedCategory.value = category;
  }

  Future<void> pickIcon() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 512,
      );
      if (image != null) {
        selectedIcon.value = image;
        final bytes = await image.readAsBytes();
        iconBytes.value = bytes; // This works with dynamic type
      }
    } catch (e) {
      ShowToastDialog.showError('Failed to pick image');
    }
  }

  void removeIcon() {
    selectedIcon.value = null;
    iconBytes.value = null;
  }

  void startEditing(CategoryModel category) {
    editingCategory.value = category;
    nameController.text = category.name ?? '';
    descriptionController.text = category.description ?? '';
    selectedIcon.value = null;
    iconBytes.value = null;
  }

  void cancelEditing() {
    editingCategory.value = null;
    nameController.clear();
    descriptionController.clear();
    removeIcon();
  }

  Future<void> saveCategory() async {
    if (nameController.text.trim().isEmpty) {
      ShowToastDialog.showError('Category name is required');
      return;
    }

    isSaving.value = true;

    try {
      String? iconUrl = editingCategory.value?.iconUrl;

      // Upload new icon if selected
      if (selectedIcon.value != null) {
        final ownerId = MahekConstant.ownerModel?.id ?? 'unknown';
        iconUrl = await ImageKitAPI.uploadImage(
          imageFile: selectedIcon.value!,
          folderName: 'categories/$ownerId',
        );
        if (iconUrl == null) {
          ShowToastDialog.showError('Failed to upload icon');
          isSaving.value = false;
          return;
        }
      }

      final category = CategoryModel(
        id: editingCategory.value?.id ?? MahekConstant.getUuid(),
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        iconUrl: iconUrl,
        itemCount: editingCategory.value?.itemCount ?? 0,
        createdAt: editingCategory.value?.createdAt ?? DateTime.now(),
      );

      bool success;
      if (editingCategory.value == null) {
        success = await CategoryFirestoreUtils.addCategory(category);
      } else {
        success = await CategoryFirestoreUtils.updateCategory(category);
      }

      if (success) {
        ShowToastDialog.showSuccess(
          editingCategory.value == null
              ? 'Category created successfully!'
              : 'Category updated successfully!',
        );
        cancelEditing();
      } else {
        ShowToastDialog.showError('Failed to save category');
      }
    } catch (e) {
      ShowToastDialog.showError('Error: ${e.toString()}');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteCategory(CategoryModel category) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (category.id == null) {
      ShowToastDialog.showError('Invalid category');
      return;
    }

    final success = await CategoryFirestoreUtils.deleteCategory(category.id!);
    if (success) {
      ShowToastDialog.showSuccess('Category deleted successfully!');
      if (editingCategory.value?.id == category.id) {
        cancelEditing();
      }
      if (selectedCategory.value?.id == category.id) {
        selectedCategory.value = null;
      }
    } else {
      ShowToastDialog.showError('Failed to delete category');
    }
  }

  void viewInventory(CategoryModel category) {
    // Navigate to inventory view filtered by category
    Get.toNamed('/my-devices', arguments: {'category': category.name});
  }

  void exportCSV() {
    // Implement CSV export
    ShowToastDialog.showSuccess('Exporting categories...');
  }
}