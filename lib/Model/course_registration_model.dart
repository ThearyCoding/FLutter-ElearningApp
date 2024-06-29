import 'package:cloud_firestore/cloud_firestore.dart';

class CourseRegistration {
  final String courseId;
  final String userId;
  final String docId;
  final Timestamp timestamp;
  final bool isRegistered;

  CourseRegistration({
    required this.courseId,
    required this.userId,
    required this.docId,
    required this.timestamp,
    required this.isRegistered
  });

  factory CourseRegistration.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CourseRegistration(
      courseId: data['courseId'] ?? '',
      userId: data['userId'] ?? '',
      docId: doc.id,
      timestamp: data['timestamp'] ?? Timestamp.now(),
      isRegistered: data['isRegistered'] ?? false
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'userId': userId,
      'docId': docId,
      'timestamp': timestamp,
    };
  }

  factory CourseRegistration.fromJson(Map<String, dynamic> json) {
    return CourseRegistration(
      courseId: json['courseId'],
      userId: json['userId'],
      docId: json['docId'],
      timestamp: Timestamp.fromMillisecondsSinceEpoch(json['timestamp']),
      isRegistered: json['isRegistered']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'userId': userId,
      'docId': docId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isRegistered': isRegistered
    };
  }
}
