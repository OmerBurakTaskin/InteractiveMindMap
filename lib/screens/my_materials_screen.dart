import 'package:flutter/material.dart';
import 'package:hackathon/custom_colors.dart';
import 'package:hackathon/models/quiz.dart';
import 'package:hackathon/screens/quiz_view_result.dart';
import 'package:hackathon/services/authentication_service.dart';
import 'package:hackathon/services/quiz_db_service.dart';
import 'package:hackathon/utils/dialogs.dart';
import 'package:intl/intl.dart';

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
          return Center(
            child: CircularProgressIndicator(
              color: color3,
            ),
          );
        }

        if (snapshot.hasData) {
          final docs = snapshot.data!.docs;
          if (docs.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final quiz =
                      Quiz.fromJson(docs[index].data() as Map<String, dynamic>);
                  final createdOn = quiz.createdOn.toDate();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color1.withOpacity(0.9),
                            color3.withOpacity(0.9)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: color1.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ViewQuizResult(quiz: quiz),
                              ),
                            );
                          },
                          onLongPress: () => normalDialogBuilder(
                            context,
                            "Quiz Silinsin mi?",
                            "Silinen materyaller geri getirilemez",
                            "Sil",
                            "İptal",
                            () async {
                              await _quizDbService.deleteQuiz(
                                AuthenticationService.user!.uid,
                                quiz.getId,
                              );
                              Navigator.pop(context);
                            },
                            () {
                              Navigator.pop(context);
                            },
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  quiz.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: color4,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "${createdOn.day}/${createdOn.month}/${createdOn.year}",
                                      style: TextStyle(
                                        color: color4,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.quiz,
                                      size: 16,
                                      color: color4,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "${quiz.questions.length} Soru",
                                      style: TextStyle(
                                        color: color4,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }
        }
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.quiz_outlined,
                size: 64,
                color: color3,
              ),
              const SizedBox(height: 16),
              Text(
                "Materyal Bulunamadı",
                style: TextStyle(
                  color: color3,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
