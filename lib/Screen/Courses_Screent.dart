
import 'package:e_leaningapp/GetxController/admin_controller.dart';
import 'package:e_leaningapp/GetxController/course_controller.dart';
import 'package:e_leaningapp/Model/admin_model.dart';
import 'package:e_leaningapp/Model/category_Model.dart';
import 'package:e_leaningapp/utils/responsive_utils.dart';
import 'package:e_leaningapp/widgets/course_card.dart';
import 'package:e_leaningapp/widgets/course_shimmer_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CoursesScreen extends StatefulWidget {
  final CategoryModel category;
  CoursesScreen({required this.category});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final CourseController controller = Get.put(CourseController());
  final AdminController adminController = Get.put(AdminController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getCoursesByCategory(widget.category.id);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.title),
      ),
      body: Obx(() {
        if (controller.isLoading.value || adminController.isLoading.value) {
          return const CourseShimerWidget();
        } else if (controller.courseByCategoryId.isEmpty) {
          return const Center(child: Text('No courses found for this category.'));
        } else {
          return GridView.builder(
           padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
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

              // Get the quiz count for this course
              final quizCount = controller.quizCounts[course.id] ?? 0;

              return CourseCard(
                course: course,
                admin: admin,
                quizCount: quizCount,
              );
            },
          );
        }
      }),
    );
  }
}
