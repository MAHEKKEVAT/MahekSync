import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maheksync/app/services/imagekit_api.dart';
import 'package:maheksync/app/models/my_contacts_model.dart';

class VcfContact {
  final String firstName;
  final String lastName;
  final String mobileNumber;
  VcfContact({required this.firstName, required this.lastName, required this.mobileNumber});
}

class MyContactsCrud {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collection = 'my_contacts';

  static String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  static CollectionReference<Map<String, dynamic>> get _ref =>
      _db.collection(_collection);

  static Future<MyContactsModel?> checkContactExists(String mobileNumber) async {
    final clean = mobileNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final snapshot = await _ref
        .where('ownerId', isEqualTo: _uid)
        .where('mobileNumber', isEqualTo: clean)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return MyContactsModel.fromJson(snapshot.docs.first.data());
  }

  static Future<String> createOrUpdateContact(MyContactsModel model) async {
    final existing = await checkContactExists(model.mobileNumber);
    if (existing != null) {
      final updated = model.copyWith(
        id: existing.id,
        searchKeywords: MyContactsModel.generateSearchKeywords(
          model.firstName,
          model.lastName,
          model.mobileNumber,
        ),
      );
      await _ref.doc(existing.id).update(updated.toUpdateJson());
      return existing.id;
    }
    final keywords = MyContactsModel.generateSearchKeywords(
      model.firstName,
      model.lastName,
      model.mobileNumber,
    );
    final docRef = _ref.doc();
    final newModel = model.copyWith(
      id: docRef.id,
      ownerId: _uid,
      searchKeywords: keywords,
    );
    await docRef.set(newModel.toJson());
    return docRef.id;
  }

  static Future<String> createOnlyNewContact(MyContactsModel model) async {
    final existing = await checkContactExists(model.mobileNumber);
    if (existing != null) {
      if (existing.firstName != model.firstName || existing.lastName != model.lastName) {
        final updated = existing.copyWith(
          firstName: model.firstName,
          lastName: model.lastName,
          searchKeywords: MyContactsModel.generateSearchKeywords(
            model.firstName,
            model.lastName,
            model.mobileNumber,
          ),
        );
        await _ref.doc(existing.id).update(updated.toUpdateJson());
      }
      return existing.id;
    }
    final keywords = MyContactsModel.generateSearchKeywords(
      model.firstName,
      model.lastName,
      model.mobileNumber,
    );
    final docRef = _ref.doc();
    final newModel = model.copyWith(
      id: docRef.id,
      ownerId: _uid,
      searchKeywords: keywords,
    );
    await docRef.set(newModel.toJson());
    return docRef.id;
  }

  static Future<void> deleteContact(String id) async {
    await _ref.doc(id).delete();
  }

  static Stream<List<MyContactsModel>> streamContacts() {
    return _ref
        .where('ownerId', isEqualTo: _uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => MyContactsModel.fromJson(doc.data()))
        .toList());
  }

  static Stream<List<MyContactsModel>> searchContacts(String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return streamContacts();
    return _ref
        .where('ownerId', isEqualTo: _uid)
        .where('searchKeywords', arrayContains: q)
        .orderBy('updatedAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => MyContactsModel.fromJson(doc.data()))
        .toList());
  }

  static Future<String?> uploadProfileImage(XFile imageFile) async {
    try {
      return await ImageKitAPI.uploadImage(
        imageFile: imageFile,
        folderName: 'contacts/$_uid',
      );
    } catch (_) {
      return null;
    }
  }

  static Future<List<MyContactsModel>> getContactsPaginated({
    DocumentSnapshot? lastDoc,
    int limit = 20,
  }) async {
    Query<Map<String, dynamic>> query = _ref
        .where('ownerId', isEqualTo: _uid)
        .orderBy('updatedAt', descending: true)
        .limit(limit);
    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }
    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => MyContactsModel.fromJson(doc.data()))
        .toList();
  }

  static List<VcfContact> parseVcfString(String vcfContent) {
    final contacts = <VcfContact>[];
    final vcardBlocks = vcfContent.split(RegExp(r'BEGIN:VCARD', caseSensitive: false));
    for (final block in vcardBlocks) {
      if (block.trim().isEmpty) continue;
      String firstName = '';
      String lastName = '';
      String mobile = '';
      final lines = block.split(RegExp(r'\r?\n'));
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;
        final nMatch = RegExp(r'^N[:;](.*)$', caseSensitive: false).firstMatch(trimmed);
        if (nMatch != null) {
          final parts = nMatch.group(1)!.split(';');
          if (parts.isNotEmpty) lastName = parts[0].trim();
          if (parts.length > 1) firstName = parts[1].trim();
        }
        final fnMatch = RegExp(r'^FN[:;](.*)$', caseSensitive: false).firstMatch(trimmed);
        if (fnMatch != null) {
          final fnValue = fnMatch.group(1)!.trim();
          if (firstName.isEmpty && lastName.isEmpty && fnValue.isNotEmpty) {
            final nameParts = fnValue.split(' ');
            if (nameParts.length > 1) {
              firstName = nameParts.first;
              lastName = nameParts.sublist(1).join(' ');
            } else {
              firstName = fnValue;
            }
          }
        }
        final telMatch = RegExp(r'^TEL[;:]+(?:.*?:)?(.+)$', caseSensitive: false).firstMatch(trimmed);
        if (telMatch != null) {
          mobile = telMatch.group(1)!.trim();
        }
      }
      mobile = mobile.replaceAll(RegExp(r'[^0-9+]'), '');
      if (mobile.isNotEmpty) {
        contacts.add(VcfContact(firstName: firstName, lastName: lastName, mobileNumber: mobile));
      }
    }
    return contacts;
  }
}
