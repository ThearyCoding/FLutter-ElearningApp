import '../export/export.dart';

class SearchengineController extends GetxController {
  var txtsearch = ''.obs;
  var courses = <CourseModel>[].obs;
  var isLoading = false.obs;
 var searchAttempted = false.obs;
  void searchCourses(String query) async {
    isLoading.value = true; // Show loading indicator
     searchAttempted.value = true; // Mark that a search has been attempted
    try {
      String lowerCaseQuery = query.toLowerCase();

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collectionGroup('courses')
          .get();

      courses.value = querySnapshot.docs.where((doc) {
        String title = doc.get('title').toString().toLowerCase();
        return title.contains(lowerCaseQuery);
      }).map((doc) {
        Map<String,dynamic> data = doc.data() as Map<String,dynamic>;
        Timestamp timestamp = doc.get('timestamp');
        return CourseModel(
          id: doc.get('id'),
          title: doc.get('title'),
          imageUrl: doc.get('imageUrl'),
          categoryId: doc.get('categoryId'),
          adminId: doc.get('adminId'),
          originalPrice: data.containsKey('originalPrice') ? doc.get('originalPrice') : 0.0,
          discountedPrice: data.containsKey('discountedPrice') ? doc.get('discountedPrice') : 0.0,
          timestamp: timestamp.toDate(),
        );
      }).toList();
    } catch (error) {
      print('Error fetching courses: $error');
      courses.value = [];
    } finally {
      isLoading.value = false; // Hide loading indicator
    }
  }
}
