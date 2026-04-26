// lib/app/models/reminder_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maheksync/app/utils/app_colors.dart';

class ReminderModel {
  String? id;
  String? ownerId;
  String? name;
  String? description;
  String? importance; // HIGH, MEDIUM, LOW
  String? iconUrl;
  bool? isActive;
  DateTime? createdDate;
  DateTime? expiryDate;
  Timestamp? createdAt;

  ReminderModel({
    this.id,
    this.ownerId,
    this.name,
    this.description,
    this.importance = 'MEDIUM',
    this.iconUrl,
    this.isActive = true,
    this.createdDate,
    this.expiryDate,
    this.createdAt,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'],
      ownerId: json['ownerId'],
      name: json['name'],
      description: json['description'],
      importance: json['importance'] ?? 'MEDIUM',
      iconUrl: json['iconUrl'],
      isActive: json['isActive'] ?? true,
      createdDate: json['createdDate']?.toDate(),
      expiryDate: json['expiryDate']?.toDate(),
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'description': description,
      'importance': importance,
      'iconUrl': iconUrl,
      'isActive': isActive,
      'createdDate': createdDate,
      'expiryDate': expiryDate,
      'createdAt': createdAt ?? Timestamp.now(),
    };
  }

  String get formattedCreatedDate => createdDate != null
      ? '${createdDate!.day}/${createdDate!.month}/${createdDate!.year}'
      : 'N/A';

  String get formattedExpiryDate => expiryDate != null
      ? '${expiryDate!.day}/${expiryDate!.month}/${expiryDate!.year}'
      : 'N/A';

  int get daysRemaining => expiryDate != null
      ? expiryDate!.difference(DateTime.now()).inDays
      : 0;

  bool get isExpired => expiryDate != null && expiryDate!.isBefore(DateTime.now());
  bool get isExpiringSoon => daysRemaining <= 3 && daysRemaining >= 0 && isActive == true;

  Color get importanceColor {
    switch (importance) {
      case 'HIGH':
        return AppThemeData.danger300;
      case 'MEDIUM':
        return AppThemeData.pending400;
      case 'LOW':
        return AppThemeData.success400;
      default:
        return AppThemeData.grey5;
    }
  }

  IconData get importanceIcon {
    switch (importance) {
      case 'HIGH':
        return Icons.priority_high_rounded;
      case 'MEDIUM':
        return Icons.flag_rounded;
      case 'LOW':
        return Icons.low_priority_rounded;
      default:
        return Icons.flag_outlined;
    }
  }

  String get importanceLabel {
    switch (importance) {
      case 'HIGH':
        return 'High';
      case 'MEDIUM':
        return 'Medium';
      case 'LOW':
        return 'Low';
      default:
        return 'Medium';
    }
  }
}