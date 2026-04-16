import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart' hide MahekConstant;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import '../constant/collection_name.dart';
import '../constant/constants.dart';
import '../models/user_model.dart';


class FireStoreUtils {
  static final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  static final ImagePicker _picker = ImagePicker();

  static String? getCurrentUid() {
    if (FirebaseAuth.instance.currentUser == null) {
      return null;
    }
    return FirebaseAuth.instance.currentUser!.uid;
  }


  static Future<bool> ownerExistOrNot(String uid) async {
    try {
      var value = await fireStore.collection(CollectionName.owners).doc(uid).get();
      return value.exists;
    } catch (e) {
      developer.log("Failed to check user exist: $e");
      return false;
    }
  }

  static Future<bool> isLogin() async {
    try {
      if (FirebaseAuth.instance.currentUser != null) {
        return await ownerExistOrNot(FirebaseAuth.instance.currentUser!.uid);
      }
    } catch (e) {
      developer.log("Failed to check login status: $e");
    }
    return false;
  }


  static Future<UserModel?> getOwnerProfile(String uuid) async {
    try {
      var doc = await fireStore.collection(CollectionName.owners).doc(uuid).get();
      if (doc.exists) {
        UserModel user = UserModel.fromJson(doc.data()!);
        MahekConstant.ownerModel = user;
        return user;
      }
      return null;
    } catch (e) {
      developer.log("Failed to get user profile: $e");
    }
    return null;
  }

  // Track previous name/pic to detect changes
  static String? _prevUserName;
  static String? _prevUserPic;

  static Future<bool> updateOwner(UserModel userModel) async {
    try {
      await fireStore.collection(CollectionName.owners).doc(userModel.id).set(userModel.toJson());
      MahekConstant.ownerModel = userModel;
      return true;
    } catch (e) {
      developer.log("Failed to update user: $e");
      return false;
    }
  }

  static Future<void> clearFcmToken() async {
    try {
      final uid = getCurrentUid();
      if (uid != null) {
        await fireStore.collection(CollectionName.owners).doc(uid).update({'fcmToken': ''});
      }
    } catch (e) {
      developer.log("Failed to clear FCM token: $e");
    }
  }

  static Future<void> deleteOwnerAccount() async {
    try {
      final uid = getCurrentUid();
      if (uid == null) return;

      // 1. Clear FCM token first
      await clearFcmToken();

      // 3. Delete customer document from Firestore
      await fireStore.collection(CollectionName.owners).doc(uid).delete();

      // 5. Delete from Firebase Auth
      await FirebaseAuth.instance.currentUser!.delete();
    } on FirebaseAuthException catch (error) {
      developer.log("Firebase Auth Exception : $error");
      rethrow;
    } catch (error) {
      developer.log("Error deleting account: $error");
      rethrow;
    }
  }



  static Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      developer.log("Error picking image: $e");
      return null;
    }
  }
  //
  // static Future<String?> storeImageDB({
  //   required File imageFile,
  //   required String folderName,
  //   required String fileName,
  // }) async {
  //   try {
  //     final ref = _storage.ref().child('$folderName/$fileName');
  //     await ref.putFile(imageFile);
  //     final downloadUrl = await ref.getDownloadURL();
  //     return downloadUrl;
  //   } catch (e) {
  //     developer.log("Error uploading image: $e");
  //     return null;
  //   }
  // }



}