import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hackathon/models/quiz.dart';
import 'package:hackathon/services/user_db_service.dart';

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
        .doc(quiz.id)
        .set(quiz.toJson());
  }

  Future<void> updateQuiz(Quiz quiz, String userId) async {
    _firestore
        .collection("users")
        .doc(userId)
        .collection("quizzes")
        .doc(quiz.id)
        .update(quiz.toJson());
  }

  Future<void> deleteQuiz(String userId, String quizId) async {
    _firestore
        .collection("users")
        .doc(userId)
        .collection("quizzes")
        .doc(quizId)
        .delete();
  }

  Stream<QuerySnapshot> getQuizzesStream(String userId) {
    return _firestore
        .collection("users")
        .doc(userId)
        .collection("quizzes")
        .snapshots();
  }
}
