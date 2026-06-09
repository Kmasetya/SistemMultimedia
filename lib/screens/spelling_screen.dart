import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';
import '../models/animal.dart';
import '../services/audio_manager.dart';

class SpellingScreen extends StatefulWidget {
  const SpellingScreen({super.key});

  @override
  State<SpellingScreen> createState() => _SpellingScreenState();
}

class _SpellingScreenState extends State<SpellingScreen> {
  static const int total = 8;
  late Animal currentAnimal;
  late String wordToSpell;
  late List<String> shuffledLetters;
  late List<bool> letterUsed;
  late List<String?> guessedLetters;

  int qNum = 0;
  int score = 0;
  int currentIndex = 0;
  bool isFinished = false;

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _startRound();
  }

  void _startRound() {
    // Pilih hewan acak
    final shuffled = List<Animal>.from(allAnimals)..shuffle();
    currentAnimal = shuffled[0];
    
    // Siapkan kata (dalam bahasa Indonesia, huruf kapital semua)
    wordToSpell = currentAnimal.nameId.toUpperCase();
    
    // Buat huruf acak untuk ditebak
    shuffledLetters = wordToSpell.split('')..shuffle();
    
    // Hindari huruf acak yang kebetulan urutannya sama persis dengan aslinya jika memungkinkan
    if (shuffledLetters.join() == wordToSpell && wordToSpell.length > 1) {
      shuffledLetters.shuffle();
    }

    letterUsed = List.filled(shuffledLetters.length, false);
    guessedLetters = List.filled(wordToSpell.length, null);
    currentIndex = 0;
  }

  void _playAnimalSound() async {
    final path = currentAnimal.audioPath;
    try {
      final source = kIsWeb ? UrlSource('assets/$path') : AssetSource(path);
      await _audioPlayer.stop();
      await _audioPlayer.play(source);
    } catch (e) {
      debugPrint("Gagal memutar suara hewan.");
    }
  }

  void _handleLetterTap(int index) {
    if (letterUsed[index] || currentIndex >= wordToSpell.length) return;

    final tappedLetter = shuffledLetters[index];
    final expectedLetter = wordToSpell[currentIndex];

    if (tappedLetter == expectedLetter) {
      // Benar!
      AudioManager().playCorrect();
      setState(() {
        letterUsed[index] = true;
        guessedLetters[currentIndex] = tappedLetter;
        currentIndex++;
      });

      // Cek apakah kata sudah selesai
      if (currentIndex == wordToSpell.length) {
        score++;
        _playAnimalSound();
        
        Timer(const Duration(milliseconds: 2000), () {
          if (!mounted) return;
          if (qNum + 1 >= total) {
            setState(() => isFinished = true);
            AudioManager().playWin();
          } else {
            setState(() {
              qNum++;
              _startRound();
            });
          }
        });
      }
    } else {
      // Salah ketuk
      AudioManager().playWrong();
    }
  }

  void _restart() {
    setState(() {
      qNum = 0;
      score = 0;
      isFinished = false;
      _startRound();
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
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
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB), Color(0xFF64B5F6)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // HEADER
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      children: [
                        _CircleBtn(onTap: () => Navigator.pop(context, score)),
                        Expanded(
                          child: Text('Spelling Game', textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFF1565C0))),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(16)),
                          child: Row(children: [
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text('$score', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: const Color(0xFF1565C0), fontSize: 16)),
                          ]),
                        ),
                      ],
                    ),
                  ),

                  // PROGRESS BAR
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: qNum / total,
                        backgroundColor: Colors.white.withOpacity(0.4),
                        valueColor: const AlwaysStoppedAnimation(Color(0xFF1976D2)),
                        minHeight: 8,
                      ),
                    ),
                  ),

                  // GAMBAR HEWAN
                  const SizedBox(height: 16),
                  Container(
                    width: size.width * 0.5,
                    height: size.width * 0.5,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Image.asset(currentAnimal.imagePath, fit: BoxFit.contain)
                      .animate(key: ValueKey(currentAnimal.id)).scale(duration: 400.ms, curve: Curves.easeOutBack),
                  ),

                  const Spacer(),

                  // SLOT KOSONG UNTUK KATA
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: List.generate(wordToSpell.length, (index) {
                      final letter = guessedLetters[index];
                      final isCurrent = index == currentIndex;
                      
                      return Container(
                        width: 45,
                        height: 55,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: letter != null ? AppColors.green : Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                          border: isCurrent ? Border.all(color: Colors.white, width: 3) : null,
                          boxShadow: letter != null 
                              ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))]
                              : null,
                        ),
                        child: Text(
                          letter ?? '',
                          style: GoogleFonts.nunito(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white),
                        ).animate(target: letter != null ? 1 : 0).scale(curve: Curves.elasticOut),
                      );
                    }),
                  ),

                  const SizedBox(height: 30),

                  // TOMBOL HURUF ACAK
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: List.generate(shuffledLetters.length, (index) {
                        final letter = shuffledLetters[index];
                        final used = letterUsed[index];

                        return GestureDetector(
                          onTap: () => _handleLetterTap(index),
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: used ? 0.0 : 1.0,
                            child: Container(
                              width: 55,
                              height: 65,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6, offset: const Offset(0, 4))],
                              ),
                              child: Text(
                                letter,
                                style: GoogleFonts.nunito(fontSize: 32, fontWeight: FontWeight.w900, color: const Color(0xFF1565C0)),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  const Spacer(flex: 2),
                ],
              ),

              // OVERLAY SELESAI
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
                            score >= 6 ? 'Ejaan Sempurna!' : score >= 4 ? 'Bagus Sekali!' : 'Terus Berlatih!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(fontSize: 26, fontWeight: FontWeight.w900, color: const Color(0xFF1565C0)),
                          ),
                          const SizedBox(height: 4),
                          Text('$score / $total Benar', style: GoogleFonts.nunito(fontSize: 18, color: Colors.grey[700])),
                          const SizedBox(height: 24),
                          _FullBtn(label: 'Main Lagi', color: const Color(0xFF1565C0), onTap: _restart),
                          TextButton(
                            onPressed: () => Navigator.pop(context, score),
                            child: Text('Kembali ke Menu', style: GoogleFonts.nunito(color: Colors.grey[600], fontSize: 16, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ).animate().scale(curve: Curves.elasticOut, duration: 600.ms),
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
        width: 40, height: 40,
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), shape: BoxShape.circle),
        child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1565C0), size: 24),
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
          style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
      ),
    );
  }
}
