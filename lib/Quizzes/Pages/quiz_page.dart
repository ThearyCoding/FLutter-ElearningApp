import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_leaningapp/Quizzes/Controller/quiz_controller.dart';
import 'package:shimmer/shimmer.dart';

class QuizPage extends StatefulWidget {
  final String courseId;
  final String courseTitle;

  QuizPage({required this.courseId, required this.courseTitle});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final QuizController quizController = Get.put(QuizController());
  User? user = FirebaseAuth.instance.currentUser;
 @override
  void initState() {
    super.initState();
    quizController.setUserId(user!.uid); // Set userId before fetching questions
    quizController.setCourseId(widget.courseId);
    quizController.fetchQuestions(widget.courseId);
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text(
                "Exit Quiz",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              content: const Text(
                "Are you sure you want to exit the quiz?",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    quizController.restartQuiz();
                    quizController.cancelTimer();
                    Navigator.pop(context);
                    Get.back();
                  },
                  child: const Text(
                    "Exit",
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.courseTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text(
                      "Exit Quiz",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    content: const Text(
                      "Are you sure you want to exit the quiz?",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          quizController.restartQuiz();
                          quizController.cancelTimer();
                          Navigator.pop(context);
                          Get.back();
                        },
                        child: const Text(
                          "Exit",
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    backgroundColor: Colors.white,
                    elevation: 5,
                    contentPadding: const EdgeInsets.all(20.0),
                  );
                },
              );
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(() {
            return quizController.questions.isEmpty
                ? _buildShimmerLoading()
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Time Remaining: ${quizController.time.value} seconds',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: (quizController.currentQuestionIndex.value + 1) /
                              quizController.questions.length,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Question ${quizController.currentQuestionIndex.value + 1}:',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            quizController.questions[quizController
                                .currentQuestionIndex.value]['question'],
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: List.generate(
                            quizController.questions[quizController
                                .currentQuestionIndex.value]['options'].length,
                            (index) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Material(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    quizController.selectedAnswer.value =
                                        quizController.questions[quizController
                                            .currentQuestionIndex.value]['options'][index];
                                  },
                                  splashColor: Colors.blue.withOpacity(0.3),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: quizController.selectedAnswer.value ==
                                                quizController.questions[quizController
                                                    .currentQuestionIndex.value]['options'][index]
                                            ? Colors.blue
                                            : Colors.grey.shade400,
                                      ),
                                    ),
                                    child: Text(
                                      quizController.questions[quizController
                                          .currentQuestionIndex.value]['options'][index],
                                      style: const TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: quizController.currentQuestionIndex.value == 0
                                    ? null
                                    : () {
                                     quizController.goToPreviousQuestion();
                                      },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  backgroundColor: quizController.currentQuestionIndex.value == 0
                                      ? Colors.grey.shade300
                                      : Colors.blue,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Previous'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: quizController.selectedAnswer.isEmpty
                                    ? null
                                    : () {
                                        quizController.goToNextQuestion();
                                      },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.blue,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Next'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
          }),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            period: const Duration(milliseconds: 1000),
            child: Column(
              children: [
                Container(
                  height: 20,
                  width: double.infinity,
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                ),
                Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                ),
                Container(
                  height: 20,
                  width: double.infinity,
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List.generate(
                    4,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Container(
                        height: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: null,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.grey.shade300,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Previous'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: null,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.grey.shade300,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Next'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
