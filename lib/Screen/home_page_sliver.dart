import 'package:e_leaningapp/GetxController/admin_controller.dart';
import 'package:e_leaningapp/GetxController/category_controller.dart';
import 'package:e_leaningapp/GetxController/course_controller.dart';
import 'package:e_leaningapp/GetxController/course_registration_controller.dart';
import 'package:e_leaningapp/GetxController/user_profile_controller.dart';
import 'package:e_leaningapp/Model/admin_model.dart';
import 'package:e_leaningapp/local_storage/user_authentication_local_storage.dart';
import 'package:e_leaningapp/utils/responsive_utils.dart';
import 'package:e_leaningapp/widgets/category_widget.dart';
import 'package:e_leaningapp/widgets/course_card.dart';
import 'package:e_leaningapp/widgets/course_shimmer_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ignore: use_key_in_widget_constructors
class MyHomePage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CourseController courseController = Get.put(CourseController());
  final AdminController adminController = Get.put(AdminController());
  late LocalStorageSharedPreferences
      localStorageController; // Declare the variable
  final User? user = FirebaseAuth.instance.currentUser;
  final CourseRegistrationController _courseRegistrationController =
      Get.put(CourseRegistrationController());
  @override
void initState() {
  super.initState();
  _tabController = TabController(length: 3, vsync: this);
  localStorageController = Get.find<LocalStorageSharedPreferences>();
  _courseRegistrationController.fetchAllRegistrations(user!.uid);
 
  // Add listener to TabController to handle tab changes
  if(mounted){
   courseController.fetchCourses();
  }
  _tabController.addListener(() {
    if (_tabController.index == 1 && !courseController.hasFetchedRecentCourses) {
      if (mounted) { // Check if the state is still mounted
        courseController.fetchRecentCourses();
      }
    } else if (_tabController.index == 2 && !courseController.hasFetchedPopularCourses) {
      if (mounted) { // Check if the state is still mounted
        courseController.fetchPopularCourses();
      }
    }
  });
}


  int totalQuestionQuiz = 0;
  final UserController userController = Get.put(UserController());
  final CategoryController categoryController = Get.put(CategoryController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
         title: Text(
      'Learn New Technology!',
      style: TextStyle(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.black // Use black text color for light theme
            : Colors.white, // Use white text color for dark theme
      ),
    ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Obx(() {
              if (userController.user.value != null) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications),
                      onPressed: () {},
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.network(
                          userController.user.value!.photoURL,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return const SizedBox();
              }
            }),
          ),
        ],
      ),
      body: Column(
        children: [
        Padding(
      padding: EdgeInsets.all(8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.onSecondary, // Text and icon color
          backgroundColor: Theme.of(context).colorScheme.secondary, // Button background color
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0, vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {},
        child: const Row(
          children: [
            Icon(
              Icons.search,
              size: 24,
            ),
            SizedBox(width: 8.0),
            Text(
              'Search Courses',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    ),
          Expanded(
            child: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    automaticallyImplyLeading: false,
                    pinned: false,
                    floating: true,
                    expandedHeight: 300.0,
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.pin,
                      background: Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.lightbulb_outline),
                                  label: const Text('ពត៌មាន'),
                                  onPressed: () {},
                                ),
                                TextButton.icon(
                                  icon: const Icon(Icons.description),
                                  label: const Text('ឯកសារសៀវភៅ'),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ),
                          Container(
                            color: Colors.blueAccent,
                            padding: const EdgeInsets.all(16.0),
                            margin: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    'អនុវត្តីនិស្សិត: មកពីរាជបណ្ឌិត្យសភា\nចំនួន៖ ១០នាក់',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                          CategoryWidget(categoryController: categoryController)
                        ],
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        indicatorWeight: 5.6,
                        indicatorColor: Colors.orange,
                        tabAlignment: TabAlignment.start,
                        isScrollable: true,
                        controller: _tabController,
                        tabs: const [
                          Tab(
                            child: Text(
                              "Lessons",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          Tab(
                            child: Text(
                              "Recent Lessons",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          Tab(
                            child: Text(
                              "popular Lessons",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  Obx(() {
                    if (courseController.isLoading.value ||
                        adminController.isLoading.value) {
                      return const CourseShimerWidget();
                    } else if (courseController.courses.isEmpty ||
                        adminController.admins.isEmpty) {
                      return const Center(
                        child: Text("No Course Found yet!"),
                      );
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
                        itemCount: courseController.courses.length,
                        itemBuilder: (context, index) {
                          final course = courseController.courses[index];
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
                          return CourseCard(
                            course: course,
                            admin: admin,
                            quizCount: totalQuestionQuiz,
                          );
                        },
                      );
                    }
                  }),
                  Obx(() {
                    if (courseController.isLoading.value) {
                      return const CourseShimerWidget();
                    }

                    if (courseController.recentCourses.isEmpty) {
                      return const Center(
                          child: Text('No recent courses found'));
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: getCrossAxisCount(context),
                        childAspectRatio: getChildAspectRatio(context),
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: courseController.recentCourses.length,
                      itemBuilder: (context, index) {
                        final course = courseController.recentCourses[index];

                        final admin = adminController.admins.firstWhere(
                          (admin) => admin.id == course.adminId,
                          orElse: () => AdminModel(
                            id: '',
                            name: 'Unknown',
                            email: '',
                            imageUrl: '',
                          ),
                        );
                        return CourseCard(
                          course: course,
                          admin: admin,
                          quizCount: totalQuestionQuiz,
                        );
                      },
                    );
                  }),
                  Obx(() {
                    if (courseController.isLoading.value) {
                      return const CourseShimerWidget();
                    }
                    if (courseController.popularCourses.isEmpty) {
                      return const Center(
                          child: Text('No popular courses found'));
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: getCrossAxisCount(context),
                        childAspectRatio: getChildAspectRatio(context),
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: courseController.popularCourses.length,
                      itemBuilder: (context, index) {
                        final course = courseController.popularCourses[index];
                        final admin = adminController.admins.firstWhere(
                          (admin) => admin.id == course.adminId,
                          orElse: () => AdminModel(
                            id: '',
                            name: 'Unknown',
                            email: '',
                            imageUrl: '',
                          ),
                        );
                        return CourseCard(
                            course: course,
                            admin: admin,
                            quizCount: totalQuestionQuiz);
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
