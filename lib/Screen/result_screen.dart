import 'package:e_leaningapp/controller/quiz_controller.dart';
import 'package:e_leaningapp/utils/show_dialog_infor_utils.dart';
import 'package:e_leaningapp/widgets/custom_checkbox.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/custom_btn_for_quiz.dart';
import '../widgets/custom_underline_painter.dart';

// ignore: must_be_immutable
class ResultPage extends StatelessWidget {
  final List<Map<String, dynamic>> questions;
  final List<String> userAnswers;
  final List<String> correctAnswers;

  ResultPage({
    super.key,
    required this.questions,
    required this.userAnswers,
    required this.correctAnswers,
  });

  bool showSolution = false;

  @override
  Widget build(BuildContext context) {
    // Calculate the total score and other metrics
    int totalQuestions = questions.length;
    int correctCount = 0;
    int incorrectCount = 0;
    for (int i = 0; i < totalQuestions; i++) {
      if (userAnswers[i] == correctAnswers[i]) {
        correctCount++;
      } else {
        incorrectCount++;
      }
    }
    double scorePercentage = (correctCount / totalQuestions) * 100;
     final QuizController controller = Get.put(QuizController());
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Quiz Result'),
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
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
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
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Correct Answers:',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        '$correctCount',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Incorrect Answers:',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '$incorrectCount',
                        style: const TextStyle(fontSize: 16, color: Colors.red),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Score:',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        '${scorePercentage.toStringAsFixed(2)}%',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.blue),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Questions Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  String question = questions[index]['question'];
                  List<String> options =
                      List<String>.from(questions[index]['options']);
                  String userAnswer =
                      index < userAnswers.length ? userAnswers[index] : '';
                  String correctAnswer = correctAnswers[index];
                  // ignore: unused_local_variable
                  bool isCorrect = userAnswer == correctAnswer;

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Question ${index + 1}:',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            question,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Column(
                            children: options.map((option) {
                              bool isSelected = option == userAnswer;
                              bool isCorrectOption = option == correctAnswer;
                              bool isUserWrong = isSelected && !isCorrectOption;

                              return Row(
                                children: [
                                  CustomCheckbox(
                                    isSelected: isSelected,
                                    isCorrectOption: isCorrectOption,
                                  ),
                                  Expanded(
                                    child: CustomPaint(
                                      painter: isUserWrong
                                          ? UnderlinePainter()
                                          : null,
                                      child: Text(
                                        option,
                                        style: TextStyle(
                                          color: isCorrectOption
                                              ? Colors.green
                                              : isUserWrong
                                                  ? Colors.red
                                                  : Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge!
                                                      .color,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Correct Answer: $correctAnswer',
                            style: const TextStyle(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomButton(
                      onPressed: () async {
                        bool? isExit = await showExitQuizDialog(
                            context,
                            controller.resetQuiz,
                            'Re-Quiz?',
                            'Are you sure you want to re-quiz?');
                        if (isExit!) {
                          Get.back();
                          Get.back();
                        }
                      },
                      labelColor: Theme.of(context).textTheme.bodyLarge!.color,
                      label: 'Restart Quiz',
                      bgColor: Colors.transparent,
                      width: MediaQuery.of(context).size.width * 0.4,
                    ),
                    const SizedBox(width: 16),
                    CustomButton(
                      onPressed: () {
                        Get.back();
                        Get.back();
                      },
                      borderColor: Colors.transparent,
                      label: 'Finish',
                      labelColor: Colors.white,
                      bgColor: Colors.green,
                      width: MediaQuery.of(context).size.width * 0.4,
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}