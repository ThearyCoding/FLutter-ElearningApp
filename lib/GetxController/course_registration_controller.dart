import 'package:e_leaningapp/FirebaseService/course_registration_service.dart';
import 'package:get/get.dart';
import 'package:e_leaningapp/Model/course_registration_model.dart';

class CourseRegistrationController extends GetxController {
  final CourseRegistrationService _courseRegistrationService =
      CourseRegistrationService();
  var isRegistered = false.obs;
  var hasShownDialog = false.obs;
  var registeredCourses = <CourseRegistration>[].obs;

  Future<void> checkRegistration(String userId, String courseId) async {
    // Check if the course is already in the registeredCourses list
    isRegistered.value =
        registeredCourses.any((course) => course.courseId == courseId);

    // If not found in the registeredCourses list, check the service
    if (!isRegistered.value) {
      isRegistered.value =
          await _courseRegistrationService.isUserRegisteredForCourse(
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
    hasShownDialog.value =
        false; // Reset the flag to show the dialog once after registration
  }

  Future<void> fetchAllRegistrations(String userId) async {
    registeredCourses.value =
        await _courseRegistrationService.getUserRegisteredCourses(userId);
  }
}
