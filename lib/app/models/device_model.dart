// lib/app/models/device_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceModel {
  String? id;
  String? ownerId;
  String? deviceName;
  String? category;
  String? condition;
  double? price;
  String? storeName;
  DateTime? purchaseDate;
  DateTime? warrantyEndDate;
  String? paymentMethod;
  String? deviceImageUrl;
  String? notes;
  Timestamp? createdAt;
  Timestamp? updatedAt;

  DeviceModel({
    this.id,
    this.ownerId,
    this.deviceName,
    this.category,
    this.condition,
    this.price,
    this.storeName,
    this.purchaseDate,
    this.warrantyEndDate,
    this.paymentMethod,
    this.deviceImageUrl,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  DeviceModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    ownerId = json['ownerId'];
    deviceName = json['deviceName'];
    category = json['category'];
    condition = json['condition'];
    price = json['price']?.toDouble();
    storeName = json['storeName'];
    purchaseDate = json['purchaseDate']?.toDate();
    warrantyEndDate = json['warrantyEndDate']?.toDate();
    paymentMethod = json['paymentMethod'];
    deviceImageUrl = json['deviceImageUrl'];
    notes = json['notes'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['ownerId'] = ownerId;
    data['deviceName'] = deviceName;
    data['category'] = category;
    data['condition'] = condition;
    data['price'] = price;
    data['storeName'] = storeName;
    data['purchaseDate'] = purchaseDate;
    data['warrantyEndDate'] = warrantyEndDate;
    data['paymentMethod'] = paymentMethod;
    data['deviceImageUrl'] = deviceImageUrl;
    data['notes'] = notes;
    data['createdAt'] = createdAt ?? Timestamp.now();
    data['updatedAt'] = Timestamp.now();
    return data;
  }

  // Helper getters
  String get formattedPrice => '\$${price?.toStringAsFixed(2) ?? '0.00'}';

  String get formattedPurchaseDate => purchaseDate != null
      ? '${purchaseDate!.month}/${purchaseDate!.day}/${purchaseDate!.year}'
      : 'N/A';

  String get formattedWarrantyEnd => warrantyEndDate != null
      ? '${warrantyEndDate!.month}/${warrantyEndDate!.day}/${warrantyEndDate!.year}'
      : 'N/A';

  bool get isWarrantyExpired => warrantyEndDate != null
      ? warrantyEndDate!.isBefore(DateTime.now())
      : false;

  int get daysUntilWarrantyExpires => warrantyEndDate != null
      ? warrantyEndDate!.difference(DateTime.now()).inDays
      : 0;
}