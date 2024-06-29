import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_leaningapp/controller/search_controller.dart';

class SearchEnginePage extends StatelessWidget {
  const SearchEnginePage({super.key});

  @override
  Widget build(BuildContext context) {
    final SearchengineController controller = Get.find();
    final TextEditingController textController = TextEditingController();
    final FocusNode focusNode = FocusNode();

    // Request focus when the page is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            controller.courses.clear();
            controller.isLoading(false);
            controller.searchAttempted(false);
            controller.txtsearch.value = '';
            Get.back();
          },
        ),
        title: const Text(
          'ស្វែងរក',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: TextField(
                controller: textController,
                focusNode: focusNode, // Assign the focus node
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    controller.txtsearch.value = value;
                    controller.searchCourses(value);
                  }
                },
                decoration: const InputDecoration(
                  icon: Icon(Icons.search),
                  border: InputBorder.none,
                  hintText: 'ស្វែងរក៖ម៉ាដ្រោន',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(
              () {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                } else if (!controller.searchAttempted.value) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 50, color: Colors.blue),
                        SizedBox(height: 20),
                        Text(
                          'ចាប់ផ្តើមស្វែងរកដោយការសរសេរចូលទីនេះ',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                } else if (controller.courses.isEmpty) {
                  return const Center(
                    child: Text(
                      'រកមិនឃើញលទ្ធផល',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                } else {
                  return ListView.builder(
                    itemCount: controller.courses.length,
                    itemBuilder: (context, index) {
                      final course = controller.courses[index];
                      return ListTile(
                        leading: course.imageUrl.isNotEmpty
                            ? Image.network(course.imageUrl)
                            : const Icon(Icons.image, size: 50, color: Colors.grey),
                        title: Text(course.title),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
