import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/constant/toast_service.dart';
import 'package:maheksync/app/modules/splash_screen/views/splash_screen_view.dart';
import 'package:provider/provider.dart';
import 'app/constant/global_controller.dart';
import 'app/routes/app_pages.dart';
import 'app/utils/app_colors.dart';
import 'app/utils/dark_theme_provider.dart';
import 'app/utils/preferences.dart';
import 'app/utils/styles.dart';
import 'firebase_options.dart';

// lib/main.dart - Alternative with App Check disabled in debug mode
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Preferences.initPref();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseFirestore.instance.settings = Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // Only activate App Check in production (non-debug, non-web for now)
  if (!kDebugMode && !kIsWeb) {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.appAttest,
    );
  }

  configLoading();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  @override
  void initState() {
    getCurrentAppTheme();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    getCurrentAppTheme();
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme = await themeChangeProvider.darkThemePreference.isDarkThemee();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      behavior: HitTestBehavior.translucent,
      child: ChangeNotifierProvider(
        create: (_) => themeChangeProvider,
        child: Consumer<DarkThemeProvider>(
          builder: (context, value, child) {
            return GetMaterialApp(
              navigatorKey: navigatorKey,
              title: 'Mahek Owner'.tr,
              debugShowCheckedModeBanner: false,
              theme: Styles.themeData(
                themeChangeProvider.darkTheme == 0
                    ? true
                    : themeChangeProvider.darkTheme == 1
                    ? false
                    : themeChangeProvider.getSystemThem(),
                context,
              ),
              darkTheme: Styles.themeData(true, context),
              themeMode: themeChangeProvider.darkTheme == 1 ? ThemeMode.light : ThemeMode.dark,
              builder: EasyLoading.init(),
              initialRoute: AppPages.INITIAL,
              getPages: AppPages.routes,
              home: GetBuilder<GlobalController>(
                init: GlobalController(),
                builder: (context) {
                  return const SplashScreenView();
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 45
    ..radius = 10
    ..progressColor = AppThemeData.primary50
    ..backgroundColor = AppThemeData.primaryWhite
    ..indicatorColor = AppThemeData.primary50
    ..textColor = AppThemeData.primary50
    ..maskColor = AppThemeData.primaryWhite
    ..dismissOnTap = false
    ..userInteractions = false;
}
