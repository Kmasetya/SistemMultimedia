import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../models/animal.dart';
import '../services/audio_manager.dart';

class _CardData {
  final String id;
  final Animal animal;
  bool isFlipped;
  bool isMatched;

  _CardData({
    required this.id,
    required this.animal,
    this.isFlipped = false,
    this.isMatched = false,
  });
}

List<_CardData> _makeCards() {
  final selected = allAnimals.take(8).toList();
  final pairs = [...selected, ...selected];
  pairs.shuffle();
  return pairs
      .asMap()
      .entries
      .map((e) => _CardData(id: '${e.value.id}-${e.key}', animal: e.value))
      .toList();
}

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  late List<_CardData> cards;
  List<String> selected = [];
  int moves = 0;
  int matches = 0;
  bool isChecking = false;
  bool isWon = false;

  @override
  void initState() {
    super.initState();
    AudioManager().pauseBgm();
    cards = _makeCards();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _handleTap(String id) {
    if (isChecking) return;
    final card = cards.firstWhere((c) => c.id == id);
    if (card.isFlipped || card.isMatched) return;

    AudioManager().playTap();

    setState(() {
      card.isFlipped = true;
      selected.add(id);
    });

    if (selected.length == 2) {
      isChecking = true;
      moves++;
      final c1 = cards.firstWhere((c) => c.id == selected[0]);
      final c2 = cards.firstWhere((c) => c.id == selected[1]);

      Timer(const Duration(milliseconds: 900), () {
        setState(() {
          if (c1.animal.id == c2.animal.id) {
            c1.isMatched = true;
            c2.isMatched = true;
            matches++;
            if (matches == 8) {
              isWon = true;
              AudioManager().playWin();
            } else {
              AudioManager().playCorrect();
            }
          } else {
            AudioManager().playWrong();
            c1.isFlipped = false;
            c2.isFlipped = false;
          }
          selected = [];
          isChecking = false;
        });
      });
    }
  }

  void _restart() {
    setState(() {
      cards = _makeCards();
      selected = [];
      moves = 0;
      matches = 0;
      isChecking = false;
      isWon = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEDE7F6), Color(0xFFD1C4E9), Color(0xFFB39DDB)],
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
                        _CircleBtn(
                          icon: Icons.arrow_back_rounded,
                          color: AppColors.purple,
                          onTap: () {
                            Navigator.pop(context, matches);
                          },
                        ),
                        Expanded(
                          child: Text(
                            'Memory Match',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF4A148C),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.bolt_rounded, color: AppColors.purple, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                '$moves',
                                style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.purple,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(8, (i) => Container(
                        width: 12,
                        height: 12,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i < matches ? AppColors.purple : Colors.transparent,
                          border: Border.all(color: AppColors.purple, width: 2),
                        ),
                      )),
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: 16,
                        itemBuilder: (context, i) => _MemoryCard(
                          card: cards[i],
                          onTap: () => _handleTap(cards[i].id),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              if (isWon)
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.all(32),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🎉', style: TextStyle(fontSize: 60)),
                          const SizedBox(height: 8),
                          Text('You Win!', style: GoogleFonts.nunito(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.purple)),
                          const SizedBox(height: 4),
                          Text('Completed in $moves moves', style: GoogleFonts.nunito(fontSize: 16, color: AppColors.textGrey)),
                          const SizedBox(height: 24),
                          _FullBtn(label: 'Play Again', color: AppColors.purple, onTap: _restart),
                          TextButton(
                            onPressed: () => Navigator.pop(context, matches),
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

class _MemoryCard extends StatelessWidget {
  final _CardData card;
  final VoidCallback onTap;

  const _MemoryCard({required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: card.isFlipped || card.isMatched
            ? Container(
                key: const ValueKey('front'),
                decoration: BoxDecoration(
                  color: card.isMatched
                      ? card.animal.color.withOpacity(0.2)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: card.isMatched
                      ? Border.all(color: card.animal.color, width: 3)
                      : null,
                ),
                padding: const EdgeInsets.all(4),
                child: Image.asset(card.animal.imagePath, fit: BoxFit.contain),
              )
            : Container(
                key: const ValueKey('back'),
                decoration: BoxDecoration(
                  color: AppColors.purple,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '?',
                    style: GoogleFonts.nunito(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CircleBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 22),
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
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
    );
  }
}
