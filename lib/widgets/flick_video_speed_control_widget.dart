import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlaybackSpeedController extends GetxController {
  var playbackSpeed = 1.0.obs;

  void setPlaybackSpeed(double speed) {
    playbackSpeed.value = speed;
  }
}
class FlickVideoSpeedControlWidget extends StatelessWidget {
  final FlickManager flickManager;

  const FlickVideoSpeedControlWidget({super.key, required this.flickManager});

  @override
  Widget build(BuildContext context) {
    final PlaybackSpeedController playbackSpeedController = Get.find();

    void _showSpeedControlSheet() {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Obx(() {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text("0.5x"),
                  trailing: playbackSpeedController.playbackSpeed.value == 0.5
                      ? Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    flickManager.flickControlManager?.setPlaybackSpeed(0.5);
                    playbackSpeedController.setPlaybackSpeed(0.5);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text("1x"),
                  trailing: playbackSpeedController.playbackSpeed.value == 1.0
                      ? Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    flickManager.flickControlManager?.setPlaybackSpeed(1.0);
                    playbackSpeedController.setPlaybackSpeed(1.0);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text("1.5x"),
                  trailing: playbackSpeedController.playbackSpeed.value == 1.5
                      ? Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    flickManager.flickControlManager?.setPlaybackSpeed(1.5);
                    playbackSpeedController.setPlaybackSpeed(1.5);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text("2x"),
                  trailing: playbackSpeedController.playbackSpeed.value == 2.0
                      ? Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    flickManager.flickControlManager?.setPlaybackSpeed(2.0);
                    playbackSpeedController.setPlaybackSpeed(2.0);
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
        },
      );
    }

    return IconButton(
      icon: const Icon(Icons.speed, size: 35, color: Colors.red),
      onPressed: _showSpeedControlSheet,
    );
  }
}