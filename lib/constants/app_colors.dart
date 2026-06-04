import 'package:flutter/material.dart';

class AppColors {
  static const Color skyTop = Color(0xFF87CEEB);
  static const Color skyMid = Color(0xFF4DD0E1);
  static const Color skyBottom = Color(0xFF26C6DA);

  static const Color red = Color(0xFFE53935);
  static const Color yellow = Color(0xFFFFD740);
  static const Color golden = Color(0xFFFFA726);
  static const Color green = Color(0xFF43A047);
  static const Color purple = Color(0xFF7E57C2);
  static const Color orange = Color(0xFFFF7043);

  static const Color white = Colors.white;
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGrey = Color(0xFF888888);

  static const LinearGradient skyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [skyTop, skyMid, skyBottom],
  );
}
