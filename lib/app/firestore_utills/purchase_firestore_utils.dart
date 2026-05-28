// lib/app/utils/purchase_firestore_utils.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/models/purchase_model.dart';

class PurchaseFirestoreUtils {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'purchases';

  static Future<bool> addPurchase(PurchaseModel purchase) async {
    try {
      final purchaseId = MahekConstant.getUuid();
      purchase.id = purchaseId;
      purchase.createdAt = Timestamp.now();
      purchase.updatedAt = Timestamp.now();

      await _firestore
          .collection(_collectionName)
          .doc(purchaseId)
          .set(purchase.toJson());
      return true;
    } catch (e) {
      print('Error adding purchase: $e');
      return false;
    }
  }

  static Future<bool> updatePurchase(PurchaseModel purchase) async {
    try {
      purchase.updatedAt = Timestamp.now();
      await _firestore
          .collection(_collectionName)
          .doc(purchase.id)
          .update(purchase.toJson());
      return true;
    } catch (e) {
      print('Error updating purchase: $e');
      return false;
    }
  }

  static Future<bool> deletePurchase(String purchaseId) async {
    try {
      await _firestore.collection(_collectionName).doc(purchaseId).delete();
      return true;
    } catch (e) {
      print('Error deleting purchase: $e');
      return false;
    }
  }

  static Stream<List<PurchaseModel>> getUserPurchases(String ownerId) {
    return _firestore
        .collection(_collectionName)
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) {
      final purchases = snapshot.docs
          .map((doc) => PurchaseModel.fromJson(doc.data()))
          .toList();

      purchases.sort((a, b) {
        final aTime = a.createdAt?.toDate() ?? DateTime(2000);
        final bTime = b.createdAt?.toDate() ?? DateTime(2000);
        return bTime.compareTo(aTime);
      });

      return purchases;
    });
  }

  static Future<PurchaseModel?> getPurchase(String purchaseId) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(purchaseId).get();
      if (doc.exists) {
        return PurchaseModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}