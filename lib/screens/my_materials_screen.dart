import 'package:flutter/material.dart';
import 'package:hackathon/custom_colors.dart';
import 'package:hackathon/models/quiz.dart';
import 'package:hackathon/screens/quiz_view_result.dart';
import 'package:hackathon/services/authentication_service.dart';
import 'package:hackathon/services/quiz_db_service.dart';
import 'package:hackathon/utils/dialogs.dart';

class MyMaterialsScreen extends StatefulWidget {
  const MyMaterialsScreen({super.key});

  @override
  State<MyMaterialsScreen> createState() => _MyMaterialsScreenState();
}

class _MyMaterialsScreenState extends State<MyMaterialsScreen> {
  final _quizDbService = QuizDbService();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _quizDbService.getQuizzesStream(AuthenticationService.user!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          final docs = snapshot.data!.docs;
          if (docs.isNotEmpty) {
            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final quiz =
                    Quiz.fromJson(docs[index].data() as Map<String, dynamic>);
                final createdOn = quiz.createdOn.toDate();
                return ListTile(
                  title: Text(
                    quiz.title,
                    style: TextStyle(
                        color: color3,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    "Oluşturulma Tarihi: ${createdOn.day}/${createdOn.month}/${createdOn.year}",
                    style: TextStyle(color: color1),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewQuizResult(quiz: quiz),
                      ),
                    );
                  },
                  onLongPress: () => normalDialogBuilder(
                      context,
                      "Quiz Silinsin mi?",
                      "Silinen materyaller geri getirilemez",
                      "Sil",
                      "İptal", () async {
                    await _quizDbService.deleteQuiz(
                        AuthenticationService.user!.uid, quiz.getId);
                    Navigator.pop(context);
                  }, () {
                    Navigator.pop(context);
                  }),
                );
              },
            );
          }
        }
        return const Center(child: Text("Materyal Bulunamadı"));
      },
    );
  }
}
