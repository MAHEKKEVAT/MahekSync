// lib/app/modules/subscription_details/controllers/subscription_details_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/models/subscription_model.dart';
import 'package:maheksync/app/utils/subscription_firestore_utils.dart';

class SubscriptionDetailsController extends GetxController {
  final subscription = Rxn<SubscriptionModel>();

  @override
  void onInit() {
    super.onInit();
    subscription.value = Get.arguments as SubscriptionModel?;
  }

  Future<void> renewSubscription() async {
    if (subscription.value != null) {
      // ✅ Use the new method with a 30-day renewal
      final newExpiryDate = DateTime.now().add(const Duration(days: 30));
      final success = await SubscriptionFirestoreUtils.renewSubscriptionWithDate(
        subscription.value!,
        newExpiryDate,
      );
      if (success) {
        // Update local subscription data
        subscription.value!.expiryDate = newExpiryDate;
        subscription.value!.status = 'ACTIVE';
        subscription.refresh();

        Get.snackbar(
          'Success',
          'Subscription renewed for 30 days',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to renew subscription',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    }
  }

  Future<void> renewSubscriptionWithCustomDate(DateTime newDate) async {
    if (subscription.value != null) {
      final success = await SubscriptionFirestoreUtils.renewSubscriptionWithDate(
        subscription.value!,
        newDate,
      );
      if (success) {
        subscription.value!.expiryDate = newDate;
        subscription.value!.status = 'ACTIVE';
        subscription.refresh();

        Get.snackbar(
          'Success',
          'Subscription renewed successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    }
  }
}