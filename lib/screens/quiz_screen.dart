import 'package:flutter/material.dart';
import 'package:hackathon/models/quiz.dart';
import 'package:hackathon/screens/quiz_view_result.dart';
import 'package:hackathon/services/authentication_service.dart';
import 'package:hackathon/services/quiz_db_service.dart';

class QuizScreen extends StatefulWidget {
  final Quiz quiz;
  const QuizScreen({super.key, required this.quiz});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  late List<int?> _choices;

  @override
  void initState() {
    super.initState();
    _choices = [for (int i = 0; i < widget.quiz.getQuestions.length; i++) null];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[600],
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: PageView.builder(
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: widget.quiz.getQuestions.length,
                itemBuilder: (context, index) {
                  return Center(child: _buildQuestion(index));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      maxLines: null,
                      "${_currentIndex + 1}/${widget.quiz.getQuestions.length}",
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_choices.contains(null)) {
                          _finishQuizDialog(
                              context,
                              AuthenticationService.auth.currentUser!.uid,
                              widget.quiz,
                              "Quiz Bitirilsin mi?",
                              "Halen bitirilmemiş sorularınız var.",
                              "Bitir",
                              "İptal", () async {
                            await QuizDbService().addQuiz(widget.quiz,
                                AuthenticationService.auth.currentUser!.uid);
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ViewQuizResult(quiz: widget.quiz),
                                ));
                          }, () {
                            Navigator.of(context).pop();
                          });
                        } else {
                          _finishQuizDialog(
                              context,
                              AuthenticationService.auth.currentUser!.uid,
                              widget.quiz,
                              "Quiz Bitirilsin mi?",
                              "Soruları bitirdiniz. Quizi bitirmek istiyor musunuz?",
                              "Bitir",
                              "İptal", () async {
                            await QuizDbService().addQuiz(widget.quiz,
                                AuthenticationService.auth.currentUser!.uid);
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ViewQuizResult(quiz: widget.quiz),
                                ));
                          }, () {
                            Navigator.of(context).pop();
                          });
                        }
                      },
                      child: const Text("Testi Bitir"),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildQuestion(int index) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Column(
          children: [
            Container(
              constraints: BoxConstraints(
                  minWidth: 250,
                  minHeight: 300,
                  maxWidth: MediaQuery.sizeOf(context).width * 0.8),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(30))),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Center(
                  child: Text(
                    widget.quiz.getQuestions[index]['head'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildChoice(widget.quiz.getQuestions[index]['A'], 0),
            const SizedBox(height: 10),
            _buildChoice(widget.quiz.getQuestions[index]['B'], 1),
            const SizedBox(height: 10),
            _buildChoice(widget.quiz.getQuestions[index]['C'], 2),
            const SizedBox(height: 10),
            _buildChoice(widget.quiz.getQuestions[index]['D'], 3),
          ],
        ),
      ),
    );
  }

  Widget _buildChoice(String choice, int choiceIndex) {
    final isSelected = choiceIndex == _choices[_currentIndex];
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_choices[_currentIndex] == choiceIndex) {
            _choices[_currentIndex] = null;
            return;
          }
          _choices[_currentIndex] = choiceIndex;
        });
        widget.quiz.answers[_currentIndex] = choiceIndex;
      },
      child: AnimatedContainer(
        constraints: BoxConstraints(
            minWidth: 250,
            minHeight: 55,
            maxWidth: MediaQuery.sizeOf(context).width * 0.8),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeIn,
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple : Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(30)),
          boxShadow: isSelected
              ? [const BoxShadow(color: Colors.deepPurple, blurRadius: 5)]
              : null,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              choice,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.deepPurple,
                fontSize: 17,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _finishQuizDialog(
      BuildContext context,
      String userId,
      Quiz quiz,
      String title,
      String subtitle,
      String choice1,
      String choice2,
      Function onPressed1,
      Function onPressed2) {
    final _quizdbService = QuizDbService();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(
            subtitle,
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: Text(choice1),
              onPressed: () => onPressed1(),
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: Text(choice2),
              onPressed: () => onPressed2(),
            ),
          ],
        );
      },
    );
  }
}
