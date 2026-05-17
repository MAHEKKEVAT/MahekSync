import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:maheksync/app/utils/app_colors.dart';

class PersonalTaskModel {
  String? id;
  String? ownerId;
  String? title;
  String? description;
  String? priority;
  String? category;
  String? status;
  String? iconUrl;
  String? colorHex;
  List<String>? tags;
  bool? isPinned;
  bool? isCompleted;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? dueDate;
  String? notes;

  PersonalTaskModel({
    this.id,
    this.ownerId,
    this.title,
    this.description,
    this.priority = 'MEDIUM',
    this.category = 'GENERAL',
    this.status = 'PENDING',
    this.iconUrl,
    this.colorHex,
    this.tags,
    this.isPinned = false,
    this.isCompleted = false,
    this.createdAt,
    this.updatedAt,
    this.dueDate,
    this.notes,
  });

  factory PersonalTaskModel.fromJson(Map<String, dynamic> json) {
    return PersonalTaskModel(
      id: json['id'] as String?,
      ownerId: json['ownerId'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      priority: (json['priority'] as String?) ?? 'MEDIUM',
      category: (json['category'] as String?) ?? 'GENERAL',
      status: (json['status'] as String?) ?? 'PENDING',
      iconUrl: json['iconUrl'] as String?,
      colorHex: json['colorHex'] as String?,
      tags: json['tags'] != null ? List<String>.from(json['tags'] as List) : [],
      isPinned: (json['isPinned'] as bool?) ?? false,
      isCompleted: (json['isCompleted'] as bool?) ?? false,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      dueDate: _parseDateTime(json['dueDate']),
      notes: json['notes'] as String?,
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
      'title': title,
      'description': description,
      'priority': priority,
      'category': category,
      'status': status,
      'iconUrl': iconUrl,
      'colorHex': colorHex,
      'tags': tags ?? [],
      'isPinned': isPinned ?? false,
      'isCompleted': isCompleted ?? false,
      'createdAt': createdAt ?? Timestamp.now(),
      'updatedAt': updatedAt ?? Timestamp.now(),
      'dueDate': dueDate,
      'notes': notes,
    };
  }

  PersonalTaskModel copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? description,
    String? priority,
    String? category,
    String? status,
    String? iconUrl,
    String? colorHex,
    List<String>? tags,
    bool? isPinned,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueDate,
    String? notes,
  }) {
    return PersonalTaskModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      status: status ?? this.status,
      iconUrl: iconUrl ?? this.iconUrl,
      colorHex: colorHex ?? this.colorHex,
      tags: tags ?? this.tags,
      isPinned: isPinned ?? this.isPinned,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dueDate: dueDate ?? this.dueDate,
      notes: notes ?? this.notes,
    );
  }

  int get daysUntilDue => dueDate != null
      ? dueDate!.difference(DateTime.now()).inDays
      : 999;

  bool get isOverdue => dueDate != null && dueDate!.isBefore(DateTime.now()) && isCompleted != true;

  bool get isDueSoon => daysUntilDue <= 3 && daysUntilDue >= 0 && isCompleted != true;

  String get formattedDueDate => dueDate != null
      ? '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}'
      : 'No due date';

  String get formattedCreatedAt => createdAt != null
      ? '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}'
      : 'N/A';

  Color get priorityColor {
    switch (priority) {
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

  IconData get priorityIcon {
    switch (priority) {
      case 'HIGH':
        return SolarIconsBold.dangerTriangle;
      case 'MEDIUM':
        return SolarIconsOutline.flag;
      case 'LOW':
        return SolarIconsOutline.arrowDown;
      default:
        return SolarIconsOutline.flag;
    }
  }

  String get priorityLabel {
    switch (priority) {
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

  Color get statusColor {
    switch (status) {
      case 'COMPLETED':
        return AppThemeData.success400;
      case 'IN_PROGRESS':
        return AppThemeData.pending400;
      case 'PENDING':
        return AppThemeData.grey5;
      case 'CANCELLED':
        return AppThemeData.danger300;
      default:
        return AppThemeData.grey5;
    }
  }

  String get statusLabel {
    switch (status) {
      case 'COMPLETED':
        return 'Completed';
      case 'IN_PROGRESS':
        return 'In Progress';
      case 'PENDING':
        return 'Pending';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return 'Pending';
    }
  }
}
