import 'dart:convert';
import 'package:http/http.dart' as http;

class AiStudioHttpService {

  Future generateText(String imageBase64, String prompt)async{

    String apiKey = "AIzaSyD977QxyTVKR19OqDzKV6R-q07zQq4RCqs";
    String apiUrl = "https://generativelanguage.googleapis.com/v1/models/gemini-2.0-flash-lite:generateContent";

    final url = Uri.parse("$apiUrl?key=$apiKey");
    final headers = {
      'Content-Type': 'application/json'
    };

    final List<Map<String, dynamic>> parts = [
      {"text": prompt}
    ];

    if(imageBase64.isNotEmpty){
      parts.add({
        "inline_data": {
          "mime_type": "image/jpeg",
          "data": imageBase64
        }
      });
    }

    final body = jsonEncode({
      'contents': [
        {
          'parts': parts
        }
      ],
      "generationConfig": {
        "maxOutputTokens": 4000
      }
    });

    try{
      final response = await http.post(url, headers: headers, body: body);

      if(response.statusCode == 200){
        final jsonResponse = jsonDecode(response.body);
        return {
          "message": jsonResponse['candidates']?[0]?['content']?['parts']?[0]?['text'],
          "tokens": jsonResponse['usageMetadata']?["totalTokenCount"]
        };
      }
      else{
        return null;
      }
    }
    catch(e){
      return null;
    }
  }
}