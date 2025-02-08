import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../config/api_config.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ElevenLabsService {
  static const String baseUrl = 'https://api.elevenlabs.io/v1';

  Future<List<int>> generateSpeech(String text) async {
    try {
      final response = await http.post(
        Uri.parse(
            '$baseUrl/text-to-speech/${ApiConfig.elevenLabsVoiceId}/stream'),
        headers: {
          'Accept': 'audio/mpeg',
          'xi-api-key': ApiConfig.elevenLabsApiKey,
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'text': text,
          'model_id': 'eleven_multilingual_v1',
          'voice_settings': {
            'stability': 0.7,
            'similarity_boost': 0.8,
          },
        }),
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to generate speech: ${response.statusCode}');
      }
    } catch (e) {
      print('Error generating speech: $e');
      throw Exception('Failed to generate speech: $e');
    }
  }

  Future<String> saveAudio(List<int> audioBytes, String text) async {
    if (kIsWeb) return '';

    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          '${text.toLowerCase().replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.mp3';
      final file = File('${directory.path}/audio/$fileName');

      await file.parent.create(recursive: true);
      await file.writeAsBytes(audioBytes);

      return file.path;
    } catch (e) {
      print('Error saving audio file: $e');
      throw Exception('Failed to save audio file: $e');
    }
  }
}
