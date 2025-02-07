import 'package:speech_to_text/speech_to_text.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import '../config/api_config.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:html' if (dart.library.io) 'dart:io' as html;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';

class SpeechService {
  final SpeechToText _speech = SpeechToText();
  AudioPlayer _audioPlayer = AudioPlayer();
  bool _isListening = false;
  String _currentText = '';
  Timer? _silenceTimer;
  bool _hasSentFinalResult = false;
  static const silenceThreshold = Duration(milliseconds: 1000);
  bool _isSpeaking = false;
  html.AudioElement? _webAudio; // Track web audio element

  Future<void> initialize() async {
    await _speech.initialize(
      onStatus: (status) {
        print('Speech status: $status');
      },
      onError: (error) => print('Speech error: $error'),
    );
  }

  Future<void> listen({
    required Function(String) onTextRecognized,
    Function()? onSilence,
  }) async {
    if (!_isListening) {
      _isListening = true;

      try {
        await _speech.initialize(
          onStatus: (status) {
            print('Speech status: $status');
            if (status == 'notListening') {
              onSilence?.call();
            }
          },
          onError: (error) => print('Speech error: $error'),
        );

        await _speech.listen(
          onResult: (result) {
            if (result.recognizedWords.isNotEmpty) {
              onTextRecognized(result.recognizedWords);
            }
          },
          onSoundLevelChange: (level) {
            if (level <= 0) {
              onSilence?.call();
            }
          },
          localeId: 'ar-SA',
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
          partialResults: true,
          cancelOnError: false,
          listenMode: ListenMode.dictation,
        );
      } catch (e) {
        print('Listen error: $e');
        _isListening = false;
      }
    }
  }

  Future<void> stop() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
    }
  }

  Future<void> stopSpeaking() async {
    try {
      print('Force stopping all audio...');
      _isSpeaking = false;

      if (kIsWeb) {
        final elements = html.window.document.getElementsByTagName('audio');
        for (var i = 0; i < elements.length; i++) {
          final audio = elements[i] as html.AudioElement;
          audio.pause();
          audio.currentTime = 0;
          audio.remove();
        }
      } else {
        if (_audioPlayer.playing) {
          await _audioPlayer.stop();
        }
        await _audioPlayer.dispose();
        _audioPlayer = AudioPlayer();
      }
      print('All audio stopped successfully');
    } catch (e) {
      print('Error stopping audio: $e');
    }
  }

  Future<void> forceStopAudio() async {
    try {
      print('Force stopping ElevenLabs audio...');
      _isSpeaking = false; // Set this first

      if (kIsWeb) {
        // Stop web audio
        if (_webAudio != null) {
          _webAudio!.pause();
          _webAudio!.remove();
          _webAudio = null;
        }
        // Clean up any other audio elements
        final elements = html.window.document.getElementsByTagName('audio');
        for (var i = elements.length - 1; i >= 0; i--) {
          final audio = elements[i] as html.AudioElement;
          audio.pause();
          audio.remove();
        }
      } else {
        // Stop mobile audio
        if (_audioPlayer.playing) {
          await _audioPlayer.stop();
          await _audioPlayer.dispose();
          _audioPlayer = AudioPlayer();
        }
      }

      print('Audio stopped successfully');
    } catch (e) {
      print('Error stopping audio: $e');
    } finally {
      _isSpeaking = false;
    }
  }

  bool get isSpeaking => _isSpeaking;
  set isSpeaking(bool value) => _isSpeaking = value;

  Future<void> killAllAudio() async {
    try {
      print('Killing all audio immediately...');

      // إيقاف فوري لكل الأصوات
      if (kIsWeb) {
        final elements = html.window.document.getElementsByTagName('audio');
        for (var i = elements.length - 1; i >= 0; i--) {
          final audio = elements[i] as html.AudioElement;
          audio.pause();
          audio.src = ''; // مسح المصدر
          audio.remove(); // إزالة العنصر
        }
      } else {
        if (_audioPlayer.playing) {
          _audioPlayer.stop();
        }
        await _audioPlayer.dispose();
        _audioPlayer = AudioPlayer();
      }

      _isSpeaking = false;
      print('All audio killed successfully');
    } catch (e) {
      print('Error killing audio: $e');
    }
  }

  Future<void> speakWithElevenLabs(String text) async {
    if (_isSpeaking) return;

    try {
      _isSpeaking = true;

      final url = Uri.parse(
          'https://api.elevenlabs.io/v1/text-to-speech/21m00Tcm4TlvDq8ikWAM/stream');

      final response = await http.post(
        url,
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
          }
        }),
      );

      if (!_isSpeaking) return; // Check if stopped

      if (response.statusCode == 200) {
        if (kIsWeb) {
          final blob = html.Blob([response.bodyBytes]);
          final url = html.Url.createObjectUrlFromBlob(blob);
          _webAudio = html.AudioElement()
            ..src = url
            ..autoplay = true;

          try {
            if (!_isSpeaking) {
              _webAudio?.pause();
              _webAudio?.remove();
              _webAudio = null;
              return;
            }
            await _webAudio?.onEnded.first;
          } finally {
            html.Url.revokeObjectUrl(url);
            _webAudio = null;
            _isSpeaking = false;
          }
        } else {
          final dir = await getTemporaryDirectory();
          final file = File('${dir.path}/response_audio.mp3');
          await file.writeAsBytes(response.bodyBytes);

          if (!_isSpeaking) {
            await file.delete();
            return;
          }

          try {
            await _audioPlayer.setFilePath(file.path);
            if (!_isSpeaking) return; // Check again before playing
            await _audioPlayer.play();
            await _audioPlayer.playerStateStream.firstWhere(
              (state) =>
                  state.processingState == ProcessingState.completed ||
                  !_isSpeaking,
            );
          } finally {
            _isSpeaking = false;
            await file.delete();
          }
        }
      }
    } catch (e) {
      print('Speech error: $e');
    } finally {
      _isSpeaking = false;
      _webAudio = null;
    }
  }

  bool get isListening => _isListening;

  @override
  void dispose() async {
    _silenceTimer?.cancel();
    await _audioPlayer.dispose();
    await _speech.stop();
  }
}
