import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class SkyBackground extends StatelessWidget {
  final Widget child;

  const SkyBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.skyGradient),
      child: Stack(
        children: [
          // Elegant, simple clouds — no messy shadows
          const _Cloud(left: -15, top: 60, scale: 1.2, opacity: 0.9),
          _Cloud(left: size.width - 140, top: 50, scale: 0.9, opacity: 0.8),
          _Cloud(left: size.width / 2 - 70, top: 100, scale: 0.7, opacity: 0.7),
          _Cloud(left: -20, top: size.height * 0.4, scale: 0.8, opacity: 0.5),
          _Cloud(left: size.width - 110, top: size.height * 0.45, scale: 1.0, opacity: 0.6),

          // Clean, modern curved ground at the bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: size.height * 0.1,
              child: CustomPaint(
                painter: _SmoothGroundPainter(),
                size: Size(size.width, size.height * 0.1),
              ),
            ),
          ),

          child,
        ],
      ),
    );
  }
}

// ─── Simple, Clean Clouds ─────────────────────────────────

class _Cloud extends StatelessWidget {
  final double left;
  final double top;
  final double scale;
  final double opacity;

  const _Cloud({
    required this.left,
    required this.top,
    this.scale = 1.0,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Opacity(
        opacity: opacity,
        child: Transform.scale(
          scale: scale,
          child: SizedBox(
            width: 120,
            height: 60,
            child: CustomPaint(painter: _CloudPainter()),
          ),
        ),
      ),
    );
  }
}

class _CloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;

    // A single, unified cloud shape
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size.height * 0.5, size.width, size.height * 0.5),
        const Radius.circular(30), // smoother pill shape bottom
      ),
      paint,
    );
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.5), 20, paint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.35), 28, paint);
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.45), 22, paint);
  }

  @override
  bool shouldRepaint(_CloudPainter oldDelegate) => false;
}

// ─── Smooth Minimalist Ground ─────────────────────────────

class _SmoothGroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF66BB6A); // Clean, solid green

    final path = Path()
      ..moveTo(0, size.height * 0.4)
      ..quadraticBezierTo(size.width * 0.5, -size.height * 0.3, size.width, size.height * 0.5)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SmoothGroundPainter oldDelegate) => false;
}
