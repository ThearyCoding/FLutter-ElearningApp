import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_leaningapp/Model/Courses_Model.dart';
import 'package:e_leaningapp/Model/Topic_Model.dart';
import 'package:e_leaningapp/Model/admin_model.dart';
import 'package:e_leaningapp/Model/category_Model.dart';
import 'package:e_leaningapp/Model/course_admin_model.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class FirebaseService {
  final CollectionReference categoriesCollection =
      FirebaseFirestore.instance.collection('categories');
  final CollectionReference coursesCollection =
      FirebaseFirestore.instance.collection('courses');
  final CollectionReference adminsCollection =
      FirebaseFirestore.instance.collection('admins');

  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<String?> uploadImageToStorage(
      XFile imageFile, String folderName) async {
    try {
      Reference storageRef = storage
          .ref('$folderName/${DateTime.now().millisecondsSinceEpoch}.jpg');
      UploadTask uploadTask = storageRef.putFile(File(imageFile.path));
      String downloadURL = await (await uploadTask).ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
      return null;
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      QuerySnapshot querySnapshot = await categoriesCollection.get();
      return querySnapshot.docs.map((doc) {
        return CategoryModel(
          id: doc.get('id'),
          title: doc.get('title'),
          imageUrl: doc.get('imageUrl'),
        );
      }).toList();
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching categories: $e');
      return [];
    }
  }

  Stream<List<CategoryModel>> getCategoriesStream() {
    return categoriesCollection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => CategoryModel.fromSnapshot(doc)).toList());
  }

  Future<CategoryModel> getCategoryByCourseCategoryId(String categoryId) async {
    DocumentSnapshot<Object?> querySnapshot =
        await categoriesCollection.doc(categoryId).get();
    return CategoryModel(
        id: querySnapshot.get('id'),
        title: querySnapshot.get('title'),
        imageUrl: querySnapshot.get('imageUrl'));
  }

  Future<AdminModel> getAdminById(String adminId) async {
    try {
      DocumentSnapshot<Object?> adminSnapshot =
          await adminsCollection.doc(adminId).get();
      return AdminModel.fromJson(adminSnapshot.data() as Map<String, dynamic>);
    } catch (e) {
      print('Error fetching admin: $e');
      rethrow;
    }
  }

  Future<List<CourseModel>> getCourses() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collectionGroup('courses').get();
      print('Course count : ${querySnapshot.docs.length}');
      return querySnapshot.docs.map((doc) {
        Timestamp timestamp = doc.get('timestamp');
        return CourseModel(
          id: doc.get('id'),
          title: doc.get('title'),
          imageUrl: doc.get('imageUrl'),
          categoryId: doc.get('categoryId'),
          adminId: doc['adminId'],
           pdfCount: doc['pdfCount'] ?? 0,
    quizCount: doc['quizCount'] ?? 0,
    videoCount: doc['videoCount']?? 0,
       originalPrice: doc.get('originalPrice') ?? 0.0,
            discountedPrice: doc.get('discountedPrice') ?? 0.0,
    timestamp: timestamp.toDate()
        );
      }).toList();
    } catch (error) {
      // ignore: avoid_print
      print('Error fetching courses: $error');
      return [];
    }
  }

 Future<List<CourseModel>> getCoursesByCategory(String categoryId) async {
  try {
    QuerySnapshot snapshot = await categoriesCollection
        .doc(categoryId)
        .collection('courses')
        .get();

    return snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      Timestamp timestamp = data['timestamp'] ?? Timestamp.now();
      return CourseModel(
        id: doc.id,
        title: data['title'] ?? "",
        imageUrl: data['imageUrl'] ?? "",
        adminId: data['adminId'] ?? "",
        categoryId: categoryId,
        pdfCount: data.containsKey('pdfCount') ? data['pdfCount'] : 0,
        quizCount: data.containsKey('quizCount') ? data['quizCount'] : 0,
        videoCount: data.containsKey('videoCount') ? data['videoCount'] : 0,
        originalPrice: data.containsKey('originalPrice') ? data['originalPrice'] : 0.0,
        discountedPrice: data.containsKey('discountedPrice') ? data['discountedPrice'] : 0.0,
        timestamp: timestamp.toDate(),
      );
    }).toList();
  } catch (error) {
    print('Error fetching courses: $error');
    rethrow;
  }
}

Future<List<CourseModel>> fetchCoursesByAdminId(String adminId) async {
  try {
    QuerySnapshot courseQuery = await FirebaseFirestore.instance
        .collection('courses')
        .where('adminId', isEqualTo: adminId)
        .get();

    List<CourseModel> courses = courseQuery.docs.map((doc) =>
        CourseModel.fromJson(doc.data() as Map<String, dynamic>)).toList();

    return courses;
  } catch (e) {
    print('Error fetching courses by admin ID: $e');
    return []; // Return an empty list in case of error
  }
}
Future<CourseModel?> fetchCourseById(String courseId) async {
  try {
    DocumentSnapshot courseSnapshot = await FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .get();

    if (courseSnapshot.exists) {
      return CourseModel.fromJson(courseSnapshot.data() as Map<String, dynamic>);
    } else {
      return null; // Course with the given ID does not exist
    }
  } catch (e) {
    print('Error fetching course by ID: $e');
    return null; // Return null in case of error
  }
}
  Future<List<CourseModel>> getCoursesGroup() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collectionGroup('courses').get();
      return querySnapshot.docs.map((doc) {
        Timestamp timestamp = doc.get('timestamp');
        return CourseModel(
            id: doc.id,
            title: doc.get('title'),
            imageUrl: doc.get('imageUrl'),
            categoryId: doc.get('categoryId'),
            adminId: doc.get('adminId'),
            pdfCount: doc.get('pdfCount') ?? 0,
            quizCount: doc.get('quizCount') ?? 0,
            videoCount: doc.get('videoCount') ?? 0,
               originalPrice: doc.get('originalPrice') ?? 0.0,
            discountedPrice: doc.get('discountedPrice') ?? 0.0,
            timestamp:   timestamp.toDate(),

            );
      }).toList();
    } catch (e) {
      print('Error fetching courses: $e');
      return [];
    }
  }

  Future<List<CourseWithAdmin>> getAllCoursesWithAdmins() async {
    try {
      List<CourseModel> courses = await getCoursesGroup();
      List<CourseWithAdmin> coursesWithAdmins = [];

      for (CourseModel course in courses) {
        AdminModel admin = await getAdminById(course.adminId);
        coursesWithAdmins.add(CourseWithAdmin(course: course, admin: admin));
      }
      return coursesWithAdmins;
    } catch (e) {
      print('Error fetching courses with admins: $e');
      return [];
    }
  }

  Future<void> updateViewCounts(String categoryId, String courseId,
      String videoTitle, String currentUserUid) async {
    try {
      // Check if the user has watched any video before
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('watchedVideos')
          .doc(currentUserUid)
          .get();

      // Check if the userDoc exists and contains the videoTitle field
      bool hasWatched = userDoc.exists &&
          (userDoc.data() as Map<String, dynamic>).containsKey(videoTitle);

      if (!hasWatched) {
        // If the user has not watched this video before, update the view count
        await FirebaseFirestore.instance
            .collection('categories')
            .doc(categoryId)
            .collection('courses')
            .doc(courseId)
            .collection('topics')
            .doc(videoTitle)
            .update({'views': FieldValue.increment(1)});

        // Mark the video as watched for the user
        await FirebaseFirestore.instance
            .collection('watchedVideos')
            .doc(currentUserUid)
            .set({
          videoTitle: true
        }, SetOptions(merge: true)); // Merge the new field with existing fields
      }
    } catch (e) {
      print('Error updating view counts: $e');
    }
  }

  Future<void> updateUser({
    String? uid,
    String? firstName,
    String? lastName,
    String? displayName,
    String? shortDescription,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set(
        {
          'firstName': firstName,
          'lastName': lastName,
          'fullName': displayName,
          'shortDescription': shortDescription,
        },
        SetOptions(merge: true),
      );
    } catch (error) {
      print('Error updating user data: $error');
      // Handle error
    }
  }

  Future<List<TopicModel>> getTopics(String categoryId, String courseId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('categories')
          .doc(categoryId)
          .collection('courses')
          .doc(courseId)
          .collection('topics')
          .orderBy('timestamp', descending: false)
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        Timestamp timestamp = data['timestamp'] as Timestamp;

        return TopicModel(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          videoUrl: data['videoUrl'] ?? '',
          timestamp: timestamp.toDate(),
          courseId: data['courseId'] ?? '',
          views: data['views'] ?? 0,
        );
      }).toList();
    } catch (e) {
      print('Error fetching topics: $e');
      return [];
    }
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateUserProgress(String userId, String categoryTitle,
      String courseTitle, String topicTitle) async {
    try {
      // Update the user's progress for the course in Firebase
      await _firestore
          .collection('user_progress')
          .doc(courseTitle)
          .collection('users')
          .doc(userId)
          .set(
              {
            'category_title': categoryTitle,
            'course_title': courseTitle,
            'topics': {
              topicTitle: true,
            },
          },
              SetOptions(
                  merge:
                      true)); // Use merge option to update only specified fields
    } catch (e) {
      print('Error updating user progress: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserProgress(
      String userId, String courseId) async {
    try {
      // Retrieve the user's progress for the specified course from Firestore
      DocumentSnapshot<Map<String, dynamic>> userProgressSnapshot =
          await _firestore
              .collection('user_progress')
              .doc(courseId)
              .collection('users')
              .doc(userId)
              .get();

      if (userProgressSnapshot.exists) {
        return userProgressSnapshot.data();
      } else {
        print('User progress not found for course: $courseId');
        return null;
      }
    } catch (e) {
      print('Error getting user progress: $e');
      return null;
    }
  }

  Future<int> fetchTotalQuestions(String courseId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('quizzes')
              .doc(courseId)
              .collection('questions')
              .get();

      List<Map<String, dynamic>> fetchedQuestions =
          querySnapshot.docs.map((doc) => doc.data()).toList();
      //fetchedQuestions.shuffle();

      fetchedQuestions.forEach((question) {
        if (question['options'] != null && question['options'] is List) {
          List<dynamic> options = question['options'];
          options.shuffle();
        }
      });

      // Return the total number of fetched questions
      return fetchedQuestions.length;
    } catch (e) {
      print("Error fetching questions: $e");
      return 0; // Return 0 if there's an error
    }
  }



  Stream<List<CourseModel>> getCoursesByCategoryStream(String categoryId) {
    return FirebaseFirestore.instance
        .collection('categories')
        .doc(categoryId)
        .collection('courses')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CourseModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

}
