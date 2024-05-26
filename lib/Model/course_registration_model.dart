import 'package:cloud_firestore/cloud_firestore.dart';

class CourseRegistration {
  final String courseId;
  final String userId;
  final String docId;
  final Timestamp timestamp;

  CourseRegistration({
    required this.courseId,
    required this.userId,
    required this.docId,
    required this.timestamp,
  });

  factory CourseRegistration.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CourseRegistration(
      courseId: data['courseId'] ?? '',
      userId: data['userId'] ?? '',
      docId: doc.id,
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'userId': userId,
      'timestamp': timestamp,
    };
  }
}