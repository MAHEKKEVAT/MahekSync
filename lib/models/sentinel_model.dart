import 'package:cloud_firestore/cloud_firestore.dart';

class SentinelModel {
  String? id;
  String? ownerId;
  String? masterPasswordHash;
  String? passwordSalt;
  int? failedAttempts;
  DateTime? lockedUntil;
  String? resetEmail;
  bool? isPasswordSet;
  DateTime? createdAt;
  DateTime? updatedAt;

  SentinelModel({
    this.id,
    this.ownerId,
    this.masterPasswordHash,
    this.passwordSalt,
    this.failedAttempts = 0,
    this.lockedUntil,
    this.resetEmail,
    this.isPasswordSet = false,
    this.createdAt,
    this.updatedAt,
  });

  factory SentinelModel.fromJson(Map<String, dynamic> json) {
    return SentinelModel(
      id: json['id'] as String?,
      ownerId: json['ownerId'] as String?,
      masterPasswordHash: json['masterPasswordHash'] as String?,
      passwordSalt: json['passwordSalt'] as String?,
      failedAttempts: (json['failedAttempts'] as int?) ?? 0,
      lockedUntil: _parseDateTime(json['lockedUntil']),
      resetEmail: json['resetEmail'] as String?,
      isPasswordSet: (json['isPasswordSet'] as bool?) ?? false,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'masterPasswordHash': masterPasswordHash,
      'passwordSalt': passwordSalt,
      'failedAttempts': failedAttempts ?? 0,
      'lockedUntil': lockedUntil,
      'resetEmail': resetEmail,
      'isPasswordSet': isPasswordSet ?? false,
      'createdAt': createdAt ?? Timestamp.now(),
      'updatedAt': updatedAt ?? Timestamp.now(),
    };
  }

  bool get isLocked {
    if (lockedUntil == null) return false;
    return DateTime.now().isBefore(lockedUntil!);
  }

  Duration? get remainingLockTime {
    if (lockedUntil == null) return null;
    final remaining = lockedUntil!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }
}
