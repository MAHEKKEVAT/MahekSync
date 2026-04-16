// ignore_for_file: depend_on_referenced_packages

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? fullName;
  String? slug;
  String? id;
  String? email;
  String? loginType;
  String? userType;
  String? profilePic;
  String? fcmToken;
  String? countryCode;
  String? phoneNumber;
  bool? isActive;
  Timestamp? createdAt;
  List<String>? blockedUsers;
  bool? isVerified;
  String? gender;

  UserModel({
    this.fullName,
    this.slug,
    this.id,
    this.isActive,
    this.email,
    this.loginType,
    this.userType,
    this.profilePic,
    this.fcmToken,
    this.countryCode,
    this.phoneNumber,
    this.createdAt,
    this.blockedUsers,
    this.isVerified,
    this.gender,
  });



  UserModel.fromJson(Map<String, dynamic> json) {
    fullName = json['fullName'];
    slug = json['slug'];
    id = json['id'];
    email = json['email'];
    loginType = json['loginType'];
    userType = json['userType'];
    profilePic = json['profilePic'];
    fcmToken = json['fcmToken'];
    countryCode = json['countryCode'];
    phoneNumber = json['phoneNumber'];
    createdAt = json['createdAt'];
    isActive = json['isActive'];
    blockedUsers = json['blockedUsers'] != null ? List<String>.from(json['blockedUsers']) : [];
    isVerified = json['isVerified'] ?? false;
    gender = json['gender'];
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['fullName'] = fullName;
    data['slug'] = slug;
    data['id'] = id;
    data['email'] = email;
    data['loginType'] = loginType;
    data['userType'] = userType;
    data['profilePic'] = profilePic;
    data['fcmToken'] = fcmToken;
    data['countryCode'] = countryCode;
    data['phoneNumber'] = phoneNumber;
    data['createdAt'] = createdAt;
    data['isActive'] = isActive;
    data['blockedUsers'] = blockedUsers ?? [];
    data['isVerified'] = isVerified ?? false;
    data['gender'] = gender;

    return data;
  }
}

class VerificationData {
  String? adminNotes;
  Timestamp? submittedAt;
  Timestamp? reviewedAt;

  VerificationData({
    this.adminNotes,
    this.submittedAt,
    this.reviewedAt,
  });

  VerificationData.fromJson(Map<String, dynamic> json) {
    adminNotes = json['adminNotes'];
    submittedAt = json['submittedAt'];
    reviewedAt = json['reviewedAt'];

  }

  Map<String, dynamic> toJson() {
    return {
      'adminNotes': adminNotes,
      'submittedAt': submittedAt,
      'reviewedAt': reviewedAt,
    };
  }
}
