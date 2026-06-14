// lib/app/firestore_utills/bill_firestore_utils.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/models/bill_model.dart';

class BillFirestoreUtils {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'bills';

  static Future<bool> addBill(BillModel bill) async {
    try {
      final billId = MahekConstant.getUuid();
      bill.id = billId;
      bill.createdAt = Timestamp.now();
      bill.updatedAt = Timestamp.now();

      await _firestore
          .collection(_collectionName)
          .doc(billId)
          .set(bill.toJson());
      return true;
    } catch (e) {
      print('Error adding bill: $e');
      return false;
    }
  }

  static Future<bool> updateBill(BillModel bill) async {
    try {
      bill.updatedAt = Timestamp.now();
      await _firestore
          .collection(_collectionName)
          .doc(bill.id)
          .update(bill.toJson());
      return true;
    } catch (e) {
      print('Error updating bill: $e');
      return false;
    }
  }

  static Future<bool> deleteBill(String billId) async {
    try {
      await _firestore.collection(_collectionName).doc(billId).delete();
      return true;
    } catch (e) {
      print('Error deleting bill: $e');
      return false;
    }
  }

  static Stream<List<BillModel>> getUserBills(String ownerId) {
    return _firestore
        .collection(_collectionName)
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) {
      final bills = snapshot.docs
          .map((doc) => BillModel.fromJson(doc.data()))
          .toList();

      bills.sort((a, b) {
        final aTime = a.createdAt?.toDate() ?? DateTime(2000);
        final bTime = b.createdAt?.toDate() ?? DateTime(2000);
        return bTime.compareTo(aTime);
      });

      return bills;
    });
  }

  static Future<BillModel?> getBill(String billId) async {
    try {
      final doc =
          await _firestore.collection(_collectionName).doc(billId).get();
      if (doc.exists) {
        return BillModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
