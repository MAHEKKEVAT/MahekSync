// lib/app/models/payment_method_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentMethodModel {
  String? id;
  String? pIcon;
  String? pName;
  DateTime? createdAt;
  DateTime? updatedAt;

  PaymentMethodModel({
    this.id,
    this.pIcon,
    this.pName,
    this.createdAt,
    this.updatedAt,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'],
      pIcon: json['p_icon'],
      pName: json['p_name'],
      createdAt: json['createdAt']?.toDate(),
      updatedAt: json['updatedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'p_icon': pIcon,
      'p_name': pName,
      'createdAt': createdAt ?? Timestamp.now(),
      'updatedAt': Timestamp.now(),
    };
  }

  String get formattedDate => createdAt != null
      ? '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}'
      : 'N/A';
}