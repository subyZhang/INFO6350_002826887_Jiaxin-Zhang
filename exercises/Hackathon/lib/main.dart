import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as rootBundle;

void main() {
  runApp(QuizApp());
}

class QuizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: QuizScreen(),
    );
  }
}

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<dynamic> questions = [];
  int currentQuestionIndex = 0;
  int score = 0;
  int remainingTime = 60;
  bool isTimeout = false;

  @override
  void initState() {
    super.initState();
    loadQuiz();
    startTimer();
  }

  Future<void> loadQuiz() async {
    final data = await rootBundle.rootBundle.loadString('assets/quiz_data.json');
    List<dynamic> quizData = jsonDecode(data);
    quizData.shuffle(); // 打乱问题顺序
    setState(() {
      questions = quizData;
    });
  }

  void startTimer() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingTime > 0) {
        if (mounted) {
          setState(() {
            remainingTime--;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isTimeout = true;
          });
        }
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isTimeout) {
      return QuizTimeoutScreen();
    }

    if (questions.isEmpty) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz App'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(child: Text('Time: $remainingTime s')),
          ),
        ],
      ),
      body: QuestionWidget(
        question: questions[currentQuestionIndex],
        onNext: (int points) {
          setState(() {
            score += points;
            if (currentQuestionIndex < questions.length - 1) {
              currentQuestionIndex++;
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ResultScreen(score: score),
                ),
              );
            }
          });
        },
      ),
    );
  }
}

class QuestionWidget extends StatelessWidget {
  final Map<String, dynamic> question;
  final Function(int) onNext;

  QuestionWidget({required this.question, required this.onNext});

  @override
  Widget build(BuildContext context) {
    String type = question['type'];
    if (type == 'single_choice') {
      return SingleChoiceQuestion(question: question, onNext: onNext);
    } else if (type == 'true_false') {
      return TrueFalseQuestion(question: question, onNext: onNext);
    } else if (type == 'multiple_choice') {
      return MultipleChoiceQuestion(question: question, onNext: onNext);
    }
    return Container();
  }
}

class SingleChoiceQuestion extends StatefulWidget {
  final Map<String, dynamic> question;
  final Function(int) onNext;

  SingleChoiceQuestion({required this.question, required this.onNext});

  @override
  _SingleChoiceQuestionState createState() => _SingleChoiceQuestionState();
}

class _SingleChoiceQuestionState extends State<SingleChoiceQuestion> {
  int selectedOption = -1;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.question['question'], style: TextStyle(fontSize: 20)),
        ...List.generate(widget.question['options'].length, (index) {
          return RadioListTile(
            title: Text(widget.question['options'][index]),
            value: index,
            groupValue: selectedOption,
            onChanged: (int? value) {
              setState(() {
                selectedOption = value!;
              });
            },
          );
        }),
        ElevatedButton(
          onPressed: () {
            if (selectedOption == widget.question['correct_answer'][0]) {
              widget.onNext(1);
            } else {
              widget.onNext(0);
            }
          },
          child: Text('Next'),
        ),
      ],
    );
  }
}

class TrueFalseQuestion extends StatelessWidget {
  final Map<String, dynamic> question;
  final Function(int) onNext;

  TrueFalseQuestion({required this.question, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(question['question'], style: TextStyle(fontSize: 20)),
        ListTile(
          title: Text('True'),
          onTap: () => onNext(question['correct_answer'][0] == 0 ? 1 : 0),
        ),
        ListTile(
          title: Text('False'),
          onTap: () => onNext(question['correct_answer'][0] == 1 ? 1 : 0),
        ),
      ],
    );
  }
}

class MultipleChoiceQuestion extends StatefulWidget {
  final Map<String, dynamic> question;
  final Function(int) onNext;

  MultipleChoiceQuestion({required this.question, required this.onNext});

  @override
  _MultipleChoiceQuestionState createState() => _MultipleChoiceQuestionState();
}

class _MultipleChoiceQuestionState extends State<MultipleChoiceQuestion> {
  List<int> selectedOptions = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.question['question'], style: TextStyle(fontSize: 20)),
        ...List.generate(widget.question['options'].length, (index) {
          return CheckboxListTile(
            title: Text(widget.question['options'][index]),
            value: selectedOptions.contains(index),
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  selectedOptions.add(index);
                } else {
                  selectedOptions.remove(index);
                }
              });
            },
          );
        }),
        ElevatedButton(
          onPressed: () {
            bool isCorrect = selectedOptions.length == widget.question['correct_answer'].length &&
                selectedOptions.every((index) => widget.question['correct_answer'].contains(index));
            widget.onNext(isCorrect ? 1 : 0);
          },
          child: Text('Next'),
        ),
      ],
    );
  }
}

class ResultScreen extends StatelessWidget {
  final int score;

  ResultScreen({required this.score});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Your Score: $score', style: TextStyle(fontSize: 24)),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizScreen(), // 重新创建QuizScreen
                  ),
                );
              },
              child: Text('Restart Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}

class QuizTimeoutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Time’s up! You scored 0.', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
