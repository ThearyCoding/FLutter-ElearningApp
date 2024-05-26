import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_leaningapp/FirebaseService/Firebase_Service.dart';
import 'package:e_leaningapp/Model/Courses_Model.dart';
import 'package:get/get.dart';

class CourseController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  final RxList<CourseModel> courses = <CourseModel>[].obs;
  final RxList<CourseModel> courseByCategoryId = <CourseModel>[].obs;
  final RxMap<String, int> quizCounts = <String, int>{}.obs;
  final RxList<CourseModel> recentCourses = <CourseModel>[].obs;
  final RxList<CourseModel> popularCourses = <CourseModel>[].obs;
  final isLoading = false.obs;
 // Flags to track if data has already been fetched
  bool hasFetchedRecentCourses = false;
  bool hasFetchedPopularCourses = false;
  @override
  void onInit() {
    super.onInit();
    fetchCourses();
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
            .map((doc) => CourseModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
        isLoading(false);
                hasFetchedRecentCourses = true;

      });
    } catch (e) {
      print('Error fetching recent courses: $e');
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
            .map((doc) => CourseModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
        hasFetchedRecentCourses = true;
      });
    } catch (e) {
      print('Error fetching popular courses: $e');
      isLoading(false);
      rethrow;
    }finally{
      isLoading(false);
    }
  }

  void fetchCourses() {
    try {
      isLoading(true);
      FirebaseFirestore.instance.collectionGroup('courses').snapshots().listen((courseQuery) {
        courses.value = courseQuery.docs
            .map((doc) => CourseModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
        isLoading(false);
      });
    } catch (e) {
      print('Error fetching courses: $e');
      isLoading(false);
    }
  }

  void getCoursesByCategory(String categoryId) {
    try {
      isLoading(true);
      _firebaseService.getCoursesByCategoryStream(categoryId).listen((filterByCategoryId) {
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
      print('Error fetching courses by category: $error');
      isLoading(false);
    }
  }
}
