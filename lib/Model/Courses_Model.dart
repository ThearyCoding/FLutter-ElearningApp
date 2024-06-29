import 'package:cloud_firestore/cloud_firestore.dart';

class CourseModel {
  final String id;
  final String title;
  final String imageUrl;
  final String categoryId;
  final String adminId;
  final double originalPrice;
  final double discountedPrice;
  final DateTime timestamp;
  
  CourseModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.categoryId,
    required this.adminId,
    required this.originalPrice,
    required this.discountedPrice,
    required this.timestamp
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
      'adminId': adminId
    };
  }

factory CourseModel.fromJson(Map<String, dynamic> json) {
  return CourseModel(
    id: json['id'],
    title: json['title'] ?? "",
    imageUrl: json['imageUrl'] ?? "",
    categoryId: json['categoryId'] ?? "",
    adminId: json['adminId'] ?? "",
    originalPrice: double.tryParse(json['originalPrice'] ?? "") ?? 0.0,
    discountedPrice: double.tryParse(json['discountedPrice'] ?? "") ?? 0.0,
    timestamp: (json['timestamp'] as Timestamp).toDate(),
  );
}



  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
      'adminId': adminId,
      'timestamp': timestamp
    };
  }
}