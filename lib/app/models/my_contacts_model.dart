import 'package:cloud_firestore/cloud_firestore.dart';

class MyContactsModel {
  final String id;
  final String ownerId;
  final String firstName;
  final String lastName;
  final String mobileNumber;
  final String profileImage;
  final List<String> searchKeywords;
  final DateTime createdAt;
  final DateTime updatedAt;

  MyContactsModel({
    required this.id,
    required this.ownerId,
    required this.firstName,
    required this.lastName,
    required this.mobileNumber,
    this.profileImage = '',
    this.searchKeywords = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  String get formattedName => '$firstName $lastName'.trim();

  bool get hasProfile => profileImage.isNotEmpty;

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$f$l';
  }

  static List<String> generateSearchKeywords(String firstName, String lastName, String mobileNumber) {
    final keywords = <String>{};
    final fullName = '$firstName $lastName'.trim().toLowerCase();
    for (int i = 1; i <= fullName.length; i++) {
      keywords.add(fullName.substring(0, i));
    }
    final reverseName = '$lastName $firstName'.trim().toLowerCase();
    for (int i = 1; i <= reverseName.length; i++) {
      keywords.add(reverseName.substring(0, i));
    }
    final fn = firstName.toLowerCase();
    for (int i = 1; i <= fn.length; i++) {
      keywords.add(fn.substring(0, i));
    }
    final ln = lastName.toLowerCase();
    for (int i = 1; i <= ln.length; i++) {
      keywords.add(ln.substring(0, i));
    }
    final cleanMobile = mobileNumber.replaceAll(RegExp(r'[^0-9]'), '');
    for (int i = 1; i <= cleanMobile.length; i++) {
      keywords.add(cleanMobile.substring(0, i));
    }
    return keywords.toList();
  }

  factory MyContactsModel.fromJson(Map<String, dynamic> json) {
    return MyContactsModel(
      id: json['id'] as String? ?? '',
      ownerId: json['ownerId'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      mobileNumber: json['mobileNumber'] as String? ?? '',
      profileImage: json['profileImage'] as String? ?? '',
      searchKeywords: List<String>.from(json['searchKeywords'] as List? ?? []),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'firstName': firstName,
      'lastName': lastName,
      'mobileNumber': mobileNumber,
      'profileImage': profileImage,
      'searchKeywords': searchKeywords,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'mobileNumber': mobileNumber,
      'profileImage': profileImage,
      'searchKeywords': searchKeywords,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  MyContactsModel copyWith({
    String? id,
    String? ownerId,
    String? firstName,
    String? lastName,
    String? mobileNumber,
    String? profileImage,
    List<String>? searchKeywords,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MyContactsModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      profileImage: profileImage ?? this.profileImage,
      searchKeywords: searchKeywords ?? this.searchKeywords,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
