import 'package:flutter/material.dart';

class QuizProvider extends ChangeNotifier {
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void nextQuestion() {
    _currentIndex++;
    notifyListeners();
  }
}
