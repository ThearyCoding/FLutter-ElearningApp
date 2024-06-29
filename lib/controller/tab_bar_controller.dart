import 'package:e_leaningapp/export/export.dart';

class TabBarController extends GetxController {
  late ScrollController categoryScrollController;
  List<GlobalKey> categoryItemKeys = [];
  List<String> tabItems = [];
  var selectedIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    getTabBarItems();
    categoryScrollController = ScrollController();
  }

  void getTabBarItems() {
    List<String> items = ['Lessons', 'Recent Lessons', 'Popular Lessons'];
    tabItems.assignAll(items);
    categoryItemKeys = List.generate(items.length, (index) => GlobalKey());
    update();
  }

  void selectTab(int index) {
    selectedIndex.value = index;
    update();
  }

  @override
  void onClose() {
    categoryScrollController.dispose();
    super.onClose();
  }
}
