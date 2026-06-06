import 'package:flutter/material.dart';

class AppColors {
  // Premium, soft sky gradient
  static const Color skyTop = Color(0xFF5AB9EA);
  static const Color skyBottom = Color(0xFFE2F3FD);

  // Solid, vibrant typography colors
  static const Color textKids = Color(0xFFFF9800);
  static const Color textGames = Color(0xFF4CAF50);

  // Legacy names kept for compatibility with other screens
  static const Color red = Color(0xFFF06292); // Softened pinkish-red
  static const Color yellow = Color(0xFFFFCA28);
  static const Color golden = Color(0xFFFFB300);
  static const Color green = Color(0xFF66BB6A);
  static const Color purple = Color(0xFFBA68C8);
  static const Color orange = Color(0xFFFFA726);

  // Clean, 3D Play button
  static const Color playButton = Color(0xFF8BC34A);
  static const Color playButtonShadow = Color(0xFF558B2F);

  static const Color white = Colors.white;
  static const Color textDark = Color(0xFF2C3E50);
  static const Color textGrey = Color(0xFF7F8C8D);

  static const LinearGradient skyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [skyTop, skyBottom],
  );
}
