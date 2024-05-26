import 'package:e_leaningapp/widgets/flick_video_speed_control_widget.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FlickVideoPlayerWidget extends StatelessWidget {
  final FlickManager flickManager;

  const FlickVideoPlayerWidget({super.key, required this.flickManager});

  @override
  Widget build(BuildContext context) {
    // Initialize the PlaybackSpeedController
    Get.put(PlaybackSpeedController());

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            FlickVideoPlayer(
              flickManager: flickManager,
              wakelockEnabled: true,
              
              flickVideoWithControls: FlickVideoWithControls(
                playerLoadingFallback:
                    const Center(child: CircularProgressIndicator()),
                iconThemeData: const IconThemeData(size: 30, color: Colors.red),
                textStyle: const TextStyle(color: Colors.red, fontSize: 16),
                backgroundColor: Colors.black,
                controls: Stack(
                  children: [
                    Align(
                      alignment: AlignmentDirectional.topEnd,
                      child: FlickVideoSpeedControlWidget(
                          flickManager: flickManager),
                    ),
                    const FlickPortraitControls(),
                  ],
                ),
              ),
              flickVideoWithControlsFullscreen: FlickVideoWithControls(
                
                videoFit: BoxFit.fill,
                controls: Stack(
                  children: [
                    Align(
                      alignment: AlignmentDirectional.topEnd,
                      child: FlickVideoSpeedControlWidget(
                          flickManager: flickManager),
                    ),
                    const FlickPortraitControls(
                      
                    ),
                  ],
                ),
                playerLoadingFallback:
                    const Center(child: CircularProgressIndicator()),
                iconThemeData: const IconThemeData(size: 30, color: Colors.red),
                textStyle: const TextStyle(color: Colors.red, fontSize: 16),
                backgroundColor: Colors.black,
              ),
            ),
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: FlickVideoSpeedControlWidget(flickManager: flickManager),
            ),
          ],
        ),
      ],
    );
  }
}
