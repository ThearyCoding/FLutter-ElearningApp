

import '../export/export.dart';

class BannerController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  final RxList<BannerModel> banners = <BannerModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBanners();
  }

  void fetchBanners() {
    try {
      isLoading(true);
      _firebaseService.fetchBanners().listen((fetchedBanners) {
        banners.assignAll(fetchedBanners);
        isLoading(false);
      });
    } catch (e) {
      print('Error fetching banners: $e');
      isLoading(false);
    }
  }
}
