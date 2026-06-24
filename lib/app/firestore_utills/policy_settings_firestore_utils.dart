import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maheksync/app/constant/collection_name.dart';

class PolicySettingsFirestoreUtils {
  static const String _docId = 'policy_data';

  static DocumentReference get _doc =>
      FirebaseFirestore.instance.collection(CollectionName.policySettings).doc(_docId);

  static Future<Map<String, String>> getPolicies() async {
    try {
      final doc = await _doc.get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'termsAndConditions': (data['termsAndConditions'] ?? '') as String,
          'privacyPolicy': (data['privacyPolicy'] ?? '') as String,
          'aboutApp': (data['aboutApp'] ?? '') as String,
        };
      }
      return {
        'termsAndConditions': _defaultTerms,
        'privacyPolicy': _defaultPrivacy,
        'aboutApp': _defaultAbout,
      };
    } catch (_) {
      return {
        'termsAndConditions': _defaultTerms,
        'privacyPolicy': _defaultPrivacy,
        'aboutApp': _defaultAbout,
      };
    }
  }

  static Stream<DocumentSnapshot> getPoliciesStream() {
    return _doc.snapshots();
  }

  static Future<bool> savePolicies({
    required String termsAndConditions,
    required String privacyPolicy,
    required String aboutApp,
  }) async {
    try {
      await _doc.set({
        'termsAndConditions': termsAndConditions,
        'privacyPolicy': privacyPolicy,
        'aboutApp': aboutApp,
        'updatedAt': Timestamp.now(),
      }, SetOptions(merge: true));
      return true;
    } catch (_) {
      return false;
    }
  }

  static final String _defaultTerms = '''Terms & Conditions

Last updated: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}

Welcome to MahekSync. By using this application, you agree to the following terms and conditions:

1. Acceptance of Terms
By accessing or using MahekSync, you agree to be bound by these Terms and Conditions.

2. Use of the Application
MahekSync is a personal data management tool designed to help you organize your devices, subscriptions, contacts, and other personal information.

3. Data Ownership
All data entered into MahekSync belongs to you. We do not access, sell, or share your personal data with third parties.

4. Data Storage
Your data is stored securely in Firebase Cloud Firestore and is accessible only by you through your authenticated account.

5. Limitation of Liability
MahekSync is provided "as is" without warranties of any kind.

6. Changes to Terms
We reserve the right to modify these terms at any time.''';

  static final String _defaultPrivacy = '''Privacy Policy

Last updated: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}

MahekSync ("we", "our", or "us") is committed to protecting your privacy.

1. Information We Collect
- Account information (email, name)
- Data you manually enter (devices, contacts, tasks, subscriptions, etc.)
- Usage analytics (anonymized)

2. How We Use Your Information
- To provide and maintain the MahekSync service
- To store and sync your personal data across devices
- To send reminder notifications you have configured

3. Data Storage & Security
- All data is stored in Firebase Cloud Firestore
- Data is encrypted in transit (TLS) and at rest
- Access is restricted to authenticated users only

4. Data Sharing
We do not sell, trade, or share your personal information with third parties.

5. Data Retention
Your data is retained as long as your account is active. You may delete your data at any time.

6. Your Rights
- Access your data
- Update your data
- Delete your data and account

7. Contact Us
For privacy-related inquiries, please contact us through the app.''';

  static const String _defaultAbout = '''MahekSync — Personal Data Manager

MahekSync is your all-in-one personal data management companion. Keep track of everything that matters in your life, all in one secure place.

Features:
• Device Manager — Register and track all your devices with warranty info
• Subscriptions — Never lose track of recurring payments
• Contacts — Maintain your personal contact directory
• Personal Tasks — Stay on top of your daily activities
• Dues Tracker — Track who owes you and what you owe
• Reminders — Never miss important dates and deadlines
• Bills & Documents — Generate and manage invoices
• Aegis Security — Secure vault for sensitive data
• Image to Text — Extract text from images using OCR
• Smart Map — Location-based features

Built with ❤️ using Flutter and Firebase.''';
}
