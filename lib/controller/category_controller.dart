import '../export/export.dart';

class CategoryController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();

  final categories = <CategoryModel>[].obs;
  late StreamSubscription<List<CategoryModel>> _categorySubscription;
  final isLoading = false.obs;
  bool _categoriesLoaded = false; // Flag to track if categories have been loaded

  @override
  void onInit() {
    super.onInit();
    if (!_categoriesLoaded) {
      _fetchCategories();
    }
  }

  void _fetchCategories() {
    isLoading.value = true;
    _categorySubscription = _firebaseService.getCategoriesStream().listen((categoryList) {
      categories.assignAll(categoryList);
      isLoading.value = false;
      _categoriesLoaded = true; // Update flag when categories are loaded

    }, onError: (error) {
      print('Error fetching categories: $error');
      isLoading.value = false;
    });
  }

  @override
  void onClose() {
    _categorySubscription.cancel();
    super.onClose();
  }
}
