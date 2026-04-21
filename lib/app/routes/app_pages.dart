import 'package:get/get.dart';

import '../modules/add_edit_purchase/bindings/add_edit_purchase_binding.dart';
import '../modules/add_edit_purchase/views/add_edit_purchase_view.dart';
import '../modules/add_new_devices/bindings/add_new_devices_binding.dart';
import '../modules/add_new_devices/views/add_new_devices_view.dart';
import '../modules/admin_profile/bindings/admin_profile_binding.dart';
import '../modules/admin_profile/views/admin_profile_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/auth_view.dart';
import '../modules/categories/bindings/categories_binding.dart';
import '../modules/categories/views/categories_view.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/login_screen/bindings/login_screen_binding.dart';
import '../modules/login_screen/views/login_screen_view.dart';
import '../modules/my_devices/bindings/my_devices_binding.dart';
import '../modules/my_purchases/bindings/my_purchases_binding.dart';
import '../modules/my_purchases/views/my_purchases_view.dart';
import '../modules/payement_method/bindings/payement_method_binding.dart';
import '../modules/payement_method/views/payement_method_view.dart';
import '../modules/policy_settings/bindings/policy_settings_binding.dart';
import '../modules/policy_settings/views/policy_settings_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/sign_up/bindings/sign_up_binding.dart';
import '../modules/sign_up/views/sign_up_view.dart';
import '../modules/splash_screen/bindings/splash_screen_binding.dart';
import '../modules/splash_screen/views/splash_screen_view.dart';
import '../modules/view_devices/bindings/view_devices_binding.dart';
import '../modules/view_devices/views/view_devices_view.dart';
import '../utils/auth_middleware.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH_SCREEN;

  static GetPage _dashboardPage(String name, {Bindings? screenBinding}) {
    return GetPage(
      name: name,
      page: () => const DashboardView(),
      bindings: [
        DashboardBinding(),
        if (screenBinding != null) screenBinding,
      ],
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    );
  }

  static final routes = [
    GetPage(
      name: _Paths.SPLASH_SCREEN,
      page: () => const SplashScreenView(),
      binding: SplashScreenBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN_SCREEN,
      page: () => const LoginScreenView(),
      binding: LoginScreenBinding(),
    ),
    GetPage(
      name: _Paths.AUTH,
      page: () => const AuthView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.SIGN_UP,
      page: () => const SignUpView(),
      binding: SignUpBinding(),
    ),

    // Standalone pages (NOT nested under dashboard)
    GetPage(
      name: _Paths.ADD_NEW_DEVICES,
      page: () => const AddNewDevicesView(),
      binding: AddNewDevicesBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.VIEW_DEVICES,
      page: () => const ViewDevicesView(),
      binding: ViewDevicesBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.ADMIN_PROFILE,
      page: () => const AdminProfileView(),
      binding: AdminProfileBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.POLICY_SETTINGS,
      page: () => const PolicySettingsView(),
      binding: PolicySettingsBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
      middlewares: [AuthMiddleware()],
    ),

    // Dashboard-embedded pages
    _dashboardPage(_Paths.DASHBOARD),
    _dashboardPage(_Paths.HOME),
    _dashboardPage(_Paths.MY_DEVICES, screenBinding: MyDevicesBinding()),
    _dashboardPage(_Paths.WARRANTY_TRACKER),
    _dashboardPage(_Paths.EXPENSES),
    _dashboardPage(_Paths.SUPPORT),
    _dashboardPage(_Paths.CATEGORIES, screenBinding: CategoriesBinding()),
    _dashboardPage(_Paths.MY_PURCHASES, screenBinding: MyPurchasesBinding()),


    _dashboardPage(_Paths.PAYMENT_METHODS,
        screenBinding: PaymentMethodsBinding()),
    GetPage(
      name: _Paths.CATEGORIES,
      page: () => const CategoriesView(),
      binding: CategoriesBinding(),
    ),
    GetPage(
      name: _Paths.ADD_EDIT_PURCHASE,
      page: () => const AddEditPurchaseView(),
      binding: AddEditPurchaseBinding(),
    ),
  ];
}
