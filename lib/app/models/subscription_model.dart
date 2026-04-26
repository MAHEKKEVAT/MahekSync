// lib/app/models/subscription_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maheksync/app/utils/app_colors.dart';

class SubscriptionModel {
  String? id;
  String? ownerId;
  String? name;
  String? description;
  double? price;
  String? billingCycle;
  DateTime? startDate;
  DateTime? expiryDate;
  String? status;
  String? category;
  String? iconUrl;
  List<String>? imageUrls;
  String? notes;
  bool? autoRenew;
  int? reminderDays;
  String? paymentMethod; // Added payment method field
  Timestamp? createdAt;
  Timestamp? updatedAt;

  SubscriptionModel({
    this.id,
    this.ownerId,
    this.name,
    this.description,
    this.price,
    this.billingCycle = 'MONTHLY',
    this.startDate,
    this.expiryDate,
    this.status = 'ACTIVE',
    this.category = 'ENTERTAINMENT',
    this.iconUrl,
    this.imageUrls,
    this.notes,
    this.autoRenew = false,
    this.reminderDays = 3,
    this.paymentMethod,
    this.createdAt,
    this.updatedAt,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'],
      ownerId: json['ownerId'],
      name: json['name'],
      description: json['description'],
      price: json['price']?.toDouble(),
      billingCycle: json['billingCycle'] ?? 'MONTHLY',
      startDate: json['startDate']?.toDate(),
      expiryDate: json['expiryDate']?.toDate(),
      status: json['status'] ?? 'ACTIVE',
      category: json['category'] ?? 'ENTERTAINMENT',
      iconUrl: json['iconUrl'],
      imageUrls: json['imageUrls'] != null ? List<String>.from(json['imageUrls']) : [],
      notes: json['notes'],
      autoRenew: json['autoRenew'] ?? false,
      reminderDays: json['reminderDays'] ?? 3,
      paymentMethod: json['paymentMethod'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'description': description,
      'price': price,
      'billingCycle': billingCycle,
      'startDate': startDate,
      'expiryDate': expiryDate,
      'status': status,
      'category': category,
      'iconUrl': iconUrl,
      'imageUrls': imageUrls ?? [],
      'notes': notes,
      'autoRenew': autoRenew,
      'reminderDays': reminderDays,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt ?? Timestamp.now(),
      'updatedAt': Timestamp.now(),
    };
  }

  // ─── Formatting ───
  String get formattedPrice => '₹${price?.toStringAsFixed(0) ?? '0'}';

  String get formattedStartDate => startDate != null
      ? '${startDate!.day}/${startDate!.month}/${startDate!.year}'
      : 'N/A';

  String get formattedExpiryDate => expiryDate != null
      ? '${expiryDate!.day}/${expiryDate!.month}/${expiryDate!.year}'
      : 'N/A';

  String get paymentMethodDisplay => paymentMethod?.isNotEmpty == true ? paymentMethod! : 'Not specified';

  // ─── Date Calculations ───
  int get daysRemaining => expiryDate != null
      ? expiryDate!.difference(DateTime.now()).inDays
      : 0;

  double get remainingPercentage {
    if (expiryDate == null || startDate == null) return 1.0;
    final total = expiryDate!.difference(startDate!).inDays;
    if (total <= 0) return 0.0;
    return (daysRemaining / total).clamp(0.0, 1.0);
  }

  // ─── Smart Flags ───
  bool get isOverdue => status == 'ACTIVE' && expiryDate != null && expiryDate!.isBefore(DateTime.now());

  bool get isExpiringCritical => daysRemaining <= 3 && daysRemaining >= 0 && status == 'ACTIVE';

  bool get isExpiringSoon => daysRemaining <= 7 && daysRemaining > 3 && status == 'ACTIVE';

  bool get isActive => status == 'ACTIVE';

  bool get isExpired => status == 'EXPIRED';

  bool get isCancelled => status == 'CANCELLED';

  bool get isPending => status == 'PENDING';

  // ─── Price Calculations ───
  double get monthlyPrice {
    if (price == null) return 0;
    switch (billingCycle) {
      case 'QUARTERLY':
        return price! / 3;
      case 'YEARLY':
        return price! / 12;
      default:
        return price!;
    }
  }

  double get yearlyPrice {
    if (price == null) return 0;
    switch (billingCycle) {
      case 'MONTHLY':
        return price! * 12;
      case 'QUARTERLY':
        return price! * 4;
      case 'YEARLY':
        return price!;
      default:
        return price! * 12;
    }
  }

  // ─── Status Color ───
  Color get statusColor {
    switch (status) {
      case 'ACTIVE':
        return isExpiringCritical
            ? AppThemeData.danger300
            : isExpiringSoon
            ? AppThemeData.pending400
            : AppThemeData.success400;
      case 'EXPIRED':
        return AppThemeData.danger300;
      case 'CANCELLED':
        return AppThemeData.grey5;
      case 'PENDING':
        return AppThemeData.pending300;
      default:
        return AppThemeData.grey5;
    }
  }

  // ─── Status Icon ───
  IconData get statusIcon {
    switch (status) {
      case 'ACTIVE':
        return Icons.check_circle_rounded;
      case 'EXPIRED':
        return Icons.cancel_rounded;
      case 'CANCELLED':
        return Icons.remove_circle_rounded;
      case 'PENDING':
        return Icons.pending_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  // ─── Billing Cycle Display ───
  String get billingCycleDisplay {
    switch (billingCycle) {
      case 'MONTHLY':
        return 'Monthly';
      case 'QUARTERLY':
        return 'Quarterly';
      case 'YEARLY':
        return 'Yearly';
      default:
        return billingCycle ?? 'Monthly';
    }
  }

  // ─── Primary Image ───
  String get primaryImageUrl => imageUrls != null && imageUrls!.isNotEmpty
      ? imageUrls!.first
      : '';

  bool get hasImages => imageUrls != null && imageUrls!.isNotEmpty;

  bool get hasIcon => iconUrl != null && iconUrl!.isNotEmpty;

  // ─── Copy With ───
  SubscriptionModel copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? description,
    double? price,
    String? billingCycle,
    DateTime? startDate,
    DateTime? expiryDate,
    String? status,
    String? category,
    String? iconUrl,
    List<String>? imageUrls,
    String? notes,
    bool? autoRenew,
    int? reminderDays,
    String? paymentMethod,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      billingCycle: billingCycle ?? this.billingCycle,
      startDate: startDate ?? this.startDate,
      expiryDate: expiryDate ?? this.expiryDate,
      status: status ?? this.status,
      category: category ?? this.category,
      iconUrl: iconUrl ?? this.iconUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      notes: notes ?? this.notes,
      autoRenew: autoRenew ?? this.autoRenew,
      reminderDays: reminderDays ?? this.reminderDays,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}