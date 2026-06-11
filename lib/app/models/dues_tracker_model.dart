

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DueType {
  static const String owe = 'owe';
  static const String take = 'take';
  static const List<String> values = [owe, take];

  static String label(String type) {
    switch (type) {
      case owe:
        return 'I Owe';
      case take:
        return 'They Owe Me';
      default:
        return 'Unknown';
    }
  }

  static String shortLabel(String type) {
    switch (type) {
      case owe:
        return 'OWE';
      case take:
        return 'TAKE';
      default:
        return 'N/A';
    }
  }

  static bool isOwe(String? type) => type == owe;
  static bool isTake(String? type) => type == take;
}

class DueStatus {
  static const String pending = 'PENDING';
  static const String partial = 'PARTIAL';
  static const String settled = 'SETTLED';
  static const List<String> values = [pending, partial, settled];

  static String label(String? status) {
    switch (status) {
      case pending:
        return 'Pending';
      case partial:
        return 'Partial';
      case settled:
        return 'Settled';
      default:
        return 'Pending';
    }
  }

  static bool isPending(String? status) => status == pending;
  static bool isPartial(String? status) => status == partial;
  static bool isSettled(String? status) => status == settled;
}

class DuesTrackerModel {
  String? id;
  String? ownerId;
  String? customerName;
  String? dueType;
  double? amount;
  String? paymentMethod;
  String? paymentMethodIcon;
  String? paymentMethodId; // ← NEW: Firestore doc ID of the payment method
  DateTime? giveDate;
  DateTime? oweDate;
  String? note;
  String? status;
  Timestamp? createdAt;
  Timestamp? updatedAt;

  DuesTrackerModel({
    this.id,
    this.ownerId,
    this.customerName,
    this.dueType = DueType.owe,
    this.amount,
    this.paymentMethod,
    this.paymentMethodIcon,
    this.paymentMethodId, // ← NEW
    this.giveDate,
    this.oweDate,
    this.note,
    this.status = DueStatus.pending,
    this.createdAt,
    this.updatedAt,
  });

  factory DuesTrackerModel.fromJson(Map<String, dynamic> json) {
    return DuesTrackerModel(
      id: json['id'] as String?,
      ownerId: json['ownerId'] as String?,
      customerName: json['customerName'] as String?,
      dueType: json['dueType'] as String? ?? DueType.owe,
      amount: _parseDouble(json['amount']),
      paymentMethod: json['paymentMethod'] as String?,
      paymentMethodIcon: json['paymentMethodIcon'] as String?,
      paymentMethodId: json['paymentMethodId'] as String?, // ← NEW
      giveDate: _parseDateTime(json['giveDate']),
      oweDate: _parseDateTime(json['oweDate']),
      note: json['note'] as String?,
      status: json['status'] as String? ?? DueStatus.pending,
      createdAt: json['createdAt'] as Timestamp?,
      updatedAt: json['updatedAt'] as Timestamp?,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'customerName': customerName,
      'dueType': dueType,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'paymentMethodIcon': paymentMethodIcon,
      'paymentMethodId': paymentMethodId, // ← NEW
      'giveDate': giveDate != null ? Timestamp.fromDate(giveDate!) : null,
      'oweDate': oweDate != null ? Timestamp.fromDate(oweDate!) : null,
      'note': note,
      'status': status,
      'createdAt': createdAt ?? Timestamp.now(),
      'updatedAt': Timestamp.now(),
    };
  }

  String get formattedAmount {
    if (amount == null) return '\u20B90.00';
    return '\u20B9${_formatNumber(amount!)}';
  }

  String get shortFormattedAmount {
    if (amount == null) return '\u20B90';
    final a = amount!;
    if (a >= 100000) {
      return '\u20B9${(a / 100000).toStringAsFixed(1)}L';
    } else if (a >= 1000) {
      return '\u20B9${(a / 1000).toStringAsFixed(1)}K';
    }
    return '\u20B9${a.toStringAsFixed(0)}';
  }

  static String _formatNumber(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];

    String formatted;
    if (intPart.length <= 3) {
      formatted = intPart;
    } else {
      final lastThree = intPart.substring(intPart.length - 3);
      final remaining = intPart.substring(0, intPart.length - 3);
      final buffer = StringBuffer();
      for (int i = 0; i < remaining.length; i++) {
        if (i > 0 && (remaining.length - i) % 2 == 0) {
          buffer.write(',');
        }
        buffer.write(remaining[i]);
      }
      formatted = '$buffer,$lastThree';
    }
    return '$formatted.$decPart';
  }

  String get formattedGiveDate {
    if (giveDate == null) return 'Not set';
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${giveDate!.day} ${months[giveDate!.month]} ${giveDate!.year}';
  }

  String get formattedOweDate {
    if (oweDate == null) return 'Not set';
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${oweDate!.day} ${months[oweDate!.month]} ${oweDate!.year}';
  }

  String get shortGiveDate {
    if (giveDate == null) return '\u2014';
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${giveDate!.day} ${months[giveDate!.month]}';
  }

  String get shortOweDate {
    if (oweDate == null) return '\u2014';
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${oweDate!.day} ${months[oweDate!.month]}';
  }

  int get daysUntilDue {
    if (oweDate == null) return 0;
    return oweDate!.difference(DateTime.now()).inDays;
  }

  bool get isOverdue {
    if (DueStatus.isSettled(status)) return false;
    if (oweDate == null) return false;
    return oweDate!.isBefore(DateTime.now());
  }

  int get urgencyLevel {
    if (DueStatus.isSettled(status)) return 0;
    if (oweDate == null) return 1;
    final days = daysUntilDue;
    if (days < 0) return 3;
    if (days <= 3) return 2;
    return 1;
  }

  String get dueTypeLabel => DueType.label(dueType ?? DueType.owe);
  String get dueTypeShortLabel => DueType.shortLabel(dueType ?? DueType.owe);
  String get statusLabel => DueStatus.label(status);

  Color get statusColor {
    switch (status) {
      case DueStatus.settled:
        return const Color(0xFF10B981);
      case DueStatus.partial:
        return const Color(0xFFF59E0B);
      case DueStatus.pending:
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  Color get statusBgColor => statusColor.withValues(alpha: 0.10);

  Color get dueTypeColor {
    switch (dueType) {
      case DueType.owe:
        return const Color(0xFFEF4444);
      case DueType.take:
        return const Color(0xFF10B981);
      default:
        return Colors.grey;
    }
  }

  Color get dueTypeBgColor => dueTypeColor.withValues(alpha: 0.10);

  Color get urgencyColor {
    switch (urgencyLevel) {
      case 3:
        return const Color(0xFFEF4444);
      case 2:
        return const Color(0xFFF59E0B);
      default:
        return Colors.transparent;
    }
  }

  bool get hasPaymentIcon =>
      paymentMethodIcon != null && paymentMethodIcon!.isNotEmpty;
}
