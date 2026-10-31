import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/session_state.dart';
import 'welcome_screen.dart';
import 'home_screen.dart';
import 'fashion_try_on.dart';
import 'makeup_try_on.dart';
import 'complete_the_look.dart';
import 'discover.dart';
import 'lookbook.dart';
import 'better_deals.dart';

class EighteenthScreen extends StatefulWidget {
  const EighteenthScreen({super.key});

  @override
  State<EighteenthScreen> createState() => _EighteenthScreenState();
}

class _EighteenthScreenState extends State<EighteenthScreen> {
  int _selectedBottomNavIndex = 3; // "Saved" tab active
  int _selectedCategoryIndex = 0; // "All" active

  final List<String> _archiveTabs = const [
    'All',
    'Outfits',
    'Makeups',
    'Jewelry',
    'Coordinated Pieces'
  ];

  static const String _lipstickImageUrl =
      'https://images.unsplash.com/photo-1586495777744-4413f21062fa?auto=format&fit=crop&w=500&q=80';
  static const String _outfitImageUrl =
      'https://images.unsplash.com/photo-1509631179647-0177331693ae?auto=format&fit=crop&w=500&q=80';

  bool _isLipstickBookmarked = true;
  bool _isOutfitBookmarked = true;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionState>();
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
                    const SizedBox(width: 24), // Spacer balancing right icon
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
                  'YOUR PERSONAL ARCHIVE',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2,
                    color: Color(0xFF888077),
                  ),
                ),

                const SizedBox(height: 6),

                // Main Title
                const Text(
                  'Make Your Wishlist.',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF201D19),
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 6),

                // Subtitle
                const Text(
                  'Looks and pieces that you liked and saved.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF6E6760),
                  ),
                ),

                const SizedBox(height: 20),

                // Category Tabs Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: List.generate(_archiveTabs.length, (index) {
                      final tab = _archiveTabs[index];
                      final isSelected = index == _selectedCategoryIndex;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategoryIndex = index;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 24),
                          padding: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            border: isSelected
                                ? const Border(
                                    bottom: BorderSide(
                                      color: Color(0xFF201D19),
                                      width: 1.5,
                                    ),
                                  )
                                : null,
                          ),
                          child: Text(
                            tab,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? const Color(0xFF201D19)
                                  : const Color(0xFF888077),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 20),

                if (session.savedLooks.isNotEmpty) ...[
                  const Text(
                    'SAVED LIVE TRY-ON LOOKS',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                      color: Color(0xFF888077),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 20,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: session.savedLooks.length,
                    itemBuilder: (context, index) {
                      final savedLook = session.savedLooks[index];
                      final isFileImage = savedLook.imagePath.startsWith('/') || File(savedLook.imagePath).existsSync();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.0),
                                color: const Color(0xFFE2DDD3),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: isFileImage
                                        ? Image.file(File(savedLook.imagePath), fit: BoxFit.cover)
                                        : Image.network(
                                            savedLook.imagePath,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Container(
                                              color: const Color(0xFFDDD7CC),
                                              child: const Icon(Icons.person_outline_rounded, size: 32, color: Color(0xFF8C8278)),
                                            ),
                                          ),
                                  ),
                                  if (savedLook.garmentImagePath != null && savedLook.garmentImagePath!.isNotEmpty)
                                    Positioned(
                                      bottom: 8,
                                      right: 8,
                                      child: Container(
                                        width: 45,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.white, width: 1.5),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: File(savedLook.garmentImagePath!).existsSync()
                                            ? Image.file(File(savedLook.garmentImagePath!), fit: BoxFit.cover)
                                            : Image.network(savedLook.garmentImagePath!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox()),
                                      ),
                                    ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: Color(0xEBF5F3EC),
                                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                                      ),
                                      child: const Icon(
                                        Icons.bookmark_rounded,
                                        size: 16,
                                        color: Color(0xFF201D19),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            savedLook.title,
                            style: const TextStyle(
                              fontFamily: 'serif',
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF201D19),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            savedLook.category,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF888077),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],

                // 2 Column Grid of Saved Items
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item 1: Beauty Note / Makeup
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AspectRatio(
                            aspectRatio: 0.8,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.0),
                                color: const Color(0xFFE2DDD3),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Image.network(
                                      _lipstickImageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                        color: const Color(0xFFDDD7CC),
                                        child: const Icon(
                                          Icons.brush_outlined,
                                          size: 32,
                                          color: Color(0xFF8C8278),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _isLipstickBookmarked =
                                              !_isLipstickBookmarked;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                          color: Color(0xEBF5F3EC),
                                          shape: BoxShape.rectangle,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4.0)),
                                        ),
                                        child: Icon(
                                          _isLipstickBookmarked
                                              ? Icons.bookmark_rounded
                                              : Icons.bookmark_border_rounded,
                                          size: 16,
                                          color: const Color(0xFF201D19),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Warm Rose 04',
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF201D19),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Shade · Beauty notes',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF888077),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const EleventhScreen(),
                                    ),
                                  );
                                },
                                child: const Row(
                                  children: [
                                    Text(
                                      'Open item',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF5A544D),
                                      ),
                                    ),
                                    SizedBox(width: 2),
                                    Icon(
                                      Icons.north_east_rounded,
                                      size: 11,
                                      color: Color(0xFF5A544D),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const EleventhScreen(),
                                    ),
                                  );
                                },
                                child: const Row(
                                  children: [
                                    Text(
                                      'Try-On',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF5A544D),
                                      ),
                                    ),
                                    SizedBox(width: 2),
                                    Icon(
                                      Icons.north_east_rounded,
                                      size: 11,
                                      color: Color(0xFF5A544D),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Item 2: Outfit Look
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AspectRatio(
                            aspectRatio: 0.8,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.0),
                                color: const Color(0xFFE2DDD3),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Image.network(
                                      _outfitImageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                        color: const Color(0xFFDDD7CC),
                                        child: const Icon(
                                          Icons.person_outline_rounded,
                                          size: 32,
                                          color: Color(0xFF8C8278),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _isOutfitBookmarked =
                                              !_isOutfitBookmarked;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                          color: Color(0xEBF5F3EC),
                                          shape: BoxShape.rectangle,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4.0)),
                                        ),
                                        child: Icon(
                                          _isOutfitBookmarked
                                              ? Icons.bookmark_rounded
                                              : Icons.bookmark_border_rounded,
                                          size: 16,
                                          color: const Color(0xFF201D19),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Quiet romance',
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF201D19),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Outfit look · 5 pieces',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF888077),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const TwelfthScreen(),
                                    ),
                                  );
                                },
                                child: const Row(
                                  children: [
                                    Text(
                                      'Open look',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF5A544D),
                                      ),
                                    ),
                                    SizedBox(width: 2),
                                    Icon(
                                      Icons.north_east_rounded,
                                      size: 11,
                                      color: Color(0xFF5A544D),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const NinthScreen(),
                                    ),
                                  );
                                },
                                child: const Row(
                                  children: [
                                    Text(
                                      'Try-On',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF5A544D),
                                      ),
                                    ),
                                    SizedBox(width: 2),
                                    Icon(
                                      Icons.north_east_rounded,
                                      size: 11,
                                      color: Color(0xFF5A544D),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Saved Outfit Summary Section
                const Text(
                  'Saved outfit · 6 Coordinated Pieces · Sample Total ₹9,500',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF201D19),
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 12),

                // Select Items To Purchase Action Link
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TwentiethScreen(),
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Select Items To Purchase',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF201D19),
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.north_east_rounded,
                        size: 15,
                        color: Color(0xFF201D19),
                      ),
                    ],
                  ),
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
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FifteenthScreen(),
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
