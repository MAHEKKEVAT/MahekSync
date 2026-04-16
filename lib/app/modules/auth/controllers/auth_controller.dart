// lib/app/modules/auth/controllers/auth_controller.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/constant/collection_name.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/models/user_model.dart';
import 'package:maheksync/app/routes/app_pages.dart';
import 'package:maheksync/app/utils/fire_store_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../constant/show_toast.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final obscurePassword = true.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      ShowToastDialog.showError('Please fill all fields');
      return;
    }

    isLoading.value = true;

    try {
      // Try to sign in
      UserCredential userCredential;

      try {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          // Auto-create account if doesn't exist
          userCredential = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

          // Create user profile in Firestore
          final newUser = UserModel(
            id: userCredential.user!.uid,
            email: email,
            fullName: email.split('@')[0],
            loginType: MahekConstant.emailLoginType,
            userType: 'editor',
            isActive: true,
            isVerified: false,
            createdAt: Timestamp.now(),
          );

          await FireStoreUtils.fireStore
              .collection(CollectionName.owners)
              .doc(newUser.id)
              .set(newUser.toJson());

          MahekConstant.ownerModel = newUser;
          ShowToastDialog.showSuccess('Account created successfully!');
        } else if (e.code == 'wrong-password') {
          ShowToastDialog.showError('Invalid email or password');
          isLoading.value = false;
          return;
        } else if (e.code == 'invalid-email') {
          ShowToastDialog.showError('Invalid email format');
          isLoading.value = false;
          return;
        } else {
          rethrow;
        }
      }

      final user = userCredential.user;

      if (user != null) {
        // Fetch user profile
        final userModel = await FireStoreUtils.getOwnerProfile(user.uid);

        if (userModel != null) {
          MahekConstant.ownerModel = userModel;
          MahekConstant.isLogin = true;

          ShowToastDialog.showSuccess('Welcome back, ${userModel.fullName ?? 'User'}!');

          // Navigate to dashboard
          Get.offAllNamed(Routes.DASHBOARD);
        } else {
          // Create profile if missing
          final newUser = UserModel(
            id: user.uid,
            email: user.email ?? email,
            fullName: user.displayName ?? email.split('@')[0],
            profilePic: user.photoURL,
            loginType: MahekConstant.emailLoginType,
            userType: 'editor',
            isActive: true,
            isVerified: user.emailVerified,
            createdAt: Timestamp.now(),
          );

          await FireStoreUtils.fireStore
              .collection(CollectionName.owners)
              .doc(newUser.id)
              .set(newUser.toJson());

          MahekConstant.ownerModel = newUser;
          MahekConstant.isLogin = true;

          Get.offAllNamed(Routes.DASHBOARD);
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Authentication failed';

      switch (e.code) {
        case 'network-request-failed':
          message = 'Network error. Please check your connection.';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Please try again later.';
          break;
        case 'operation-not-allowed':
          message = 'Email/password sign-in is not enabled.';
          break;
        default:
          message = e.message ?? 'An error occurred';
      }

      ShowToastDialog.showError(message);
    } catch (e) {
      ShowToastDialog.showError('An unexpected error occurred');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await FireStoreUtils.clearFcmToken();
      MahekConstant.isLogin = false;
      MahekConstant.ownerModel = null;
      Get.offAllNamed(Routes.LOGIN_SCREEN);
    } catch (e) {
      ShowToastDialog.showError('Error signing out');
    }
  }

  void forgotPassword() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter your email address and we\'ll send you a password reset link.',
              style: TextStyle(
                fontFamily: 'Figtree-Regular',
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: 'Email address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.email_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.isNotEmpty) {
                try {
                  await _auth.sendPasswordResetEmail(
                    email: emailController.text.trim(),
                  );
                  Get.back();
                  ShowToastDialog.showSuccess('Password reset email sent');
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'user-not-found') {
                    ShowToastDialog.showError('No account found with this email');
                  } else {
                    ShowToastDialog.showError(e.message ?? 'Error sending reset email');
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5D54F2),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  // Social login methods (optional)
  Future<void> signInWithGoogle() async {
    // Implement Google Sign-In
    ShowToastDialog.showWarning('Google Sign-In coming soon');
  }

  Future<void> signInWithApple() async {
    // Implement Apple Sign-In
    ShowToastDialog.showWarning('Apple Sign-In coming soon');
  }
}