import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:maheksync/app/utils/app_colors.dart';

class VaultModel {
  String? id;
  String? ownerId;
  String? title;
  String? email;
  String? username;
  String? password;
  String? website;
  String? phone;
  String? category;
  String? iconUrl;
  List<String>? tags;
  String? notes;
  bool? isFavorite;
  bool? isPinned;
  bool? isHidden;
  DateTime? createdAt;
  DateTime? updatedAt;

  VaultModel({
    this.id,
    this.ownerId,
    this.title,
    this.email,
    this.username,
    this.password,
    this.website,
    this.phone,
    this.category = 'PASSWORD',
    this.iconUrl,
    this.tags,
    this.notes,
    this.isFavorite = false,
    this.isPinned = false,
    this.isHidden = false,
    this.createdAt,
    this.updatedAt,
  });

  factory VaultModel.fromJson(Map<String, dynamic> json) {
    return VaultModel(
      id: json['id'] as String?,
      ownerId: json['ownerId'] as String?,
      title: json['title'] as String?,
      email: json['email'] as String?,
      username: json['username'] as String?,
      password: json['password'] as String?,
      website: json['website'] as String?,
      phone: json['phone'] as String?,
      category: (json['category'] as String?) ?? 'PASSWORD',
      iconUrl: json['iconUrl'] as String?,
      tags: json['tags'] != null ? List<String>.from(json['tags'] as List) : [],
      notes: json['notes'] as String?,
      isFavorite: (json['isFavorite'] as bool?) ?? false,
      isPinned: (json['isPinned'] as bool?) ?? false,
      isHidden: (json['isHidden'] as bool?) ?? false,
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
      'title': title,
      'email': email,
      'username': username,
      'password': password,
      'website': website,
      'phone': phone,
      'category': category,
      'iconUrl': iconUrl,
      'tags': tags ?? [],
      'notes': notes,
      'isFavorite': isFavorite ?? false,
      'isPinned': isPinned ?? false,
      'isHidden': isHidden ?? false,
      'createdAt': createdAt ?? Timestamp.now(),
      'updatedAt': updatedAt ?? Timestamp.now(),
    };
  }

  VaultModel copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? email,
    String? username,
    String? password,
    String? website,
    String? phone,
    String? category,
    String? iconUrl,
    List<String>? tags,
    String? notes,
    bool? isFavorite,
    bool? isPinned,
    bool? isHidden,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VaultModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      email: email ?? this.email,
      username: username ?? this.username,
      password: password ?? this.password,
      website: website ?? this.website,
      phone: phone ?? this.phone,
      category: category ?? this.category,
      iconUrl: iconUrl ?? this.iconUrl,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      isFavorite: isFavorite ?? this.isFavorite,
      isPinned: isPinned ?? this.isPinned,
      isHidden: isHidden ?? this.isHidden,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get formattedCreatedAt => createdAt != null
      ? '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}'
      : 'N/A';

  String get formattedUpdatedAt => updatedAt != null
      ? '${updatedAt!.day}/${updatedAt!.month}/${updatedAt!.year}'
      : 'N/A';

  Color get categoryColor {
    switch (category) {
      case 'PASSWORD':
        return AppThemeData.primary50;
      case 'API_KEY':
        return AppThemeData.pending400;
      case 'WIFI':
        return const Color(0xFF6C63FF);
      case 'BANK':
        return AppThemeData.success400;
      case 'EMAIL':
        return AppThemeData.danger300;
      case 'SUBSCRIPTION':
        return const Color(0xFFFF9800);
      case 'LICENSE':
        return const Color(0xFF00BCD4);
      case 'NOTE':
        return AppThemeData.grey5;
      case 'VEHICLE':
        return const Color(0xFF795548);
      case 'SERVER':
        return const Color(0xFF607D8B);
      case 'DEVICE':
        return const Color(0xFFE91E63);
      default:
        return AppThemeData.grey5;
    }
  }

  IconData get categoryIcon {
    switch (category) {
      case 'PASSWORD':
        return SolarIconsOutline.lockKeyhole;
      case 'API_KEY':
        return SolarIconsOutline.key;
      case 'WIFI':
        return SolarIconsOutline.lock;
      case 'BANK':
        return SolarIconsOutline.card;
      case 'EMAIL':
        return SolarIconsOutline.letter;
      case 'SUBSCRIPTION':
        return SolarIconsOutline.star;
      case 'LICENSE':
        return SolarIconsOutline.document;
      case 'NOTE':
        return SolarIconsOutline.notes;
      case 'VEHICLE':
        return SolarIconsOutline.bus;
      case 'SERVER':
        return SolarIconsOutline.server;
      case 'DEVICE':
        return SolarIconsOutline.smartphone;
      default:
        return SolarIconsOutline.lockKeyhole;
    }
  }

  String get categoryLabel {
    switch (category) {
      case 'PASSWORD':
        return 'Password';
      case 'API_KEY':
        return 'API Key';
      case 'WIFI':
        return 'WiFi';
      case 'BANK':
        return 'Bank';
      case 'EMAIL':
        return 'Email';
      case 'SUBSCRIPTION':
        return 'Subscription';
      case 'LICENSE':
        return 'License';
      case 'NOTE':
        return 'Note';
      case 'VEHICLE':
        return 'Vehicle';
      case 'SERVER':
        return 'Server';
      case 'DEVICE':
        return 'Device';
      default:
        return 'Other';
    }
  }
}
