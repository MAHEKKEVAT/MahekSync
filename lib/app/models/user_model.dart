// ignore_for_file: depend_on_referenced_packages

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? fullName;
  String? id;
  String? email;
  String? loginType;
  String? userType;
  String? profilePic;
  String? fcmToken;
  String? phoneNumber;
  Timestamp? createdAt;
  String? gender;

  UserModel({
    this.fullName,
    this.id,
    this.email,
    this.loginType,
    this.userType,
    this.profilePic,
    this.fcmToken,
    this.phoneNumber,
    this.createdAt,
    this.gender,
  });



  UserModel.fromJson(Map<String, dynamic> json) {
    fullName = json['fullName'];
    id = json['id'];
    email = json['email'];
    loginType = json['loginType'];
    userType = json['userType'];
    profilePic = json['profilePic'];
    fcmToken = json['fcmToken'];
    phoneNumber = json['phoneNumber'];
    createdAt = json['createdAt'];
    gender = json['gender'];
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['fullName'] = fullName;
    data['id'] = id;
    data['email'] = email;
    data['loginType'] = loginType;
    data['userType'] = userType;
    data['profilePic'] = profilePic;
    data['fcmToken'] = fcmToken;
    data['phoneNumber'] = phoneNumber;
    data['createdAt'] = createdAt;
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
