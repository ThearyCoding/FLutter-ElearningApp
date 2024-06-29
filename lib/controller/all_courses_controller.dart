import 'dart:async';
import 'dart:io';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../export/export.dart';
import '../utils/show_error_utils.dart';

class AllCoursesController extends GetxController {
  late RefreshController refreshController;
  var courses = <DocumentSnapshot<CourseModel>>[].obs;
    late ScrollController categoryScrollController;
  var isLoading = false.obs;
  var isPaginating = false.obs;
  var adminMap = <String, AdminModel>{}.obs;
  var quizCounts = <String, int>{}.obs;
  var pdfCounts = <String, int>{}.obs;
  var courseByCategoryId = <DocumentSnapshot<CourseModel>>[].obs;
  User? user = FirebaseAuth.instance.currentUser;
  final categories = <CategoryModel>[].obs;
  final selectedCategory = 'all'.obs; // Set default selection to 'all'
  final int limit = 10;
  final FirebaseService _firebaseService = FirebaseService();
  final Set<String> courseIds = <String>{}; // Set to track course IDs
  final Map<String, List<DocumentSnapshot<CourseModel>>> categoryCourseCache = {}; // Cache to store courses by category

  @override
  void onInit() {
    super.onInit();
    refreshController = RefreshController(initialRefresh: false);
        categoryScrollController = ScrollController();

    fetchCategories();
    fetchCourses();
  }
  List<GlobalKey> categoryItemKeys = [];
  @override
  void onClose() {
    refreshController.dispose();
    categoryScrollController.dispose();
    super.onClose();
  }

  Future<void> fetchCategories() async {
    try {
      List<CategoryModel> tempCategories =
          await _firebaseService.getCategories();
      tempCategories.insert(
          0,
          CategoryModel(
              id: 'all',
              title: 'All Categories',
              imageUrl: '')); // Add "All Categories"
      categories.assignAll(tempCategories);
      categoryItemKeys =
          List.generate(tempCategories.length, (index) => GlobalKey());
      update();
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching categories: $error');
      }
      if (error is SocketException) {
        showError('No internet connection. Please check your network.');
      } else if (error is TimeoutException) {
        showError('Connection timed out. Please try again.');
      } else {
        showError('Error fetching categories: $error');
      }
    }
  }

  Future<void> fetchCourses({bool isRefresh = false, bool isPagination = false}) async {
    if (isLoading.value || isPaginating.value) return;

    if (isPagination) {
      isPaginating.value = true;
    } else {
      isLoading.value = true;
    }

    try {
      QuerySnapshot<CourseModel> courseSnapshot;
      if (courses.isEmpty || isRefresh) {
        courseSnapshot = await _getCourseSnapshot();
      } else {
        courseSnapshot = await _getCourseSnapshot(startAfter: courses.last);
      }

      await Future.wait([
        fetchAdminData(),
        fetchQuizAndPdfCounts(courseSnapshot.docs),
      ]);

      if (isRefresh) {
        courses.clear();
        courseIds.clear();
        for (var doc in courseSnapshot.docs) {
          if (!courseIds.contains(doc.id)) {
            courses.add(doc);
            courseIds.add(doc.id);
          }
        }
        refreshController.refreshCompleted();
      } else {
        for (var doc in courseSnapshot.docs) {
          if (!courseIds.contains(doc.id)) {
            courses.add(doc);
            courseIds.add(doc.id);
          }
        }
        refreshController.loadComplete();
      }

      // Update the cache after fetching courses
      categoryCourseCache[selectedCategory.value] = List<DocumentSnapshot<CourseModel>>.from(courses);
    } catch (error) {
      handleError(error, 'Error fetching courses: $error');
      if (isRefresh) {
        refreshController.refreshFailed();
      } else {
        refreshController.loadFailed();
      }
    } finally {
      isLoading.value = false;
      isPaginating.value = false;
    }
  }

  Future<QuerySnapshot<CourseModel>> _getCourseSnapshot({DocumentSnapshot<CourseModel>? startAfter}) {
    var query = FirebaseFirestore.instance
        .collectionGroup('courses')
        .withConverter<CourseModel>(
          fromFirestore: (snapshot, _) => CourseModel.fromJson(snapshot.data()!),
          toFirestore: (course, _) => course.toJson(),
        )
        .limit(limit);

    if (selectedCategory.value != 'all') {
      query = query.where('categoryId', isEqualTo: selectedCategory.value);
    }

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return query.get();
  }

  Future<void> fetchAdminData() async {
    try {
      QuerySnapshot adminSnapshot = await FirebaseFirestore.instance.collection('admins').get();
      Map<String, AdminModel> adminMapData = {
        for (var doc in adminSnapshot.docs)
          doc.id: AdminModel.fromJson(doc.data() as Map<String, dynamic>)
      };
      adminMap.assignAll(adminMapData);
    } catch (error) {
      handleError(error, 'Error fetching admin data: $error');
    }
  }

  Future<void> fetchQuizAndPdfCounts(List<DocumentSnapshot> courseDocs) async {
    try {
      await Future.wait(courseDocs.map((doc) async {
        String courseId = doc.id;
        await Future.wait([
          fetchQuizCount(courseId),
         // fetchPdfCount(courseId),
        ]);
      }));
    } catch (error) {
      handleError(error, 'Error fetching quiz and PDF counts: $error');
    }
  }

  Future<void> fetchQuizCount(String courseId) async {
    try {
      int quizCount = await FirebaseService().fetchTotalQuestions(courseId);
      quizCounts[courseId] = quizCount;
    } catch (error) {
      handleError(error, 'Error fetching quiz count: $error');
    }
  }

  Future<void> fetchPdfCount(String courseId) async {
    try {
      int pdfFileCount = await FirebaseService().fetchTotalPdfFilesByCourseId(courseId);
      pdfCounts[courseId] = pdfFileCount;
    } catch (error) {
      handleError(error, 'Error fetching PDF count: $error');
    }
  }

  Future<void> refreshCourses() async {
    courses.clear();
    courseIds.clear();
    quizCounts.clear();
    pdfCounts.clear();
    await fetchCourses(isRefresh: true);
    courses.shuffle(Random());

    // Update the cache after refreshing courses
    categoryCourseCache[selectedCategory.value] = List<DocumentSnapshot<CourseModel>>.from(courses);
  }

  void getCoursesByCategory(String categoryId) {
    if (selectedCategory.value == categoryId) return;
    selectedCategory.value = categoryId;

    // Check if the category's courses are already cached
    if (categoryCourseCache.containsKey(categoryId)) {
      courses.assignAll(categoryCourseCache[categoryId]!);
      courseIds.addAll(categoryCourseCache[categoryId]!.map((doc) => doc.id));
      update(); // Notify GetBuilder of changes
    } else {
      courses.clear();
      courseIds.clear();
      quizCounts.clear();
      pdfCounts.clear();
      fetchCourses(isRefresh: true);
      update(); // Notify GetBuilder of changes
    }
  }
}

  void handleError(error, String message) {
    if (error is SocketException) {
      showError('No internet connection. Please check your network.');
    } else if (error is TimeoutException) {
      showError('Connection timed out. Please try again.');
    } else {
      showError(message);
    }
  }

