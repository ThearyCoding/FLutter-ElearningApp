import 'package:get/get.dart';

class TopicController extends GetxController {
  int _selectedIndex = 0;
  var _videoTitle = ''.obs; // Observable video title
  var isExpanded = false.obs;
  var _views = 0.obs;

  var _timestamp = ''.obs;
  int get views => _views.value; // Getter for views
  String get timestamp => _timestamp.value;
  void setViews(num views) {
    _views.value = views.toInt(); // Convert num to int
  }

  void setTimestamp(String timestamp) {
    _timestamp.value = timestamp;
  }

  void toggleExpansion() {
    isExpanded.toggle();
  }

  var _videoDescription = ''.obs;
  String get videoDescription => _videoDescription.value;
  var isDescriptionExpanded = false.obs;
  String get videoTitle => _videoTitle.value; // Getter
  void toggleDescriptionExpansion() {
    isDescriptionExpanded.value = !isDescriptionExpanded.value;
  }

  void setVideoTitle(String title) {
    _videoTitle.value = title; // Setter
  }

  void setVideoDescription(String Description) {
    _videoDescription.value = Description;
  }

  bool isSelected(int index) {
    return _selectedIndex == index;
  }

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    update();
  }
}
