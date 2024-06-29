

import '../export/export.dart';

class AppRoutes {
  static const login = '/';
  static const home = '/home';
  static const completeInfo = '/complete-info';
  static const result = '/result';

  static final routes = [
    GetPage(
      name: '/',
      page: () => LoginScreen(),
    ),
    GetPage(
      name: '/complete-info',
      page: () => const CompleteInformations(),
    ),
    GetPage(
      name: '/home',
      page: () => const HomeScreen(),
    ),
   
  ];
}
