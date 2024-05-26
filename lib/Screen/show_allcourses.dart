import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_leaningapp/FirebaseService/Firebase_Service.dart';
import 'package:e_leaningapp/Model/Courses_Model.dart';
import 'package:e_leaningapp/Model/admin_model.dart';
import 'package:e_leaningapp/utils/responsive_utils.dart';
import 'package:e_leaningapp/widgets/course_card.dart';
import 'package:flutter/material.dart';

class AllCoursesScreen extends StatefulWidget {
  @override
  _AllCoursesScreenState createState() => _AllCoursesScreenState();
}

class _AllCoursesScreenState extends State<AllCoursesScreen> {
  late ScrollController _scrollController;
  late List<DocumentSnapshot<CourseModel>> _courses;
  late bool _isLoading;
  Map<String, AdminModel> _adminMap = {};
  Map<String, int> _quizCounts = {}; // Store quiz counts

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _courses = [];
    _isLoading = false;
    _fetchCourses();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _fetchCourses();
    }
  }

  Future<void> _fetchCourses() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    try {
      QuerySnapshot<CourseModel> courseSnapshot;
      if (_courses.isEmpty) {
        courseSnapshot = await FirebaseFirestore.instance
            .collectionGroup('courses')
            .withConverter<CourseModel>(
              fromFirestore: (snapshot, _) =>
                  CourseModel.fromJson(snapshot.data()!),
              toFirestore: (course, _) => course.toJson(),
            )
            .limit(10)
            .get();
      } else {
        courseSnapshot = await FirebaseFirestore.instance
            .collectionGroup('courses')
            .withConverter<CourseModel>(
              fromFirestore: (snapshot, _) =>
                  CourseModel.fromJson(snapshot.data()!),
              toFirestore: (course, _) => course.toJson(),
            )
            .startAfterDocument(_courses.last)
            .limit(10)
            .get();
      }

      // Fetch admins
      QuerySnapshot adminSnapshot =
          await FirebaseFirestore.instance.collection('admins').get();

      // Map admin documents by id
      Map<String, AdminModel> adminMap = {
        for (var doc in adminSnapshot.docs)
          doc.id: AdminModel.fromJson(doc.data() as Map<String, dynamic>)
      };
      // Fetch quiz counts for the courses
      for (var doc in courseSnapshot.docs) {
        String courseId = doc.id;
        int quizCount = await FirebaseService().fetchTotalQuestions(courseId);
        _quizCounts[courseId] = quizCount;
      }
      setState(() {
        _courses.addAll(courseSnapshot.docs);
        _adminMap.addAll(adminMap);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Courses"),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        controller: _scrollController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: getCrossAxisCount(context),
          childAspectRatio: getChildAspectRatio(context),
          crossAxisSpacing: getCrossAxisSpacing(context),
          mainAxisSpacing: getMainAxisSpacing(context),
        ),
        itemCount: _courses.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < _courses.length) {
            final course = _courses[index].data()!;
            final quizCount = _quizCounts[course.id] ?? 0;
            final admin = _adminMap[course.adminId] ??
                AdminModel(
                  id: '',
                  name: 'Unknown',
                  email: '',
                  imageUrl: '',
                );
            return CourseCard(
              course: course,
              admin: admin,
              quizCount: quizCount,
            );
          } else {
            return _buildLoadingIndicator();
          }
        },
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
