import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video List'),
      ),
      body: VideoList(),
    );
  }
}

class VideoList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      // Replace 'your_collection' with your actual Firestore collection.
      stream: FirebaseFirestore.instance.collection('videos').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        List<QueryDocumentSnapshot> documents = snapshot.data!.docs;

        return ListView.builder(
          itemCount: documents.length,
          itemBuilder: (context, index) {
            String videoUrl = documents[index]['videoUrl'];
            String title = documents[index]['title'];

            return ListTile(
              title: Text('${title}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoPlayerPage(videoUrl: videoUrl,title: title,),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class VideoPlayerPage extends StatelessWidget {
  final String videoUrl;
  final String title;

  VideoPlayerPage({required this.videoUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    FlickManager flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.network(videoUrl),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Video Player'),
      ),
      body: Column(
        children: [
          Text("Title of VIdeo: ${title}"),
          AspectRatio(
            aspectRatio: 16/9,
            child: FlickVideoPlayer(
              flickManager: flickManager,
            ),
          ),
        ],
      ),
    );
  }
}