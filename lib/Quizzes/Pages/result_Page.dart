import 'package:e_leaningapp/Quizzes/Controller/quiz_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class ResultPage extends StatefulWidget {
  final List<Map<String, dynamic>> questions;
  final List<String> userAnswers;
  final List<String> correctAnswers;

  ResultPage({
    required this.questions,
    required this.userAnswers,
    required this.correctAnswers,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  @override
  Widget build(BuildContext context) {
    // Calculate the total score and other metrics
    int totalQuestions = widget.questions.length;
    int correctCount = 0;
    int incorrectCount = 0;
    for (int i = 0; i < totalQuestions; i++) {
      if (widget.userAnswers[i] == widget.correctAnswers[i]) {
        correctCount++;
      } else {
        incorrectCount++;
      }
    }
    double scorePercentage = (correctCount / totalQuestions) * 100;

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Result'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Quiz Result',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Score',
                    style: TextStyle(fontSize: 18, color: Colors.blue),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Correct Answers:',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      Text(
                        '$correctCount',
                        style: TextStyle(fontSize: 16, color: Colors.green),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Incorrect Answers:',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      Text(
                        '$incorrectCount',
                        style: TextStyle(fontSize: 16, color: Colors.red),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Score:',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      Text(
                        '${scorePercentage.toStringAsFixed(2)}%',
                        style: const TextStyle(fontSize: 16, color: Colors.blue),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Questions Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: widget.questions.length,
                itemBuilder: (context, index) {
                  String question = widget.questions[index]['question'];
                  String userAnswer = index < widget.userAnswers.length
                      ? widget.userAnswers[index]
                      : '';
                  String correctAnswer = widget.correctAnswers[index];
                  bool isCorrect = userAnswer == correctAnswer;

                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Question ${index + 1}:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            question,
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 8),
                          Text(
                            userAnswer.isNotEmpty
                                ? 'Your Answer: $userAnswer'
                                : 'You Skipped this Question',
                            style: TextStyle(
                              color: userAnswer.isNotEmpty
                                  ? (isCorrect ? Colors.green : Colors.red)
                                  : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Correct Answer: $correctAnswer',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // // Restart the quiz
                    // Get.back();
                    // Get.back();
                    // //Get.find<QuizController>().restartQuiz();
                    // Get.find<QuizController>().cancelTimer();

                    // //Get.find<QuizController>().resetQuizProgress();
                    Get.find<QuizController>().resetQuiz();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text(
                    'Restart Quiz',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate back to the quiz screen to submit answers again
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.check_circle),
                  label: const Text(
                    'Submit Again',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
