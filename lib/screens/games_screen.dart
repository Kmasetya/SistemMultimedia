import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/sky_background.dart';
import '../constants/app_colors.dart';
import 'memory_game.dart';
import 'quiz_screen.dart';
import 'count_screen.dart';
import 'sounds_screen.dart';
import 'spelling_screen.dart';

class _GameInfo {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color bgLight;
  final Widget Function() screenBuilder;

  const _GameInfo({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.bgLight,
    required this.screenBuilder,
  });
}

final _games = [
  _GameInfo(
    title: 'Memory Match',
    subtitle: 'Find the pairs!',
    icon: Icons.grid_view_rounded,
    color: AppColors.purple,
    bgLight: const Color(0xFFEDE7F6),
    screenBuilder: () => const MemoryGameScreen(),
  ),
  _GameInfo(
    title: 'Animal Quiz',
    subtitle: 'Name the animal!',
    icon: Icons.help_rounded,
    color: AppColors.red,
    bgLight: const Color(0xFFFFEBEE),
    screenBuilder: () => const QuizScreen(),
  ),
  _GameInfo(
    title: 'Count Animals',
    subtitle: 'How many can you see?',
    icon: Icons.tag_rounded,
    color: AppColors.green,
    bgLight: const Color(0xFFE8F5E9),
    screenBuilder: () => const CountScreen(),
  ),
  _GameInfo(
    title: 'Animal Sounds',
    subtitle: 'Listen and guess!',
    icon: Icons.volume_up_rounded,
    color: AppColors.orange,
    bgLight: const Color(0xFFFBE9E7),
    screenBuilder: () => const SoundsScreen(),
  ),
  _GameInfo(
    title: 'Spell Animal',
    subtitle: 'Spell the name!',
    icon: Icons.abc_rounded,
    color: const Color(0xFF1565C0), // Blue
    bgLight: const Color(0xFFE3F2FD), // Light Blue
    screenBuilder: () => const SpellingScreen(),
  ),
];

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SkyBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  children: [
                    _BackButton(onTap: () => Navigator.pop(context)),
                    Expanded(
                      child: Text(
                        'Choose a Game!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: const Offset(1, 1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, color: AppColors.yellow, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '0',
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.9,
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(
                      _games.length,
                      (i) => _GameCard(game: _games[i], index: i),
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

class _GameCard extends StatelessWidget {
  final _GameInfo game;
  final int index;

  const _GameCard({required this.game, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => game.screenBuilder()),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [game.bgLight, Colors.white],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: game.color,
                shape: BoxShape.circle,
              ),
              child: Icon(game.icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              game.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: game.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              game.subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: game.color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Play',
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: (index * 120).ms)
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.8, 0.8));
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
      ),
    );
  }
}
