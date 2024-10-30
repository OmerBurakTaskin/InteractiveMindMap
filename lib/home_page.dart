import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hackathon/models/quiz.dart';
import 'package:hackathon/screens/home_screen.dart';
import 'package:hackathon/screens/login_screen.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final _auth = FirebaseAuth.instance;

  Widget getInitialScreen() {
    final bool mailVerified =
        _auth.currentUser == null ? false : _auth.currentUser!.emailVerified;
    if (mailVerified) {
      return const HomeScreen();
    }
    return const LoginScreen();
  }

  final testQuiz = Quiz(
    title: "DENEME 1",
    id: "1",
    questions: [
      {
        'question': 'Soru 1?',
        'choices': ['A) Cevap 1', 'B) Cevap 2', 'C) Cevap 3', 'D) Cevap 4'],
        'correct_answer': 0,
      },
      {
        'question': 'Soru 2?',
        'choices': ['A) Cevap 1', 'B) Cevap 32', 'C) Cevap 3', 'D) Cevap 4'],
        'correct_answer': 1,
      },
    ],
  );
  @override
  Widget build(BuildContext context) {
    return getInitialScreen();
  }
}
