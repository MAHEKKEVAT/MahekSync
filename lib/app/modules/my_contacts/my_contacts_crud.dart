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
    final clean = MyContactsModel.normalizeMobile(mobileNumber);
    final snapshot = await _ref
        .where('ownerId', isEqualTo: _uid)
        .where('mobileNumber', isEqualTo: clean)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    return MyContactsModel.fromJson(doc.data(), docId: doc.id);
  }

  static Future<String> createOrUpdateContact(MyContactsModel model) async {
    final existing = await checkContactExists(model.mobileNumber);
    if (existing != null) {
      final updated = model.copyWith(docId: existing.docId);
      await _ref.doc(existing.docId).update(updated.toJson());
      return existing.docId;
    }
    final docRef = _ref.doc();
    final newModel = model.copyWith(docId: docRef.id, ownerId: _uid);
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
        );
        await _ref.doc(existing.docId).update(updated.toJson());
      }
      return existing.docId;
    }
    final docRef = _ref.doc();
    final newModel = model.copyWith(docId: docRef.id, ownerId: _uid);
    await docRef.set(newModel.toJson());
    return docRef.id;
  }

  static Future<void> deleteContact(String docId) async {
    await _ref.doc(docId).delete();
  }

  static Stream<List<MyContactsModel>> streamContacts() {
    return _ref
        .where('ownerId', isEqualTo: _uid)
        .orderBy('firstName', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => MyContactsModel.fromJson(doc.data(), docId: doc.id))
        .toList());
  }

  static Stream<List<MyContactsModel>> searchContacts(String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return streamContacts();
    return _ref
        .where('ownerId', isEqualTo: _uid)
        .orderBy('firstName', descending: false)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => MyContactsModel.fromJson(doc.data(), docId: doc.id))
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
        .orderBy('firstName', descending: false)
        .limit(limit);
    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }
    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => MyContactsModel.fromJson(doc.data(), docId: doc.id))
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
            final nameParts =
            fnValue.trim().split(RegExp(r'\s+'));
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
      mobile = MyContactsModel.normalizeMobile(mobile);
      if (mobile.isNotEmpty) {
        contacts.add(VcfContact(firstName: firstName, lastName: lastName, mobileNumber: mobile));
      }
    }
    return contacts;
  }

  static Future<Map<String, MyContactsModel>> getAllContactsMap() async {
    final snapshot = await _ref
        .where('ownerId', isEqualTo: _uid)
        .get();

    final map = <String, MyContactsModel>{};

    for (final doc in snapshot.docs) {
      final model = MyContactsModel.fromJson(
        doc.data(),
        docId: doc.id,
      );

      map[model.mobileNumber] = model;
    }

    return map;
  }
}
