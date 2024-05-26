import 'package:cloud_firestore/cloud_firestore.dart';

class TopicModel {
  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final DateTime timestamp;
  final String courseId;
  final num views;

  TopicModel( 
      {required this.id,
      required this.title,
      required this.description,
      required this.videoUrl,
      required this.timestamp,
      required this.views,
      required this.courseId,

});
  factory TopicModel.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return TopicModel(
        id: data['id'],
        title: data['title'] ?? '',
        description: data['description'] ?? '',
        videoUrl: data['videoUrl'] ?? '',
        timestamp: data['timestamp'],
        courseId: data['courseId'] ?? '',
        views: data['views'] ?? ''
);
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'videoUrl': videoUrl,
      'timestamp': timestamp,
      'courseId': courseId,
      
    };
  }

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      views: json['views'],
      id: json['id'],
      title: json['title'],
      description: json['description'],
      videoUrl: json['videoUrl'],
      timestamp: json['timestamp'],
      courseId: json['courseId'],
      
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'videoUrl': videoUrl,
      'timestamp': timestamp,
      'courseId': courseId,
    };
  }
}
