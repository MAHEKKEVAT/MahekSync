
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:math';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/models/sentinel_model.dart';

class SentinelFirestoreUtils {
  static const String collectionName = 'sentinel_access';

  static CollectionReference get _collection =>
      FirebaseFirestore.instance.collection(collectionName);

  /// Generate a cryptographically secure salt
  static String _generateSalt() {
    final random = Random.secure();
    final saltBytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64.encode(saltBytes);
  }

  /// Hash password with salt using SHA-256 (multiple rounds for security)
  static String _hashPassword(String password, String salt) {
    var hash = password + salt;
    for (int i = 0; i < 10000; i++) {
      hash = sha256.convert(utf8.encode(hash)).toString();
    }
    return hash;
  }

  /// Create master password for a user
  static Future<bool> createMasterPassword(String ownerId, String password, {String? resetEmail}) async {
    try {
      final id = MahekConstant.getUuid();
      final salt = _generateSalt();
      final hash = _hashPassword(password, salt);
      final data = {
        'id': id,
        'ownerId': ownerId,
        'masterPasswordHash': hash,
        'passwordSalt': salt,
        'failedAttempts': 0,
        'lockedUntil': null,
        'resetEmail': resetEmail,
        'isPasswordSet': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      await _collection.doc(id).set(data);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Verify master password
  static Future<bool> verifyMasterPassword(String ownerId, String password) async {
    try {
      final query = await _collection.where('ownerId', isEqualTo: ownerId).limit(1).get();
      if (query.docs.isEmpty) return false;

      final doc = query.docs.first;
      final data = doc.data() as Map<String, dynamic>;
      final storedHash = data['masterPasswordHash'] as String?;
      final salt = data['passwordSalt'] as String?;

      if (storedHash == null || salt == null) return false;

      final inputHash = _hashPassword(password, salt);
      return inputHash == storedHash;
    } catch (e) {
      return false;
    }
  }

  /// Update master password
  static Future<bool> updateMasterPassword(String ownerId, String newPassword) async {
    try {
      final query = await _collection.where('ownerId', isEqualTo: ownerId).limit(1).get();
      if (query.docs.isEmpty) return false;

      final doc = query.docs.first;
      final salt = _generateSalt();
      final hash = _hashPassword(newPassword, salt);

      await _collection.doc(doc.id).update({
        'masterPasswordHash': hash,
        'passwordSalt': salt,
        'failedAttempts': 0,
        'lockedUntil': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Update failed attempts count
  static Future<bool> updateFailedAttempts(String ownerId, int attempts) async {
    try {
      final query = await _collection.where('ownerId', isEqualTo: ownerId).limit(1).get();
      if (query.docs.isEmpty) return false;

      await _collection.doc(query.docs.first.id).update({
        'failedAttempts': attempts,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Lock access for a duration
  static Future<bool> lockAccess(String ownerId, Duration duration) async {
    try {
      final query = await _collection.where('ownerId', isEqualTo: ownerId).limit(1).get();
      if (query.docs.isEmpty) return false;

      await _collection.doc(query.docs.first.id).update({
        'lockedUntil': DateTime.now().add(duration),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Reset lock after timer expires
  static Future<bool> resetLock(String ownerId) async {
    try {
      final query = await _collection.where('ownerId', isEqualTo: ownerId).limit(1).get();
      if (query.docs.isEmpty) return false;

      await _collection.doc(query.docs.first.id).update({
        'failedAttempts': 0,
        'lockedUntil': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get current sentinel access data
  static Future<SentinelModel?> getCurrentSentinelAccess(String ownerId) async {
    try {
      final query = await _collection.where('ownerId', isEqualTo: ownerId).limit(1).get();
      if (query.docs.isEmpty) return null;
      return SentinelModel.fromJson(query.docs.first.data() as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  /// Request password reset — deletes current sentinel record so user can recreate
  static Future<bool> requestPasswordReset(String ownerId) async {
    try {
      final query = await _collection.where('ownerId', isEqualTo: ownerId).limit(1).get();
      if (query.docs.isEmpty) return false;

      await _collection.doc(query.docs.first.id).update({
        'isPasswordSet': false,
        'masterPasswordHash': null,
        'passwordSalt': null,
        'failedAttempts': 0,
        'lockedUntil': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}


