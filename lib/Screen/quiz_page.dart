import 'package:e_leaningapp/controller/quiz_controller.dart';
import 'package:e_leaningapp/export/export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../utils/show_dialog_infor_utils.dart';

class QuizPage extends StatefulWidget {
  final String courseId;
  final String courseTitle;

  const QuizPage(
      {super.key, required this.courseId, required this.courseTitle});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final QuizController quizController = Get.put(QuizController());
  User? user = FirebaseAuth.instance.currentUser;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    quizController.setUserId(user!.uid); // Set userId before fetching questions
    quizController.setCourseId(widget.courseId);
    quizController.fetchQuestions(widget.courseId);
    // Listen to currentQuestionIndex changes to update the PageView
    quizController.currentQuestionIndex.listen((index) {
      _pageController.animateToPage(index,
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        bool? exit = await showExitQuizDialog(
            context,
            quizController.cancelTimer,
            'Exit Quiz',
            'Are you sure you want to exit the quiz?');
        return exit ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.courseTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              showExitQuizDialog(context, quizController.cancelTimer,
                  'Exit Quiz', 'Are you sure you want to exit the quiz?');
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(() {
            return quizController.questions.isEmpty
                ? BuildQuizLoader(context)
                : Column(
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
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          physics:
                              const NeverScrollableScrollPhysics(), // Disable user scrolling
                          itemCount: quizController.questions.length,
                          itemBuilder: (context, index) {
                            final question = quizController.questions[index];
                            return SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Question ${index + 1}:',
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
                                      question['question'],
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  AnimationLimiter(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: List.generate(
                                        question['options'].length,
                                        (optionIndex) {
                                          return AnimationConfiguration
                                              .staggeredList(
                                            position: optionIndex,
                                            duration: const Duration(
                                                milliseconds: 375),
                                            child: SlideAnimation(
                                              verticalOffset: 50.0,
                                              child: FadeInAnimation(
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 8.0),
                                                  child: Material(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    color: Colors.transparent,
                                                    child: InkWell(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      onTap: () {
                                                        quizController
                                                                .selectedAnswer
                                                                .value =
                                                            question['options']
                                                                [optionIndex];
                                                      },
                                                      splashColor: Colors.blue
                                                          .withOpacity(0.3),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(16),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                          border: Border.all(
                                                            color: quizController
                                                                        .selectedAnswer
                                                                        .value ==
                                                                    question[
                                                                            'options']
                                                                        [
                                                                        optionIndex]
                                                                ? Colors.blue
                                                                : Colors.grey
                                                                    .shade400,
                                                          ),
                                                        ),
                                                        child: Text(
                                                          question['options']
                                                              [optionIndex],
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 18,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed:
                                  quizController.currentQuestionIndex.value == 0
                                      ? null
                                      : () {
                                          quizController.goToPreviousQuestion();
                                        },
                              style: ElevatedButton.styleFrom(
                                foregroundColor:
                                    quizController.currentQuestionIndex.value ==
                                            0
                                        ? Colors.white
                                        : Colors.white,
                                backgroundColor:
                                    quizController.currentQuestionIndex.value ==
                                            0
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
                  );
          }),
        ),
      ),
    );
  }
}
