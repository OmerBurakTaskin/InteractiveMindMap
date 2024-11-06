import 'package:flutter/material.dart';
import 'package:hackathon/custom_colors.dart';
import 'package:hackathon/models/quiz.dart';
import 'package:hackathon/services/quiz_db_service.dart';

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
      backgroundColor: deneme,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: PageView.builder(
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemCount: widget.quiz.getQuestions.length,
                itemBuilder: (context, index) => _buildQuestion(index),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Soru ${_currentIndex + 1}/${widget.quiz.getQuestions.length}",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          _buildProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return SizedBox(
      width: 120,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
          value: (_currentIndex + 1) / widget.quiz.getQuestions.length,
          backgroundColor: color4,
          valueColor: AlwaysStoppedAnimation<Color>(color2),
          minHeight: 8,
        ),
      ),
    );
  }

  Widget _buildQuestion(int index) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              widget.quiz.getQuestions[index]['head'],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          ..._buildChoices(index),
        ],
      ),
    );
  }

  List<Widget> _buildChoices(int questionIndex) {
    final choices = ['A', 'B', 'C', 'D'];
    return choices.asMap().entries.map((entry) {
      final choiceIndex = entry.key;
      final choiceLetter = entry.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildChoice(
            widget.quiz.getQuestions[questionIndex][choiceLetter],
            choiceIndex,
            widget.quiz.getQuestions[questionIndex]['answer'],
            widget.quiz.answers[questionIndex]),
      );
    }).toList();
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: activeColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: activeColor != Colors.white
            ? [BoxShadow(color: activeColor, blurRadius: 5)]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: activeColor != Colors.white
                  ? Colors.white
                  : color1.withOpacity(0.1),
            ),
            child: Center(
              child: Text(
                String.fromCharCode(65 + choiceIndex), // A, B, C, D
                style: TextStyle(
                  color: color1,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              choice,
              style: TextStyle(
                color: activeColor != Colors.white
                    ? Colors.white
                    : Colors.deepPurple,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
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
