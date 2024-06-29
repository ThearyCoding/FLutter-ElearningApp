
import '../export/export.dart';

class VideoPlayerUtils {
  static Future<void> saveVideoPosition(String userId, String videoUrl, int position) async {
    final prefs = await SharedPreferences.getInstance();
    String userKey = '${userId}_$videoUrl';
    await prefs.setInt(userKey, position);
  }

  static Future<int?> getSavedVideoPosition(String userId, String videoUrl) async {
    final prefs = await SharedPreferences.getInstance();
    String userKey = '${userId}_$videoUrl';
    return prefs.getInt(userKey);
  }

  static Future<void> checkUserProgress(
      String userId, List<TopicModel> topics, Function setupVideoPlayer, Function setSelectedIndex) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String lastWatchedKey = '${userId}_lastWatchedIndex';
    int lastWatchedIndex = prefs.getInt(lastWatchedKey) ?? 0;

    if (lastWatchedIndex >= topics.length) {
      lastWatchedIndex = 0;
    }

    String videoUrl = topics[lastWatchedIndex].videoUrl;
    int? savedPosition = await getSavedVideoPosition(userId, videoUrl);

    setupVideoPlayer(
      videoUrl,
      topics[lastWatchedIndex].title,
      topics[lastWatchedIndex].description,
      TimeUtils.formatTimestamp(topics[lastWatchedIndex].timestamp),
      topics[lastWatchedIndex].views,
      topics[lastWatchedIndex].id,
      savedPosition ?? 0,
    );

    setSelectedIndex(lastWatchedIndex);
  }

  static void playVideo(
      BetterPlayerController? betterPlayerController,
      String userId,
      Function(BetterPlayerController?) setBetterPlayerController,
      String videoUrl,
      String videoTitle,
      String description,
      String timestamp,
      num views,
      String topicId,
      int startPosition,
      Function(BetterPlayerEvent) eventListener) {
    
    betterPlayerController?.dispose();

    BetterPlayerConfiguration betterPlayerConfiguration = BetterPlayerConfiguration(
      autoPlay: true,
      looping: false,
      allowedScreenSleep: true,
      showPlaceholderUntilPlay: true,
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

    BetterPlayerController newController = BetterPlayerController(
      betterPlayerConfiguration,
      betterPlayerDataSource: dataSource,
    );

    newController.addEventsListener(eventListener);

    setBetterPlayerController(newController);
  }
}
