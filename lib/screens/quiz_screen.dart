import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../models/animal.dart';
import '../services/audio_manager.dart';

class _Question {
  final Animal correct;
  final List<Animal> options;

  _Question({required this.correct, required this.options});

  factory _Question.random() {
    final shuffled = List<Animal>.from(allAnimals)..shuffle();
    final correct = shuffled[0];
    final options = [correct, ...shuffled.skip(1).take(3).toList()]..shuffle();
    return _Question(correct: correct, options: options);
  }
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  static const int total = 10;
  late _Question question;
  int qNum = 0;
  int score = 0;
  String? answered;
  bool isFinished = false;

  @override
  void initState() {
    super.initState();
    AudioManager().pauseBgm();
    question = _Question.random();
  }

  void _handleAnswer(String animalId) {
    if (answered != null) return;
    final correct = animalId == question.correct.id;
    
    if (correct) {
      AudioManager().playCorrect();
    } else {
      AudioManager().playWrong();
    }

    setState(() {
      answered = animalId;
      if (correct) score++;
    });

    Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      if (qNum + 1 >= total) {
        setState(() => isFinished = true);
        AudioManager().playWin();
      } else {
        setState(() {
          qNum++;
          question = _Question.random();
          answered = null;
        });
      }
    });
  }

  void _restart() {
    setState(() {
      qNum = 0;
      score = 0;
      answered = null;
      isFinished = false;
      question = _Question.random();
    });
  }

  @override
  Widget build(BuildContext context) {
    final stars = score >= 8 ? 3 : score >= 5 ? 2 : score >= 3 ? 1 : 0;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFEBEE), Color(0xFFFFCDD2), Color(0xFFEF9A9A)],
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
                        _CircleBtn(onTap: () => Navigator.pop(context, score), color: AppColors.red),
                        Expanded(
                          child: Text('Kuis Hewan', textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFFB71C1C))),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), borderRadius: BorderRadius.circular(16)),
                          child: Row(children: [
                            const Icon(Icons.star_rounded, color: AppColors.red, size: 16),
                            const SizedBox(width: 4),
                            Text('$score', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: AppColors.red, fontSize: 16)),
                          ]),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: qNum / total,
                            backgroundColor: Colors.white.withOpacity(0.4),
                            valueColor: const AlwaysStoppedAnimation(AppColors.red),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('${qNum + 1} / $total', style: GoogleFonts.nunito(color: const Color(0xFFB71C1C), fontSize: 13)),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text('Hewan apakah ini?',
                      style: GoogleFonts.nunito(fontSize: 26, fontWeight: FontWeight.w800, color: const Color(0xFFB71C1C))),
                  ),

                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: MediaQuery.of(context).size.width * 0.6,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 6))],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Image.asset(question.correct.imagePath, fit: BoxFit.contain),
                  ),

                  const SizedBox(height: 20),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: question.options.map((animal) {
                          Color bg = Colors.white;
                          Color textColor = AppColors.textDark;
                          Widget? trailing;
                          if (answered != null) {
                            if (animal.id == question.correct.id) {
                              bg = AppColors.green;
                              textColor = Colors.white;
                              trailing = const Icon(Icons.check_circle_rounded, color: Colors.white);
                            } else if (animal.id == answered) {
                              bg = AppColors.red;
                              textColor = Colors.white;
                              trailing = const Icon(Icons.cancel_rounded, color: Colors.white);
                            }
                          }
                          return GestureDetector(
                            onTap: () => _handleAnswer(animal.id),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              decoration: BoxDecoration(
                                color: bg,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 2))],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(animal.nameId, style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w700, color: textColor)),
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
                            score >= 8 ? 'Luar Biasa!' : score >= 5 ? 'Bagus Sekali!' : 'Terus Berusaha!',
                            style: GoogleFonts.nunito(fontSize: 30, fontWeight: FontWeight.w900, color: AppColors.red),
                          ),
                          const SizedBox(height: 4),
                          Text('$score / $total Benar', style: GoogleFonts.nunito(fontSize: 18, color: AppColors.textGrey)),
                          const SizedBox(height: 24),
                          _FullBtn(label: 'Coba Lagi', color: AppColors.red, onTap: _restart),
                          TextButton(
                            onPressed: () => Navigator.pop(context, score),
                            child: Text('Kembali ke Menu', style: GoogleFonts.nunito(color: AppColors.textGrey, fontSize: 15)),
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
  final Color color;
  const _CircleBtn({required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), shape: BoxShape.circle),
        child: Icon(Icons.arrow_back_rounded, color: color, size: 22),
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
