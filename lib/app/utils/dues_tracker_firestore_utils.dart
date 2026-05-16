import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/models/dues_tracker_model.dart';

class DuesTrackerFirestoreUtils {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'dues_tracker';

  static Future<bool> addDue(DuesTrackerModel due) async {
    try {
      final dueId = MahekConstant.getUuid();
      due.id = dueId;
      due.createdAt = Timestamp.now();
      due.updatedAt = Timestamp.now();

      await _firestore
          .collection(_collectionName)
          .doc(dueId)
          .set(due.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateDue(DuesTrackerModel due) async {
    try {
      due.updatedAt = Timestamp.now();
      await _firestore
          .collection(_collectionName)
          .doc(due.id)
          .update(due.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteDue(String dueId) async {
    try {
      await _firestore.collection(_collectionName).doc(dueId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  static Stream<List<DuesTrackerModel>> getUserDues(String ownerId) {
    return _firestore
        .collection(_collectionName)
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) {
      final dues = snapshot.docs
          .map((doc) => DuesTrackerModel.fromJson(doc.data()))
          .toList();

      dues.sort((a, b) {
        final aTime = a.createdAt?.toDate() ?? DateTime(2000);
        final bTime = b.createdAt?.toDate() ?? DateTime(2000);
        return bTime.compareTo(aTime);
      });

      return dues;
    });
  }

  static Future<DuesTrackerModel?> getDue(String dueId) async {
    try {
      final doc = await _firestore
          .collection(_collectionName)
          .doc(dueId)
          .get();
      if (doc.exists) {
        return DuesTrackerModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<int> getDueCount(String ownerId, {String? status}) async {
    try {
      Query query = _firestore
          .collection(_collectionName)
          .where('ownerId', isEqualTo: ownerId);

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      final snapshot = await query.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  static Future<bool> batchSettle(List<String> dueIds) async {
    try {
      final batch = _firestore.batch();
      for (final id in dueIds) {
        batch.update(
          _firestore.collection(_collectionName).doc(id),
          {
            'status': 'SETTLED',
            'updatedAt': Timestamp.now(),
          },
        );
      }
      await batch.commit();
      return true;
    } catch (e) {
      return false;
    }
  }
}
