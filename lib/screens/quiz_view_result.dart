import 'package:flutter/material.dart';
import 'package:hackathon/models/quiz.dart';

class ViewQuizResult extends StatefulWidget {
  final Quiz quiz;
  const ViewQuizResult({super.key, required this.quiz});

  @override
  State<ViewQuizResult> createState() => _ViewQuizResultState();
}

class _ViewQuizResultState extends State<ViewQuizResult> {
  int _currentIndex = 0;

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
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildQuestion(int index) {
    final correctAnswer = widget.quiz.questions[index]['answer'];
    final selectedAnswer = widget.quiz.answers[index];
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Column(children: [
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
          _buildChoice(widget.quiz.getQuestions[index]['A'], 0, correctAnswer,
              selectedAnswer),
          const SizedBox(height: 10),
          _buildChoice(widget.quiz.getQuestions[index]['B'], 1, correctAnswer,
              selectedAnswer),
          const SizedBox(height: 10),
          _buildChoice(widget.quiz.getQuestions[index]['C'], 2, correctAnswer,
              selectedAnswer),
          const SizedBox(height: 10),
          _buildChoice(widget.quiz.getQuestions[index]['D'], 3, correctAnswer,
              selectedAnswer),
        ]),
      ),
    );
  }

  Widget _buildChoice(
      String choice, int choiceIndex, int correctAnswer, int? selectedAnswer) {
    Color activeColor = Colors.green;
    final isChoiceCorrect = choiceIndex == correctAnswer;
    final isChoiceWrong =
        choiceIndex == selectedAnswer && selectedAnswer != correctAnswer;
    if (isChoiceWrong) {
      activeColor = Colors.red;
    } else if (isChoiceCorrect) {
      activeColor = Colors.green;
    } else {
      activeColor = Colors.white;
    }
    return Container(
      constraints: BoxConstraints(
          minWidth: 250,
          minHeight: 55,
          maxWidth: MediaQuery.sizeOf(context).width * 0.8),
      decoration: BoxDecoration(
        color: activeColor,
        borderRadius: const BorderRadius.all(Radius.circular(30)),
        boxShadow: activeColor != Colors.white
            ? [BoxShadow(color: activeColor, blurRadius: 5)]
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
              color: activeColor != Colors.white
                  ? Colors.white
                  : Colors.deepPurple,
              fontSize: 17,
            ),
          ),
        ),
      ),
    );
  }
}
