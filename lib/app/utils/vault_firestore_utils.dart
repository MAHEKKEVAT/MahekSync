import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/models/vault_model.dart';

class VaultFirestoreUtils {
  static const String collectionName = 'vault_items';

  static CollectionReference get _collection =>
      FirebaseFirestore.instance.collection(collectionName);

  static Future<bool> addVaultItem(VaultModel item) async {
    try {
      final id = item.id ?? MahekConstant.getUuid();
      final data = item.toJson();
      data['id'] = id;
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _collection.doc(id).set(data);
      return true;
    } catch (e) {
      debugPrint('VaultFirestoreUtils.addVaultItem error: $e');
      return false;
    }
  }

  static Future<bool> updateVaultItem(VaultModel item) async {
    try {
      if (item.id == null) return false;
      final data = item.toJson();
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _collection.doc(item.id).update(data);
      return true;
    } catch (e) {
      debugPrint('VaultFirestoreUtils.updateVaultItem error: $e');
      return false;
    }
  }

  static Future<bool> deleteVaultItem(String id) async {
    try {
      await _collection.doc(id).delete();
      return true;
    } catch (e) {
      debugPrint('VaultFirestoreUtils.deleteVaultItem error: $e');
      return false;
    }
  }

  static Stream<List<VaultModel>> getVaultItems(String ownerId) {
    return _collection
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => VaultModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      // Sort: pinned first, then favorites
      list.sort((a, b) {
        if ((a.isPinned ?? false) != (b.isPinned ?? false)) {
          return (b.isPinned ?? false) ? 1 : -1;
        }
        if ((a.isFavorite ?? false) != (b.isFavorite ?? false)) {
          return (b.isFavorite ?? false) ? 1 : -1;
        }
        return 0;
      });
      return list;
    });
  }

  static Future<bool> toggleFavorite(VaultModel item) async {
    try {
      if (item.id == null) return false;
      await _collection.doc(item.id).update({
        'isFavorite': !(item.isFavorite ?? false),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('VaultFirestoreUtils.toggleFavorite error: $e');
      return false;
    }
  }

  static Future<bool> togglePin(VaultModel item) async {
    try {
      if (item.id == null) return false;
      await _collection.doc(item.id).update({
        'isPinned': !(item.isPinned ?? false),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('VaultFirestoreUtils.togglePin error: $e');
      return false;
    }
  }

  static Future<bool> toggleHidden(VaultModel item) async {
    try {
      if (item.id == null) return false;
      await _collection.doc(item.id).update({
        'isHidden': !(item.isHidden ?? false),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('VaultFirestoreUtils.toggleHidden error: $e');
      return false;
    }
  }

  static Future<VaultModel?> getVaultItemById(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (doc.exists) {
        return VaultModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('VaultFirestoreUtils.getVaultItemById error: $e');
      return null;
    }
  }
}

void debugPrint(String message) {
  print(message);
}
