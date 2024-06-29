
import '../export/export.dart';

class InitialBinding extends Bindings{
   @override
  void dependencies() {
    Get.lazyPut<AdminController>(() => AdminController());
    Get.lazyPut<CourseController>(() => CourseController(),);
    Get.lazyPut<CourseRegistrationController>(() => CourseRegistrationController(),);
    Get.lazyPut<CategoryController>(() => CategoryController(),);
    Get.lazyPut<UserController>(() => UserController(),);
    Get.lazyPut<ThemeController>(() => ThemeController());
    Get.lazyPut<SearchengineController>(() => SearchengineController(),);
  }
}