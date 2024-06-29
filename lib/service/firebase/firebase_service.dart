import 'dart:io';
import 'package:e_leaningapp/Model/course_admin_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../export/export.dart';
import '../../utils/show_error_utils.dart';

class FirebaseService {
  final CollectionReference categoriesCollection =
      FirebaseFirestore.instance.collection('categories');
  final CollectionReference coursesCollection =
      FirebaseFirestore.instance.collection('courses');
  final CollectionReference adminsCollection =
      FirebaseFirestore.instance.collection('admins');

  final FirebaseStorage storage = FirebaseStorage.instance;
Stream<bool> isInformationComplete(User user) async* {
    // Assume you have a collection named 'users' in Firestore
    final CollectionReference users =
        FirebaseFirestore.instance.collection('users');

    try {
      // Listen to changes in the user's document
      Stream<DocumentSnapshot> documentStream = users.doc(user.uid).snapshots();

      await for (DocumentSnapshot snapshot in documentStream) {
        // Check if the document exists and if all required fields are present
        if (snapshot.exists) {
          Map<String, dynamic> userData =
              snapshot.data() as Map<String, dynamic>;
          if (userData.containsKey('firstName') &&
              userData.containsKey('lastName')) {
            // Required fields are present
            yield true;
          } else {
            // Information is not complete
            yield false;
          }
        } else {
          // Document does not exist, information is not complete
          yield false;
        }
      }
    } catch (error) {
      // Error occurred while checking information completeness
      if (kDebugMode) {
        print('Error checking information completeness: $error');
      }
      yield false;
    }
  }
   Future<String?> uploadImageToStorage(XFile imageFile, String folderName, {String? oldPhotoUrl}) async {
  try {
    // Check if oldPhotoUrl is a Firebase Storage URL before attempting to delete it
    if (oldPhotoUrl != null && oldPhotoUrl.isNotEmpty) {
      try {
        Reference oldPhotoRef = FirebaseStorage.instance.refFromURL(oldPhotoUrl);
        await oldPhotoRef.delete();
        if (kDebugMode) {
          print('Old photo deleted successfully');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error deleting old photo from Firebase Storage: $e');
        }
      }
    }

    // Upload the new photo with progress tracking
    Reference storageRef = FirebaseStorage.instance
        .ref('$folderName/${DateTime.now().millisecondsSinceEpoch}.jpg');
    UploadTask uploadTask = storageRef.putFile(File(imageFile.path));

    // Show upload progress
    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      double progress = (snapshot.bytesTransferred / snapshot.totalBytes);
      EasyLoading.showProgress(progress, status: 'Uploading... ${(progress * 100).toStringAsFixed(0)}%');
    });

    // Await task completion
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadURL = await taskSnapshot.ref.getDownloadURL();
    return downloadURL;
  } catch (e) {
    if (kDebugMode) {
      print('Error uploading image to Firebase Storage: $e');
    }
    return null;
  }
}


  Future<int> fetchTotalPdfFilesByCourseId(String courseId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('course_file_pdf')
          .where('courseId', isEqualTo: courseId)
          .orderBy('timestamp', descending: false)
          .limit(10) // Limiting to 10 documents
          .get();

      return querySnapshot.docs.length;
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching total PDF files: $error');
      }
      if (error is SocketException) {
        showError('No internet connection. Please check your network.');
      } else if (error is TimeoutException) {
        showError('Connection timed out. Please try again.');
      } else {
        showError('Error fetching PDF count: $error');
      }
      rethrow;
    }
  }

  Future<List<PdfFileModel>> fetchPdfFilesByCourseId(String courseId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('course_file_pdf')
          .where('courseId', isEqualTo: courseId)
          .orderBy('timestamp', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => PdfFileModel.fromFirestore(doc))
          .toList();
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching PDF files: $error');
      }
      rethrow;
    }
  }

  Stream<List<CourseModel>> fetchCourses() {
    return _firestore
        .collectionGroup('courses')
        .limit(10) // Limiting to 10 documents
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map(
              (doc) => CourseModel.fromJson(doc.data()))
          .toList();
    });
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
      if (kDebugMode) {
        print('Error fetching admin: $e');
      }
      rethrow;
    }
  }

  Future<List<CourseModel>> getCourses() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collectionGroup('courses').get();
      if (kDebugMode) {
        print('Course count : ${querySnapshot.docs.length}');
      }
      return querySnapshot.docs.map((doc) {
        Timestamp timestamp = doc.get('timestamp');
        return CourseModel(
            id: doc.get('id'),
            title: doc.get('title'),
            imageUrl: doc.get('imageUrl'),
            categoryId: doc.get('categoryId'),
            adminId: doc['adminId'],
            originalPrice: doc.get('originalPrice') ?? 0.0,
            discountedPrice: doc.get('discountedPrice') ?? 0.0,
            timestamp: timestamp.toDate());
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
          originalPrice:
              data.containsKey('originalPrice') ? data['originalPrice'] : 0.0,
          discountedPrice: data.containsKey('discountedPrice')
              ? data['discountedPrice']
              : 0.0,
          timestamp: timestamp.toDate(),
        );
      }).toList();
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching courses: $error');
      }
      rethrow;
    }
  }

  Future<List<CourseModel>> fetchCoursesByAdminId(String adminId) async {
    try {
      QuerySnapshot courseQuery = await FirebaseFirestore.instance
          .collection('courses')
          .where('adminId', isEqualTo: adminId)
          .get();

      List<CourseModel> courses = courseQuery.docs
          .map(
              (doc) => CourseModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return courses;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching courses by admin ID: $e');
      }
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
        return CourseModel.fromJson(
            courseSnapshot.data() as Map<String, dynamic>);
      } else {
        return null; // Course with the given ID does not exist
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching course by ID: $e');
      }
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

          originalPrice: doc.get('originalPrice') ?? 0.0,
          discountedPrice: doc.get('discountedPrice') ?? 0.0,
          timestamp: timestamp.toDate(),
        );
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching courses: $e');
      }
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
      if (kDebugMode) {
        print('Error fetching courses with admins: $e');
      }
      return [];
    }
  }

  Future<void> incrementTopicViews(String topicId) async {
    try {
      // Perform a collectionGroup query to find the specific topic document
      final querySnapshot = await FirebaseFirestore.instance
          .collectionGroup('topics')
          .where('id', isEqualTo: topicId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        await doc.reference.update({'views': FieldValue.increment(1)});
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error incrementing topic views: $e');
      }
    }
  }

  Future<void> updateViewCounts(
      String topicId, String currentUserUid) async {
    try {
      // Check if the user has watched any video before
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('watchedVideos')
          .doc(currentUserUid)
          .get();

      // Check if the userDoc exists and contains the topicId field
      bool hasWatched = userDoc.exists &&
          (userDoc.data() as Map<String, dynamic>).containsKey(topicId);

      if (!hasWatched) {
        // If the user has not watched this video before, update the view count
        await incrementTopicViews(topicId);

        // Mark the video as watched for the user
        await FirebaseFirestore.instance
            .collection('watchedVideos')
            .doc(currentUserUid)
            .set({
          topicId: true
        }, SetOptions(merge: true)); // Merge the new field with existing fields
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating view counts: $e');
      }
    }
  }

  Future<void> updateUser({
    String? uid,
    String? firstName,
    String? lastName,
    String? displayName,
    String? shortDescription,
    DateTime? dob, // Add Date of Birth field
  }) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set(
        {
          'firstName': firstName,
          'lastName': lastName,
          'fullName': displayName,
          'shortDescription': shortDescription,
          'dob': dob != null ? Timestamp.fromDate(dob) : null, // Convert dob to Timestamp if not null
        },
        SetOptions(merge: true),
      );
    } catch (error) {
      if (kDebugMode) {
        print('Error updating user data: $error');
      }
      // Handle error
    }
  }

  Future<List<TopicModel>> getTopicsGroup(String courseId) async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collectionGroup('topics')
        .where('courseId', isEqualTo: courseId)
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
    if (kDebugMode) {
      print('Error fetching topics: $e');
    }
    return [];
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
      if (kDebugMode) {
        print('Error fetching topics: $e');
      }
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
      if (kDebugMode) {
        print('Error updating user progress: $e');
      }
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
        if (kDebugMode) {
          print('User progress not found for course: $courseId');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user progress: $e');
      }
      return null;
    }
  }

  Future<int> fetchTotalQuestions(String courseId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('quizzes')
          .doc(courseId)
          .collection('questions')
          .limit(10)
          .get();

      List<Map<String, dynamic>> fetchedQuestions =
          querySnapshot.docs.map((doc) => doc.data()).toList();

      for (var question in fetchedQuestions) {
        if (question['options'] != null && question['options'] is List) {
          List<dynamic> options = question['options'];
          options.shuffle();
        }
      }

      return fetchedQuestions.length;
    } catch (error) {
      if (kDebugMode) {
        print("Error fetching questions: $e");
      }
      if (error is SocketException) {
        showError('No internet connection. Please check your network.');
      } else if (error is TimeoutException) {
        showError('Connection timed out. Please try again.');
      } else {
        showError('Error fetching quiz count: $error');
      }
      return 0; // Return 0 if there's an error
    }
  }
Stream<List<DocumentSnapshot<CourseModel>>> filterByCoursesByCategory(String categoryId) {
    return FirebaseFirestore.instance
        .collection('categories')
        .doc(categoryId)
        .collection('courses')
        .withConverter<CourseModel>(
          fromFirestore: (snapshot, _) => CourseModel.fromJson(snapshot.data()!),
          toFirestore: (course, _) => course.toJson(),
        )
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }
  Stream<List<CourseModel>> getCoursesByCategoryStream(String categoryId) {
    return FirebaseFirestore.instance
        .collection('categories')
        .doc(categoryId)
        .collection('courses')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                CourseModel.fromJson(doc.data()))
            .toList());
  }

  // Fetch banners from Firestore
  Stream<List<BannerModel>> fetchBanners() {
    return _firestore.collection('banners').snapshots().map((query) {
      return query.docs.map((doc) {
        return BannerModel.fromJson(doc.data());
      }).toList();
    });
  }

  // Method to update user information in Firestore
  Future<void> userRegistration(
      String? uid,
      String? email,
      String? photoURL,
      String firstName,
      String lastName,
      int gender,
      DateTime dob,
      String svg
      ) async {
    try {

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'firstName': firstName,
        'lastName': lastName,
        'fullName': '$firstName$lastName',
        'photoURL': photoURL,
        'email': email,
        'gender': gender,
        'dob': dob,
        'avatar_svg': svg,
      }, SetOptions(merge: true)); // Merge to only update new fields
    } catch (error) {
      if (kDebugMode) {
        print("Error updating user in Firestore: $error");
      }
    }
  }


}
