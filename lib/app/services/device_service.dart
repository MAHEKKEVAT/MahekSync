// lib/app/services/device_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maheksync/app/models/device_model.dart';
import 'package:maheksync/app/utils/fire_store_utils.dart';
import 'package:uuid/uuid.dart';

class DeviceService {
  static const String collectionName = 'devices';

  static final FirebaseFirestore _firestore = FireStoreUtils.fireStore;

  static Future<bool> addDevice(DeviceModel device) async {
    try {
      final deviceId = const Uuid().v4();
      device.id = deviceId;
      device.createdAt = Timestamp.now();
      device.updatedAt = Timestamp.now();

      await _firestore
          .collection(collectionName)
          .doc(deviceId)
          .set(device.toJson());
      return true;
    } catch (e) {
      print('Error adding device: $e');
      return false;
    }
  }

  static Future<bool> updateDevice(DeviceModel device) async {
    try {
      device.updatedAt = Timestamp.now();
      await _firestore
          .collection(collectionName)
          .doc(device.id)
          .update(device.toJson());
      return true;
    } catch (e) {
      print('Error updating device: $e');
      return false;
    }
  }

  static Future<bool> deleteDevice(String deviceId) async {
    try {
      await _firestore.collection(collectionName).doc(deviceId).delete();
      return true;
    } catch (e) {
      print('Error deleting device: $e');
      return false;
    }
  }

  // FIXED: Client-side sorting - no index required
  static Stream<List<DeviceModel>> getUserDevices(String ownerId) {
    return _firestore
        .collection(collectionName)
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) {
      final devices = snapshot.docs
          .map((doc) => DeviceModel.fromJson(doc.data()))
          .toList();

      // Sort by createdAt descending (newest first) on client side
      devices.sort((a, b) {
        final aTime = a.createdAt?.toDate() ?? DateTime(2000);
        final bTime = b.createdAt?.toDate() ?? DateTime(2000);
        return bTime.compareTo(aTime);
      });

      return devices;
    });
  }

  static Future<DeviceModel?> getDevice(String deviceId) async {
    try {
      final doc = await _firestore.collection(collectionName).doc(deviceId).get();
      if (doc.exists) {
        return DeviceModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}