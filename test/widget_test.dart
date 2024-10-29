import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hackathon/models/quiz.dart';
import 'package:hackathon/screens/quiz_screen.dart';

void main() {
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
        'choices': ['A) Cevap 1', 'B) Cevap 2', 'C) Cevap 3', 'D) Cevap 4'],
        'correct_answer': 1,
      },
    ],
  );

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: QuizScreen(quiz: testQuiz),
    );
  }

  testWidgets('QuizScreen başlangıç durumunu kontrol et', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // İlk sorunun görüntülendiğini kontrol et
    expect(find.text('Soru 1?'), findsOneWidget);

    // Tüm seçeneklerin görüntülendiğini kontrol et
    expect(find.text('A) Cevap 1'), findsOneWidget);
    expect(find.text('B) Cevap 2'), findsOneWidget);
    expect(find.text('C) Cevap 3'), findsOneWidget);
    expect(find.text('D) Cevap 4'), findsOneWidget);

    // Soru sayacının doğru gösterildiğini kontrol et
    expect(find.text('1/2'), findsOneWidget);
  });

  testWidgets('Bir seçenek seçildiğinde stil değişimini kontrol et',
      (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // İlk seçeneğe tıkla
    await tester.tap(find.text('A) Cevap 1'));
    await tester.pump();

    // Seçilen seçeneğin container'ını bul
    final selectedContainer = tester.widget<AnimatedContainer>(
      find.ancestor(
        of: find.text('A) Cevap 1'),
        matching: find.byType(AnimatedContainer),
      ),
    );

    // Seçilen seçeneğin renginin değiştiğini kontrol et
    final BoxDecoration decoration =
        selectedContainer.decoration as BoxDecoration;
    expect(decoration.color, Colors.deepPurple);
  });

  testWidgets('Sayfa değişimini kontrol et', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Sağa kaydırarak sonraki soruya geç
    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pumpAndSettle();

    // İkinci sorunun görüntülendiğini kontrol et
    expect(find.text('Soru 2?'), findsOneWidget);

    // Soru sayacının güncellendiğini kontrol et
    expect(find.text('2/2'), findsOneWidget);
  });

  testWidgets('Seçimlerin kaydedildiğini kontrol et', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // İlk soruda bir seçim yap
    await tester.tap(find.text('A) Cevap 1'));
    await tester.pump();

    // Sonraki soruya geç
    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pumpAndSettle();

    // İkinci soruda bir seçim yap
    await tester.tap(find.text('B) Cevap 2'));
    await tester.pump();

    // Önceki soruya geri dön
    await tester.drag(find.byType(PageView), const Offset(500, 0));
    await tester.pumpAndSettle();

    // İlk seçimin hala seçili olduğunu kontrol et
    final selectedContainer = tester.widget<AnimatedContainer>(
      find.ancestor(
        of: find.text('A) Cevap 1'),
        matching: find.byType(AnimatedContainer),
      ),
    );

    final BoxDecoration decoration =
        selectedContainer.decoration as BoxDecoration;
    expect(decoration.color, Colors.deepPurple);
  });
}
