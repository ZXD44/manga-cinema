import 'dart:async';
import 'package:flutter/material.dart';
import '../models/cinema_models.dart';
import '../services/manga_url_loader_service.dart';
import '../services/voice_engine.dart';

class CinemaPlaybackState extends ChangeNotifier {
  final VoiceSynthesizerEngine _voiceEngine = VoiceSynthesizerEngine();

  bool _isPlaying = false;
  bool _isLoadingUrl = false;
  int _currentPanelIndex = 0;
  int _currentBubbleIndex = 0;
  final double _playbackSpeed = 1.0;
  bool _showOverlay = true;
  String _errorMessage = '';

  MangaStoryChapter? _chapter;

  bool get isPlaying => _isPlaying;
  bool get isLoadingUrl => _isLoadingUrl;
  int get currentPanelIndex => _currentPanelIndex;
  int get currentBubbleIndex => _currentBubbleIndex;
  double get playbackSpeed => _playbackSpeed;
  bool get showOverlay => _showOverlay;
  String get errorMessage => _errorMessage;
  MangaStoryChapter? get chapter => _chapter;

  PanelKeyframe? get currentPanel {
    final ch = _chapter;
    if (ch == null || _currentPanelIndex >= ch.keyframes.length) return null;
    return ch.keyframes[_currentPanelIndex];
  }

  BubbleAnnotation? get currentBubble {
    final panel = currentPanel;
    if (panel == null || _currentBubbleIndex >= panel.bubbles.length) {
      return null;
    }
    return panel.bubbles[_currentBubbleIndex];
  }

  void loadChapter(MangaStoryChapter chapter) {
    _chapter = chapter;
    _currentPanelIndex = 0;
    _currentBubbleIndex = 0;
    _errorMessage = '';
    notifyListeners();
  }

  Future<bool> loadFromWebtoonUrl(String url) async {
    _isLoadingUrl = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final newChapter = await MangaUrlLoaderService.loadFromUrl(url);
      _chapter = newChapter;
      _currentPanelIndex = 0;
      _currentBubbleIndex = 0;
      _isLoadingUrl = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoadingUrl = false;
      notifyListeners();
      return false;
    }
  }

  void toggleOverlay() {
    _showOverlay = !_showOverlay;
    notifyListeners();
  }

  void togglePlayPause() {
    if (_isPlaying) {
      pause();
    } else {
      play();
    }
  }

  void play() {
    _isPlaying = true;
    notifyListeners();
    _executeCinemaStep();
  }

  void pause() {
    _isPlaying = false;
    _voiceEngine.stop();
    notifyListeners();
  }

  void nextPanel() {
    final ch = _chapter;
    if (ch == null) return;
    if (_currentPanelIndex < ch.keyframes.length - 1) {
      _currentPanelIndex++;
      _currentBubbleIndex = 0;
      notifyListeners();
    }
  }

  void previousPanel() {
    if (_currentPanelIndex > 0) {
      _currentPanelIndex--;
      _currentBubbleIndex = 0;
      notifyListeners();
    }
  }

  void jumpToPanel(int index) {
    final ch = _chapter;
    if (ch == null) return;
    if (index >= 0 && index < ch.keyframes.length) {
      _currentPanelIndex = index;
      _currentBubbleIndex = 0;
      notifyListeners();
    }
  }

  Future<void> _executeCinemaStep() async {
    while (_isPlaying && _chapter != null) {
      final panel = currentPanel;
      if (panel == null) {
        _isPlaying = false;
        notifyListeners();
        break;
      }

      if (_currentBubbleIndex < panel.bubbles.length) {
        final bubble = panel.bubbles[_currentBubbleIndex];
        notifyListeners();

        // Speak current bubble
        await _voiceEngine.speakDialogue(
          text: bubble.speechText,
          role: bubble.role,
        );

        if (!_isPlaying) break;

        // Dramatic Pause
        await Future<void>.delayed(
          Duration(milliseconds: (bubble.pauseSeconds * 1000).toInt()),
        );

        if (!_isPlaying) break;
        _currentBubbleIndex++;
      } else {
        // Smooth scroll to next panel
        if (_currentPanelIndex < _chapter!.keyframes.length - 1) {
          _currentPanelIndex++;
          _currentBubbleIndex = 0;
          notifyListeners();
          await Future<void>.delayed(const Duration(milliseconds: 700));
        } else {
          _isPlaying = false;
          notifyListeners();
          break;
        }
      }
    }
  }
}
