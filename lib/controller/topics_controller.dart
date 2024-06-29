

import '../export/export.dart';

class TopicController extends GetxController {
  int _selectedIndex = 0;
  final _videoTitle = ''.obs; // Observable video title
  var isExpanded = false.obs;
  final _views = 0.obs;

  final _timestamp = ''.obs;
  int get views => _views.value; // Getter for views
  String get timestamp => _timestamp.value;
  void setViews(num views) {
    _views.value = views.toInt(); // Convert num to int
  }
  final totalquestion = 0.obs;
  void fetchTotalQuestions(String courseId)async{
      totalquestion.value =await FirebaseService().fetchTotalQuestions(courseId);
      update();
  }
  void setTimestamp(String timestamp) {
    _timestamp.value = timestamp;
  }

  void toggleExpansion() {
    isExpanded.toggle();
  }

  final _videoDescription = ''.obs;
  String get videoDescription => _videoDescription.value;
  var isDescriptionExpanded = false.obs;
  String get videoTitle => _videoTitle.value; // Getter
  void toggleDescriptionExpansion() {
    isDescriptionExpanded.value = !isDescriptionExpanded.value;
  }

  void setVideoTitle(String title) {
    _videoTitle.value = title; // Setter
  }

  void setVideoDescription(String description) {
    _videoDescription.value = description;
  }

  bool isSelected(int index) {
    return _selectedIndex == index;
  }

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    update();
  }

  var topics = <TopicModel>[].obs;
  var isLoading = false.obs;

  Future<void> fetchTopics(String categoryId, String courseId) async {
    try {
      isLoading.value = true;
      List<TopicModel> fetchedTopics =
          await FirebaseService().getTopics(categoryId, courseId);
      topics.assignAll(fetchedTopics);
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      rethrow;
    }
  }
}
