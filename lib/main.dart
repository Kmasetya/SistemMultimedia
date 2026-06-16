import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'services/audio_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize BGM player settings (does not auto-play)
  AudioManager().initBgm();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(const AniKidsApp());
}

class AniKidsApp extends StatelessWidget {
  const AniKidsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AniKids - Permainan Anak',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4DD0E1)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
