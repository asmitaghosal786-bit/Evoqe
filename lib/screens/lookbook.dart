import 'dart:ui';
import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import 'home_screen.dart';
import 'discover.dart';
import 'lookbook_analysis.dart';
import 'lookbook_results.dart';
import 'saved_looks.dart';

class FifteenthScreen extends StatefulWidget {
  const FifteenthScreen({super.key});

  @override
  State<FifteenthScreen> createState() => _FifteenthScreenState();
}

class _FifteenthScreenState extends State<FifteenthScreen> {
  int _selectedBottomNavIndex = 2; // Lookbook tab active

  final TextEditingController _aestheticController = TextEditingController(
    text: 'Quiet luxury meets modern romanticism',
  );

  final List<String> _references = [
    'Color palette',
    'Tones- warm, neutral...',
    'Add Category +',
  ];

  @override
  void dispose() {
    _aestheticController.dispose();
    super.dispose();
  }

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

                // Top Bar: Centered EVOQE Logo | Shopping Bag Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 24), // Left spacer balancing right icon
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
                  'Gather your inspiration',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF201D19),
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle
                const Text(
                  'Upload an image of a detail you love. Curate board.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6E6760),
                  ),
                ),

                const SizedBox(height: 20),

                // Dashed Photo Upload Box
                CustomPaint(
                  painter: _DashedRectPainter(),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 22.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFECE4),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 30,
                          color: Color(0xFF3E3129),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add a photo or inspiration',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF201D19),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'JPG or PNG · optional · private by default',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF888077),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Section: Your references
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Your references',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF201D19),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: const Row(
                        children: [
                          Text(
                            'Add image',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF5A544D),
                            ),
                          ),
                          SizedBox(width: 2),
                          Icon(
                            Icons.north_east_rounded,
                            size: 12,
                            color: Color(0xFF5A544D),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Reference Items List
                Column(
                  children: List.generate(_references.length, (index) {
                    final item = _references[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 18.0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.drag_indicator_rounded,
                            size: 18,
                            color: Color(0xFF201D19),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF201D19),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: const Text(
                              'Add',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF5A544D),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _references.removeAt(index);
                              });
                            },
                            child: const Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: Color(0xFF201D19),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),

                const Divider(
                  color: Color(0xFFD6CFC4),
                  height: 1,
                  thickness: 1,
                ),

                const SizedBox(height: 20),

                // Aesthetic Description Label
                const Text(
                  'Aesthetic description',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6E6760),
                  ),
                ),

                const SizedBox(height: 8),

                // Aesthetic Description Input Field
                TextField(
                  controller: _aestheticController,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF201D19),
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFEFECE4),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: const BorderSide(
                        color: Color(0xFFCDC6BA),
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: const BorderSide(
                        color: Color(0xFF3E3129),
                        width: 1.2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Primary CTA: Generate My Lookbook
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SeventeenthScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3E3129),
                      foregroundColor: const Color(0xFFF5F3EC),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    child: const Text(
                      'Generate My Lookbook',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Dual Action Buttons: View Board & View Saved Lookbook
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SixteenthScreen(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFEFECE4),
                            foregroundColor: const Color(0xFF201D19),
                            side: const BorderSide(
                              color: Color(0xFFCDC6BA),
                              width: 1.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'View Board',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF201D19),
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
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'View Saved Lookbooks',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF201D19),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),

      // Taskbar Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF5F3EC),
          border: Border(
            top: BorderSide(
              color: Color(0xFFD6CFC4),
              width: 1.0,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(
                0,
                Icons.home_outlined,
                Icons.home_rounded,
                'Home',
              ),
              _buildBottomNavItem(
                1,
                Icons.search_rounded,
                Icons.search_rounded,
                'Discover',
              ),
              _buildBottomNavItem(
                2,
                Icons.menu_book_outlined,
                Icons.menu_book_rounded,
                'Lookbook',
              ),
              _buildBottomNavItem(
                3,
                Icons.bookmark_border_rounded,
                Icons.bookmark_rounded,
                'Saved',
              ),
              _buildBottomNavItem(
                4,
                Icons.person_outline_rounded,
                Icons.person_rounded,
                'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(
    int index,
    IconData icon,
    IconData selectedIcon,
    String label,
  ) {
    final isSelected = index == _selectedBottomNavIndex;
    final color = isSelected ? const Color(0xFF201D19) : const Color(0xFF888077);

    return InkWell(
      onTap: () {
        if (index == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EighthScreen(initialTabIndex: 0),
            ),
          );
        } else if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ThirteenthScreen(),
            ),
          );
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EighteenthScreen(),
            ),
          );
        } else if (index == 4) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EighthScreen(initialTabIndex: 4),
            ),
          );
        } else {
          setState(() {
            _selectedBottomNavIndex = index;
          });
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? selectedIcon : icon,
            size: 22,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter to render the dashed rectangular outline for the photo upload box
class _DashedRectPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCDC6BA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final path = Path();
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(4.0),
    ));

    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      const double dashWidth = 5.0;
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
