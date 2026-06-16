import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/sky_background.dart';
import '../constants/app_colors.dart';
import '../services/audio_manager.dart';
import 'games_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500), // Slower, smoother floating
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOutSine),
    );

    // Start BGM when home screen loads (no-op if already playing)
    AudioManager().ensureBgmPlaying();
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize = (screenWidth * 0.8).clamp(150.0, 300.0);

    return Scaffold(
      body: SkyBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),

                  // Title "Kids" — clean solid color with thick cartoon drop shadow
                  Text(
                    'Animals',
                    style: GoogleFonts.nunito(
                      fontSize: 76,
                      height: 1.0,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textKids,
                      shadows: const [
                        // Thick solid bottom shadow for 3D effect
                        Shadow(color: Colors.black26, offset: Offset(0, 6), blurRadius: 0),
                        // Soft white outline effect using shadows
                        Shadow(color: Colors.white, offset: Offset(-2, -2), blurRadius: 0),
                        Shadow(color: Colors.white, offset: Offset(2, -2), blurRadius: 0),
                        Shadow(color: Colors.white, offset: Offset(-2, 2), blurRadius: 0),
                        Shadow(color: Colors.white, offset: Offset(2, 2), blurRadius: 0),
                      ],
                    ),
                  ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),

                  // Title "Games"
                  Text(
                    'Games',
                    style: GoogleFonts.nunito(
                      fontSize: 48,
                      height: 1.0,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textGames,
                      shadows: const [
                        Shadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 0),
                        Shadow(color: Colors.white, offset: Offset(-1.5, -1.5), blurRadius: 0),
                        Shadow(color: Colors.white, offset: Offset(1.5, -1.5), blurRadius: 0),
                        Shadow(color: Colors.white, offset: Offset(-1.5, 1.5), blurRadius: 0),
                        Shadow(color: Colors.white, offset: Offset(1.5, 1.5), blurRadius: 0),
                      ],
                    ),
                  ).animate().fadeIn(duration: 600.ms, delay: 100.ms),

                  const SizedBox(height: 32),

                  // Animal image — simple, clean, premium rounded border
                  AnimatedBuilder(
                    animation: _bounceAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _bounceAnimation.value),
                        child: child,
                      );
                    },
                    child: Container(
                      width: imageSize,
                      height: imageSize,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(36),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(8), // White border thickness
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Container(
                          color: const Color(0xFFFFF9E6), // Soft warm background behind animals
                          child: Image.asset(
                            'assets/images/animals-hero.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 800.ms, delay: 200.ms),

                  const SizedBox(height: 48),

                  // Simple, clean, pill-shaped Play button
                  _PlayButton(
                    onTap: () async {
                      // BGM keeps playing — no stop needed between home and games
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GamesScreen()),
                      );
                      // Resume BGM in case it was paused by a game screen
                      AudioManager().ensureBgmPlaying();
                    },
                  ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.9, 0.9)),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          
          // Volume Control at top right
          Positioned(
            top: 16,
            right: 16,
            child: _VolumeControl(),
          ),
        ],
      ),
        ),
      ),
    );
  }
}

class _PlayButton extends StatefulWidget {
  final VoidCallback onTap;
  const _PlayButton({required this.onTap});

  @override
  State<_PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<_PlayButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000), // Slower, elegant pulse
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) => Transform.scale(
        scale: _pulseAnimation.value,
        child: child,
      ),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.playButton,
            borderRadius: BorderRadius.circular(100), // Perfect pill shape
            border: const Border(
              bottom: BorderSide(
                color: AppColors.playButtonShadow,
                width: 6, // Thick 3D bottom border
              ),
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
              const SizedBox(width: 8),
              Text(
                'Play',
                style: GoogleFonts.nunito(
                  fontSize: 32,
                  height: 1.0,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                      color: AppColors.playButtonShadow,
                      offset: Offset(0, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VolumeControl extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.volume_up_rounded, color: AppColors.textDark, size: 20),
          SizedBox(
            width: 80,
            child: ValueListenableBuilder<double>(
              valueListenable: AudioManager().bgmVolume,
              builder: (context, vol, child) {
                return Slider(
                  value: vol,
                  min: 0.0,
                  max: 1.0,
                  activeColor: AppColors.textDark,
                  inactiveColor: Colors.white,
                  onChanged: (newVol) {
                    AudioManager().bgmVolume.value = newVol;
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
