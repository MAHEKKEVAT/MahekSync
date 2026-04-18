// lib/app/models/device_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceModel {
  String? id;
  String? ownerId;
  String? deviceName;
  String? brandName;
  String? category;
  String? condition;
  double? price;
  String? storeName;
  String? description;
  DateTime? purchaseDate;
  DateTime? warrantyEndDate;
  String? paymentMethod;
  List<String>? deviceImageUrls;
  String? notes;
  Timestamp? createdAt;
  Timestamp? updatedAt;

  DeviceModel({
    this.id,
    this.ownerId,
    this.deviceName,
    this.brandName,
    this.category,
    this.condition,
    this.price,
    this.storeName,
    this.description,
    this.purchaseDate,
    this.warrantyEndDate,
    this.paymentMethod,
    this.deviceImageUrls,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  DeviceModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    ownerId = json['ownerId'];
    deviceName = json['deviceName'];
    brandName = json['brandName'];
    category = json['category'];
    condition = json['condition'];
    price = json['price']?.toDouble();
    storeName = json['storeName'];
    description = json['description'];
    purchaseDate = json['purchaseDate']?.toDate();
    warrantyEndDate = json['warrantyEndDate']?.toDate();
    paymentMethod = json['paymentMethod'];
    deviceImageUrls = json['deviceImageUrls'] != null
        ? List<String>.from(json['deviceImageUrls'])
        : [];
    notes = json['notes'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['ownerId'] = ownerId;
    data['deviceName'] = deviceName;
    data['brandName'] = brandName;
    data['category'] = category;
    data['condition'] = condition;
    data['price'] = price;
    data['storeName'] = storeName;
    data['description'] = description;
    data['purchaseDate'] = purchaseDate;
    data['warrantyEndDate'] = warrantyEndDate;
    data['paymentMethod'] = paymentMethod;
    data['deviceImageUrls'] = deviceImageUrls ?? [];
    data['notes'] = notes;
    data['createdAt'] = createdAt ?? Timestamp.now();
    data['updatedAt'] = Timestamp.now();
    return data;
  }

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

  String get primaryImageUrl => deviceImageUrls != null && deviceImageUrls!.isNotEmpty
      ? deviceImageUrls!.first
      : '';
}