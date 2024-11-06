import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:hackathon/models/mind_card.dart';
import 'package:hackathon/models/quiz.dart';

class AiService {
  final model = GenerativeModel(
      model: 'gemini-1.5-pro',
      apiKey: "AIzaSyAFtXec3qGryWoi7STmg9IjwZkJg_2BAew");

  final suggestionSchema = Schema.array(
      description: 'Önerilerin Listesi',
      items: Schema.object(properties: {
        'title': Schema.string(description: 'Öneri Başlığı', nullable: false),
        'description':
            Schema.string(description: 'Önerinin açıklaması', nullable: false)
      }, requiredProperties: [
        'Öneri Başlığı'
      ]));

  final quizSchema = Schema.array(
      description: 'Soruların Listesi',
      items: Schema.object(properties: {
        'head': Schema.string(description: 'Soru metni', nullable: false),
        'A': Schema.string(description: 'A şıkkı', nullable: false),
        'B': Schema.string(description: 'B şıkkı', nullable: false),
        'C': Schema.string(description: 'C şıkkı', nullable: false),
        'D': Schema.string(description: 'D şıkkı', nullable: false),
        'answer':
            Schema.integer(description: 'Doğru cevap indexi', nullable: false)
      }, requiredProperties: [
        'Öneri Başlığı'
      ]));

  Future<Quiz?> generateQuiz(
      Set<MindCard> selectedCards, String? userOccupation) async {
    String mindcardstring = mindCardToString(selectedCards);
    String prompt = '''
        Veri: $mindcardstring
        Kullanıcın seçtiği mindcardların topic ve subtopic verileri hakkında ilgili ortalama uzunlukta bir quiz hazırla.
        Kullanıcının uzmanlık alanı / eğitim durumu : ${userOccupation ?? 'Belirtilmemiş'}, eğer veriler uzmanlık alanıyla bağdaşıyorsa soru daha detaylı ve teknik olmalıdır.
        Her quizde en az 3 soru olmalıdır.
        3'ten fazla konu verilmişse 3'ten fazla soru da olabilir.
        Sorular sadece verilen bilgiler ve konular ile alakalı olmalıdır.
        Her bir sorunun tek doğru cevabı olacaktır.
        Soruların cevabı index şeklinde olmalıdır(0,1,2,3), örn: "Cevap: 1"
        Response json formatında olmalıdır.
        Soru formatı:
        {
          "head": "Soru metni",
          "A": "A şıkkı",
          "B": "B şıkkı",
          "C": "C şıkkı",
          "D": "D şıkkı",
          "answer": "Doğru cevap indexi"
        }
        istenilen: Array<Map<String,dynamic>>
    ''';

    final id = DateTime.now().millisecondsSinceEpoch.toString();

    final response = await model.generateContent([Content.text(prompt)]);
    try {
      final dynamic questionsText = jsonDecode(
        response.text!.substring(
          response.text!.indexOf('['),
          response.text!.lastIndexOf(']') + 1,
        ),
      );
      final questions = (questionsText as List<dynamic>)
          .map((question) => {
                'head': question['head'] as String,
                'A': question['A'] as String,
                'B': question['B'] as String,
                'C': question['C'] as String,
                'D': question['D'] as String,
                'answer': int.parse(question['answer']),
              })
          .toList();
      return Quiz(title: "Quiz", id: id, questions: questions);
    } catch (e) {
      return null;
    }
  }

  Future<String> generateSummary(
      Set<MindCard> selectedCards, String? userOccupation) async {
    String mindCardString = mindCardToString(selectedCards);

    final prompt = '''
        Kullanıcının seçtiği mindCard'ların bilgilerini kullanarak bir özet oluştur.
        Kullanıcının uzmanlık alanı: ${userOccupation ?? 'Belirtilmemiş'}
        Eğer kullanıcnın uzmanlık alanıyla alakalı ise, özet daha detaylı ve teknik olmalıdır.
        Konuya özellikle mindcard verisindeki kullanıcının takıldığı noktalara odaklanmayı ihmal etme.
        Özet en az 100 kelime olmalıdır.
        Özet sadece verilen bilgiler ve konular ile alakalı olmalıdır.
        Seçilen mindcardların topic ve subtopicleri: $mindCardString
        
        Özetin formatı string şeklinde olmalıdır:
    
        "Özet:
        "
    ''';
    final response = await model.generateContent([Content.text(prompt)]);
    return response.text!;
  }

  Future<List<Map<String, dynamic>>> generateSuggestions(
      MindCard selectedCard, String? userOccupation) async {
    String topic = selectedCard.title;
    String subTopic = selectedCard.subTitle;
    String prompt = '''
        Kullanıcı $topic ve $subTopic konularında sıkıntı yaşıyor. Akıl haritasında bu kartı seçmiş.
        Kullanıcının bu konularda takılmış olmasından yola buna benzer hangi konularda takılmış olabileceğine dair önerilerde bulun.
        Kullanıcının uzmanlık alanı: ${userOccupation ?? 'Belirtilmemiş'}
        Eğer kullanıcının uzmanlık alanı ile alakalı ise öneri açıklaması daha detaylı ve teknik olmalıdır.
        Öneriler sadece verilen bilgiler ve konular ile alakalı olmalıdır.
        Her öneride en az 5 öneri olmalıdır.
        Title'ların uzunluğu en fazla 20 karakter olmalıdır.
        Öneriler birbirinden farklı olmalıdır.
        Önerilerin formatı "List<Map<String, String>>": şeklinde olmalı, içinde liste dışında başka hiçbir şey bulunmamalıdır:
        
        "[
          {"title": "Öneri 1 başlığı", "description": "Öneri 1 açıklaması"},
          {"title": "Öneri 2 başlığı", "description": "Öneri 2 açıklaması"},
          {"title": "Öneri 3 başlığı", "description": "Öneri 3 açıklaması"},
          {"title": "Öneri 4 başlığı", "description": "Öneri 4 açıklaması"},
          {"title": "Öneri 5 başlığı", "description": "Öneri 5 açıklaması"}
        ]"
        
    ''';
    final response = await model.generateContent([Content.text(prompt)]);
    try {
      final dynamic suggestions = jsonDecode(
        response.text!.substring(
          response.text!.indexOf('['),
          response.text!.lastIndexOf(']') + 1,
        ),
      );
      return (suggestions as List<dynamic>)
          .map((suggestion) => {
                'title': suggestion['title'] as String,
                'description': suggestion['description'] as String,
              })
          .toList();
    } catch (e) {
      print(e);
    }
    return [];
  }

  Future<MindCard?> createMotherMindCard(
      String userInput, String? userOccupation) async {
    String prompt = '''
        Kullanıcının girdiği metni kullanarak bir akıl haritası kartı oluştur.
        Kart iki bölümden oluşuyor: başlık ve açıklama.
        Başlık kullanıcının istediği konunun açıklayıcı kısa başlığı olacak.
        Kartın başlığı en fazla 3 kelime olacaktır. Amaç kısa ve öz olmasıdır.
        Kartın açıklaması kullanıcının istediği biçimde olacak. 
        Mesela kullanıcı '3 tane örnek istiyorum' demişse açıklama kısmında 3 tane örnek olacak.
        Eğer kullanıcının uzmanlık alanı ile alakalı ise kart daha detaylı ve teknik olacak.
        Eğer kullanıcın uzmanlık alanı ile doğrudan alakalı değilse uzmanlık alanıyla ilgili hiçbir şey olmayacak.
        Title ve description kısımlarında amaç sadece bilgi vermek. Teknik anlamda denklem, şema, kod benzeri şeyler içermeyecek.
        Kullanıcı uzmanlık alanı: ${userOccupation ?? 'Belirtilmemiş'}  
        Kullanıcının girdiği metin: $userInput
        Kartın başlık ve alt başlığı olmalıdır.
        Çıktı Map<String, String> şeklinde olacak ve başka hiçbir şey içermeyecek:
        Çıktı:
        {
          "title": "Mindcard Başlığı",
          "description": "Mindcard Açıklaması"
        }
    ''';

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      final cardMap =
          Map<String, String>.from(jsonDecode(response.text!.substring(
        response.text!.indexOf('{'),
        response.text!.lastIndexOf('}') + 1,
      )));
      return MindCard(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: cardMap["title"]!,
          subTitle: cardMap["description"]!,
          locationX: 50.0,
          locationY: 50.0,
          childCardIds: []);
    } catch (e) {
      print("GENERATE MINDCARD ERROR: $e");
    }
    return null;
  }

  String mindCardToString(Set<MindCard> selectedCards) {
    String result = '';
    for (MindCard mindCard in selectedCards) {
      result += "topic:${mindCard.title}, subtopic:${mindCard.subTitle} \n";
    }
    return result;
  }
}
