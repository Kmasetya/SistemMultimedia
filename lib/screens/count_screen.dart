import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../models/animal.dart';
import '../services/audio_manager.dart';

class _Round {
  final Animal animal;
  final int count;

  _Round({required this.animal, required this.count});

  factory _Round.random() {
    final animals = List<Animal>.from(allAnimals)..shuffle();
    return _Round(
      animal: animals.first,
      count: (1 + (DateTime.now().millisecondsSinceEpoch % 5)).toInt(),
    );
  }
}

class CountScreen extends StatefulWidget {
  const CountScreen({super.key});

  @override
  State<CountScreen> createState() => _CountScreenState();
}

class _CountScreenState extends State<CountScreen> {
  static const int total = 10;
  late _Round round;
  int qNum = 0;
  int score = 0;
  int? selected;
  bool isFinished = false;

  @override
  void initState() {
    super.initState();
    AudioManager().pauseBgm();
    round = _Round.random();
  }

  void _handleAnswer(int num) {
    if (selected != null) return;
    final correct = num == round.count;
    
    if (correct) {
      AudioManager().playCorrect();
    } else {
      AudioManager().playWrong();
    }

    setState(() {
      selected = num;
      if (correct) score++;
    });

    Timer(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      if (qNum + 1 >= total) {
        setState(() => isFinished = true);
        AudioManager().playWin();
      } else {
        setState(() {
          qNum++;
          round = _Round.random();
          selected = null;
        });
      }
    });
  }

  void _restart() {
    setState(() {
      qNum = 0;
      score = 0;
      selected = null;
      isFinished = false;
      round = _Round.random();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cardSize = (size.width - 100) / 3;
    final stars = score >= 8 ? 3 : score >= 5 ? 2 : score >= 3 ? 1 : 0;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9), Color(0xFFA5D6A7)],
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
                        _CircleBtn(onTap: () => Navigator.pop(context, score)),
                        Expanded(
                          child: Text('Hitung Hewan', textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFF1B5E20))),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(16)),
                          child: Row(children: [
                            const Icon(Icons.star_rounded, color: AppColors.green, size: 16),
                            const SizedBox(width: 4),
                            Text('$score', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: AppColors.green, fontSize: 16)),
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
                            backgroundColor: Colors.white.withValues(alpha: 0.4),
                            valueColor: const AlwaysStoppedAnimation(AppColors.green),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('${qNum + 1} / $total', style: GoogleFonts.nunito(color: const Color(0xFF2E7D32), fontSize: 13)),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text('Ada berapa hewan?',
                      style: GoogleFonts.nunito(fontSize: 28, fontWeight: FontWeight.w800, color: const Color(0xFF1B5E20))),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: List.generate(5, (i) => i < round.count
                          ? Container(
                              width: cardSize,
                              height: cardSize,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6, offset: const Offset(0, 3))],
                              ),
                              padding: const EdgeInsets.all(4),
                              child: Image.asset(round.animal.imagePath, fit: BoxFit.contain),
                            )
                          : SizedBox(width: cardSize, height: cardSize)),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(round.animal.nameId,
                      style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF388E3C))),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      final num = i + 1;
                      Color bg = Colors.white;
                      Color textColor = AppColors.textDark;
                      if (selected != null) {
                        if (num == round.count) { bg = AppColors.green; textColor = Colors.white; }
                        else if (num == selected) { bg = AppColors.red; textColor = Colors.white; }
                      }
                      return GestureDetector(
                        onTap: () => _handleAnswer(num),
                        child: Container(
                          width: 56, height: 56,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: bg, shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 6, offset: const Offset(0, 3))],
                          ),
                          child: Center(
                            child: Text('$num', style: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.w900, color: textColor)),
                          ),
                        ),
                      );
                    }),
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
                            score >= 8 ? 'Luar Biasa!' : score >= 5 ? 'Hebat!' : 'Terus Menghitung!',
                            style: GoogleFonts.nunito(fontSize: 30, fontWeight: FontWeight.w900, color: AppColors.green),
                          ),
                          const SizedBox(height: 4),
                          Text('$score / $total Benar', style: GoogleFonts.nunito(fontSize: 18, color: AppColors.textGrey)),
                          const SizedBox(height: 24),
                          _FullBtn(label: 'Main Lagi', color: AppColors.green, onTap: _restart),
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
  const _CircleBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.6), shape: BoxShape.circle),
        child: const Icon(Icons.arrow_back_rounded, color: AppColors.green, size: 22),
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
