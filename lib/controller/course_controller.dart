
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../export/export.dart';

class CourseController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  final RxList<CourseModel> courses = <CourseModel>[].obs;
  final RxList<CourseModel> courseByCategoryId = <CourseModel>[].obs;
  final RxMap<String, int> quizCounts = <String, int>{}.obs;
  final RxList<CourseModel> recentCourses = <CourseModel>[].obs;
  final RxList<CourseModel> popularCourses = <CourseModel>[].obs;
  final isLoading = false.obs;
  final RefreshController refreshController = RefreshController(initialRefresh: false);

  // Flags to track if data has already been fetched
  bool hasFetchedRecentCourses = false;
  bool hasFetchedPopularCourses = false;

  @override
  void onInit() {
    super.onInit();
    fetchCourses();
    fetchRecentCourses();
    fetchPopularCourses();
  }

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }

  Future<void> fetchQuizCount(String courseId) async {
    try {
      int count = await _firebaseService.fetchTotalQuestions(courseId);
      quizCounts[courseId] = count;
    } catch (error) {
      debugPrint('Error fetching quiz count: $error');
    }
  }

  void fetchRecentCourses() {
    if (hasFetchedRecentCourses) return;
    try {
      isLoading(true);
      FirebaseFirestore.instance
          .collectionGroup('courses')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .snapshots()
          .listen((courseQuery) {
        recentCourses.value = courseQuery.docs
            .map((doc) => CourseModel.fromJson(doc.data()))
            .toList();
        isLoading(false);
        hasFetchedRecentCourses = true;
      });
    } catch (e) {
      debugPrint('Error fetching recent courses: $e');
      isLoading(false);
      rethrow;
    }
  }

  void fetchPopularCourses() {
    if (hasFetchedPopularCourses) return;
    try {
      isLoading(true);
      FirebaseFirestore.instance
          .collectionGroup('courses')
          .orderBy('registerCounts', descending: true)
          .limit(10) // Fetch the top 10 popular courses
          .snapshots()
          .listen((courseQuery) {
        popularCourses.value = courseQuery.docs
            .map((doc) => CourseModel.fromJson(doc.data()))
            .toList();
        isLoading(false);
        hasFetchedPopularCourses = true;
      });
    } catch (e) {
      debugPrint('Error fetching popular courses: $e');
      isLoading(false);
      rethrow;
    }
  }

  void fetchCourses() async {
    try {
      isLoading(true);
      _firebaseService.fetchCourses().listen((fetchedCourses) async {
        courses.assignAll(fetchedCourses);
        courses.shuffle();
        // Fetch counts for each course in parallel
        await Future.wait(courses.map((course) async {
          await Future.wait([
            fetchQuizCount(course.id), // Fetch Quiz counts
          ]);
        }));
        isLoading(false);
      });
    } catch (e) {
      debugPrint('Error fetching courses: $e');
      isLoading(false);
    }
  }

  void getCoursesByCategory(String categoryId) {
    try {
      isLoading(true);
      _firebaseService
          .getCoursesByCategoryStream(categoryId)
          .listen((filterByCategoryId) {
        courseByCategoryId.assignAll(filterByCategoryId);

        // Fetch quiz counts for each course in the category
        for (var course in filterByCategoryId) {
          _firebaseService.fetchTotalQuestions(course.id).then((quizCount) {
            quizCounts[course.id] = quizCount;
          });
        }
        isLoading(false);
      });
    } catch (error) {
      debugPrint('Error fetching courses by category: $error');
      isLoading(false);
    }
  }

  // Refresh method to re-fetch the courses and update counts
  Future<void> refreshCourses() async {
    try {
      isLoading(true);
        fetchCourses(); // Re-fetch the courses
      // Re-fetch the counts for each course
      await Future.wait(courses.map((course) async {
        await Future.wait([
          fetchQuizCount(course.id),
        ]);
      }));
      isLoading(false);
      refreshController.refreshCompleted(); // Notify the refreshController that refresh is completed
    } catch (e) {
      debugPrint('Error refreshing courses: $e');
      isLoading(false);
      refreshController.refreshFailed(); // Notify the refreshController that refresh has failed
    }
  }
}
