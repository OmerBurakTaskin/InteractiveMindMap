import 'package:flutter/material.dart';
import 'package:hackathon/models/quiz.dart';

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
      body: Column(
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
                return _buildQuestion(index);
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
                    "${_currentIndex + 1}/${widget.quiz.getQuestions.length}",
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
                const Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: null,
                    child: Text("Testi Bitir"),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQuestion(int index) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(30))),
            child: Text(
              widget.quiz.getQuestions[index]['question'],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildChoice(widget.quiz.getQuestions[index]['choices'][0], 0),
          const SizedBox(height: 10),
          _buildChoice(widget.quiz.getQuestions[index]['choices'][1], 1),
          const SizedBox(height: 10),
          _buildChoice(widget.quiz.getQuestions[index]['choices'][2], 2),
          const SizedBox(height: 10),
          _buildChoice(widget.quiz.getQuestions[index]['choices'][3], 3),
        ],
      ),
    );
  }

  Widget _buildChoice(String choice, int choiceIndex) {
    final isSelected = choiceIndex == _choices[_currentIndex];
    return GestureDetector(
      onTap: () {
        setState(() {
          _choices[_currentIndex] = choiceIndex;
        });
      },
      child: AnimatedContainer(
        constraints: BoxConstraints(
            minWidth: 250,
            minHeight: 50,
            maxWidth: MediaQuery.sizeOf(context).width * 0.8),
        duration: const Duration(milliseconds: 300),
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
            padding: const EdgeInsets.all(10.0),
            child: Text(
              maxLines: 5,
              choice,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.deepPurple,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
