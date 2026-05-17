import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/models/personal_task_model.dart';

class PersonalTaskFirestoreUtils {
  static const String collectionName = 'personal_tasks';

  static CollectionReference get _collection =>
      FirebaseFirestore.instance.collection(collectionName);

  static Future<bool> addTask(PersonalTaskModel task) async {
    try {
      final id = task.id ?? MahekConstant.getUuid();
      final data = task.toJson();
      data['id'] = id;
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _collection.doc(id).set(data);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateTask(PersonalTaskModel task) async {
    try {
      if (task.id == null) return false;
      final data = task.toJson();
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _collection.doc(task.id).update(data);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteTask(String id) async {
    try {
      await _collection.doc(id).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  static Stream<List<PersonalTaskModel>> getUserTasks(String ownerId) {
    return _collection
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => PersonalTaskModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      list.sort((a, b) {
        if ((a.isPinned ?? false) != (b.isPinned ?? false)) {
          return (b.isPinned ?? false) ? 1 : -1;
        }
        return 0;
      });
      return list;
    });
  }

  static Future<bool> toggleTask(PersonalTaskModel task) async {
    try {
      if (task.id == null) return false;
      await _collection.doc(task.id).update({
        'isCompleted': !(task.isCompleted ?? false),
        'status': (task.isCompleted ?? false) ? 'PENDING' : 'COMPLETED',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> pinTask(PersonalTaskModel task) async {
    try {
      if (task.id == null) return false;
      await _collection.doc(task.id).update({
        'isPinned': !(task.isPinned ?? false),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> markCompleted(String id) async {
    try {
      await _collection.doc(id).update({
        'isCompleted': true,
        'status': 'COMPLETED',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<PersonalTaskModel?> getTaskById(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (doc.exists) {
        return PersonalTaskModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
