import 'package:e_leaningapp/FirebaseService/auth_service_google.dart';
import 'package:e_leaningapp/GetxController/theme_controller.dart';
import 'package:e_leaningapp/Screen/CompleteInfo_Screen.dart';
import 'package:e_leaningapp/Screen/login-page.dart';
import 'package:e_leaningapp/firebase_options.dart';
import 'package:e_leaningapp/local_storage/user_authentication_local_storage.dart';
import 'package:e_leaningapp/theme/custom_theme.dart';
import 'package:e_leaningapp/widgets/bottom_navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SharedPreferences.getInstance();
    await GetStorage.init();
    Get.put(ThemeController());
  Get.put(
      LocalStorageSharedPreferences());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: CustomThemes.lightTheme,
      darkTheme: CustomThemes.darkTheme,
      themeMode: Get.find<ThemeController>().getThemeModeFromStorage(),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => LoginPage()), // LoginPage route
        GetPage(
            name: '/complete-info',
            page: () =>
                const CompleteInformations()), // CompleteInformations route
        GetPage(
            name: '/home', page: () => const HomeScreen()), // MyHomePage route
      ],
      builder: EasyLoading.init(),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else if (snapshot.connectionState == ConnectionState.active) {
            User? currentUser = snapshot.data;

            // Check if the user is authenticated
            if (currentUser != null) {
              // Access isLoggedIn from LocalStorageSharedPreferences controller
              bool isLoggedIn =
                  Get.find<LocalStorageSharedPreferences>().isLoggedIn.value;

              if (isLoggedIn) {
                return const HomeScreen();
              } else {
                // User not authenticated, navigate to LoginPage
                return FutureBuilder<bool>(
                  future:
                      AuthServiceGoogle().isInformationComplete(currentUser),
                  builder: (context, infoSnapshot) {
                    if (infoSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      // Information completeness is being verified, show loading indicator
                      return const Center(
                        child: CupertinoActivityIndicator(),
                      );
                    } else {
                      if (infoSnapshot.data == true) {
                        Get.find<LocalStorageSharedPreferences>()
                            .saveUserLoginStatus(true);
                        // User authenticated and information is complete, navigate to HomePage
                        return const HomeScreen();
                      } else {
                        // User authenticated but information is not complete, stay on CompleteInfo1 page
                        return const CompleteInformations();
                      }
                    }
                  },
                );
              }
            } else {
              // User not authenticated, navigate to LoginPage
              return LoginPage();
            }
          } else if (snapshot.data == null) {
            return LoginPage();
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CupertinoActivityIndicator(),
            );
          }
          return LoginPage();
        },
      ),
    );
  }
}
