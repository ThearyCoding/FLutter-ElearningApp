import '../export/export.dart';
class CourseRegistrationController extends GetxController {
  final CourseRegistrationService _courseRegistrationService = CourseRegistrationService();
  var isRegistered = false.obs;
  var hasShownDialog = false.obs;
  var registeredCourses = <CourseRegistration>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCachedRegistrations();
  }

  Future<void> checkRegistration(String userId, String courseId) async {
    // Check if the course is already in the registeredCourses list
    isRegistered.value = registeredCourses.any((course) => course.courseId == courseId);

    // If not found in the registeredCourses list, check the service
    if (!isRegistered.value) {
      isRegistered.value = await _courseRegistrationService.isUserRegisteredForCourse(
        userId: userId,
        courseId: courseId,
      );
    }
  }

  Future<void> registerUser(String userId, String courseId) async {
    await _courseRegistrationService.checkAndRegisterUser(
      userId: userId,
      courseId: courseId,
    );
    await fetchAllRegistrations(userId); // Refresh the registered courses list
    await checkRegistration(userId, courseId); // Recheck registration status
    isRegistered.value = true;
    hasShownDialog.value = false; // Reset the flag to show the dialog once after registration
  }

  Future<void> fetchAllRegistrations(String userId) async {
    try {
      registeredCourses.value = await _courseRegistrationService.getUserRegisteredCourses(userId);
      await cacheRegistrations();
    } catch (e) {
      loadCachedRegistrations();
    }
  }

  Future<void> cacheRegistrations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String registrationsJson = jsonEncode(registeredCourses.map((course) => course.toJson()).toList());
    await prefs.setString('Registration', registrationsJson);
  }

  Future<void> loadCachedRegistrations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? registrationsJson = prefs.getString('Registration');
    if (registrationsJson != null) {
      List<dynamic> registrationsList = jsonDecode(registrationsJson);
      registeredCourses.value = registrationsList.map((json) => CourseRegistration.fromJson(json)).toList();
      
    }
  }
   Future<void> removeCachedRegistrations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('Registration');
  }
}
