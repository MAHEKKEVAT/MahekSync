// lib/app/models/purchase_model.dart
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PurchaseModel {
  String? id;
  String? ownerId;
  String? assetName;
  String? brand;
  String? category;
  String? condition;
  double? price;
  String? paymentMethod;
  String? storeLocation;
  String? size;
  String? description;
  DateTime? purchaseDate;
  DateTime? warrantyDate;
  List<String>? imageUrls;
  String? status; // DELIVERED, IN TRANSIT, PRE-ORDER
  int? units;
  Timestamp? createdAt;
  Timestamp? updatedAt;

  PurchaseModel({
    this.id,
    this.ownerId,
    this.assetName,
    this.brand,
    this.category,
    this.condition,
    this.price,
    this.paymentMethod,
    this.storeLocation,
    this.size,
    this.description,
    this.purchaseDate,
    this.warrantyDate,
    this.imageUrls,
    this.status = 'DELIVERED',
    this.units = 1,
    this.createdAt,
    this.updatedAt,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    return PurchaseModel(
      id: json['id'],
      ownerId: json['ownerId'],
      assetName: json['assetName'],
      brand: json['brand'],
      category: json['category'],
      condition: json['condition'],
      price: json['price']?.toDouble(),
      paymentMethod: json['paymentMethod'],
      storeLocation: json['storeLocation'],
      size: json['size'],
      description: json['description'],
      purchaseDate: json['purchaseDate']?.toDate(),
      warrantyDate: json['warrantyDate']?.toDate(),
      imageUrls: json['imageUrls'] != null
          ? List<String>.from(json['imageUrls'])
          : [],
      status: json['status'] ?? 'DELIVERED',
      units: json['units'] ?? 1,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'assetName': assetName,
      'brand': brand,
      'category': category,
      'condition': condition,
      'price': price,
      'paymentMethod': paymentMethod,
      'storeLocation': storeLocation,
      'size': size,
      'description': description,
      'purchaseDate': purchaseDate,
      'warrantyDate': warrantyDate,
      'imageUrls': imageUrls ?? [],
      'status': status,
      'units': units,
      'createdAt': createdAt ?? Timestamp.now(),
      'updatedAt': Timestamp.now(),
    };
  }

  String get formattedPrice => '\$${price?.toStringAsFixed(2) ?? '0.00'}';

  String get formattedPurchaseDate => purchaseDate != null
      ? '${purchaseDate!.month}/${purchaseDate!.day}/${purchaseDate!.year}'
      : 'N/A';

  String get formattedWarrantyDate => warrantyDate != null
      ? '${warrantyDate!.month}/${warrantyDate!.day}/${warrantyDate!.year}'
      : 'N/A';

  String get primaryImageUrl => imageUrls != null && imageUrls!.isNotEmpty
      ? imageUrls!.first
      : '';

  Color get statusColor {
    switch (status) {
      case 'DELIVERED':
        return const Color(0xFF10B981);
      case 'IN TRANSIT':
        return const Color(0xFFF59E0B);
      case 'PRE-ORDER':
        return const Color(0xFF3B82F6);
      default:
        return Colors.grey;
    }
  }
}