import 'dart:async';
import 'package:e_leaningapp/FirebaseService/Firebase_Service.dart';
import 'package:get/get.dart';
import 'package:e_leaningapp/Model/category_Model.dart';


class CategoryController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();

  final categories = <CategoryModel>[].obs;
  late StreamSubscription<List<CategoryModel>> _categorySubscription;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchCategories();
  }

  void _fetchCategories() {
    isLoading.value = true;
    _categorySubscription = _firebaseService.getCategoriesStream().listen((categoryList) {
      categories.assignAll(categoryList);
      isLoading.value = false;
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
