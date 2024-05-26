import 'package:e_leaningapp/Model/Courses_Model.dart';
import 'package:e_leaningapp/Model/admin_model.dart';
import 'package:e_leaningapp/Screen/detail_course_screen.dart';
import 'package:e_leaningapp/utils/responsive_utils.dart';
import 'package:e_leaningapp/utils/time_utils.dart';
import 'package:e_leaningapp/widgets/shimer_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CourseCard extends StatelessWidget {
  final CourseModel course;
  final AdminModel admin;
  final int quizCount;

  const CourseCard(
      {super.key,
      required this.course,
      required this.admin,
      required this.quizCount});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.to(
            DetailCourseScreen(
              categoryId: course.categoryId,
              course: course,
              admin: admin,
            ),
            transition: Transition.downToUp);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                ShimmerImage(
                  imageUrl: course.imageUrl,
                  height: getResponsiveWidth(context, 110),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
                if (TimeUtils.isNew(course.timestamp, 4, TimeUnit.days))
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      color: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      child: const Text(
                        'NEW',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                Positioned(
                  left: 8,
                  bottom: -15,
                  right: 8,
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          admin.imageUrl,
                          height: getResponsiveHeight(context, 70),
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          admin.name,
                          style: TextStyle(
                              fontSize: getResponsiveFontSize(context, 15),
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 10.0, right: 10.0, top: 20.0, bottom: 10.0),
              child: Text(
                course.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: getResponsiveFontSize(context, 18),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Column(
                    children: [
                      const Icon(Icons.play_circle_outline, size: 16),
                      Text(
                        '${course.videoCount}',
                        style: TextStyle(
                          fontSize: getResponsiveFontSize(context, 14),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                       Icon(Icons.picture_as_pdf, size: 16,
                            color: Theme.of(context).iconTheme.color,
                      ),
                      Text(
                        '${course.pdfCount}',
                        style: TextStyle(
                          fontSize: getResponsiveFontSize(context, 14),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Icon(Icons.quiz, size: 16),
                      Text(
                        '$quizCount',
                        style: TextStyle(
                          fontSize: getResponsiveFontSize(context, 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Divider(
                color: Colors.grey,
                thickness: 1,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  course.originalPrice == 0 && course.discountedPrice == 0
                      ? Text(
                          "Free",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: getResponsiveFontSize(context, 14),
                          ),
                        )
                      : Row(
                          children: [
                            Text(
                              '\$${course.discountedPrice}',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: getResponsiveFontSize(context, 14),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              '\$${course.originalPrice}',
                              style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                fontSize: getResponsiveFontSize(context, 14),
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                  width: getResponsiveWidth(context, 32),
                                  height: getResponsiveHeight(context, 32),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: Colors.blue[200]),
                                  child: const Icon(
                                    Icons.shopping_bag,
                                    size: 18,
                                  )),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
