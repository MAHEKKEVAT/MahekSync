// lib/app/models/category_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  String? id;
  String? name;
  String? description;
  String? iconUrl;
  int? itemCount;
  DateTime? createdAt;
  DateTime? updatedAt;

  CategoryModel({
    this.id,
    this.name,
    this.description,
    this.iconUrl,
    this.itemCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      iconUrl: json['iconUrl'],
      itemCount: json['itemCount'] ?? 0,
      createdAt: json['createdAt']?.toDate(),
      updatedAt: json['updatedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'itemCount': itemCount ?? 0,
      'createdAt': createdAt ?? Timestamp.now(),
      'updatedAt': Timestamp.now(),
    };
  }

  String get formattedDate => createdAt != null
      ? '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}'
      : 'N/A';

  String get shortDescription => description != null && description!.length > 60
      ? '${description!.substring(0, 60)}...'
      : description ?? '';
}