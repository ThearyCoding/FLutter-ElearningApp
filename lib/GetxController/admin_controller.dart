import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_leaningapp/Model/admin_model.dart';
import 'package:get/get.dart';

class AdminController extends GetxController {
  final RxList<AdminModel> admins = <AdminModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAdmins();
  }

  void fetchAdmins() {
    try {
      isLoading.value = true;
      FirebaseFirestore.instance.collection('admins').snapshots().listen((adminQuery) {
        admins.value = adminQuery.docs.map((doc) =>
            AdminModel.fromJson(doc.data() as Map<String, dynamic>)).toList();
        isLoading.value = false;
      });
    } catch (e) {
      print('Error fetching admins: $e');
      isLoading.value = false;
    }
  }
}
