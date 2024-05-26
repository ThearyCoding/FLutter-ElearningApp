import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_leaningapp/Quizzes/Pages/result_Page.dart';
import 'package:get/get.dart';

class QuizController extends GetxController {
  var questions = <Map<String, dynamic>>[].obs;
  var currentQuestionIndex = 0.obs;
  var selectedAnswer = ''.obs;
  var userAnswers = <String>[].obs;
  var _timer = 20.obs;
  RxInt get time => _timer;
  Timer? _countdownTimer;

  late String courseId; // Store the course ID
  late String defaultQuizId; // Store the ID of the default quiz
  late String userId; // Store the user ID
  bool isQuizCompleted = false; // Indicates whether the quiz is completed

   void restartQuiz() {
    currentQuestionIndex.value = 0;
    selectedAnswer.value = '';
    userAnswers.clear();
    _timer.value = 20;
    _countdownTimer?.cancel();
    startTimer();
    isQuizCompleted = false;
    saveUserProgress(); // Save the reset progress
  }

  void resetQuiz() async {
    try {
      await FirebaseFirestore.instance
          .collection('user_progress_quiz')
          .doc(userId)
          .collection('quizzes')
          .doc(courseId)
          .delete();
      restartQuiz();
    } catch (e) {
      print("Error resetting quiz: $e");
    }
  }

  void fetchQuestions(String courseId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('quizzes')
              .doc(courseId)
              .collection('questions')
              .get();

      List<Map<String, dynamic>> fetchedQuestions =
          querySnapshot.docs.map((doc) => doc.data()).toList();

      fetchedQuestions.forEach((question) {
        if (question['options'] != null && question['options'] is List) {
          List<dynamic> options = question['options'];
          options.shuffle();
        }
      });

      questions.assignAll(fetchedQuestions);
      loadUserProgress(); // Load user progress after fetching questions
    } catch (e) {
      print("Error fetching questions: $e");
    }
  }

  void startTimer() {
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timer.value == 0) {
        goToNextQuestion();
      } else {
        _timer.value--;
      }
    });
  }

  void resetTimer() {
    _timer.value = 20;
  }

  void cancelTimer() {
    _countdownTimer?.cancel();
  }

  void goToNextQuestion() {
    cancelTimer();

    if (currentQuestionIndex.value < questions.length - 1) {
      bool isCorrect = selectedAnswer.value ==
          questions[currentQuestionIndex.value]['answer'];

      if (currentQuestionIndex.value < userAnswers.length) {
        userAnswers[currentQuestionIndex.value] = selectedAnswer.value;
      } else {
        userAnswers.add(selectedAnswer.value);
      }
      saveUserProgress(); // Save progress when going to the next question

      currentQuestionIndex++;
      selectedAnswer.value = '';

      resetTimer();
      startTimer();
    } else {
      if (currentQuestionIndex.value < userAnswers.length) {
        userAnswers[currentQuestionIndex.value] = selectedAnswer.value;
      } else {
        userAnswers.add(selectedAnswer.value);
      }
      isQuizCompleted = true; // Mark quiz as completed
      saveUserProgress(); // Save progress as completed
      Get.to(ResultPage(
        questions: questions,
        userAnswers: userAnswers,
        correctAnswers: questions
            .map((question) =>
                question['answer'] != null ? question['answer'] as String : '')
            .toList(),
      ));
    }
  }

  void goToPreviousQuestion() {
    cancelTimer();

    if (currentQuestionIndex.value > 0) {
      currentQuestionIndex--;
      selectedAnswer.value = userAnswers[currentQuestionIndex.value];

      resetTimer();
      startTimer();
    }
  }

  void setCourseId(String id) {
    courseId = id;
  }

  void setDefaultQuizId(String id) {
    defaultQuizId = id;
  }

  void setUserId(String id) {
    userId = id;
  }

  void saveUserProgress() async {
    if (userId.isEmpty) {
      print("Error saving user progress: userId is not set.");
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('user_progress_quiz')
          .doc(userId)
          .collection('quizzes')
          .doc(courseId)
          .set({
        'currentQuestionIndex': currentQuestionIndex.value,
        'userAnswers': userAnswers,
        'isQuizCompleted': isQuizCompleted,
        'timer': _timer.value,
      });
    } catch (e) {
      print("Error saving user progress: $e");
    }
  }

  void loadUserProgress() async {
    if (userId.isEmpty) {
      print("Error loading user progress: userId is not set.");
      return;
    }

    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('user_progress_quiz')
              .doc(userId)
              .collection('quizzes')
              .doc(courseId)
              .get();

      if (snapshot.exists) {
        var data = snapshot.data();
        if (data != null) {
          currentQuestionIndex.value = data['currentQuestionIndex'] ?? 0;
          userAnswers.assignAll(List<String>.from(data['userAnswers'] ?? []));
          isQuizCompleted = data['isQuizCompleted'] ?? false;
          _timer.value = data['timer'] ?? 20;

          if (isQuizCompleted) {
            Get.to(ResultPage(
              questions: questions,
              userAnswers: userAnswers,
              correctAnswers: questions
                  .map((question) =>
                      question['answer'] != null ? question['answer'] as String : '')
                  .toList(),
            ));
          } else {
            startTimer();
          }
        }
      }
    } catch (e) {
      print("Error loading user progress: $e");
    }
  }

  @override
  void onClose() {
    super.onClose();
    cancelTimer();
  }
}
