import '../export/export.dart';
export 'package:flutter/material.dart';

class CategoryWidget extends StatelessWidget {
  final CategoryController categoryController;
  final int itemCount;
  const CategoryWidget({super.key, required this.categoryController, required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double widgetHeight;
        double widgetWidth = 200;
        double fontSize = 16;
        if (constraints.maxWidth < 360) {
          // Small mobile devices
          widgetHeight = 80.0;
          fontSize = 10;
        } else if (constraints.maxWidth < 480) {
          // Medium mobile devices
          widgetHeight = 90.0;
          widgetWidth = 180;
          fontSize = 12;
        } else if (constraints.maxWidth < 600) {
          // Large mobile devices
          widgetHeight = 120.0;
          widgetWidth = 200.0;
          fontSize = 16;
        } else {
          // Tablets
          widgetHeight = 160.0;
          widgetWidth = 220.0;
          fontSize = 18;
        }

        return SizedBox(
          height: widgetHeight,
          child: Obx(() {
            if (categoryController.categories.isEmpty &&
                !categoryController.isLoading.value) {
              return const Center(
                child: Text("No Categories Found yet!"),
              );
            }
            if (categoryController.isLoading.value) {
              return BuildCategoriesShimmerWidget();
            }
            return ListView.separated(
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
                      Get.to(CoursesScreen(category: category,itemCount: itemCount,),
                          transition: Transition.cupertino);
                    },
                    child: CategoryCard(
                      imageUrl: category.imageUrl,
                      title: category.title,
                      widgetWidth: widgetWidth,
                      fontSize: fontSize,
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return const SizedBox(width: 5);
              },
            );
          }),
        );
      },
    );
  }
}
