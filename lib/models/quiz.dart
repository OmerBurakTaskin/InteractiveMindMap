import 'package:cloud_firestore/cloud_firestore.dart';

class Quiz {
  List<Map<String, dynamic>> questions;
  String title;
  String id;
  Timestamp createdOn = Timestamp.now();
  List<int?> answers = [];

  Quiz({required this.questions, required this.title, required this.id})
      : answers = List<int?>.filled(questions.length, null);

  Quiz.fromJson(Map<String, dynamic> json)
      : questions = List<Map<String, dynamic>>.from(json['questions']),
        answers = List<int>.from(json['answers']),
        createdOn = json['createdOn'],
        title = json['title'],
        id = json['id'];

  Map<String, dynamic> toJson() => {
        'questions': questions,
        'answers': answers,
        'createdOn': createdOn,
        'title': title,
        'id': id,
      };
  String get getTitle => title;
  List<Map<String, dynamic>> get getQuestions => questions;
  String get getId => id;
  List<int?> get getAnswers => answers;
}
