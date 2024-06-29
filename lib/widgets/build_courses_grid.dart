import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../export/export.dart';

Widget buildCoursesGrid(
  List<CourseModel> courses,
  CourseController courseController,
  AdminController adminController,
  int itemCount,
  BuildContext context,
  CourseRegistrationController registrationController,
  User? user,
  VoidCallback onSeeAllCoursesTapped,
  RefreshController refreshController,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Obx(() {
      if (courseController.isLoading.value) {
        return CourseShimmerLoadingWidget(
          itemCount: itemCount,
        );
      }
      if (courses.isEmpty) {
        return const Center(child: Text('No courses found'));
      }

      return SmartRefresher(
        controller: refreshController,
        enablePullDown: true,
        onRefresh: () async {
          await courseController.refreshCourses();
          refreshController.refreshCompleted();
        },
        child: ListView(
          children: <Widget>[
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: getCrossAxisCount(context),
                childAspectRatio: getChildAspectRatio(context),
                crossAxisSpacing: getCrossAxisSpacing(context),
                mainAxisSpacing: getMainAxisSpacing(context),
              ),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                final quizCount = courseController.quizCounts[course.id] ?? 0;
                final admin = adminController.admins.firstWhere(
                  (admin) => admin.id == course.adminId,
                  orElse: () => AdminModel(
                    id: '',
                    name: 'Unknown',
                    email: '',
                    imageUrl: '',
                  ),
                );
                final isRegistered = registrationController.registeredCourses
                    .any((register) => register.courseId == course.id);
                return CourseCard(
                  course: course,
                  admin: admin,
                  quizCount: quizCount,
                  userId: user!.uid,
                  isRegistered: isRegistered,
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(
                      Icons.arrow_forward_outlined,
                      size: 18,
                    ),
                    iconAlignment: IconAlignment.end,
                    onPressed: onSeeAllCoursesTapped,
                    label: const Text(
                      'See all',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.blueAccent,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }),
  );
}
