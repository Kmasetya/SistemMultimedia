import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class SkyBackground extends StatelessWidget {
  final Widget child;

  const SkyBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.skyGradient),
      child: Stack(
        children: [
          const _Cloud(left: -15, top: 60, scale: 1.2, opacity: 0.9),
          _Cloud(left: MediaQuery.of(context).size.width - 140, top: 50, scale: 0.9, opacity: 0.85),
          _Cloud(left: MediaQuery.of(context).size.width / 2 - 70, top: 100, scale: 0.7, opacity: 0.7),
          _Cloud(left: -20, top: MediaQuery.of(context).size.height * 0.4, scale: 0.8, opacity: 0.6),
          _Cloud(left: MediaQuery.of(context).size.width - 110, top: MediaQuery.of(context).size.height * 0.45, scale: 1.0, opacity: 0.7),
          child,
        ],
      ),
    );
  }
}

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

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size.height * 0.5, size.width, size.height * 0.5),
        const Radius.circular(15),
      ),
      paint,
    );
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.45), 20, paint);
    canvas.drawCircle(Offset(size.width * 0.45, size.height * 0.3), 28, paint);
    canvas.drawCircle(Offset(size.width * 0.72, size.height * 0.42), 20, paint);
  }

  @override
  bool shouldRepaint(_CloudPainter oldDelegate) => false;
}
