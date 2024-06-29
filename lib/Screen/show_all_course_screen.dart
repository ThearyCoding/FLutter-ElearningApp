import 'package:e_leaningapp/controller/all_courses_controller.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../export/export.dart';
import '../widgets/category_item_widget.dart';

class AllCoursesScreen extends StatelessWidget {
  final AllCoursesController _controller = Get.put(AllCoursesController());
  final CourseRegistrationController registrationController = Get.find();
  AllCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Courses"),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildCategoryList(context),
              Expanded(
                child: Obx(() {
                  if (_controller.isLoading.value) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: CourseShimmerLoadingWidget(itemCount: 6),
                    );
                  } else if( _controller.courses.isEmpty){
                    return const Center(
                      child: Text('No have course yet at this time!'),
                    );
                  }
                  else {
                    return SmartRefresher(
                      controller: _controller.refreshController,
                      enablePullDown: true,
                      enablePullUp: true,
                      onRefresh: _controller.refreshCourses,
                      onLoading: () => _controller.fetchCourses(isPagination: true),
                      child: GridView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: getCrossAxisCount(context),
                          childAspectRatio: getChildAspectRatio(context),
                          crossAxisSpacing: getCrossAxisSpacing(context),
                          mainAxisSpacing: getMainAxisSpacing(context),
                        ),
                        itemCount: _controller.courses.length,
                        itemBuilder: (context, index) {
                          final course = _controller.courses[index].data()!;
                          final quizCount = _controller.quizCounts[course.id] ?? 0;
                          final admin = _controller.adminMap[course.adminId] ??
                              AdminModel(
                                id: '',
                                name: 'Unknown',
                                email: '',
                                imageUrl: '',
                              );
                          final isRegistered = registrationController.registeredCourses.any((register) => register.courseId == course.id);
                          return CourseCard(
                            course: course,
                            admin: admin,
                            quizCount: quizCount,
                            userId: _controller.user!.uid,
                            isRegistered: isRegistered,
                          );
                        },
                      ),
                    );
                  }
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context) {
    return GetBuilder<AllCoursesController>(
      init: _controller,
      builder: (controller) {
        return SizedBox(
          height: 60,
          child: ListView.builder(
            controller: _controller.categoryScrollController,
            scrollDirection: Axis.horizontal,
            itemCount: controller.categories.length,
            itemBuilder: (context, index) {
              final category = controller.categories[index];
              final isSelected = category.id == controller.selectedCategory.value;
              final isLightTheme = Theme.of(context).brightness == Brightness.light;

              return GestureDetector(
                onTap: () {
                  controller.getCoursesByCategory(category.id);
                  _scrollToCenter(index);
                },
                child: CategoryItem(
                  category: category,
                  isSelected: isSelected,
                  isLightTheme: isLightTheme,
                  itemKey: controller.categoryItemKeys[index],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _scrollToCenter(int index) {
    // Get the sizes of the category items
    final itemKeys = _controller.categoryItemKeys;
    if (itemKeys.length <= index || itemKeys[index].currentContext == null) return;

    // Calculate the width of all previous items
    double scrollOffset = 0.0;
    for (int i = 0; i < index; i++) {
      final context = itemKeys[i].currentContext;
      if (context != null) {
        final box = context.findRenderObject() as RenderBox;
        scrollOffset += box.size.width;
      }
    }

    // Calculate the width of the current item
    final currentContext = itemKeys[index].currentContext;
    if (currentContext != null) {
      final currentBox = currentContext.findRenderObject() as RenderBox;
      scrollOffset += currentBox.size.width / 2;
    }

    // Center the selected item
    final screenWidth = Get.context!.size!.width;
    final centeredOffset = scrollOffset - screenWidth / 2;

    // Ensure offset stays within bounds
    final maxScrollExtent = _controller.categoryScrollController.position.maxScrollExtent;
    final minScrollExtent = _controller.categoryScrollController.position.minScrollExtent;
    final adjustedOffset = centeredOffset.clamp(minScrollExtent, maxScrollExtent);

    _controller.categoryScrollController.animateTo(
      adjustedOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}

