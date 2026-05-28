// lib/app/utils/device_firestore_utils.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/models/device_model.dart';
import 'package:maheksync/app/services/imagekit_api.dart';

class DeviceFirestoreUtils {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'devices';

  // Add new device
  static Future<bool> addDevice(DeviceModel device) async {
    try {
      final deviceId = MahekConstant.getUuid();
      device.id = deviceId;
      device.createdAt = Timestamp.now();
      device.updatedAt = Timestamp.now();

      await _firestore
          .collection(_collectionName)
          .doc(deviceId)
          .set(device.toJson());
      return true;
    } catch (e) {
      print('Error adding device: $e');
      return false;
    }
  }

  // Update device
  static Future<bool> updateDevice(DeviceModel device) async {
    try {
      device.updatedAt = Timestamp.now();
      await _firestore
          .collection(_collectionName)
          .doc(device.id)
          .update(device.toJson());
      return true;
    } catch (e) {
      print('Error updating device: $e');
      return false;
    }
  }

  // Delete device
  static Future<bool> deleteDevice(String deviceId) async {
    try {
      await _firestore.collection(_collectionName).doc(deviceId).delete();
      return true;
    } catch (e) {
      print('Error deleting device: $e');
      return false;
    }
  }

  // Get user devices (stream)
  static Stream<List<DeviceModel>> getUserDevices(String ownerId) {
    return _firestore
        .collection(_collectionName)
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) {
      final devices = snapshot.docs
          .map((doc) => DeviceModel.fromJson(doc.data()))
          .toList();

      devices.sort((a, b) {
        final aTime = a.createdAt?.toDate() ?? DateTime(2000);
        final bTime = b.createdAt?.toDate() ?? DateTime(2000);
        return bTime.compareTo(aTime);
      });

      return devices;
    });
  }

  // Get single device
  static Future<DeviceModel?> getDevice(String deviceId) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(deviceId).get();
      if (doc.exists) {
        return DeviceModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Store image and return URL
  static Future<String?> storeDeviceImage({
    required dynamic imageFile, // Can be XFile or Uint8List
    required String ownerId,
  }) async {
    final folderName = 'devices/$ownerId';

    if (imageFile is XFile) {
      return await ImageKitAPI.uploadImage(
        imageFile: imageFile,
        folderName: folderName,
      );
    }
    return null;
  }

  // Store multiple images
  static Future<List<String>> storeMultipleDeviceImages({
    required List<XFile> imageFiles,
    required String ownerId,
  }) async {
    final folderName = 'devices/$ownerId';
    return await ImageKitAPI.uploadMultipleImages(
      imageFiles: imageFiles,
      folderName: folderName,
    );
  }
}