import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsModel {
  String? id;
  String? ownerId;

  // Appearance
  int? themeMode; // 0=dark, 1=light, 2=system
  String? accentColor;
  String? language;

  // Notifications
  bool? pushNotifications;
  bool? emailNotifications;
  bool? reminderAlerts;

  // Security
  bool? biometricLock;
  String? autoLockTimeout;
  bool? twoFactorAuth;

  // Data & Storage
  bool? cloudBackup;
  bool? offlineMode;
  bool? autoSync;

  // About
  String? appVersion;
  String? buildNumber;

  DateTime? createdAt;
  DateTime? updatedAt;

  SettingsModel({
    this.id,
    this.ownerId,
    this.themeMode = 0,
    this.accentColor = 'Indigo Violet',
    this.language = 'English',
    this.pushNotifications = true,
    this.emailNotifications = false,
    this.reminderAlerts = true,
    this.biometricLock = false,
    this.autoLockTimeout = 'Never',
    this.twoFactorAuth = false,
    this.cloudBackup = true,
    this.offlineMode = true,
    this.autoSync = true,
    this.appVersion = '1.0.0',
    this.buildNumber = '1',
    this.createdAt,
    this.updatedAt,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      id: json['id'],
      ownerId: json['ownerId'],
      themeMode: json['themeMode'] ?? 0,
      accentColor: json['accentColor'] ?? 'Indigo Violet',
      language: json['language'] ?? 'English',
      pushNotifications: json['pushNotifications'] ?? true,
      emailNotifications: json['emailNotifications'] ?? false,
      reminderAlerts: json['reminderAlerts'] ?? true,
      biometricLock: json['biometricLock'] ?? false,
      autoLockTimeout: json['autoLockTimeout'] ?? 'Never',
      twoFactorAuth: json['twoFactorAuth'] ?? false,
      cloudBackup: json['cloudBackup'] ?? true,
      offlineMode: json['offlineMode'] ?? true,
      autoSync: json['autoSync'] ?? true,
      appVersion: json['appVersion'] ?? '1.0.0',
      buildNumber: json['buildNumber'] ?? '1',
      createdAt: json['createdAt']?.toDate(),
      updatedAt: json['updatedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'themeMode': themeMode ?? 0,
      'accentColor': accentColor ?? 'Indigo Violet',
      'language': language ?? 'English',
      'pushNotifications': pushNotifications ?? true,
      'emailNotifications': emailNotifications ?? false,
      'reminderAlerts': reminderAlerts ?? true,
      'biometricLock': biometricLock ?? false,
      'autoLockTimeout': autoLockTimeout ?? 'Never',
      'twoFactorAuth': twoFactorAuth ?? false,
      'cloudBackup': cloudBackup ?? true,
      'offlineMode': offlineMode ?? true,
      'autoSync': autoSync ?? true,
      'appVersion': appVersion ?? '1.0.0',
      'buildNumber': buildNumber ?? '1',
      'createdAt': createdAt ?? Timestamp.now(),
      'updatedAt': Timestamp.now(),
    };
  }
}
