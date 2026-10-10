import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/cinema_models.dart';

class VoiceSynthesizerEngine {
  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  Future<void> initializeEngine() async {
    if (_initialized) return;
    try {
      await _tts.setLanguage('th-TH');
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      _initialized = true;
    } catch (e) {
      debugPrint('TTS Initialization Notice: $e');
    }
  }

  Future<void> speakDialogue({
    required String text,
    required DialogueRole role,
  }) async {
    await initializeEngine();
    _applyVoiceProfile(role);

    final Completer<void> completer = Completer<void>();
    _tts.setCompletionHandler(() {
      if (!completer.isCompleted) completer.complete();
    });
    _tts.setErrorHandler((dynamic err) {
      if (!completer.isCompleted) completer.complete();
    });

    await _tts.speak(text);
    return completer.future;
  }

  void _applyVoiceProfile(DialogueRole role) {
    switch (role) {
      case DialogueRole.narrator:
        _tts.setPitch(0.9);
        _tts.setSpeechRate(0.48);
        break;
      case DialogueRole.hero:
        _tts.setPitch(1.0);
        _tts.setSpeechRate(0.52);
        break;
      case DialogueRole.heroine:
        _tts.setPitch(1.35);
        _tts.setSpeechRate(0.54);
        break;
      case DialogueRole.villain:
        _tts.setPitch(0.65);
        _tts.setSpeechRate(0.45);
        break;
      case DialogueRole.thought:
        _tts.setPitch(1.1);
        _tts.setSpeechRate(0.42);
        break;
    }
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}
