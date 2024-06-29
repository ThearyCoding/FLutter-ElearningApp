import 'package:e_leaningapp/controller/admin_controller.dart';
import 'package:e_leaningapp/controller/course_controller.dart';
import 'package:e_leaningapp/Model/admin_model.dart';
import 'package:e_leaningapp/Model/category_Model.dart';
import 'package:e_leaningapp/controller/course_registration_controller.dart';
import 'package:e_leaningapp/utils/responsive_utils.dart';
import 'package:e_leaningapp/widgets/course_card.dart';
import 'package:e_leaningapp/widgets/course_shimmer_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CoursesScreen extends StatefulWidget {
  final CategoryModel category;
  final int itemCount;
  const CoursesScreen({super.key, required this.category, required this.itemCount});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final CourseController controller = Get.find();
  final AdminController adminController = Get.find();
  final CourseRegistrationController courseRegistrationController = Get.find();
  User? user = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getCoursesByCategory(widget.category.id);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.title),
      ),
      body: Obx(() {
        if (controller.isLoading.value || adminController.isLoading.value) {
          return  CourseShimmerLoadingWidget(itemCount: widget.itemCount,);
        } else if (controller.courseByCategoryId.isEmpty) {
          return const Center(
              child: Text('No courses found for this category.'));
        } else {
          return GridView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: getCrossAxisCount(context),
              childAspectRatio: getChildAspectRatio(context),
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: controller.courseByCategoryId.length,
            itemBuilder: (context, index) {
              final course = controller.courseByCategoryId[index];

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
              final isRegistered = courseRegistrationController
                  .registeredCourses
                  .any((register) => register.courseId == course.id);
              // Get the quiz count for this course
              final quizCount = controller.quizCounts[course.id] ?? 0;
              return CourseCard(
                course: course,
                admin: admin,
                quizCount: quizCount,
                userId: user!.uid,
                isRegistered: isRegistered,
              );
            },
          );
        }
      }),
    );
  }
}
