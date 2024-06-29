import 'package:flutter/services.dart';
import 'export/export.dart';
import 'service/firebase/auth_state_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  );
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SharedPreferences.getInstance();
  Get.put(ThemeController());
  Get.put(LocalStorageSharedPreferences());
  Get.put(SearchengineController());
  runApp(const MyApp());
  configLoading();
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
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.login,
      getPages: AppRoutes.routes,
      builder: EasyLoading.init(),
      home: const AuthStateHandler(),
    );
  }
}
