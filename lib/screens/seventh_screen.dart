import 'package:flutter/material.dart';
import 'home_screen.dart';

class SeventhScreen extends StatelessWidget {
  const SeventhScreen({super.key});

  // Portrait (close-up) and full-body avatar previews
  static const String _portraitImageUrl =
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=500&q=80';
  static const String _fullBodyImageUrl =
      'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=500&q=80';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EC),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // Top App Bar Row: Back Arrow | EVOQE Logo | Shopping Bag Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF201D19),
                        size: 25,
                      ),
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const EvoqeHeaderLogo(),
                    IconButton(
                      icon: const Icon(
                        Icons.shopping_bag_outlined,
                        color: Color(0xFF201D19),
                        size: 22,
                      ),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Eyebrow Label
                const Text(
                  'YOUR STYLE PORTRAIT',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.0,
                    color: Color(0xFF888077),
                  ),
                ),

                const SizedBox(height: 8),

                // Main Title
                const Text(
                  'Your Virtual Avatar',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF201D19),
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 20),

                // Avatar Previews: Portrait + Full Body
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 108,
                      child: _buildAvatarImage(
                        imageUrl: _portraitImageUrl,
                        fallbackIcon: Icons.person_outline_rounded,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 106,
                      child: _buildAvatarImage(
                        imageUrl: _fullBodyImageUrl,
                        fallbackIcon: Icons.accessibility_new_rounded,
                      ),
                    ),
                    const Spacer(flex: 30),
                  ],
                ),

                const SizedBox(height: 22),

                const Divider(
                  color: Color(0xFFD6CFC4),
                  height: 1,
                  thickness: 1,
                ),

                const SizedBox(height: 18),

                // Change Uploaded Photos Button
                _buildOutlinedActionButton(
                  label: 'Change Uploaded Photos',
                  onPressed: () {},
                ),

                const SizedBox(height: 14),

                // Edit Avatar Details Button
                _buildOutlinedActionButton(
                  label: 'Edit Avatar Details',
                  onPressed: () {},
                ),

                const SizedBox(height: 22),

                // Footer Disclaimer
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Center(
                    child: Text(
                      'Your avatar is a visual preview, not an exact representation of body shape or garment fit.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF7C746C),
                        height: 1.45,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarImage({
    required String imageUrl,
    required IconData fallbackIcon,
  }) {
    return AspectRatio(
      aspectRatio: 108 / 154,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2.0),
          color: const Color(0xFFE2DDD3),
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: const Color(0xFFDDD7CC),
            child: Center(
              child: Icon(
                fallbackIcon,
                size: 40,
                color: const Color(0xFF8C8278),
              ),
            ),
          ),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: const Color(0xFFDDD7CC),
              child: const Center(
                child: Icon(
                  Icons.image_outlined,
                  size: 32,
                  color: Color(0xFF8C8278),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOutlinedActionButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFFF5F3EC),
          foregroundColor: const Color(0xFF201D19),
          side: const BorderSide(
            color: Color(0xFF8C8278),
            width: 1.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.0),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF201D19),
          ),
        ),
      ),
    );
  }
}