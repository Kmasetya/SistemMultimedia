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

  /// Initialize BGM player settings (loop mode, volume listener).
  /// Does NOT start playing — call ensureBgmPlaying() to start.
  Future<void> initBgm() async {
    if (_isBgmInitialized) return;
    _isBgmInitialized = true;

    _bgmPlayer.setReleaseMode(ReleaseMode.loop);

    // Listen to volume changes
    bgmVolume.addListener(() {
      _bgmPlayer.setVolume(bgmVolume.value);
    });
  }

  /// Check if BGM is currently playing.
  bool get isBgmPlaying => _bgmPlayer.state == PlayerState.playing;

  /// Ensure BGM is playing. If already playing, does nothing.
  /// If paused, resumes. If stopped/completed, starts from beginning.
  Future<void> ensureBgmPlaying() async {
    try {
      final state = _bgmPlayer.state;
      if (state == PlayerState.playing) {
        // Already playing, do nothing
        return;
      } else if (state == PlayerState.paused) {
        // Resume from where it was paused
        await _bgmPlayer.resume();
      } else {
        // Stopped or completed — start from beginning
        const path = 'audio/audio effect/bgm_game.mp3';
        final source = kIsWeb ? UrlSource('assets/$path') : AssetSource(path);
        await _bgmPlayer.play(source, volume: bgmVolume.value);
      }
    } catch (e) {
      debugPrint('Error ensuring BGM: $e');
    }
  }

  /// Pause BGM playback (preserves position for resume).
  void pauseBgm() {
    _bgmPlayer.pause();
  }

  /// Stop BGM playback completely (loses position).
  void stopBgm() {
    _bgmPlayer.stop();
  }

  /// Resume BGM from where it was paused.
  /// If stopped/completed, restarts from beginning.
  Future<void> resumeBgm() async {
    await ensureBgmPlaying();
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
}
