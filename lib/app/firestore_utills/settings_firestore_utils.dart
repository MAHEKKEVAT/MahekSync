import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maheksync/app/constant/collection_name.dart';
import 'package:maheksync/app/models/settings_model.dart';

class SettingsFirestoreUtils {
  static const String _docId = 'app_settings';

  static DocumentReference get _doc =>
      FirebaseFirestore.instance.collection(CollectionName.settings).doc(_docId);

  /// Get settings stream (real-time listener)
  static Stream<SettingsModel?> getSettingsStream() {
    return _doc.snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return SettingsModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  /// Get settings once (future)
  static Future<SettingsModel?> getSettings() async {
    try {
      final doc = await _doc.get();
      if (doc.exists && doc.data() != null) {
        return SettingsModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting settings: $e');
      return null;
    }
  }

  /// Create or update settings (upsert)
  static Future<bool> saveSettings(SettingsModel model) async {
    try {
      final data = model.toJson();
      data['id'] = _docId;
      data['updatedAt'] = Timestamp.now();
      await _doc.set(data, SetOptions(merge: true));
      return true;
    } catch (e) {
      print('Error saving settings: $e');
      return false;
    }
  }

  /// Update a single field
  static Future<bool> updateField(String field, dynamic value) async {
    try {
      await _doc.update({
        field: value,
        'updatedAt': Timestamp.now(),
      });
      return true;
    } catch (e) {
      print('Error updating setting field $field: $e');
      return false;
    }
  }
}
