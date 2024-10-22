import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return getInitialScreen();
  }
}
