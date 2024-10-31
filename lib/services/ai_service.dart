import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:hackathon/models/user.dart';

class AiService {
  User user;
  AiService({required this.user});
  final _apiKey = "";

  String formatPrompt(String topic) {
    return '''
      Generate a response to the following topic, tailored to a user with the specified occupation and interests:
      If the user's profession is similar to the topic, the response should be more detailed and technical.
      Also consider the age of the user while generating response due to understanding level.

      Topic: $topic
      Occupation: ${user.occupation}
      Interests: ${user.interests}
      Age: ${user.age}

      Please ensure the response is at least 50 words long and relevant to the user's profile.
    ''';
  }

  Future<String?> textGenTextOnlyPrompt(String prompt) async {
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
