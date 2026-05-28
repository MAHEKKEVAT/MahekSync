// lib/app/utils/payment_method_firestore_utils.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/models/payment_method_model.dart';

class PaymentMethodFirestoreUtils {
  static const String collectionName = 'payment_methods';

  static CollectionReference get _collection =>
      FirebaseFirestore.instance.collection(collectionName);

  static Future<bool> addPaymentMethod(PaymentMethodModel method) async {
    try {
      final id = method.id ?? MahekConstant.getUuid();
      final data = method.toJson();
      data['id'] = id;
      await _collection.doc(id).set(data);
      return true;
    } catch (e) {
      print('Error adding payment method: $e');
      return false;
    }
  }

  static Future<bool> updatePaymentMethod(PaymentMethodModel method) async {
    try {
      if (method.id == null) return false;
      await _collection.doc(method.id).update(method.toJson());
      return true;
    } catch (e) {
      print('Error updating payment method: $e');
      return false;
    }
  }

  static Future<bool> deletePaymentMethod(String id) async {
    try {
      await _collection.doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting payment method: $e');
      return false;
    }
  }

  static Stream<List<PaymentMethodModel>> getPaymentMethods() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => PaymentMethodModel.fromJson(
        doc.data() as Map<String, dynamic>))
        .toList());
  }

  static Future<PaymentMethodModel?> getPaymentMethodById(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (doc.exists) {
        return PaymentMethodModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting payment method: $e');
      return null;
    }
  }
}