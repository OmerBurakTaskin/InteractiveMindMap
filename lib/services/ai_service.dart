import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:hackathon/models/mind_card.dart';
import 'package:hackathon/providers/workspace_provider.dart';
import 'package:hackathon/services/user_db_service.dart';
import 'package:provider/provider.dart';

class AiService {
  final _auth = FirebaseAuth.instance;
  AiService({required UserDbService userDbService})
      : _userDbService = userDbService {
    _initializeUserInfo();
  }

  final UserDbService _userDbService;
  final String _apiKey = "AIzaSyDPNPq14ivElRmmjmlQsBGW21X2WSFGGJ8"; //Gemini API
  
  late String userAge;
  late String userOccupation;
  late String userInterests;
  late String userProfession;

  void _initializeUserInfo() async  {
    final userInfo = await _userDbService.getSpecificUser(_auth.currentUser!.uid);  
    userAge = userInfo!.age.toString();
    userOccupation = userInfo.occupation;
    userInterests = userInfo.interest;
    userProfession = userInfo.occupation;
  }

  String formatPrompt(String topic) {
    return '''
        Aşağıdaki konuya bir yanıt oluşturun: $topic
        Bunu aşağıdaki profile sahip bir kullanıcıya göre uyarlayın:
        Yaş: $userAge
        Meslek: $userOccupation
        İlgi Alanları: $userInterests
        Uzmanlık: $userProfession

        Kullanıcının uzmanlığı konu ile benzerlik gösteriyorsa, yanıt daha detaylı ve teknik olmalıdır.
        Lütfen yanıtın en az 50 kelime uzunluğunda ve kullanıcının profiline uygun olmasını sağlayın.
    ''';
  }

  String quizPrompt(BuildContext context) {
    final provider = Provider.of<WorkSpaceProvider>(context, listen: false);
    final selectedCards = provider.getSelectedMindCards;
    String prompt = '''
        Verilen $selectedCards verileri ile ilgili kısa bir quiz hazırlayın.
        Quizin formatı şu şekilde olmalıdır:
    
        "Soru: 
        A)
        B)
        C)
        D)

        Cevap:
        "

        Her quizde en az 5 soru olmalıdır.
        Sorular sadece verilen bilgiler ve konular ile alakalı olmalıdır.

    ''';
    return prompt;
  }

  String summaryPrompt(BuildContext context) {
    final provider = Provider.of<WorkSpaceProvider>(context, listen: false);
    final selectedCards = provider.getSelectedMindCards;
    String prompt = '''
        Verilen $selectedCards verileri kullanarak kısa bir özet oluşturun.
        Özetin formatı şu şekilde olmalıdır:
    
        "Özet:
        "
        Eğer veriler kullanıcının uzmanlık alanı ile alakalı ise, özet daha detaylı ve teknik olmalıdır.
        Uzmanlık alanı = $userOccupation
        Özet en az 100 kelime olmalıdır.
        Özet sadece verilen bilgiler ve konular ile alakalı olmalıdır.
    ''';

    return prompt;

  }
  

  String newSuggestionsPrompt(BuildContext context) {
    final provider = Provider.of<WorkSpaceProvider>(context, listen: false);
    final selectedCards = provider.getSelectedMindCards;
    String prompt = '''
        Verilen $selectedCards verileri ile ilgili yeni öneriler oluşturun.
        Önerilerin formatı şu şekilde olmalıdır:
    
        "Öneri:
        "

        Her öneride en az 5 öneri olmalıdır.
        Öneriler sadece verilen bilgiler ve konular ile alakalı olmalıdır fakat önceki veriler ile aynı öneriler olmamalıdır.
        
    ''';

    return prompt;
  }

  Future<String?> generatePrompt(String prompt) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-pro',
        apiKey: _apiKey,
      );

      final response = await model.generateContent([Content.text(prompt)]);
      return response.text;
    } catch (e) {
      // Handle errors here, e.g., log the error, retry, or notify the user.
      print('Error generating text: $e');
      return null;
}
}
}