import 'package:e_leaningapp/GetxController/TapController.dart';
import 'package:e_leaningapp/Model/Courses_Model.dart';
import 'package:e_leaningapp/FirebaseService/Firebase_Service.dart';
import 'package:e_leaningapp/Model/Topic_Model.dart';
import 'package:e_leaningapp/Quizzes/Pages/quiz_page.dart';
import 'package:e_leaningapp/utils/time_utils.dart';
import 'package:e_leaningapp/widgets/video_playerHandle.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class TopicsScreen extends StatefulWidget {
  final String categoryId;
  final CourseModel course;

  // ignore: use_key_in_widget_constructors
  const TopicsScreen({required this.categoryId, required this.course});

  @override
  // ignore: library_private_types_in_public_api
  _TopicsScreenState createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen>
    with SingleTickerProviderStateMixin {
  late FlickManager flickManager;
  late VideoPlayerController videoPlayerController;
  final topicController = Get.put(TopicController()); // GetX controller
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchTotalQuestions();
    // Initialize with a dummy video URL
    // ignore: deprecated_member_use
    videoPlayerController = VideoPlayerController.network(
      '',
    );
    flickManager = FlickManager(
      videoPlayerController: videoPlayerController,
    );

    // Fetch the initial video URL from Firebase
    FirebaseService()
        .getTopics(widget.categoryId, widget.course.id)
        .then((List<TopicModel> topics) {
      if (topics.isNotEmpty) {
        String initialVideoUrl = topics[0].videoUrl;
        topicController.setVideoTitle(topics[0].title);
        topicController
            .setTimestamp(TimeUtils.formatTimestamp(topics[0].timestamp));
        topicController.setSelectedIndex(0);
        topicController.setViews(topics[0].views);
        playVideo(initialVideoUrl, topics[0].title, topics[0].description,
            TimeUtils.formatTimestamp(topics[0].timestamp), topics[0].views);
        FirebaseService().updateUserProgress(
            user!.uid, widget.categoryId, widget.course.title, topics[0].title);
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    flickManager.dispose();
    _tabController.dispose();
    super.dispose();
  }

  User? user = FirebaseAuth.instance.currentUser;

  void playVideo(String videoUrl, String videoTitle, String description,
      String timestamp, num views) {
    // Update view count in Firebase

    // ignore: unnecessary_null_comparison
    if (flickManager == null) {
      flickManager = FlickManager(
        // ignore: deprecated_member_use
        videoPlayerController: VideoPlayerController.network(videoUrl,
            videoPlayerOptions:
                VideoPlayerOptions(allowBackgroundPlayback: true)),
      );
    } else {
      // ignore: deprecated_member_use
      flickManager.handleChangeVideo(VideoPlayerController.network(videoUrl,
          videoPlayerOptions: VideoPlayerOptions(
              allowBackgroundPlayback: true, mixWithOthers: true)));
    }
    topicController.setVideoTitle(videoTitle); // Update title using controller
    topicController.setVideoDescription(description);
    topicController.setTimestamp(timestamp);
    topicController.setViews(views);
    FirebaseService().updateViewCounts(
        widget.categoryId, widget.course.id, videoTitle, user!.uid);
    FirebaseService().updateUserProgress(
        user!.uid, widget.categoryId, widget.course.id, videoTitle);
  }

  int totalquestionquiz = 0;
  int selectedTileIndex = 0;

  void fetchTotalQuestions() async {
    totalquestionquiz =
        await FirebaseService().fetchTotalQuestions(widget.course.id);
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        topicController.setVideoDescription('');
        topicController.setTimestamp('');
        topicController.setVideoTitle('');
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.course.title),
          elevation: 0,
          titleSpacing: 0,
        ),
        body: Column(
          children: [
            // video player
            VideoPlayerHandle(
                flickManager: flickManager, topicController: topicController),
            //Expanded(child: FlickVideoPlayerWidget(flickManager: flickManager,)),
            // add table for list of video , quiz and practices
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Video'),
                Tab(text: 'Files'),
                Tab(text: 'Practice'),
              ],
            ),
            // Content based on selected tab
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Video tab content
                  ListVideoTab(),

                  // Quiz tab content
                  FileTab(),

                  // Practice tab content
                  QuizTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// ignore: non_constant_identifier_names
  Widget QuizTab(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 40, vertical: 40), // Padding only on left and right
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Let's Quiz",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20), // Smaller spacing
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Question',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '$totalquestionquiz Questions',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20), // Smaller spacing
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Time Quiz',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '1 question is 20s',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20), // Smaller spacing
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Score',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '20',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20), // Smaller spacing
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.to(QuizPage(
                          courseId: widget.course.id,
                          courseTitle: widget.course.title));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 100, vertical: 10),
                      child: const Text(
                        'Start Quiz',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget FileTab() {
    return ListView(
      children: const [
        ListTile(
          title: Text('Quiz 1'),
          subtitle: Text('Description for Quiz 1'),
        ),
        ListTile(
          title: Text('Quiz 2'),
          subtitle: Text('Description for Quiz 2'),
        ),
        // Add more list tiles for quizzes as needed
      ],
    );
  }

  // ignore: non_constant_identifier_names
  Widget ListVideoTab() {
    return FutureBuilder(
      future: FirebaseService().getTopics(
        widget.categoryId,
        widget.course.id,
      ),
      builder: (context, AsyncSnapshot<List<TopicModel>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No topics found for this course.');
        } else {
          return GetBuilder<TopicController>(
            init: TopicController(),
            builder: (controller) => ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                bool isTapped = controller.isSelected(index);
                return Container(
                  color: isTapped
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).colorScheme.background,
                  child: ListTile(
                    onTap: () {
                      controller.setSelectedIndex(index);

                      playVideo(
                          snapshot.data![index].videoUrl,
                          snapshot.data![index].title,
                          snapshot.data![index].description,
                          TimeUtils.formatTimestamp(
                              snapshot.data![index].timestamp),
                          snapshot.data![index].views);
                    },
                    title: Text(
                      snapshot.data![index].title,
                      style: TextStyle(
                        color: isTapped
                            ? Colors.white
                            : Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                    ),
                    leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: isTapped
                                ? Colors.deepPurple
                                : Colors.deepPurple.withOpacity(.5)),
                        child: Icon(
                          isTapped ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                        )),
                    subtitle: SizedBox(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // ignore: avoid_unnecessary_containers
                        Container(
                          child: Text(
                              '${snapshot.data![index].views.toInt().toString()} Views'), // Convert views to a string
                        ),
                        // ignore: avoid_unnecessary_containers
                        Container(
                            child: Text(TimeUtils.formatTimestamp(
                                snapshot.data![index].timestamp))),
                      ],
                    )),
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}
