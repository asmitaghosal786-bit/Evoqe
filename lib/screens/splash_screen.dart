import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/session_state.dart';
import 'welcome_screen.dart';
import 'home_screen.dart';
import 'selfie_capture.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Vintage fashion illustration / moodboard background image
  static const String _backgroundImageUrl =
      'https://images.unsplash.com/photo-1558769132-cb1aea458c5e?auto=format&fit=crop&w=1000&q=80';

  Timer? _timer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), () {
      _goToNext();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      precacheImage(
        const NetworkImage(_backgroundImageUrl),
        context,
        onError: (exception, stackTrace) {},
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _goToNext() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    _timer?.cancel();

    final session = context.read<SessionState>();
    Widget nextScreen;
    if (session.shouldSkipToHome) {
      nextScreen = const EighthScreen();
    } else if (session.isLoggedIn && !session.hasCompletedOnboarding) {
      nextScreen = const ThirdScreen();
    } else {
      nextScreen = const EvoqeHomeScreen();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _goToNext,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F3EC),
        body: Stack(
          children: [
            // Moodboard Background Image
            Positioned.fill(
              child: Image.network(
                _backgroundImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFFEFECE4),
                ),
              ),
            ),

            // Light Translucent Overlay for Text Contrast & Warm Vintage Aesthetic
            Positioned.fill(
              child: Container(
                color: const Color(0x73F5F3EC),
              ),
            ),

            // Main Foreground Content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const Spacer(flex: 3),

                    // Centered Logo & Sub-tagline
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const EvoqeHeaderLogoLarge(),
                        const SizedBox(height: 8),
                        const Text(
                          'Your style, virtually.',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF201D19),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(flex: 4),

                    // Bottom Tagline & Brand Category Eyebrow
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Discover. Try on.',
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 36,
                              fontWeight: FontWeight.w400,
                              height: 1.15,
                              color: Color(0xFF201D19),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const Text(
                            'Make it yours.',
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 36,
                              fontWeight: FontWeight.w400,
                              height: 1.15,
                              color: Color(0xFF201D19),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 28),
                          const Text(
                            'A PRIVATE DIGITAL ATELIER',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.8,
                              color: Color(0xFF201D19),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Large variant of EVOQE Logo header used on Splash Screen
class EvoqeHeaderLogoLarge extends StatelessWidget {
  const EvoqeHeaderLogoLarge({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'EVOQE',
      style: TextStyle(
        fontFamily: 'serif',
        fontSize: 42,
        fontWeight: FontWeight.w400,
        letterSpacing: 6.0,
        color: Color(0xFF201D19),
      ),
    );
  }
}
