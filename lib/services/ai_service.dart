import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:hackathon/models/mind_card.dart';
import 'package:hackathon/models/quiz.dart';

class AiService {
  final model = GenerativeModel(
      model: 'gemini-1.5-pro',
      apiKey: "AIzaSyAJvfDre_J9EhUQvJUa9XBymCfzxbharUU");

  final suggestionSchema = Schema.array(
      description: 'Önerilerin Listesi',
      items: Schema.object(properties: {
        'title': Schema.string(description: 'Öneri Başlığı', nullable: false),
        'description':
            Schema.string(description: 'Önerinin açıklaması', nullable: false)
      }, requiredProperties: [
        'Öneri Başlığı'
      ]));

  String formatPrompt(String topic, int? userAge, String? userOccupation,
      String? userInterests, String? userProfession) {
    return '''
        Aşağıdaki konuya bir yanıt oluşturun: $topic
        Bunu aşağıdaki profile sahip bir kullanıcıya göre uyarlayın:
        Yaş: ${userAge ?? 'Belirtilmemiş'}
        Meslek: ${userOccupation ?? 'Belirtilmemiş'}
        İlgi Alanları: ${userInterests ?? 'Belirtilmemiş'}
        Uzmanlık: ${userProfession ?? 'Belirtilmemiş'}

        Kullanıcının uzmanlığı konu ile benzerlik gösteriyorsa, yanıt daha detaylı ve teknik olmalıdır.
        Lütfen yanıtın en az 50 kelime uzunluğunda ve kullanıcının profiline uygun olmasını sağlayın.
    ''';
  }

  Future<Quiz> generateQuiz(
      List<MindCard> selectedCards, String? userOccupation) async {
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
          "Soru": "Soru metni",
          "A": "A şıkkı",
          "B": "B şıkkı",
          "C": "C şıkkı",
          "D": "D şıkkı",
          "Cevap": "Doğru cevap indexi"
        }
        istenilen: Array<Soru>
    ''';

    final response = await model.generateContent([Content.text(prompt)]);
    final questions =
        List<Map<String, dynamic>>.from(jsonDecode(response.text!));
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    return Quiz(questions: questions, title: 'Quiz', id: id);
  }

  Future<String> generateSummary(
      List<MindCard> selectedCards, String? userOccupation) async {
    String mindCardString = mindCardToString(selectedCards);
    final model = GenerativeModel(
      model: 'gemini-1.5-pro',
      apiKey: "AIzaSyAJvfDre_J9EhUQvJUa9XBymCfzxbharUU",
      generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          responseSchema: suggestionSchema),
    );
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

  Future<List<Map<String, String>>> genrateSuggestions(
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
    final suggestions = List<Map<String, String>>.from(
        jsonDecode((response.text!).replaceFirst("```json", " ").trim()));
    return suggestions;
  }

  String mindCardToString(List<MindCard> selectedCards) {
    String result = '';
    for (MindCard mindCard in selectedCards) {
      result += "topic:${mindCard.title}, subtopic:${mindCard.subTitle} '\n'}";
    }
    return result;
  }
}
