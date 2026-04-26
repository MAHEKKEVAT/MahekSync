// lib/app/utils/subscription_firestore_utils.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/models/subscription_model.dart';

class SubscriptionFirestoreUtils {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'subscriptions';

  static Future<bool> addSubscription(SubscriptionModel sub) async {
    try {
      final id = MahekConstant.getUuid();
      sub.id = id;
      sub.createdAt = Timestamp.now();
      sub.updatedAt = Timestamp.now();
      await _firestore.collection(_collectionName).doc(id).set(sub.toJson());
      return true;
    } catch (e) {
      print('Error adding subscription: $e');
      return false;
    }
  }

  static Future<bool> updateSubscription(SubscriptionModel sub) async {
    try {
      sub.updatedAt = Timestamp.now();
      await _firestore.collection(_collectionName).doc(sub.id).update(sub.toJson());
      return true;
    } catch (e) {
      print('Error updating subscription: $e');
      return false;
    }
  }

  static Future<bool> deleteSubscription(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting subscription: $e');
      return false;
    }
  }

  // ✅ Backward compatible - renews for 30 days
  static Future<bool> renewSubscription(SubscriptionModel sub) async {
    return await renewSubscriptionWithDate(sub, DateTime.now().add(const Duration(days: 30)));
  }

  // ✅ New method - renew with custom date
  static Future<bool> renewSubscriptionWithDate(SubscriptionModel sub, DateTime newExpiryDate) async {
    try {
      sub.expiryDate = newExpiryDate;
      sub.status = 'ACTIVE';
      return await updateSubscription(sub);
    } catch (e) {
      return false;
    }
  }

  static Stream<List<SubscriptionModel>> getUserSubscriptions(String ownerId) {
    return _firestore
        .collection(_collectionName)
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => SubscriptionModel.fromJson(doc.data())).toList());
  }

  static Future<SubscriptionModel?> getSubscription(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();
      return doc.exists ? SubscriptionModel.fromJson(doc.data()!) : null;
    } catch (e) {
      return null;
    }
  }
}