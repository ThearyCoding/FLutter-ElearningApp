import 'package:e_leaningapp/widgets/tab_item.dart';
import 'package:flutter/scheduler.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../export/export.dart';
import '../utils/no_internet_connnection.dart';
import '../widgets/build_courses_grid.dart';
import '../widgets/category_widget.dart';

class MyHomePage extends StatefulWidget {
  final VoidCallback? onProfileImageTapped;
  final VoidCallback? onSeeAllCoursesTapped;

  const MyHomePage({super.key, this.onProfileImageTapped, this.onSeeAllCoursesTapped});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CourseController courseController = Get.find();
  final AdminController adminController = Get.find();
  final CourseRegistrationController registrationController = Get.find();
  final UserController userController = Get.find();
  final CategoryController categoryController = Get.find();
  final User? user = FirebaseAuth.instance.currentUser;
  bool isConnectedToInternet = true;
  bool wasConnectedToInternet = true;

  final RefreshController _coursesRefreshController = RefreshController(initialRefresh: false);
  final RefreshController _recentCoursesRefreshController = RefreshController(initialRefresh: false);
  final RefreshController _popularCoursesRefreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);

    courseController.fetchCourses();
    _tabController.addListener(() {
      if (_tabController.index == 1 && !courseController.hasFetchedRecentCourses) {
        courseController.fetchRecentCourses();
      } else if (_tabController.index == 2 && !courseController.hasFetchedPopularCourses) {
        courseController.fetchPopularCourses();
      }
    });

    isConnected();
  }

  void isConnected() {
    InternetConnectionUtils.listenToInternetConnectionStatus((bool isConnected) {
      if (isConnected != wasConnectedToInternet) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              isConnectedToInternet = isConnected;
            });
          }
        });
        wasConnectedToInternet = isConnected;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _coursesRefreshController.dispose();
    _recentCoursesRefreshController.dispose();
    _popularCoursesRefreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text('E-Learning'),
        leading: IconButton(
          icon: ClipOval(child: Image.asset('assets/logo app.jpg')),
          onPressed: null,
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
                      color: Theme.of(context).iconTheme.color,
                      icon: const Icon(Icons.notifications),
                      onPressed: () {},
                    ),
                    ProfileImage(onTap: widget.onProfileImageTapped!)
                  ],
                );
              } else {
                return const SizedBox();
              }
            }),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double expandedHeight;
          int itemCount = 4;
          if (constraints.maxWidth < 360) {
            expandedHeight = 180.0;
            itemCount = 4;
          } else if (constraints.maxWidth < 480) {
            expandedHeight = 210.0;
            itemCount = 4;
          } else if (constraints.maxWidth < 600) {
            expandedHeight = 290.0;
            itemCount = 4;
          } else {
            expandedHeight = 320.0;
            itemCount = 6;
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () => Get.to(() => const SearchEnginePage(), transition: Transition.downToUp),
                  borderRadius: BorderRadius.circular(10),
                  child: Ink(
                    width: MediaQuery.of(context).size.width - 32,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search,
                            size: 24,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            'Search Courses',
                            style: TextStyle(
                              fontSize: 20,
                              color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: NestedScrollView(
                  headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                    return <Widget>[
                      SliverAppBar(
                        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                        automaticallyImplyLeading: false,
                        pinned: false,
                        floating: true,
                        expandedHeight: expandedHeight,
                        flexibleSpace: FlexibleSpaceBar(
                          collapseMode: CollapseMode.pin,
                          background: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: BannerWidget(),
                              ),
                              CategoryWidget(
                                categoryController: categoryController,
                                itemCount: itemCount,
                              )
                            ],
                          ),
                        ),
                      ),
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: SliverAppBarDelegate(
                          TabBar(
                            dividerColor: Colors.transparent,
                            controller: _tabController,
                            indicatorSize: TabBarIndicatorSize.tab,
                            isScrollable: true,
                            indicator: const BoxDecoration(color: Colors.transparent),
                            labelColor: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                            unselectedLabelColor: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white70
                                : Colors.black54,
                            tabs: [
                              TabItem(
                                title: 'Lessons',
                                count: courseController.courses.length,
                              ),
                              TabItem(
                                title: 'Recent Lessons',
                                count: courseController.recentCourses.length,
                              ),
                              TabItem(
                                title: 'Popular Lessons',
                                count: courseController.popularCourses.length,
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
                      _buildTabContent(
                        courses: courseController.courses,
                        controller: _coursesRefreshController,
                      ),
                      _buildTabContent(
                
                        courses: courseController.recentCourses,
                        controller: _recentCoursesRefreshController,
                      ),
                      _buildTabContent(
                    
                        courses: courseController.popularCourses,
                        controller: _popularCoursesRefreshController,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabContent({
    required List<CourseModel> courses,
    required RefreshController controller,
  }) {
    return isConnectedToInternet
        ? buildCoursesGrid(
            courses,
            courseController,
            adminController,
            4,
            context,
            registrationController,
            user,
            widget.onSeeAllCoursesTapped!,
            controller,
          )
        : noInternetConnection(context);
  }
}
