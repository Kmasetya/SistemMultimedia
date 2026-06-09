import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  // Singleton pattern
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  // Observable volume for UI slider
  final ValueNotifier<double> bgmVolume = ValueNotifier<double>(0.25);

  bool _isBgmInitialized = false;

  Future<void> initBgm() async {
    if (_isBgmInitialized) return;
    _isBgmInitialized = true;

    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    
    // Listen to volume changes
    bgmVolume.addListener(() {
      _bgmPlayer.setVolume(bgmVolume.value);
    });

    try {
      final path = 'audio/audio effect/bgm_game.mp3';
      final source = kIsWeb ? UrlSource('assets/$path') : AssetSource(path);
      await _bgmPlayer.play(source, volume: bgmVolume.value);
    } catch (e) {
      debugPrint('Error playing BGM: $e');
    }
  }

  void playSfx(String fileName) async {
    try {
      final path = 'audio/audio effect/$fileName';
      final source = kIsWeb ? UrlSource('assets/$path') : AssetSource(path);
      // Create a temporary player for overlapping sounds if needed, 
      // but usually the same sfx player is fine if rapid clicks aren't crucial.
      // For a better experience, we can just play on the same player (it will interrupt).
      await _sfxPlayer.play(source);
    } catch (e) {
      debugPrint('Error playing SFX: $e');
    }
  }
  
  // Specific SFX helpers
  void playTap() => playSfx('flip.mp3');
  void playCorrect() => playSfx('corect.mp3');
  void playWrong() => playSfx('wrong.mp3');
  void playWin() => playSfx('win.mp3');

  void stopBgm() {
    _bgmPlayer.stop();
  }

  void resumeBgm() {
    _bgmPlayer.resume();
  }
}
