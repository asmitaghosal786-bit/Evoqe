import 'package:flutter/material.dart';
import 'create_account.dart';

class EvoqeHomeScreen extends StatelessWidget {
  const EvoqeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EC),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    // EVOQE Logo Header
                    const EvoqeHeaderLogo(),
                    const SizedBox(height: 24),

                    // Gallery section (Two cards layout)
                    const EvoqeGalleryGrid(),
                    const SizedBox(height: 28),

                    // Main Headline
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'A world of style,\ncurated for you.',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 32,
                          fontWeight: FontWeight.w400,
                          height: 1.18,
                          color: Color(0xFF201D19),
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Feature List Items
                    const FeatureItemRow(
                      icon: Icons.auto_awesome_outlined,
                      label: 'Discover your aesthetic.',
                    ),
                    const SizedBox(height: 14),
                    const FeatureItemRow(
                      icon: Icons.crop_free_rounded,
                      label: 'Experience virtual try-on.',
                    ),
                    const SizedBox(height: 14),
                    const FeatureItemRow(
                      icon: Icons.bookmark_border_rounded,
                      label: 'Find pieces that feel like you.',
                    ),
                    const SizedBox(height: 32),

                    // Action Buttons
                    EvoqeButton(
                      label: 'Sign Up',
                      backgroundColor: const Color(0xFF3E3129),
                      textColor: const Color(0xFFF5F3EC),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const SecondScreen(initialMode: AuthMode.signUp),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    EvoqeButton(
                      label: 'Log In',
                      backgroundColor: Colors.transparent,
                      textColor: const Color(0xFF3E3129),
                      borderColor: const Color(0xFFC6BFB4),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const SecondScreen(initialMode: AuthMode.logIn),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Footer Tagline
                    const Text(
                      'Your style assistant. Your private atelier.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF7C746C),
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// EVOQE Logo header with custom underline swoosh under "QE"
class EvoqeHeaderLogo extends StatelessWidget {
  const EvoqeHeaderLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      child: const Padding(
        padding: EdgeInsets.only(bottom: 6.0),
        child: Text(
          'EVOQE',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 30,
            fontWeight: FontWeight.w400,
            letterSpacing: 4.5,
            color: Color(0xFF201D19),
          ),
        ),
      ),
    );
  }
}


/// Gallery grid displaying the two fashion cards
class EvoqeGalleryGrid extends StatelessWidget {
  const EvoqeGalleryGrid({super.key});

  // High quality fashion image URLs matching the design flatlay & street style model
  static const String _flatlayImageUrl =
      'https://images.unsplash.com/photo-1548883354-7622d03aca27?auto=format&fit=crop&w=800&q=80';
  static const String _modelImageUrl =
      'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=800&q=80';

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Image Card - Outfit Flatlay
        Expanded(
          flex: 6,
          child: AspectRatio(
            aspectRatio: 0.82,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: const Color(0xFFE2DDD3),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                _flatlayImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildPlaceholderCard(
                  icon: Icons.checkroom_rounded,
                  label: 'Outfit Flatlay',
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildPlaceholderCard(
                    icon: Icons.image_outlined,
                    label: 'Loading...',
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Right Column - Model Image + "THE ART OF YOU" text label
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 0.72,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: const Color(0xFFE2DDD3),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(
                    _modelImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildPlaceholderCard(
                      icon: Icons.person_outline_rounded,
                      label: 'Fashion Model',
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return _buildPlaceholderCard(
                        icon: Icons.image_outlined,
                        label: 'Loading...',
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'THE ART OF YOU',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.0,
                  color: Color(0xFF888077),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderCard({required IconData icon, required String label}) {
    return Container(
      color: const Color(0xFFDDD7CC),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: const Color(0xFF8C8278)),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF8C8278),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Feature item row with icon and descriptive text
class FeatureItemRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const FeatureItemRow({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF201D19),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w400,
              color: Color(0xFF322E2B),
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom styled button used for primary (Sign Up) and secondary (Log In) actions
class EvoqeButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final VoidCallback onPressed;

  const EvoqeButton({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          side: borderColor != null
              ? BorderSide(color: borderColor!, width: 1.0)
              : BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: textColor,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
