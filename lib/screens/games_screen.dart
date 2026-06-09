import 'dart:math';
import 'package:flutter/material.dart';
import 'memory_game.dart';
import 'quiz_screen.dart';
import 'count_screen.dart';
import 'sounds_screen.dart';
import 'spelling_screen.dart';

// ─────────────────────────────────────────────
//  Model
// ─────────────────────────────────────────────
class _GameItem {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final Color iconBg;
  final Widget Function() screenBuilder;

  const _GameItem({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.iconBg,
    required this.screenBuilder,
  });
}

final List<_GameItem> _kGames = [
  _GameItem(
    emoji: '🧠',
    title: 'Asah Memori Seru!',
    subtitle: 'Find the pairs!',
    color: const Color(0xFF862DCB),
    iconBg: const Color(0xFFF3EEFF),
    screenBuilder: () => const MemoryGameScreen(),
  ),
  _GameItem(
    emoji: '🦁',
    title: 'Animal Quiz',
    subtitle: 'Name the animal!',
    color: const Color(0xFFB60E3D),
    iconBg: const Color(0xFFFFF0F2),
    screenBuilder: () => const QuizScreen(),
  ),
  _GameItem(
    emoji: '🔢',
    title: 'Count Animals',
    subtitle: 'How many can you see?',
    color: const Color(0xFF006780),
    iconBg: const Color(0xFFE0F5FF),
    screenBuilder: () => const CountScreen(),
  ),
  _GameItem(
    emoji: '🔊',
    title: 'Animal Sounds',
    subtitle: 'Listen and guess!',
    color: const Color(0xFFDA3054),
    iconBg: const Color(0xFFFFF0F4),
    screenBuilder: () => const SoundsScreen(),
  ),
  _GameItem(
    emoji: '✏️',
    title: 'Spell Animal',
    subtitle: 'Spell the name!',
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
  int _stars = 0;
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
  }

  @override
  void dispose() {
    for (final c in _cloudControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onPlay(_GameItem game) {
    setState(() {
      _stars += 10;
      _starPop = true;
    });
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _starPop = false);
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => game.screenBuilder()),
    );
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

          // ── Awan bergerak ──
          ...List.generate(_clouds.length, (i) {
            return AnimatedBuilder(
              animation: _cloudAnimations[i],
              builder: (_, __) {
                final screenW = MediaQuery.of(context).size.width;
                final screenH = MediaQuery.of(context).size.height;
                return Positioned(
                  top: screenH * _clouds[i].top,
                  left: _cloudAnimations[i].value *
                          (screenW + _clouds[i].width + 100) -
                      _clouds[i].width,
                  child: Opacity(
                    opacity: _clouds[i].opacity,
                    child: Container(
                      width: _clouds[i].width,
                      height: _clouds[i].height,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(_clouds[i].height / 2),
                      ),
                    ),
                  ),
                );
              },
            );
          }),

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
            'Choose a Game!',
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
//  Game Card  (dengan semua animasi)
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
    with SingleTickerProviderStateMixin {
  // ── Controller untuk float-in entry ──
  late final AnimationController _entryCtrl;
  late final Animation<double> _entryOpacity;
  late final Animation<Offset> _entrySlide;

  // ── State untuk press + tilt ──
  double _rotX = 0, _rotY = 0;
  double _scale = 1.0;
  double _translateY = 0.0;
  bool _pressed = false;

  // ── Ripple ──
  final List<_RippleData> _ripples = [];

  @override
  void initState() {
    super.initState();
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

    // Stagger entry per kartu
    Future.delayed(Duration(milliseconds: 60 * widget.index + 80), () {
      if (mounted) _entryCtrl.forward();
    });
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  // ── Tilt saat hover (desktop/mouse) ──
  void _onHover(PointerEvent e, BoxConstraints box) {
    final cx = box.maxWidth / 2;
    final cy = box.maxHeight / 2;
    setState(() {
      _rotX = (e.localPosition.dy - cy) / 18;
      _rotY = (cx - e.localPosition.dx) / 18;
      _scale = 1.03;
      _translateY = -8;
    });
  }

  void _onHoverExit() => setState(() {
        _rotX = 0;
        _rotY = 0;
        _scale = 1.0;
        _translateY = 0;
      });

  // ── Press down ──
  void _onTapDown(TapDownDetails d) {
    setState(() {
      _pressed = true;
      _scale = 0.97;
      _translateY = 3;
    });
    // Spawn ripple
    final rip = _RippleData(
      x: d.localPosition.dx,
      y: d.localPosition.dy,
      color: widget.game.color,
      id: DateTime.now().microsecondsSinceEpoch,
    );
    setState(() => _ripples.add(rip));
    Future.delayed(const Duration(milliseconds: 520), () {
      if (mounted) setState(() => _ripples.remove(rip));
    });
  }

  // ── Release ──
  void _onTapUp(TapUpDetails _) {
    setState(() {
      _pressed = false;
      _scale = 1.0;
      _translateY = 0;
    });
    widget.onPlay();
  }

  void _onTapCancel() => setState(() {
        _pressed = false;
        _scale = 1.0;
        _translateY = 0;
      });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _entryOpacity,
      child: SlideTransition(
        position: _entrySlide,
        child: LayoutBuilder(
          builder: (_, constraints) {
            return MouseRegion(
              onHover: (e) => _onHover(e, constraints),
              onExit: (_) => _onHoverExit(),
              child: GestureDetector(
                onTapDown: _onTapDown,
                onTapUp: _onTapUp,
                onTapCancel: _onTapCancel,
                child: AnimatedContainer(
                  duration: _pressed
                      ? const Duration(milliseconds: 80)
                      : const Duration(milliseconds: 350),
                  curve: _pressed ? Curves.easeIn : Curves.elasticOut,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateX(_rotX * pi / 180)
                    ..rotateY(_rotY * pi / 180)
                    ..translate(0.0, _translateY)
                    ..scale(_scale),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: widget.game.color
                            .withOpacity(_pressed ? 0.10 : 0.18),
                        blurRadius: _pressed ? 8 : 24,
                        spreadRadius: -4,
                        offset: Offset(0, _pressed ? 2 : 12),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      // ── Konten kartu ──
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 24, horizontal: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Icon bulat
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.elasticOut,
                              width: 80,
                              height: 80,
                              transform: Matrix4.identity()
                                ..scale(_pressed ? 0.9 : 1.0),
                              decoration: BoxDecoration(
                                color: widget.game.iconBg,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                widget.game.emoji,
                                style: const TextStyle(fontSize: 42),
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

                            // Tombol Play
                            _TactileButton(
                              color: widget.game.color,
                              onTap: widget.onPlay,
                            ),
                          ],
                        ),
                      ),

                      // ── Ripple overlay ──
                      ..._ripples.map((r) => _RippleWidget(data: r)),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Ripple
// ─────────────────────────────────────────────
class _RippleData {
  final double x, y;
  final Color color;
  final int id;
  const _RippleData({
    required this.x,
    required this.y,
    required this.color,
    required this.id,
  });
}

class _RippleWidget extends StatefulWidget {
  final _RippleData data;
  const _RippleWidget({required this.data});

  @override
  State<_RippleWidget> createState() => _RippleWidgetState();
}

class _RippleWidgetState extends State<_RippleWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _size;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _size = Tween<double>(begin: 0, end: 280).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _opacity = Tween<double>(begin: 0.35, end: 0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          final s = _size.value;
          return Stack(children: [
            Positioned(
              left: widget.data.x - s / 2,
              top: widget.data.y - s / 2,
              width: s,
              height: s,
              child: Opacity(
                opacity: _opacity.value,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.data.color,
                  ),
                ),
              ),
            ),
          ]);
        },
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
              'Play',
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
