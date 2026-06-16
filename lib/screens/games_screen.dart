import 'package:flutter/material.dart';
import '../services/audio_manager.dart';
import 'memory_game.dart';
import 'quiz_screen.dart';
import 'count_screen.dart';
import 'sounds_screen.dart';
import 'spelling_screen.dart';

// ─────────────────────────────────────────────
//  Model
// ─────────────────────────────────────────────
class _GameItem {
  final String imagePath;
  final String title;
  final String subtitle;
  final Color color;
  final Color iconBg;
  final Widget Function() screenBuilder;

  const _GameItem({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.iconBg,
    required this.screenBuilder,
  });
}

final List<_GameItem> _kGames = [
  _GameItem(
    imagePath: 'assets/images/memory.png',
    title: 'Permainan Memori',
    subtitle: 'Temukan pasangannya!',
    color: const Color(0xFF862DCB),
    iconBg: const Color(0xFFF3EEFF),
    screenBuilder: () => const MemoryGameScreen(),
  ),
  _GameItem(
    imagePath: 'assets/images/quiz.png',
    title: 'Kuis Hewan',
    subtitle: 'Sebutkan nama hewannya!',
    color: const Color(0xFFB60E3D),
    iconBg: const Color(0xFFFFF0F2),
    screenBuilder: () => const QuizScreen(),
  ),
  _GameItem(
    imagePath: 'assets/images/count.png',
    title: 'Hitung Hewan',
    subtitle: 'Ada berapa hewan?',
    color: const Color(0xFF006780),
    iconBg: const Color(0xFFE0F5FF),
    screenBuilder: () => const CountScreen(),
  ),
  _GameItem(
    imagePath: 'assets/images/sounds.png',
    title: 'Suara Hewan',
    subtitle: 'Dengarkan dan tebak!',
    color: const Color(0xFFDA3054),
    iconBg: const Color(0xFFFFF0F4),
    screenBuilder: () => const SoundsScreen(),
  ),
  _GameItem(
    imagePath: 'assets/images/spell.png',
    title: 'Eja Hewan',
    subtitle: 'Eja nama hewannya!',
    color: const Color(0xFF004E61),
    iconBg: const Color(0xFFE0F5FF),
    screenBuilder: () => const SpellingScreen(),
  ),
];

// ─────────────────────────────────────────────
//  Screen
// ─────────────────────────────────────────────
class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen>
    with TickerProviderStateMixin {
  static int _stars = 0;
  bool _starPop = false;

  // Cloud drift animations
  late final List<AnimationController> _cloudControllers;
  late final List<Animation<double>> _cloudAnimations;

  final List<_CloudData> _clouds = const [
    _CloudData(width: 120, height: 40, top: 0.08, duration: 38),
    _CloudData(width: 180, height: 55, top: 0.22, duration: 60, opacity: 0.38),
    _CloudData(width: 90,  height: 32, top: 0.55, duration: 28, opacity: 0.45),
    _CloudData(width: 100, height: 36, top: 0.80, duration: 45, opacity: 0.50),
  ];

  @override
  void initState() {
    super.initState();
    _cloudControllers = List.generate(_clouds.length, (i) {
      final ctrl = AnimationController(
        vsync: this,
        duration: Duration(seconds: _clouds[i].duration),
      );
      Future.delayed(Duration(seconds: i * 5), () {
        if (mounted) ctrl.repeat();
      });
      return ctrl;
    });
    _cloudAnimations = _cloudControllers
        .map((c) => Tween<double>(begin: 0.0, end: 1.0).animate(c))
        .toList();

    // Ensure BGM is playing (no-op if already playing from HomeScreen)
    AudioManager().ensureBgmPlaying();
  }

  @override
  void dispose() {
    for (final c in _cloudControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onPlay(_GameItem game) async {
    // Pause BGM before entering game screen (preserves position)
    AudioManager().pauseBgm();

    final result = await Navigator.push<int>(
      context,
      MaterialPageRoute(builder: (_) => game.screenBuilder()),
    );

    // Resume BGM when returning from game
    if (mounted) {
      AudioManager().ensureBgmPlaying();
    }

    if (!mounted) return;
    final earned = result ?? 0;
    if (earned > 0) {
      setState(() {
        _stars += earned;
        _starPop = true;
      });
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) setState(() => _starPop = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Background biru solid ──
          const Positioned.fill(
            child: ColoredBox(color: Color(0xFFA8D8EA)),
          ),

          // ── Awan bergerak (IgnorePointer + RepaintBoundary untuk web) ──
          Positioned.fill(
            child: IgnorePointer(
              child: RepaintBoundary(
                child: _CloudLayer(
                  clouds: _clouds,
                  animations: _cloudAnimations,
                ),
              ),
            ),
          ),

          // ── Konten utama ──
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────
  Widget _buildHeader() {
    return Container(
      color: const Color(0xFF4CC9F0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _GlassCircleButton(
            onTap: () => Navigator.maybePop(context),
            child: const Icon(Icons.arrow_back_rounded,
                color: Color(0xFF004E61), size: 22),
          ),
          const Text(
            'Pilih Permainan!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF003D50),
            ),
          ),
          _StarBadge(stars: _stars, popped: _starPop),
        ],
      ),
    );
  }

  // ── List kartu ──────────────────────────────
  Widget _buildList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      itemCount: _kGames.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _GameCard(
        game: _kGames[i],
        index: i,
        onPlay: () => _onPlay(_kGames[i]),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Game Card  (disederhanakan — tanpa MouseRegion/tilt/ripple
//  agar tidak crash di Flutter Web)
// ─────────────────────────────────────────────
class _GameCard extends StatefulWidget {
  final _GameItem game;
  final int index;
  final VoidCallback onPlay;

  const _GameCard({
    required this.game,
    required this.index,
    required this.onPlay,
  });

  @override
  State<_GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<_GameCard>
    with TickerProviderStateMixin {
  // ── Controller untuk float-in entry ──
  late final AnimationController _entryCtrl;
  late final Animation<double> _entryOpacity;
  late final Animation<Offset> _entrySlide;

  // ── Controller untuk bounce saat tap ──
  late final AnimationController _bounceCtrl;
  late final Animation<double> _bounceAnim;

  // ── Controller untuk emoji jump ──
  late final AnimationController _emojiJumpCtrl;
  late final Animation<double> _emojiJumpAnim;

  @override
  void initState() {
    super.initState();

    // Entry animation
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _entryOpacity = CurvedAnimation(
      parent: _entryCtrl,
      curve: Curves.easeOut,
    );
    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryCtrl,
      curve: Curves.elasticOut,
    ));

    // Bounce animation (spring effect on tap)
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _bounceAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.95), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.04), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.04, end: 0.99), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.99, end: 1.0), weight: 20),
    ]).animate(CurvedAnimation(
      parent: _bounceCtrl,
      curve: Curves.easeOut,
    ));

    // Emoji jump animation
    _emojiJumpCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _emojiJumpAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -18), weight: 25),
      TweenSequenceItem(tween: Tween(begin: -18, end: 0), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0, end: -8), weight: 25),
      TweenSequenceItem(tween: Tween(begin: -8, end: 0), weight: 25),
    ]).animate(CurvedAnimation(
      parent: _emojiJumpCtrl,
      curve: Curves.easeOut,
    ));

    // Stagger entry per kartu
    Future.delayed(Duration(milliseconds: 60 * widget.index + 80), () {
      if (mounted) _entryCtrl.forward();
    });
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _bounceCtrl.dispose();
    _emojiJumpCtrl.dispose();
    super.dispose();
  }

  void _onCardTap() {
    _bounceCtrl.forward(from: 0);
    _emojiJumpCtrl.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) widget.onPlay();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _entryOpacity,
      child: SlideTransition(
        position: _entrySlide,
        child: AnimatedBuilder(
          animation: Listenable.merge([_bounceAnim, _emojiJumpAnim]),
          builder: (context, child) {
            return Transform.scale(
              scale: _bounceAnim.value,
              child: child,
            );
          },
          child: GestureDetector(
            onTap: _onCardTap,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: widget.game.color.withOpacity(0.15),
                    blurRadius: 20,
                    spreadRadius: -4,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 24, horizontal: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Icon bulat dengan jump animation
                      AnimatedBuilder(
                        animation: _emojiJumpAnim,
                        builder: (_, child) => Transform.translate(
                          offset: Offset(0, _emojiJumpAnim.value),
                          child: child,
                        ),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: widget.game.iconBg,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: ClipOval(
                            child: Image.asset(
                              widget.game.imagePath,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Judul
                      Text(
                        widget.game.title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: widget.game.color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),

                      // Subjudul
                      Text(
                        widget.game.subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7F87),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Tombol Main
                      _TactileButton(
                        color: widget.game.color,
                        onTap: widget.onPlay,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Tactile Play Button
// ─────────────────────────────────────────────
class _TactileButton extends StatefulWidget {
  final Color color;
  final VoidCallback onTap;
  const _TactileButton({required this.color, required this.onTap});

  @override
  State<_TactileButton> createState() => _TactileButtonState();
}

class _TactileButtonState extends State<_TactileButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        transform: Matrix4.translationValues(0, _pressed ? 3 : 0, 0),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.20),
              blurRadius: 0,
              offset: Offset(0, _pressed ? 1 : 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 11),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
            SizedBox(width: 5),
            Text(
              'Main',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Glass Circle Button
// ─────────────────────────────────────────────
class _GlassCircleButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  const _GlassCircleButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.45),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: child,
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Star Badge
// ─────────────────────────────────────────────
class _StarBadge extends StatelessWidget {
  final int stars;
  final bool popped;
  const _StarBadge({required this.stars, required this.popped});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.50),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⭐', style: TextStyle(fontSize: 15)),
          const SizedBox(width: 5),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: popped ? 17 : 14,
              color:
                  popped ? const Color(0xFFF59E0B) : const Color(0xFF003D50),
            ),
            child: Text('$stars'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Cloud data helper
// ─────────────────────────────────────────────
class _CloudData {
  final double width, height, top, opacity;
  final int duration;
  const _CloudData({
    required this.width,
    required this.height,
    required this.top,
    required this.duration,
    this.opacity = 0.55,
  });
}

// ─────────────────────────────────────────────
//  Cloud Layer — CustomPaint agar tidak trigger
//  re-layout/hit-test (penyebab mouse_tracker crash)
// ─────────────────────────────────────────────
class _CloudLayer extends StatelessWidget {
  final List<_CloudData> clouds;
  final List<Animation<double>> animations;

  const _CloudLayer({required this.clouds, required this.animations});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(animations),
      builder: (_, __) {
        return CustomPaint(
          painter: _CloudPainter(
            clouds: clouds,
            progresses: animations.map((a) => a.value).toList(),
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _CloudPainter extends CustomPainter {
  final List<_CloudData> clouds;
  final List<double> progresses;

  _CloudPainter({required this.clouds, required this.progresses});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < clouds.length; i++) {
      final cloud = clouds[i];
      final progress = progresses[i];
      final left = progress * (size.width + cloud.width + 100) - cloud.width;
      final top = size.height * cloud.top;

      final paint = Paint()
        ..color = Color.fromRGBO(255, 255, 255, cloud.opacity);

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, cloud.width, cloud.height),
        Radius.circular(cloud.height / 2),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(_CloudPainter old) => true;
}
