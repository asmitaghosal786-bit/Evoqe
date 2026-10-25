import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(const EvoqeApp());
}

class EvoqeApp extends StatelessWidget {
  const EvoqeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EVOQE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F3EC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3E3129),
          surface: const Color(0xFFF5F3EC),
        ),
        fontFamily: 'serif',
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
