import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart' hide Constant;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:owner/app/constant/collection_name.dart';
import 'package:owner/app/constant/constants.dart';
import 'package:owner/app/models/currency_model.dart';
import 'package:owner/app/models/language_model.dart';
import 'package:owner/app/models/parking_model.dart';

import '../models/notification_model.dart';
import '../models/user_model.dart';


class FireStoreUtils {
  static final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  static final ImagePicker _picker = ImagePicker();
  static final FirebaseStorage _storage = FirebaseStorage.instance;

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


  Future<CurrencyModel?> getCurrency() async {
    try {
      var value = await fireStore.collection(CollectionName.currencies).where("active", isEqualTo: true).limit(1).get();

      if (value.docs.isNotEmpty) {
        return CurrencyModel.fromJson(value.docs.first.data());
      }
    } catch (e) {
      developer.log("Error fetching currency: $e");
    }
    return null;
  }

  Future<List<CurrencyModel>> getAllCurrencies() async {
    List<CurrencyModel> list = [];
    try {
      var snap = await fireStore.collection(CollectionName.currencies).where("active", isEqualTo: true).get();
      for (var doc in snap.docs) {
        list.add(CurrencyModel.fromJson(doc.data()));
      }
    } catch (e) {
      developer.log("Error fetching currencies: $e");
    }
    return list;
  }


  static Future<List<LanguageModel>> getLanguage() async {
    List<LanguageModel> languageModelList = [];
    try {
      QuerySnapshot snap = await fireStore.collection(CollectionName.languages).where("active", isEqualTo: true).get();

      for (var document in snap.docs) {
        Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;
        if (data != null) {
          languageModelList.add(LanguageModel.fromJson(data));
        } else {
          developer.log("getLanguage: data is null for a document");
        }
      }
    } catch (e) {
      developer.log("Error fetching languages: $e");
    }
    return languageModelList;
  }

  static Future<UserModel?> getOwnerProfile(String uuid) async {
    try {
      var doc = await fireStore.collection(CollectionName.owners).doc(uuid).get();
      if (doc.exists) {
        UserModel user = UserModel.fromJson(doc.data()!);
        Constant.ownerModel = user;
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
      Constant.ownerModel = userModel;
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



  static Future<bool> setNotification(NotificationModel notificationModel) async {
    try {
      await fireStore.collection(CollectionName.notification).doc(notificationModel.id).set(notificationModel.toJson(), SetOptions(merge: false));
      return true;
    } catch (e) {
      developer.log("Failed to update user notification: $e");
      return false;
    }
  }

  /// Stream of notifications for the current user, ordered by newest first
  static Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    return fireStore
        .collection(CollectionName.notification)
        .where('receiverId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots(includeMetadataChanges: true)
        .map((snap) => snap.docs.map((doc) => NotificationModel.fromJson(doc.data())).toList());
  }

  /// Mark a notification as read
  static Future<void> markNotificationRead(String notificationId) async {
    try {
      await fireStore.collection(CollectionName.notification).doc(notificationId).update({'isRead': true});
    } catch (e) {
      developer.log("markNotificationRead Error: $e");
    }
  }

  /// Mark all notifications as read for a user
  static Future<void> markAllNotificationsRead(String userId) async {
    try {
      final snap = await fireStore.collection(CollectionName.notification).where('receiverId', isEqualTo: userId).where('isRead', isEqualTo: false).get();
      final batch = fireStore.batch();
      for (final doc in snap.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      developer.log("markAllNotificationsRead Error: $e");
    }
  }

  /// Delete a notification
  static Future<void> deleteNotification(String notificationId) async {
    try {
      await fireStore.collection(CollectionName.notification).doc(notificationId).delete();
    } catch (e) {
      developer.log("deleteNotification Error: $e");
    }
  }

  static Stream<List<ParkingModel>> getParkingStream({String? ownerId}) {
    Query<Map<String, dynamic>> query = fireStore.collection(CollectionName.parking);
    if (ownerId != null && ownerId.isNotEmpty) {
      query = query.where('ownerId', isEqualTo: ownerId);
    }

    return query.snapshots(includeMetadataChanges: true).map((snapshot) {
      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            if (data['id'] == null || (data['id'] as Object).toString().isEmpty) {
              data['id'] = doc.id;
            }
            return ParkingModel.fromJson(data);
          })
          .toList()
        ..sort((a, b) {
          final aTime = a.createdAt?.millisecondsSinceEpoch ?? 0;
          final bTime = b.createdAt?.millisecondsSinceEpoch ?? 0;
          return bTime.compareTo(aTime);
        });
    });
  }

// fire_store_utils.dart (update the addParking method)
  static Future<void> addParking(ParkingModel parking) async {
    try {
      final docRef = parking.id.isEmpty
          ? fireStore.collection(CollectionName.parking).doc()
          : fireStore.collection(CollectionName.parking).doc(parking.id);

      final now = DateTime.now();
      final payload = parking.copyWith(
          id: docRef.id,
          createdAt: parking.createdAt ?? now,
          updatedAt: now
      ).toJson();

      await docRef.set(payload, SetOptions(merge: true));
    } catch (e) {
      developer.log("addParking Error: $e");
      rethrow;
    }
  }

  static Future<void> updateParkingStatus({required String parkingId, required bool isOpen}) async {
    try {
      await fireStore.collection(CollectionName.parking).doc(parkingId).set({
        'isOpen': isOpen,
        'updatedAt': Timestamp.fromDate(DateTime.now())
      }, SetOptions(merge: true));
    } catch (e) {
      developer.log("updateParkingStatus Error: $e");
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

  static Future<String?> storeImageDB({
    required File imageFile,
    required String folderName,
    required String fileName,
  }) async {
    try {
      final ref = _storage.ref().child('$folderName/$fileName');
      await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      developer.log("Error uploading image: $e");
      return null;
    }
  }



}