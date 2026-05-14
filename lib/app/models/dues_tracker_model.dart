import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DuesTrackerModel {
  String? id;
  String? ownerId;
  String? customerName;       // Person name
  String? dueType;            // 'owe' (I owe someone) or 'take' (someone owes me)
  double? amount;
  String? paymentMethod;      // Payment method name from payment_methods collection
  String? paymentMethodIcon;  // Payment method icon URL from payment_methods collection
  DateTime? giveDate;         // Date when money was given
  DateTime? oweDate;          // Date when money is due/expected back
  String? note;
  String? status;             // 'PENDING', 'PARTIAL', 'SETTLED'
  Timestamp? createdAt;
  Timestamp? updatedAt;

  DuesTrackerModel({
    this.id,
    this.ownerId,
    this.customerName,
    this.dueType = 'owe',
    this.amount,
    this.paymentMethod,
    this.paymentMethodIcon,
    this.giveDate,
    this.oweDate,
    this.note,
    this.status = 'PENDING',
    this.createdAt,
    this.updatedAt,
  });

  factory DuesTrackerModel.fromJson(Map<String, dynamic> json) {
    return DuesTrackerModel(
      id: json['id'],
      ownerId: json['ownerId'],
      customerName: json['customerName'],
      dueType: json['dueType'] ?? 'owe',
      amount: json['amount']?.toDouble(),
      paymentMethod: json['paymentMethod'],
      paymentMethodIcon: json['paymentMethodIcon'],
      giveDate: json['giveDate'] != null
          ? (json['giveDate'] as Timestamp).toDate()
          : null,
      oweDate: json['oweDate'] != null
          ? (json['oweDate'] as Timestamp).toDate()
          : null,
      note: json['note'],
      status: json['status'] ?? 'PENDING',
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
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
      'giveDate': giveDate != null ? Timestamp.fromDate(giveDate!) : null,
      'oweDate': oweDate != null ? Timestamp.fromDate(oweDate!) : null,
      'note': note,
      'status': status,
      'createdAt': createdAt ?? Timestamp.now(),
      'updatedAt': Timestamp.now(),
    };
  }

  String get formattedAmount => '\u20B9${amount?.toStringAsFixed(2) ?? '0.00'}';

  String get formattedGiveDate => giveDate != null
      ? '${giveDate!.day}/${giveDate!.month}/${giveDate!.year}'
      : 'N/A';

  String get formattedOweDate => oweDate != null
      ? '${oweDate!.day}/${oweDate!.month}/${oweDate!.year}'
      : 'N/A';

  Color get statusColor {
    switch (status) {
      case 'SETTLED':
        return const Color(0xFF10B981);
      case 'PARTIAL':
        return const Color(0xFFF59E0B);
      case 'PENDING':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  Color get dueTypeColor {
    switch (dueType) {
      case 'owe':
        return const Color(0xFFEF4444); // Red - I owe
      case 'take':
        return const Color(0xFF10B981); // Green - They owe me
      default:
        return Colors.grey;
    }
  }
}
