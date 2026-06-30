// lib/app/utils/category_firestore_utils.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/models/category_model.dart';
import 'package:maheksync/app/services/imagekit_api.dart';

class CategoryFirestoreUtils {
  static const String collectionName = 'categories';

  static CollectionReference get _collection =>
      FirebaseFirestore.instance.collection(collectionName);

  static Future<bool> addCategory(CategoryModel category) async {
    try {
      final id = category.id ?? MahekConstant.getUuid();
      final data = category.toJson();
      data['id'] = id;
      await _collection.doc(id).set(data);
      return true;
    } catch (e) {
      print('Error adding category: $e');
      return false;
    }
  }

  static Future<bool> updateCategory(CategoryModel category) async {
    try {
      if (category.id == null) return false;
      await _collection.doc(category.id).update(category.toJson());
      return true;
    } catch (e) {
      print('Error updating category: $e');
      return false;
    }
  }

  static Future<bool> deleteCategory(String id) async {
    try {
      // Fetch doc to get image URL before deleting
      final doc = await _collection.doc(id).get();
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        final iconUrl = data['iconUrl'] as String?;
        if (iconUrl != null && iconUrl.isNotEmpty) {
          ImageKitAPI.deleteFile(iconUrl);
        }
      }
      await _collection.doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting category: $e');
      return false;
    }
  }

  static Stream<List<CategoryModel>> getCategories() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => CategoryModel.fromJson(
        doc.data() as Map<String, dynamic>))
        .toList());
  }

  static Future<CategoryModel?> getCategoryById(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (doc.exists) {
        return CategoryModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting category: $e');
      return null;
    }
  }
}