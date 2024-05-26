import 'package:e_leaningapp/Model/Courses_Model.dart';
import 'package:e_leaningapp/Model/admin_model.dart';

class CourseWithAdmin {
  final CourseModel course;
  final AdminModel admin;

  CourseWithAdmin({
    required this.course,
    required this.admin,
  });
}