import 'package:flutter/material.dart';
import 'package:hackathon/custom_colors.dart';
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
  final _pageController = PageController();
  @override
  void initState() {
    super.initState();
    _choices = [for (int i = 0; i < widget.quiz.getQuestions.length; i++) null];
  }

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
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemCount: widget.quiz.getQuestions.length,
                itemBuilder: (context, index) => _buildQuestion(index),
              ),
            ),
            _buildBottomBar(),
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

  List<Widget> _buildChoices(int index) {
    final choices = ['A', 'B', 'C', 'D'];
    return choices.asMap().entries.map((entry) {
      final choiceIndex = entry.key;
      final choiceLetter = entry.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildChoice(
          widget.quiz.getQuestions[index][choiceLetter],
          choiceIndex,
        ),
      );
    }).toList();
  }

  Widget _buildChoice(String choice, int choiceIndex) {
    final isSelected = choiceIndex == _choices[_currentIndex];
    return GestureDetector(
      onTap: () => setState(() {
        if (_choices[_currentIndex] == choiceIndex) {
          _choices[_currentIndex] = null;
        } else {
          _choices[_currentIndex] = choiceIndex;
        }
        widget.quiz.answers[_currentIndex] =
            _choices[_currentIndex]; //quiz  içinde answerı değişitr
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? Colors.deepPurple : color4,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color1.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.white : color1.withOpacity(0.1),
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + choiceIndex), // A, B, C, D
                  style: TextStyle(
                    color: isSelected ? color1 : color1.withOpacity(0.8),
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
                  color: isSelected ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentIndex > 0)
            TextButton.icon(
              onPressed: () {
                _pageController.animateToPage(--_currentIndex,
                    duration: Duration(milliseconds: 200),
                    curve: Curves.easeInOut);
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              label: const Text(
                "Önceki",
                style: TextStyle(color: Colors.white),
              ),
            )
          else
            const SizedBox.shrink(),
          ElevatedButton(
            onPressed: () => _handleQuizCompletion(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Testi Bitir",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleQuizCompletion(BuildContext context) async {
    if (_choices.contains(null)) {
      await _finishQuizDialog(
        context,
        AuthenticationService.auth.currentUser!.uid,
        widget.quiz,
        "Quiz Bitirilsin mi?",
        "Halen bitirilmemiş sorularınız var.",
        "Bitir",
        "İptal",
        () async {
          await QuizDbService().addQuiz(
              widget.quiz, AuthenticationService.auth.currentUser!.uid);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ViewQuizResult(quiz: widget.quiz),
            ),
          );
        },
        () => Navigator.of(context).pop(),
      );
    } else {
      await _finishQuizDialog(
        context,
        AuthenticationService.auth.currentUser!.uid,
        widget.quiz,
        "Quiz Bitirilsin mi?",
        "Soruları bitirdiniz. Quizi bitirmek istiyor musunuz?",
        "Bitir",
        "İptal",
        () async {
          await QuizDbService().addQuiz(
              widget.quiz, AuthenticationService.auth.currentUser!.uid);
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ViewQuizResult(quiz: widget.quiz),
            ),
          );
        },
        () => Navigator.of(context).pop(),
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
}
