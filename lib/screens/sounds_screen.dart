import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../constants/app_colors.dart';
import '../models/animal.dart';
import '../services/audio_manager.dart';

class _Round {
  final Animal correct;
  final List<Animal> options;

  _Round({required this.correct, required this.options});

  factory _Round.random() {
    final shuffled = List<Animal>.from(allAnimals)..shuffle();
    final correct = shuffled[0];
    final options = [correct, ...shuffled.skip(1).take(3)]..shuffle();
    return _Round(correct: correct, options: options);
  }
}

class SoundsScreen extends StatefulWidget {
  const SoundsScreen({super.key});

  @override
  State<SoundsScreen> createState() => _SoundsScreenState();
}

class _SoundsScreenState extends State<SoundsScreen> {
  static const int total = 8;
  late _Round round;
  int qNum = 0;
  int score = 0;
  String? answered;
  bool isFinished = false;

  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _nextRoundTimer;

  @override
  void initState() {
    super.initState();
    AudioManager().pauseBgm();
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
    round = _Round.random();
  }

  void _playSound() async {
    try {
      // Always stop & release previous sound before playing new one
      await _audioPlayer.stop();
      final path = round.correct.audioPath;
      final source = kIsWeb ? UrlSource('assets/$path') : AssetSource(path);
      await _audioPlayer.play(source);
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  @override
  void dispose() {
    _nextRoundTimer?.cancel();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _handleAnswer(String animalId) {
    if (answered != null) return;

    _audioPlayer.stop();

    final correct = animalId == round.correct.id;
    
    if (correct) {
      AudioManager().playCorrect();
    } else {
      AudioManager().playWrong();
    }

    setState(() {
      answered = animalId;
      if (correct) score++;
    });

    _nextRoundTimer?.cancel();
    _nextRoundTimer = Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      _audioPlayer.stop(); // Ensure audio is fully stopped before next round
      if (qNum + 1 >= total) {
        setState(() => isFinished = true);
        AudioManager().playWin();
      } else {
        setState(() {
          qNum++;
          round = _Round.random();
          answered = null;
        });
      }
    });
  }

  void _restart() {
    _nextRoundTimer?.cancel();
    _audioPlayer.stop();
    setState(() {
      qNum = 0;
      score = 0;
      answered = null;
      isFinished = false;
      round = _Round.random();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final stars = score >= 6 ? 3 : score >= 4 ? 2 : score >= 2 ? 1 : 0;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFBE9E7), Color(0xFFFFCCBC), Color(0xFFFF8A65)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      children: [
                        _CircleBtn(onTap: () {
                          _audioPlayer.stop();
                          Navigator.pop(context, score);
                        }),
                        Expanded(
                          child: Text('Animal Sounds', textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFFBF360C))),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(16)),
                          child: Row(children: [
                            const Icon(Icons.star_rounded, color: AppColors.orange, size: 16),
                            const SizedBox(width: 4),
                            Text('$score', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: AppColors.orange, fontSize: 16)),
                          ]),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: qNum / total,
                        backgroundColor: Colors.white.withOpacity(0.4),
                        valueColor: const AlwaysStoppedAnimation(AppColors.orange),
                        minHeight: 8,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text(
                      'Listen to the sound!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFFBF360C)),
                    ),
                  ),

                  Container(
                    width: size.width * 0.72,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 6))],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: _playSound,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(color: AppColors.orange, borderRadius: BorderRadius.circular(20)),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.volume_up_rounded, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Text('Play Sound', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: round.options.map((animal) {
                          Color bg = Colors.white;
                          Color textColor = AppColors.textDark;
                          Widget? trailing;
                          if (answered != null) {
                            if (animal.id == round.correct.id) { bg = AppColors.green; textColor = Colors.white; trailing = const Icon(Icons.check_circle_rounded, color: Colors.white); }
                            else if (animal.id == answered) { bg = AppColors.red; textColor = Colors.white; }
                          }
                          return GestureDetector(
                            onTap: () => _handleAnswer(animal.id),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              decoration: BoxDecoration(
                                color: bg, borderRadius: BorderRadius.circular(18),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 2))],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(animal.nameId, style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w700, color: textColor)),
                                  if (trailing != null) trailing,
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),

              if (isFinished)
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.all(32),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${'⭐' * stars}${'☆' * (3 - stars)}', style: const TextStyle(fontSize: 40)),
                          const SizedBox(height: 8),
                          Text(
                            score >= 6 ? 'Superstar!' : score >= 4 ? 'Good ears!' : 'Keep listening!',
                            style: GoogleFonts.nunito(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.orange),
                          ),
                          const SizedBox(height: 4),
                          Text('$score / $total Correct', style: GoogleFonts.nunito(fontSize: 18, color: AppColors.textGrey)),
                          const SizedBox(height: 24),
                          _FullBtn(label: 'Play Again', color: AppColors.orange, onTap: _restart),
                          TextButton(
                            onPressed: () => Navigator.pop(context, score),
                            child: Text('Back to Menu', style: GoogleFonts.nunito(color: AppColors.textGrey, fontSize: 15)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _CircleBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), shape: BoxShape.circle),
        child: Icon(Icons.arrow_back_rounded, color: AppColors.orange, size: 22),
      ),
    );
  }
}

class _FullBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _FullBtn({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(30)),
        child: Text(label, textAlign: TextAlign.center,
          style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
      ),
    );
  }
}
