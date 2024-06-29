import 'package:flutter/material.dart';
import '../export/export.dart';

class MyCoursesScreen extends StatelessWidget {
  MyCoursesScreen({super.key});
  final User? user = FirebaseAuth.instance.currentUser;
  final CourseController controller = Get.find();
  final AdminController adminController = Get.find();
  final CourseRegistrationController registrationController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Get.back();
          },
        ),
        title: const Text('My Courses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await registrationController.removeCachedRegistrations();
              await registrationController.fetchAllRegistrations(user!.uid);
            },
          ),
        ],
      ),
      body: Obx(() {
        if (registrationController.registeredCourses.isEmpty) {
          return const Center(child: Text('No registered courses found.'));
        }

        final registeredCourseIds = registrationController.registeredCourses
            .map((course) => course.courseId)
            .toList();
        final registeredCourses = controller.courses
            .where((course) => registeredCourseIds.contains(course.id))
            .toList();

        return GridView.builder(
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: registeredCourses.length,
          shrinkWrap: false,
          physics: const BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: getCrossAxisCount(context),
            childAspectRatio: getChildAspectRatio(context),
            crossAxisSpacing: getCrossAxisSpacing(context),
            mainAxisSpacing: getMainAxisSpacing(context),
          ),
          itemBuilder: (ctx, index) {
            final course = registeredCourses[index];

            // Find the admin corresponding to the course's adminId
            final admin = adminController.admins.firstWhere(
              (admin) => admin.id == course.adminId,
              orElse: () => AdminModel(
                id: '',
                name: 'Unknown',
                email: '',
                imageUrl: '',
              ),
            );

            // Get the quiz count for this course
            final quizCount = controller.quizCounts[course.id] ?? 0;

            final isRegistered = registrationController.registeredCourses.any(
              (regCourse) => regCourse.courseId == course.id,
            );

            return CourseCard(
              course: course,
              admin: admin,
              quizCount: quizCount,
              userId: user!.uid,
              isRegistered: isRegistered,
            );
          },
        );
      }),
    );
  }
}
