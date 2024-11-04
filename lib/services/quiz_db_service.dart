import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hackathon/models/quiz.dart';

class QuizDbService {
  final _firestore = FirebaseFirestore.instance;
  Future<List<Quiz>> getQuizzes(String userId) async {
    return _firestore
        .collection("users")
        .doc(userId)
        .collection("quizzes")
        .get()
        .then(
            (value) => value.docs.map((e) => Quiz.fromJson(e.data())).toList());
  }

  Future<void> addQuiz(Quiz quiz, String userId) async {
    _firestore
        .collection("users")
        .doc(userId)
        .collection("quizzes")
        .add(quiz.toJson());
  }

  Future<void> updateQuiz(Quiz quiz, String userId) async {
    _firestore
        .collection("users")
        .doc(userId)
        .collection("quizzes")
        .doc(quiz.id)
        .update(quiz.toJson());
  }

  Future<void> deleteQuiz(Quiz quiz, String id) async {
    _firestore
        .collection("users")
        .doc(id)
        .collection("quizzes")
        .doc(quiz.id)
        .delete();
  }
}
