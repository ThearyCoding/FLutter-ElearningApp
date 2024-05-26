import 'package:e_leaningapp/GetxController/category_controller.dart';
import 'package:e_leaningapp/Screen/Courses_Screent.dart';
import 'package:e_leaningapp/widgets/category_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class CategoryWidget extends StatelessWidget {
  final CategoryController categoryController;
  const CategoryWidget({super.key, required this.categoryController});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Obx(() => ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categoryController.categories.length,
            itemBuilder: (context, index) {
              final category = categoryController.categories[index];
              return Container(
                padding: EdgeInsets.only(
                  left: index == 0 ? 10.0 : 0.0,
                  top: 10,
                ),
                child: GestureDetector(
                  onTap: () {

                      Get.to(CoursesScreen(category: category), transition: Transition.cupertino);
                  
                  },
                  child: CategoryCard(
                    imageUrl: category.imageUrl,
                    title: category.title,
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) {
              return const SizedBox(width: 5);
            },
          )),
    );
  }
}
