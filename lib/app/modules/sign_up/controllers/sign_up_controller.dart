// lib/app/modules/auth/controllers/sign_up_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/constant/collection_name.dart';
import 'package:maheksync/app/models/user_model.dart';
import 'package:maheksync/app/routes/app_pages.dart';
import 'package:maheksync/app/utils/fire_store_utils.dart';
import '../../../constant/constants.dart';
import '../../../constant/show_toast.dart';

class SignUpController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final agreedToTerms = false.obs;

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Full name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Include at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Include at least one number';
    }
    return null;
  }

  Future<void> signUpWithEmailAndPassword() async {
    if (!agreedToTerms.value) {
      ShowToastDialog.showError('Please agree to the Terms of Service');
      return;
    }

    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      ShowToastDialog.showError('Please fill all fields');
      return;
    }

    isLoading.value = true;

    try {
      // Create new user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user != null) {
        // Update display name
        await user.updateDisplayName(fullName);

        // Create user profile in Firestore
        final newUser = UserModel(
          id: user.uid,
          email: email,
          fullName: fullName,
          loginType: MahekConstant.emailLoginType,
          userType: 'owner',
          isActive: true,
          isVerified: false,
          createdAt: Timestamp.now(),
        );

        await FireStoreUtils.fireStore
            .collection(CollectionName.owners)
            .doc(newUser.id)
            .set(newUser.toJson());

        MahekConstant.ownerModel = newUser;
        MahekConstant.isLogin = true;

        ShowToastDialog.showSuccess('Account created successfully! Welcome, $fullName!');

        // Navigate to dashboard
        Get.offAllNamed(Routes.DASHBOARD);
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Registration failed';

      if (e.code == 'email-already-in-use') {
        message = 'This email is already registered. Please log in instead.';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email format';
      } else if (e.code == 'weak-password') {
        message = 'Password is too weak. Choose a stronger password.';
      } else if (e.code == 'network-request-failed') {
        message = 'Network error. Check your connection.';
      } else {
        message = e.message ?? 'An error occurred';
      }

      ShowToastDialog.showError(message);
    } catch (e) {
      ShowToastDialog.showError('An unexpected error occurred');
    } finally {
      isLoading.value = false;
    }
  }

  // These methods were accidentally placed INSIDE signUpWithEmailAndPassword
  // Move them outside as separate class methods
  void navigateToLogin() {
    Get.offAllNamed(Routes.LOGIN_SCREEN);
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleTermsAgreement() {
    agreedToTerms.value = !agreedToTerms.value;
  }
}