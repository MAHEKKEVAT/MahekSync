import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_navigation/src/routes/route_middleware.dart';

import '../routes/app_pages.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null && route != Routes.LOGIN_SCREEN) {
      return const RouteSettings(name: Routes.LOGIN_SCREEN);
    }
    return null;
  }
}