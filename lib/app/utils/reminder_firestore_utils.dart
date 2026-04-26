// lib/app/utils/reminder_firestore_utils.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/models/reminder_model.dart';

class ReminderFirestoreUtils {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'reminders';

  static Future<bool> addReminder(ReminderModel reminder) async {
    try {
      final id = MahekConstant.getUuid();
      reminder.id = id;
      reminder.createdAt = Timestamp.now();
      await _firestore.collection(_collectionName).doc(id).set(reminder.toJson());
      return true;
    } catch (e) {
      print('Error adding reminder: $e');
      return false;
    }
  }

  static Future<bool> updateReminder(ReminderModel reminder) async {
    try {
      await _firestore.collection(_collectionName).doc(reminder.id).update(reminder.toJson());
      return true;
    } catch (e) {
      print('Error updating reminder: $e');
      return false;
    }
  }

  static Future<bool> deleteReminder(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting reminder: $e');
      return false;
    }
  }

  static Future<bool> toggleReminder(ReminderModel reminder) async {
    try {
      reminder.isActive = !(reminder.isActive ?? true);
      return await updateReminder(reminder);
    } catch (e) {
      return false;
    }
  }

  static Stream<List<ReminderModel>> getUserReminders(String ownerId) {
    return _firestore
        .collection(_collectionName)
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ReminderModel.fromJson(doc.data()))
        .toList());
  }

  static Future<ReminderModel?> getReminder(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();
      return doc.exists ? ReminderModel.fromJson(doc.data()!) : null;
    } catch (e) {
      return null;
    }
  }
}