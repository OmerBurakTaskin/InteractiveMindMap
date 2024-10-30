class Quiz {
  List<Map<String, dynamic>> questions;
  String title;
  String id;
  List<int> answers = [];
  Quiz({required this.questions, required this.title, required this.id});
  Quiz.fromJson(Map<String, dynamic> json)
      : questions = json['questions'],
        answers = json['answers'],
        title = json['title'],
        id = json['id'];
  Map<String, dynamic> toJson() => {
        'questions': questions,
        'answers': answers,
        'title': title,
        'id': id,
      };
  String get getTitle => title;
  List<Map<String, dynamic>> get getQuestions => questions;
  String get getId => id;
  List<int> get getAnswers => answers;
}
