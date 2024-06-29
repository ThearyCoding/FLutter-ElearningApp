import 'package:e_leaningapp/export/export.dart';
import 'package:e_leaningapp/service/firebase/firebase_service.dart';
import 'package:e_leaningapp/controller/course_registration_controller.dart';
import 'package:e_leaningapp/Model/Courses_Model.dart';
import 'package:e_leaningapp/Model/Topic_Model.dart';
import 'package:e_leaningapp/Model/admin_model.dart';
import 'package:e_leaningapp/Screen/topic_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:palette_generator/palette_generator.dart';

class DetailCourseScreen extends StatefulWidget {
  final String categoryId;
  final CourseModel course;
  final AdminModel admin;

  const DetailCourseScreen({
    super.key,
    required this.categoryId,
    required this.course,
    required this.admin,
  });

  @override
  State<DetailCourseScreen> createState() => _DetailCourseScreenState();
}

class _DetailCourseScreenState extends State<DetailCourseScreen> {
  double profileheight = 40;
  double converheight = 220;
  int totalVideos = 0; // Variable to store the total number of videos
  int watchedtotal = 0;
  int totalQuestionQuiz = 0;

  final CourseRegistrationController _controller =
      Get.put(CourseRegistrationController());
  User? user = FirebaseAuth.instance.currentUser;

  // Method to fetch topics and update totalVideos
  void fetchTopicsAndUpdateTotalVideos() async {
    List<TopicModel> topics =
        await FirebaseService().getTopics(widget.categoryId, widget.course.id);
    setState(() {
      totalVideos = topics.length;
    });
  }

  bool isConnectedToInternet = true;
  bool wasConnectedToInternet = true;
  void fetchQuestionsQuiz() async {
    totalQuestionQuiz =
        await FirebaseService().fetchTotalQuestions(widget.course.id);
  }

  Color dominantColor = Colors.grey; // Default color
// Method to get dominant color from image
  Future<void> getDominantColor() async {
    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(
      NetworkImage(widget.course.imageUrl),
    );
    setState(() {
      dominantColor = paletteGenerator.dominantColor?.color ?? Colors.grey;
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    if (!mounted) return;
    if (mounted) {
      fetchQuestionsQuiz();
      fetchTopicsAndUpdateTotalVideos();
      _controller.checkRegistration(user!.uid, widget.course.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                margin: const EdgeInsets.all(10),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: dominantColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios, size: 16),
              ),
            ),
            expandedHeight: 220.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: widget.course.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    color: Colors.white,
                  ),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: GestureDetector(
                    onTap: () async {
                      if (!_controller.isRegistered.value) {
                        EasyLoading.show(
                            status: 'Please wait',
                            maskType: EasyLoadingMaskType.clear);
                        await _controller.registerUser(
                            user!.uid, widget.course.id);
                        EasyLoading.dismiss();
                        if (!_controller.hasShownDialog.value) {
                          bool isWatch = await _showCustomDialog();
                          _controller.hasShownDialog.value =
                              true; // Mark the dialog as shown

                          if (isWatch) {
                            Get.to(
                              TopicsScreen(
                                categoryId: widget.categoryId,
                                course: widget.course,
                              ),
                            );
                          }
                        }
                      } else {
                        Get.to(
                          TopicsScreen(
                            categoryId: widget.categoryId,
                            course: widget.course,
                          ),
                        );
                      }
                    },
                    child: Center(
                      child: Obx(() => Container(
                            width: MediaQuery.of(context).size.width * 0.7,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: _controller.isRegistered.value
                                  ? Colors.green
                                  : Colors.blue,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _controller.isRegistered.value
                                      ? 'Continue Watching'
                                      : 'Register Now',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          )),
                    ),
                  ),
                ),
                const SizedBox(height: 30), // Spacer
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    children: [
                      // Title
                      Flexible(
                        child: Text(
                          widget.course.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Lecture by ${widget.admin.name}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Row for price and favorite
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                          child: RichText(
                              text: const TextSpan(
                                  text: 'Price  ',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                  children: <TextSpan>[
                            TextSpan(
                                text: 'Free',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500))
                          ]))),
                      IconButton(
                        icon: const Icon(
                          Icons.favorite,
                          color: Colors
                              .red, // Assuming it's filled if it's a favorite
                        ),
                        onPressed: () {
                          // Toggle favorite status
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5), // Spacer

                // Divider
                const Divider(
                  color: Colors.grey,
                ),
                const SizedBox(height: 8), // Spacer

                // Row for icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        const Icon(
                          Icons.video_library, // Video Icon
                          size: 30,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text('$totalVideos')
                      ],
                    ),
                    Column(
                      children: [
                        const Icon(
                          Icons.quiz, // Quiz Icon
                          size: 30,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text('$totalQuestionQuiz')
                      ],
                    ),
                    const Column(
                      children: [
                        Icon(
                          Icons.picture_as_pdf, // PDF Icon
                          size: 30,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text('0')
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 5), // Spacer
                const Divider(
                  color: Colors.grey,
                ),

                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'Watched $totalVideos/$watchedtotal',
                        style: const TextStyle(fontSize: 25),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showCustomDialog() async {
    bool startLesson = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 150),
          child: Column(
            // mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Image.network(
                      'https://www.tripmedaddy.com/wp-content/themes/tevily/assets/images/register.png',
                      height: 150,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Successful enrollment',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Start learning now',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.course.title,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 40),
                child: Column(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(
                            true); // Return true when "Start Lesson" is tapped
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text(
                        'Start Lesson',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pop(false); // Return false when "Later" is tapped
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: Colors.blue),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text(
                        'Later',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );

    return startLesson;
  }
}
