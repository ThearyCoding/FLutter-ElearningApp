import 'package:e_leaningapp/GetxController/TapController.dart';
import 'package:e_leaningapp/widgets/flick_video_player_widget.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class VideoPlayerHandle extends StatelessWidget {
  final FlickManager flickManager;
  final TopicController topicController;
  const VideoPlayerHandle(
      {super.key, required this.flickManager, required this.topicController});
  
  @override
  Widget build(BuildContext context) {
    
    return // video player
        Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Video Player
                   FlickVideoPlayerWidget(flickManager: flickManager,),


        Obx(
          () => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topicController.videoTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Text(
                      "${topicController.views} Views",
                    ),
                    const SizedBox(width: 20),
                    Text(topicController.timestamp),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        topicController.toggleDescriptionExpansion();
                        showModalBottomSheet(
                          isDismissible: false,
                          context: context,
                          builder: (context) => Container(
                            height: MediaQuery.of(context).size.height * 0.8,
                            width: MediaQuery.of(context).size.width,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.zero,
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Description",
                                        style: TextStyle(fontSize: 17),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        icon: const Icon(Icons.cancel),
                                      )
                                    ],
                                  ),
                                ),
                                const Divider(),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8, right: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          topicController.videoTitle,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style:
                                              const TextStyle(fontSize: 16.0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 15, bottom: 0.8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text("${topicController.views} Views"),
                                      Text(topicController.timestamp)
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Container(
                                    width: MediaQuery.of(context).size.width,
                                    padding: const EdgeInsets.all(12),
                                    margin: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(.1)),
                                    child:
                                        Text(topicController.videoDescription))
                              ],
                            ),
                          ),
                        );
                      },
                      child: Text(topicController.isDescriptionExpanded.value
                          ? '...less'
                          : '...more'),
                    )
                  ],
                ),
                // if (topicController.isDescriptionExpanded.value)
                //   const Padding(
                //     padding: EdgeInsets.only(top: 8.0),
                //     child: Text(
                //       'Your expanded description goes here.',
                //       // Replace this with your actual description
                //     ),
                //   ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
