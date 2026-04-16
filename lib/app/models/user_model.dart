// ignore_for_file: depend_on_referenced_packages

import 'package:cloud_firestore/cloud_firestore.dart';

import 'add_address_model.dart';

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
  List<AddAddressModel>? addAddresses;
  List<dynamic>? searchNameKeywords;
  List<dynamic>? searchEmailKeywords;
  List<String>? blockedUsers;
  bool? isVerified;
  String? verificationStatus;
  VerificationData? verificationData;
  String? referralCode;
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
    this.addAddresses,
    this.searchNameKeywords,
    this.searchEmailKeywords,
    this.blockedUsers,
    this.isVerified,
    this.verificationStatus,
    this.verificationData,
    this.referralCode,
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
    searchNameKeywords = json['searchNameKeywords'] ?? [];
    searchEmailKeywords = json['searchEmailKeywords'] ?? [];
    blockedUsers = json['blockedUsers'] != null ? List<String>.from(json['blockedUsers']) : [];
    isVerified = json['isVerified'] ?? false;
    verificationStatus = json['verificationStatus'] ?? 'unverified';
    if (json['verificationData'] != null && json['verificationData'] is Map) {
      verificationData = VerificationData.fromJson(Map<String, dynamic>.from(json['verificationData']));
    }
    referralCode = json['referralCode'];
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
    data['searchNameKeywords'] = searchNameKeywords;
    data['searchEmailKeywords'] = searchEmailKeywords;
    data['blockedUsers'] = blockedUsers ?? [];
    data['isVerified'] = isVerified ?? false;
    data['verificationStatus'] = verificationStatus ?? 'unverified';
    data['verificationData'] = verificationData?.toJson();
    data['referralCode'] = referralCode;
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
