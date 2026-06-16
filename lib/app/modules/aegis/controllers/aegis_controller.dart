import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/constant/show_toast.dart';
import 'package:maheksync/app/firestore_utills/sentinel_firestore_utils.dart';
import 'package:maheksync/app/firestore_utills/vault_firestore_utils.dart' hide debugPrint;
import 'package:maheksync/app/models/sentinel_model.dart';
import 'package:maheksync/app/models/vault_model.dart';
import 'package:maheksync/app/routes/app_pages.dart';
import 'package:maheksync/app/services/imagekit_api.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'package:maheksync/app/widgets/text_field_widget.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/constant/round_shape_button.dart';
import 'package:solar_icons/solar_icons.dart';

class AegisController extends GetxController {
  // ═══════════════════════════════════════════════
  //  SENTINEL STATE
  // ═══════════════════════════════════════════════
  final isLoading = true.obs;
  final isPasswordSet = false.obs;
  final isVerified = false.obs;
  final isLocked = false.obs;
  final failedAttempts = 0.obs;
  final remainingLockTime = Rxn<Duration>();

  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final currentPasswordController = TextEditingController();

  SentinelModel? _sentinelData;

  // ═══════════════════════════════════════════════
  //  VAULT STATE
  // ═══════════════════════════════════════════════
  final vaultItems = <VaultModel>[].obs;
  final filteredItems = <VaultModel>[].obs;
  final searchQuery = ''.obs;
  final selectedCategory = 'ALL'.obs;
  final selectedItemId = RxnString();
  final sortBy = 'recently_used'.obs;
  final isGridView = false.obs;
  final revealedFields = <String>{}.obs;

  final categories = [
    'ALL', 'PASSWORD', 'API_KEY', 'WIFI', 'BANK', 'EMAIL',
    'SUBSCRIPTION', 'LICENSE', 'NOTE', 'VEHICLE', 'SERVER', 'DEVICE'
  ];

  final sortOptions = ['Recently Used', 'Alphabetical', 'Category'];

  VaultModel? get selectedItem {
    if (selectedItemId.value == null) return null;
    try {
      return filteredItems.firstWhere((i) => i.id == selectedItemId.value);
    } catch (_) {
      return filteredItems.isNotEmpty ? filteredItems.first : null;
    }
  }

  // ═══════════════════════════════════════════════
  //  CRUD FORM STATE
  // ═══════════════════════════════════════════════
  final titleController = TextEditingController();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final formPasswordController = TextEditingController();
  final websiteController = TextEditingController();
  final phoneController = TextEditingController();
  final notesController = TextEditingController();
  final tagController = TextEditingController();

  final formCategory = 'PASSWORD'.obs;
  final formTags = <String>[].obs;
  final selectedIcon = Rxn<XFile>();
  final iconBytes = Rxn<Uint8List>();
  final isEditMode = false.obs;
  final editingItem = Rxn<VaultModel>();
  final obscurePassword = true.obs;

  String? get ownerId => MahekConstant.ownerModel?.id;

  int get totalItems => vaultItems.length;
  int get favoriteCount => vaultItems.where((i) => i.isFavorite == true).length;
  int get pinnedCount => vaultItems.where((i) => i.isPinned == true).length;
  int get hiddenCount => vaultItems.where((i) => i.isHidden == true).length;

  @override
  void onInit() {
    super.onInit();
    loadSentinelStatus();
    loadItems();
  }

  // ═══════════════════════════════════════════════
  //  SENTINEL METHODS
  // ═══════════════════════════════════════════════

  void loadSentinelStatus() async {
    if (ownerId == null) {
      isLoading.value = false;
      return;
    }
    try {
      _sentinelData = await SentinelFirestoreUtils.getCurrentSentinelAccess(ownerId!);
      if (_sentinelData != null) {
        isPasswordSet.value = _sentinelData!.isPasswordSet ?? false;
        failedAttempts.value = _sentinelData!.failedAttempts ?? 0;
        isLocked.value = _sentinelData!.isLocked;
        remainingLockTime.value = _sentinelData!.remainingLockTime;
      }
    } catch (e) {
      debugPrint('Error loading sentinel status: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createMasterPassword() async {
    if (ownerId == null) return;
    final password = passwordController.text.trim();
    final confirm = confirmPasswordController.text.trim();

    if (password.isEmpty || password.length < 6) {
      ShowToastDialog.showError('Password must be at least 6 characters');
      return;
    }
    if (password != confirm) {
      ShowToastDialog.showError('Passwords do not match');
      return;
    }

    isLoading.value = true;
    try {
      final success = await SentinelFirestoreUtils.createMasterPassword(ownerId!, password);
      if (success) {
        isPasswordSet.value = true;
        isVerified.value = true;
        ShowToastDialog.showSuccess('Master password created!');
        passwordController.clear();
        confirmPasswordController.clear();
      } else {
        ShowToastDialog.showError('Failed to create master password');
      }
    } catch (e) {
      ShowToastDialog.showError('Error: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> verifyMasterPassword() async {
    if (ownerId == null) return false;
    if (isLocked.value) {
      ShowToastDialog.showError('Access locked. Please wait.');
      return false;
    }

    final password = currentPasswordController.text.trim();
    if (password.isEmpty) {
      ShowToastDialog.showError('Enter your master password');
      return false;
    }

    try {
      final verified = await SentinelFirestoreUtils.verifyMasterPassword(ownerId!, password);
      if (verified) {
        isVerified.value = true;
        failedAttempts.value = 0;
        await SentinelFirestoreUtils.updateFailedAttempts(ownerId!, 0);
        currentPasswordController.clear();
        return true;
      } else {
        failedAttempts.value++;
        await SentinelFirestoreUtils.updateFailedAttempts(ownerId!, failedAttempts.value);
        if (failedAttempts.value >= 5) {
          await SentinelFirestoreUtils.lockAccess(ownerId!, const Duration(minutes: 5));
          isLocked.value = true;
          remainingLockTime.value = const Duration(minutes: 5);
          ShowToastDialog.showError('Too many failed attempts. Locked for 5 minutes.');
        } else {
          ShowToastDialog.showError('Incorrect password. ${5 - failedAttempts.value} attempts remaining.');
        }
        return false;
      }
    } catch (e) {
      ShowToastDialog.showError('Verification failed');
      return false;
    }
  }

  Future<bool> reVerifyForSensitiveAction() async {
    if (!isPasswordSet.value) return true;
    if (isVerified.value) return true;

    final result = await Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppThemeData.grey10,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: AppThemeData.primary50.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(SolarIconsBold.shieldKeyhole, color: AppThemeData.primary50, size: 28),
              ),
              spaceH(height: 16),
              const TextCustom(title: 'Verify Identity', fontSize: 18, fontFamily: FontFamily.bold, color: Colors.white),
              spaceH(height: 8),
              TextCustom(
                title: 'Enter your master password to continue',
                fontSize: 13,
                fontFamily: FontFamily.regular,
                color: Colors.white.withValues(alpha: 0.6),
                textAlign: TextAlign.center,
              ),
              spaceH(height: 20),
              TextFieldWidget(
                hintText: 'Master password',
                controller: currentPasswordController,
                onPress: () {},
                obscureText: true,
                prefix: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppThemeData.primary50.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(SolarIconsOutline.lockKeyhole, color: AppThemeData.primary50, size: 18),
                ),
              ),
              spaceH(height: 20),
              Row(
                children: [
                  Expanded(
                    child: RoundShapeButton(
                      title: 'Cancel',
                      buttonColor: Colors.transparent,
                      buttonTextColor: Colors.white70,
                      borderColor: Colors.white30,
                      borderRadius: 12,
                      height: 48,
                      onTap: () => Get.back(result: false),
                    ),
                  ),
                  spaceW(width: 12),
                  Expanded(
                    child: RoundShapeButton(
                      title: 'Verify',
                      buttonColor: AppThemeData.primary50,
                      buttonTextColor: Colors.white,
                      borderRadius: 12,
                      height: 48,
                      onTap: () => Get.back(result: true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    if (result == true) {
      return await verifyMasterPassword();
    }
    return false;
  }

  Future<void> updateMasterPassword() async {
    if (ownerId == null) return;
    final currentPwd = currentPasswordController.text.trim();
    final newPwd = passwordController.text.trim();
    final confirmPwd = confirmPasswordController.text.trim();

    if (newPwd.isEmpty || newPwd.length < 6) {
      ShowToastDialog.showError('New password must be at least 6 characters');
      return;
    }
    if (newPwd != confirmPwd) {
      ShowToastDialog.showError('Passwords do not match');
      return;
    }

    isLoading.value = true;
    try {
      final isCurrentValid = await SentinelFirestoreUtils.verifyMasterPassword(ownerId!, currentPwd);
      if (!isCurrentValid) {
        ShowToastDialog.showError('Current password is incorrect');
        isLoading.value = false;
        return;
      }
      final success = await SentinelFirestoreUtils.updateMasterPassword(ownerId!, newPwd);
      if (success) {
        ShowToastDialog.showSuccess('Master password updated!');
        currentPasswordController.clear();
        passwordController.clear();
        confirmPasswordController.clear();
      } else {
        ShowToastDialog.showError('Failed to update password');
      }
    } catch (e) {
      ShowToastDialog.showError('Error: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetMasterPassword() async {
    if (ownerId == null) return;
    final confirmed = await Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppThemeData.grey10,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(color: AppThemeData.danger300.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                child: const Icon(SolarIconsOutline.dangerTriangle, color: AppThemeData.danger300, size: 28),
              ),
              spaceH(height: 16),
              const TextCustom(title: 'Reset Password', fontSize: 18, fontFamily: FontFamily.bold, color: Colors.white),
              spaceH(height: 8),
              TextCustom(
                title: "This will remove your master password. You'll need to set a new one.",
                fontSize: 13,
                fontFamily: FontFamily.regular,
                color: Colors.white.withValues(alpha: 0.6),
                textAlign: TextAlign.center,
              ),
              spaceH(height: 24),
              Row(
                children: [
                  Expanded(
                    child: RoundShapeButton(
                      title: 'Cancel',
                      buttonColor: Colors.transparent,
                      buttonTextColor: Colors.white70,
                      borderColor: Colors.white30,
                      borderRadius: 12,
                      height: 48,
                      onTap: () => Get.back(result: false),
                    ),
                  ),
                  spaceW(width: 12),
                  Expanded(
                    child: RoundShapeButton(
                      title: 'Reset',
                      buttonColor: AppThemeData.danger300,
                      buttonTextColor: Colors.white,
                      borderRadius: 12,
                      height: 48,
                      onTap: () => Get.back(result: true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      isLoading.value = true;
      try {
        final success = await SentinelFirestoreUtils.requestPasswordReset(ownerId!);
        if (success) {
          isPasswordSet.value = false;
          isVerified.value = false;
          ShowToastDialog.showSuccess('Password reset. Please set a new one.');
        } else {
          ShowToastDialog.showError('Failed to reset password');
        }
      } catch (e) {
        ShowToastDialog.showError('Error: ${e.toString()}');
      } finally {
        isLoading.value = false;
      }
    }
  }

  // ═══════════════════════════════════════════════
  //  VAULT METHODS
  // ═══════════════════════════════════════════════

  void loadItems() {
    if (ownerId == null) {
      return;
    }
    VaultFirestoreUtils.getVaultItems(ownerId!).listen((list) {
      vaultItems.value = list;
      _applyFilters();
    }, onError: (e) {
      debugPrint('Error loading vault: $e');
    });
  }

  void _applyFilters() {
    var result = vaultItems.toList();
    if (searchQuery.isNotEmpty) {
      result = result.where((i) =>
          (i.title ?? '').toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          (i.username ?? '').toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          (i.email ?? '').toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          (i.website ?? '').toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          (i.notes ?? '').toLowerCase().contains(searchQuery.value.toLowerCase())
      ).toList();
    }
    if (selectedCategory.value != 'ALL') {
      result = result.where((i) => i.category == selectedCategory.value).toList();
    }
    switch (sortBy.value) {
      case 'Alphabetical':
        result.sort((a, b) => (a.title ?? '').compareTo(b.title ?? ''));
        break;
      case 'Category':
        result.sort((a, b) => (a.category ?? '').compareTo(b.category ?? ''));
        break;
      case 'Recently Used':
      default:
        result.sort((a, b) {
          final aDate = a.updatedAt ?? a.createdAt ?? DateTime(2000);
          final bDate = b.updatedAt ?? b.createdAt ?? DateTime(2000);
          return bDate.compareTo(aDate);
        });
        break;
    }
    filteredItems.value = result;
    if (selectedItemId.value == null || !filteredItems.any((i) => i.id == selectedItemId.value)) {
      selectedItemId.value = filteredItems.isNotEmpty ? filteredItems.first.id : null;
    }
  }

  void selectItem(String? itemId) {
    selectedItemId.value = itemId;
  }

  void setSortBy(String sort) {
    sortBy.value = sort;
    _applyFilters();
  }

  String timeAgo(DateTime? date) {
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
    return '${(diff.inDays / 365).floor()}y ago';
  }

  String fieldLabel(String field) {
    final cat = selectedItem?.category ?? '';
    if (cat == 'WIFI') {
      switch (field) {
        case 'username': return 'Network Name (SSID)';
        case 'website': return 'Router IP';
        case 'phone': return 'Security Type';
        default: return field[0].toUpperCase() + field.substring(1);
      }
    }
    if (cat == 'BANK') {
      switch (field) {
        case 'username': return 'Account Holder';
        case 'website': return 'Bank Name';
        case 'phone': return 'Account Number';
        default: return field[0].toUpperCase() + field.substring(1);
      }
    }
    return field[0].toUpperCase() + field.substring(1);
  }

  String fieldHint(String field) {
    final cat = selectedItem?.category ?? '';
    if (cat == 'WIFI') {
      switch (field) {
        case 'username': return 'e.g. Mahek 5G';
        case 'website': return 'e.g. 192.168.1.1';
        case 'phone': return 'e.g. WPA2-Personal';
        default: return '';
      }
    }
    return '';
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void filterByCategory(String category) {
    selectedCategory.value = category;
    _applyFilters();
  }

  String formatDateTime(DateTime? date) {
    if (date == null) return 'N/A';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final h = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    final min = date.minute.toString().padLeft(2, '0');
    return '${months[date.month - 1]} ${date.day}, ${date.year} at $h:$min $ampm';
  }

  void copyToClipboard(String value, {String label = 'Value'}) {
    Clipboard.setData(ClipboardData(text: value));
    ShowToastDialog.showSuccess('$label copied!');
  }

  Future<void> revealField(String fieldId) async {
    if (revealedFields.contains(fieldId)) {
      revealedFields.remove(fieldId);
      return;
    }
    final verified = await reVerifyForSensitiveAction();
    if (verified) {
      revealedFields.add(fieldId);
    } else {
      ShowToastDialog.showError('Verification failed');
    }
  }

  Future<void> toggleFavorite(VaultModel item) async {
    await VaultFirestoreUtils.toggleFavorite(item);
  }

  Future<void> togglePin(VaultModel item) async {
    await VaultFirestoreUtils.togglePin(item);
  }

  Future<void> deleteItem(VaultModel item) async {
    final isDark = Get.isDarkMode;
    final confirmed = await Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? AppThemeData.grey10 : AppThemeData.primaryWhite,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(color: AppThemeData.danger300.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                child: Icon(SolarIconsOutline.trashBin2, color: AppThemeData.danger300, size: 28),
              ),
              spaceH(height: 16),
              Text('Delete Item', style: TextStyle(color: isDark ? Colors.white : AppThemeData.grey10, fontSize: 18, fontWeight: FontWeight.w700)),
              spaceH(height: 8),
              Text('Delete "${item.title}"?', style: TextStyle(color: isDark ? Colors.white.withValues(alpha: 0.6) : AppThemeData.grey6, fontSize: 14)),
              spaceH(height: 24),
              Row(
                children: [
                  Expanded(
                    child: RoundShapeButton(
                      title: 'Cancel',
                      buttonColor: Colors.transparent,
                      buttonTextColor: isDark ? Colors.white70 : AppThemeData.grey6,
                      borderColor: isDark ? Colors.white30 : AppThemeData.grey4,
                      borderRadius: 12,
                      height: 48,
                      onTap: () => Get.back(result: false),
                    ),
                  ),
                  spaceW(width: 12),
                  Expanded(
                    child: RoundShapeButton(
                      title: 'Delete',
                      buttonColor: AppThemeData.danger300,
                      buttonTextColor: Colors.white,
                      borderRadius: 12,
                      height: 48,
                      onTap: () => Get.back(result: true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed == true && item.id != null) {
      await VaultFirestoreUtils.deleteVaultItem(item.id!);
    }
  }

  void goToAdd() {
    _resetForm();
    isEditMode.value = false;
    editingItem.value = null;
    Get.toNamed(Routes.AEGIS_FORM);
  }

  void goToEdit(VaultModel item) {
    _populateForm(item);
    isEditMode.value = true;
    editingItem.value = item;
    Get.toNamed(Routes.AEGIS_FORM, arguments: item);
  }

  // ═══════════════════════════════════════════════
  //  ICON UPLOAD
  // ═══════════════════════════════════════════════

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

  void removeIcon() {
    selectedIcon.value = null;
    iconBytes.value = null;
  }

  // ═══════════════════════════════════════════════
  //  CRUD FORM
  // ═══════════════════════════════════════════════

  void _populateForm(VaultModel i) {
    titleController.text = i.title ?? '';
    emailController.text = i.email ?? '';
    usernameController.text = i.username ?? '';
    formPasswordController.text = i.password ?? '';
    websiteController.text = i.website ?? '';
    phoneController.text = i.phone ?? '';
    notesController.text = i.notes ?? '';
    formCategory.value = i.category ?? 'PASSWORD';
    if (i.tags != null) formTags.value = List<String>.from(i.tags!);
  }

  void _resetForm() {
    titleController.clear();
    emailController.clear();
    usernameController.clear();
    formPasswordController.clear();
    websiteController.clear();
    phoneController.clear();
    notesController.clear();
    tagController.clear();
    formCategory.value = 'PASSWORD';
    formTags.clear();
    selectedIcon.value = null;
    iconBytes.value = null;
    obscurePassword.value = true;
  }

  void addTag() {
    final tag = tagController.text.trim();
    if (tag.isNotEmpty && !formTags.contains(tag)) {
      formTags.add(tag);
      tagController.clear();
    }
  }

  void removeTag(String tag) => formTags.remove(tag);

  Future<void> saveItem() async {
    if (titleController.text.isEmpty) {
      ShowToastDialog.showError('Title is required');
      return;
    }

    isLoading.value = true;
    try {
      String? iconUrl = editingItem.value?.iconUrl;
      if (selectedIcon.value != null) {
        final oId = MahekConstant.ownerModel?.id ?? 'unknown';
        iconUrl = await ImageKitAPI.uploadImage(imageFile: selectedIcon.value!, folderName: 'vault/$oId');
      }

      final item = VaultModel(
        id: editingItem.value?.id ?? MahekConstant.getUuid(),
        ownerId: MahekConstant.ownerModel?.id,
        title: titleController.text.trim(),
        email: emailController.text.trim(),
        username: usernameController.text.trim(),
        password: formPasswordController.text.trim(),
        website: websiteController.text.trim(),
        phone: phoneController.text.trim(),
        category: formCategory.value,
        tags: formTags.toList(),
        notes: notesController.text.trim(),
        iconUrl: iconUrl,
        isFavorite: editingItem.value?.isFavorite ?? false,
        isPinned: editingItem.value?.isPinned ?? false,
        isHidden: editingItem.value?.isHidden ?? false,
        createdAt: editingItem.value?.createdAt,
        updatedAt: DateTime.now(),
      );

      bool success = isEditMode.value
          ? await VaultFirestoreUtils.updateVaultItem(item)
          : await VaultFirestoreUtils.addVaultItem(item);

      if (success) {
        ShowToastDialog.showSuccess(isEditMode.value ? 'Item updated!' : 'Item added!');
        Get.back(result: true);
      } else {
        ShowToastDialog.showError('Failed to save');
      }
    } catch (e) {
      ShowToastDialog.showError('Error: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    currentPasswordController.dispose();
    titleController.dispose();
    emailController.dispose();
    usernameController.dispose();
    formPasswordController.dispose();
    websiteController.dispose();
    phoneController.dispose();
    notesController.dispose();
    tagController.dispose();
    super.onClose();
  }
}
