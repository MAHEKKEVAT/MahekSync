// lib/app/modules/splash_screen/controllers/splash_screen_controller.dart
import 'dart:async';
import 'package:get/get.dart';
import 'package:maheksync/app/routes/app_pages.dart';
import 'package:maheksync/app/utils/fire_store_utils.dart';
import '../../../constant/constants.dart';

class SplashScreenController extends GetxController {
  final progressValue = 0.0.obs;
  final statusMessage = 'INITIALIZING WORKSPACE'.obs;
  final subStatusMessage = 'Curating your executive dashboard and editorial assets.'.obs;

  Timer? _progressTimer;

  @override
  void onInit() {
    super.onInit();
    _startProgressAnimation();
    _checkAuthAndNavigate();
  }

  void _startProgressAnimation() {
    const totalSteps = 4;
    const stepDuration = Duration(milliseconds: 400);
    const progressIncrement = 1.0 / totalSteps;

    int currentStep = 0;

    _progressTimer = Timer.periodic(stepDuration, (timer) {
      currentStep++;

      if (currentStep <= totalSteps) {
        progressValue.value = currentStep * progressIncrement;

        // Update status messages at each step
        switch (currentStep) {
          case 1:
            statusMessage.value = 'LOADING ASSETS';
            subStatusMessage.value = 'Preparing editorial tools and resources.';
            break;
          case 2:
            statusMessage.value = 'ESTABLISHING CONNECTION';
            subStatusMessage.value = 'Securing encrypted session.';
            break;
          case 3:
            statusMessage.value = 'SYNCHRONIZING DATA';
            subStatusMessage.value = 'Loading dashboard configuration.';
            break;
          case 4:
            statusMessage.value = 'READY';
            subStatusMessage.value = 'Workspace initialized successfully.';
            break;
        }
      } else {
        _progressTimer?.cancel();
      }
    });
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for minimum splash duration (2.5 seconds)
    await Future.delayed(const Duration(milliseconds: 2500));

    // Check if user is logged in
    final isLoggedIn = await FireStoreUtils.isLogin();

    if (isLoggedIn) {
      // Refresh user data
      final uid = FireStoreUtils.getCurrentUid();
      if (uid != null) {
        final userModel = await FireStoreUtils.getOwnerProfile(uid);
        if (userModel != null) {
          MahekConstant.ownerModel = userModel;
          MahekConstant.isLogin = true;
          Get.offAllNamed(Routes.DASHBOARD);
        } else {
          Get.offAllNamed(Routes.LOGIN_SCREEN);
        }
      } else {
        Get.offAllNamed(Routes.LOGIN_SCREEN);
      }
    } else {
      // Navigate to login after a short delay for smooth transition
      await Future.delayed(const Duration(milliseconds: 300));
      Get.offAllNamed(Routes.LOGIN_SCREEN);
    }
  }

  @override
  void onClose() {
    _progressTimer?.cancel();
    super.onClose();
  }
}