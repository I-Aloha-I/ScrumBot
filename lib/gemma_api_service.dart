import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

class ApiService {
  static const String _model = 'gemma-3-27b-it';
  static const String _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$geminiApiKey';

  static Future<String> getScrumBotResponse(String prompt) async {
    if (geminiApiKey == 'AQUÍ_VA_TU_CLAVE_API_DE_GEMINI') {
      return 'Error: La clave de API no ha sido configurada. Por favor, añádela en el archivo lib/config.dart.';
    }

    // Combinamos la instrucción de sistema con el prompt del usuario
    final String fullPrompt = """
      Eres 'ScrumBot', un asistente experto en la metodología ágil Scrum. 
      Responde únicamente a la siguiente pregunta que está relacionada con Scrum.
      Si la pregunta no tiene que ver con Scrum, responde amablemente que solo puedes hablar sobre ese tema.

      Pregunta del usuario: "$prompt"
    """;

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        // El cuerpo de la petición ya no contiene "systemInstruction"
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": fullPrompt} // Enviamos la instrucción y la pregunta juntas
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        final errorData = jsonDecode(utf8.decode(response.bodyBytes));
        return 'Error en la API: ${errorData['error']['message']}';
      }
    } catch (e) {
      return 'Error de conexión: No se pudo conectar con el servicio. Revisa tu conexión a internet.';
    }
  }
}