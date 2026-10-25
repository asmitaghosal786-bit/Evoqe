import 'dart:ui';
import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import 'full_body_capture.dart';

class ThirdScreen extends StatefulWidget {
  const ThirdScreen({super.key});

  @override
  State<ThirdScreen> createState() => _ThirdScreenState();
}

class _ThirdScreenState extends State<ThirdScreen> {
  bool _usePhotoPrivately = true;

  // High quality portrait image matching the face-centered portrait
  static const String _portraitImageUrl =
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=800&q=80';

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

                // Main Title
                const Text(
                  'A portrait of you.',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 34,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF201D19),
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 8),

                // Description Instruction
                const Text(
                  'Face a window. Keep your face centered and your shoulders in view.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6E6760),
                    height: 1.35,
                  ),
                ),

                const SizedBox(height: 20),

                // Portrait Image Card with Dashed Face Overlay
                AspectRatio(
                  aspectRatio: 1.05,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: const Color(0xFFE2DDD3),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.network(
                            _portraitImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildImagePlaceholder(),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return _buildImagePlaceholder();
                            },
                          ),
                        ),

                        // Dashed Face Oval Guide Overlay
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _DashedOvalPainter(),
                          ),
                        ),

                        // Static Preview Badge Overlay
                        Positioned(
                          left: 14,
                          bottom: 14,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xEBF5F3EC),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: const Text(
                              'STATIC PREVIEW',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                                color: Color(0xFF3E3129),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Action Buttons Row: "Take photo" & "Upload photo"
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Text(
                            'Take photo',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFF5F3EC),
                            ),
                          ),
                          label: const Icon(
                            Icons.camera_alt_outlined,
                            size: 18,
                            color: Color(0xFFF5F3EC),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3E3129),
                            foregroundColor: const Color(0xFFF5F3EC),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFEFECE4),
                            foregroundColor: const Color(0xFF201D19),
                            side: const BorderSide(
                              color: Color(0xFFCDC6BA),
                              width: 1.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  'Upload photo',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF201D19),
                                  ),
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.file_upload_outlined,
                                size: 16,
                                color: Color(0xFF201D19),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Retake & Lighting Note Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: const Row(
                        children: [
                          Icon(
                            Icons.refresh_rounded,
                            size: 16,
                            color: Color(0xFF201D19),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Retake',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF201D19),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      'No filters · even lighting',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7C746C),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Explanatory Note
                const Text(
                  'Use this image for make-up try-on previews. You can delete it in Privacy and Image Permissions.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6E6760),
                    height: 1.35,
                  ),
                ),

                const SizedBox(height: 16),

                // Option Toggle Buttons ("Use photo privately " / "Use avatar instead")
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _usePhotoPrivately = true;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: _usePhotoPrivately
                              ? const Color(0xFF4C5547)
                              : const Color(0xFFEFECE4),
                          borderRadius: BorderRadius.circular(6.0),
                          border: _usePhotoPrivately
                              ? null
                              : Border.all(
                                  color: const Color(0xFFCDC6BA),
                                  width: 1.0,
                                ),
                        ),
                        child: Text(
                          'Use photo privately',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: _usePhotoPrivately
                                ? const Color(0xFFF5F3EC)
                                : const Color(0xFF201D19),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _usePhotoPrivately = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: !_usePhotoPrivately
                              ? const Color(0xFF4C5547)
                              : const Color(0xFFEFECE4),
                          borderRadius: BorderRadius.circular(6.0),
                          border: !_usePhotoPrivately
                              ? null
                              : Border.all(
                                  color: const Color(0xFFCDC6BA),
                                  width: 1.0,
                                ),
                        ),
                        child: Text(
                          'Use avatar instead',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: !_usePhotoPrivately
                                ? const Color(0xFFF5F3EC)
                                : const Color(0xFF201D19),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Primary CTA Button: "Continue with this photo"
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FourthScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3E3129),
                      foregroundColor: const Color(0xFFF5F3EC),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text(
                      'Continue with this photo',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: const Color(0xFFDDD7CC),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline_rounded, size: 48, color: Color(0xFF8C8278)),
            SizedBox(height: 8),
            Text(
              'Portrait Preview',
              style: TextStyle(fontSize: 12, color: Color(0xFF8C8278)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter to render the white dashed face oval guide overlay
class _DashedOvalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xD9FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    final path = Path();
    final rect = Rect.fromLTWH(
      size.width * 0.20,
      size.height * 0.06,
      size.width * 0.60,
      size.height * 0.82,
    );
    path.addOval(rect);

    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      const double dashWidth = 6.0;
      const double dashSpace = 4.0;
      while (distance < metric.length) {
        final double length = (distance + dashWidth < metric.length)
            ? dashWidth
            : metric.length - distance;
        canvas.drawPath(
          metric.extractPath(distance, distance + length),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
