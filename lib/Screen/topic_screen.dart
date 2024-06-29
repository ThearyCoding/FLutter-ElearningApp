import 'package:e_leaningapp/Screen/quiz_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../export/export.dart';
import 'package:numeral/numeral.dart';

class TopicsScreen extends StatefulWidget {
  final String categoryId;
  final CourseModel course;

  const TopicsScreen(
      {super.key, required this.categoryId, required this.course});

  @override
  // ignore: library_private_types_in_public_api
  _TopicsScreenState createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen>
    with SingleTickerProviderStateMixin {
  BetterPlayerController? betterPlayerController;
  final topicController = Get.put(TopicController());
  late TabController _tabController;
  int selectedTileIndex = 0;
  int totalquestion = 0;
  final TopicController controller = Get.put(TopicController());
  User? user = FirebaseAuth.instance.currentUser;
  bool _isDisposed = false;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    controller.fetchTotalQuestions(widget.course.id);
    controller.fetchTopics(widget.categoryId, widget.course.id);
    initVideoPlayer();
  }

  @override
  void dispose() {
    _isDisposed = true;

    // Dispose BetterPlayerController if it exists
    betterPlayerController?.dispose();

    // Dispose TabController
    _tabController.dispose();

    // Remove listener for topics stream
    controller.topics.close();

    // Call the super class's dispose method
    super.dispose();
  }

  void initVideoPlayer() {
    controller.isLoading(true);

    controller.topics.listen((topics) async {
      if (topics.isNotEmpty && !_isDisposed) {
        await checkUserProgress(topics);
      }
      if (!_isDisposed) {
        controller.isLoading(false);
      }
    });
  }

  Future<void> saveVideoPosition(String videoUrl, int position) async {
    final prefs = await SharedPreferences.getInstance();
    String userKey = '${user!.uid}_$videoUrl';
    await prefs.setInt(userKey, position);
  }

  Future<int?> getSavedVideoPosition(String videoUrl) async {
    final prefs = await SharedPreferences.getInstance();
    String userKey = '${user!.uid}_$videoUrl';
    return prefs.getInt(userKey);
  }

  Future<void> checkUserProgress(List<TopicModel> topics) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String lastWatchedKey = '${user!.uid}_lastWatchedIndex';
    int lastWatchedIndex = prefs.getInt(lastWatchedKey) ?? 0;

    // Default to the first video if the user is just starting
    if (lastWatchedIndex >= topics.length) {
      lastWatchedIndex = 0;
    }

    String videoUrl = topics[lastWatchedIndex].videoUrl;
    int? savedPosition = await getSavedVideoPosition(videoUrl);

    if (savedPosition != null && savedPosition > 0) {
      setupVideoPlayer(
        videoUrl,
        topics[lastWatchedIndex].title,
        topics[lastWatchedIndex].description,
        TimeUtils.formatTimestamp(topics[lastWatchedIndex].timestamp),
        topics[lastWatchedIndex].views,
        topics[lastWatchedIndex].id,
        savedPosition,
      );
    } else {
      setupVideoPlayer(
        videoUrl,
        topics[lastWatchedIndex].title,
        topics[lastWatchedIndex].description,
        TimeUtils.formatTimestamp(topics[lastWatchedIndex].timestamp),
        topics[lastWatchedIndex].views,
        topics[lastWatchedIndex].id,
        0,
      );
    }

    controller.setSelectedIndex(lastWatchedIndex);
  }

  void setupVideoPlayer(String videoUrl, String videoTitle, String description,
      String timestamp, num views, String topicId, int position) {
    topicController.setVideoTitle(videoTitle);
    topicController.setVideoDescription(description);
    topicController.setTimestamp(timestamp);
    topicController.setSelectedIndex(selectedTileIndex);
    topicController.setViews(views);
    playVideo(
        videoUrl, videoTitle, description, timestamp, views, topicId, position);
    FirebaseService().updateUserProgress(
        user!.uid, widget.categoryId, widget.course.title, videoTitle);
    if (!_isDisposed) {
      setState(() {});
    }
  }

  void playVideo(String videoUrl, String videoTitle, String description,
      String timestamp, num views, String topicId, int startPosition) async {
    // Dispose previous BetterPlayerController if exists
    betterPlayerController?.dispose();

    BetterPlayerConfiguration betterPlayerConfiguration =
        BetterPlayerConfiguration(
      autoPlay: true,
      looping: false,
      allowedScreenSleep: true,
      showPlaceholderUntilPlay: true,
      autoDetectFullscreenDeviceOrientation: true,
      startAt: Duration(milliseconds: startPosition),
    );

    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      videoUrl,
      cacheConfiguration: BetterPlayerCacheConfiguration(
        useCache: true,
        maxCacheSize: 10 * 1024 * 1024,
        maxCacheFileSize: 10 * 1024 * 1024,
        preCacheSize: 3 * 1024 * 1024,
        key: videoUrl,
      ),
    );

    betterPlayerController = BetterPlayerController(
      betterPlayerConfiguration,
      betterPlayerDataSource: dataSource,
    );
    // Listen to player events to save the current position
    betterPlayerController!.addEventsListener((event) async {
      if (event.betterPlayerEventType == BetterPlayerEventType.pause ||
          event.betterPlayerEventType == BetterPlayerEventType.seekTo ||
          event.betterPlayerEventType == BetterPlayerEventType.finished) {
        betterPlayerController!.videoPlayerController!.position
            .then((position) async {
          await saveVideoPosition(videoUrl, position?.inMilliseconds ?? 0);
          // Check if the video has been completed
          if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
            // Update Firebase data
            FirebaseService().updateViewCounts(topicId, user!.uid);
            FirebaseService().updateUserProgress(
                user!.uid, widget.categoryId, widget.course.id, videoTitle);



            await Future.delayed(Duration(seconds: 2));
           // moveToNextVideo(topicId);
          }
        });
      }
    });

    setState(() {});

    // Update topic details
    topicController.setVideoTitle(videoTitle);
    topicController.setVideoDescription(description);
    topicController.setTimestamp(timestamp);
    topicController.setViews(views);
  }

  Future<void> moveToNextVideo(String currentTopicId) async {
    final List<TopicModel> topics = controller.topics;
    final int currentIndex =
        topics.indexWhere((topic) => topic.id == currentTopicId);

    if (currentIndex != -1 && currentIndex < topics.length - 1) {
      final TopicModel nextTopic = topics[currentIndex + 1];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String lastWatchedKey = '${user!.uid}_lastWatchedIndex';
      await prefs.setInt(lastWatchedKey, currentIndex + 1);

      playVideo(
        nextTopic.videoUrl,
        nextTopic.title,
        nextTopic.description,
        TimeUtils.formatTimestamp(nextTopic.timestamp),
        nextTopic.views,
        nextTopic.id,
        0, // Start from the beginning of the next video
      );
      controller.setSelectedIndex(currentIndex + 1);
    } else {
      // If no more videos available, do something else or display a message
      
        debugPrint('No more videos available');
      
    }
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
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Get.back();
            },
          ),
        ),
        body: Column(
          children: [
            // video player
            Expanded(
              child: VideoPlayerhandler(
                betterPlayer: betterPlayerController,
                topicController: topicController,
              ),
            ),

            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Video'),
                Tab(text: 'Practice'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Video tab content
                  listVideoTab(),
                  // Practice tab content
                  quizTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget quizTab(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
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
              const SizedBox(height: 20),
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
                    '${controller.totalquestion} Questions',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Get.to(QuizPage(
                          courseId: widget.course.id,
                          courseTitle: widget.course.title));
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12),
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Start Quiz',
                      style: TextStyle(color: Colors.white, fontSize: 16),
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

  Widget listVideoTab() {
    return GetBuilder<TopicController>(
      init: TopicController(),
      builder: (controller) {
        if (controller.isLoading.value) {
          return loadingContentTopicPlaceHolder();
        } else if (controller.topics.isEmpty) {
          return const Center(child: Text('No topics found for this course.'));
        } else {
          return ListView.builder(
            itemCount: controller.topics.length,
            itemBuilder: (context, index) {
              bool isTapped = controller.isSelected(index);
              final topic = controller.topics[index];
              return Container(
                color: isTapped
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).colorScheme.background,
                child: ListTile(
                  onTap: () {
                    setState(() {
                      betterPlayerController!.dispose();
                    });
                    controller.setSelectedIndex(index);
                    playVideo(
                        topic.videoUrl,
                        topic.title,
                        topic.description,
                        TimeUtils.formatTimestamp(topic.timestamp),
                        topic.views,
                        topic.id,
                        0);
                  },
                  title: Text(
                    topic.title,
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
                          : Colors.deepPurple.withOpacity(.5),
                    ),
                    child: Icon(
                      isTapped ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: SizedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.remove_red_eye,
                              size: 15,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                                '${topic.views.toInt().numeral(digits: 2)} views'),
                          ],
                        ),
                        Text(TimeUtils.formatTimestamp(topic.timestamp)),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  Widget loadingContentTopicPlaceHolder() {
    final baseColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[800]!
        : Colors.grey[300]!;
    final highlightColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[700]!
        : Colors.grey[100]!;
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.builder(
        itemCount: 5,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ),
    );
  }
}
