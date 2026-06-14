import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/firestore_utills/settings_firestore_utils.dart';
import 'package:maheksync/app/models/settings_model.dart';
import 'package:maheksync/app/utils/dark_theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsController extends GetxController {
  // ── Profile (read from static ownerModel) ────────────────────────────
  String get displayName => MahekConstant.ownerModel?.fullName ?? 'Admin';
  String get email => MahekConstant.ownerModel?.email ?? 'Not set';
  String get profilePic => MahekConstant.ownerModel?.profilePic ?? '';
  String get accountType => 'Editor';
  String get userId => MahekConstant.ownerModel?.id?.substring(0, 8) ?? 'N/A';

  // ── Firestore model ─────────────────────────────────────────────────
  final _settingsModel = Rxn<SettingsModel>();
  final isLoading = true.obs;

  // ── Appearance ──────────────────────────────────────────────────────
  final themeMode = 0.obs;
  final accentColor = 'Indigo Violet'.obs;
  final language = 'English'.obs;

  // ── Notifications ───────────────────────────────────────────────────
  final pushNotifications = true.obs;
  final emailNotifications = false.obs;
  final reminderAlerts = true.obs;

  // ── Security ────────────────────────────────────────────────────────
  final biometricLock = false.obs;
  final autoLockTimeout = 'Never'.obs;
  final twoFactorAuth = false.obs;

  // ── Data & Storage ──────────────────────────────────────────────────
  final cloudBackup = true.obs;
  final offlineMode = true.obs;
  final autoSync = true.obs;
  final storageUsed = '2.4 GB'.obs;

  // ── About ───────────────────────────────────────────────────────────
  String get appVersion => _settingsModel.value?.appVersion ?? '1.0.0';
  String get buildNumber => _settingsModel.value?.buildNumber ?? '1';
  String get appName => 'MahekSync';

  // ── Theme mode label ────────────────────────────────────────────────
  String get themeModeLabel {
    switch (themeMode.value) {
      case 0:
        return 'Dark';
      case 1:
        return 'Light';
      case 2:
        return 'System';
      default:
        return 'Dark';
    }
  }

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  // ── Load from Firestore ─────────────────────────────────────────────
  void _loadSettings() {
    isLoading.value = true;
    SettingsFirestoreUtils.getSettingsStream().listen((model) {
      if (model != null) {
        _settingsModel.value = model;
        themeMode.value = model.themeMode ?? 0;
        accentColor.value = model.accentColor ?? 'Indigo Violet';
        language.value = model.language ?? 'English';
        pushNotifications.value = model.pushNotifications ?? true;
        emailNotifications.value = model.emailNotifications ?? false;
        reminderAlerts.value = model.reminderAlerts ?? true;
        biometricLock.value = model.biometricLock ?? false;
        autoLockTimeout.value = model.autoLockTimeout ?? 'Never';
        twoFactorAuth.value = model.twoFactorAuth ?? false;
        cloudBackup.value = model.cloudBackup ?? true;
        offlineMode.value = model.offlineMode ?? true;
        autoSync.value = model.autoSync ?? true;
      } else {
        // First time: create default settings document
        _createDefaults();
      }
      isLoading.value = false;
    });
  }

  Future<void> _createDefaults() async {
    final model = SettingsModel(
      id: 'app_settings',
      ownerId: MahekConstant.ownerModel?.id,
      themeMode: 0,
      createdAt: DateTime.now(),
    );
    await SettingsFirestoreUtils.saveSettings(model);
    _settingsModel.value = model;
  }

  // ── Save helpers (Firestore write) ──────────────────────────────────
  Future<void> _saveField(String field, dynamic value) async {
    await SettingsFirestoreUtils.updateField(field, value);
  }

  void toggleThemeMode(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context, listen: false);
    if (themeMode.value == 0) {
      themeChange.darkTheme = 1;
      themeMode.value = 1;
    } else {
      themeChange.darkTheme = 0;
      themeMode.value = 0;
    }
    _saveField('themeMode', themeMode.value);
  }

  void togglePushNotifications() {
    pushNotifications.toggle();
    _saveField('pushNotifications', pushNotifications.value);
  }

  void toggleEmailNotifications() {
    emailNotifications.toggle();
    _saveField('emailNotifications', emailNotifications.value);
  }

  void toggleReminderAlerts() {
    reminderAlerts.toggle();
    _saveField('reminderAlerts', reminderAlerts.value);
  }

  void toggleBiometricLock() {
    biometricLock.toggle();
    _saveField('biometricLock', biometricLock.value);
  }

  void toggleTwoFactorAuth() {
    twoFactorAuth.toggle();
    _saveField('twoFactorAuth', twoFactorAuth.value);
  }

  void toggleCloudBackup() {
    cloudBackup.toggle();
    _saveField('cloudBackup', cloudBackup.value);
  }

  void toggleOfflineMode() {
    offlineMode.toggle();
    _saveField('offlineMode', offlineMode.value);
  }

  void toggleAutoSync() {
    autoSync.toggle();
    _saveField('autoSync', autoSync.value);
  }
}
