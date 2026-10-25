import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import 'digital_style_profile_avatar.dart';
import 'fashion_try_on.dart';
import 'jewelry_try_on.dart';
import 'complete_the_look.dart';
import 'discover.dart';
import 'ai_styling_assistant.dart';
import 'lookbook.dart';
import 'saved_looks.dart';

class EighthScreen extends StatefulWidget {
  final int initialTabIndex;

  const EighthScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<EighthScreen> createState() => _EighthScreenState();
}

class _EighthScreenState extends State<EighthScreen> {
  late int _selectedBottomNavIndex;

  @override
  void initState() {
    super.initState();
    _selectedBottomNavIndex = widget.initialTabIndex;
  }

  // High quality Unsplash URLs matching the design screenshot
  static const String _heroImageUrl =
      'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=800&q=80';
  static const String _waistcoatImageUrl =
      'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?auto=format&fit=crop&w=500&q=80';
  static const String _earringsImageUrl =
      'https://images.unsplash.com/photo-1630019852942-f89202989a59?auto=format&fit=crop&w=500&q=80';
  static const String _modernRomanticUrl =
      'https://images.unsplash.com/photo-1509631179647-0177331693ae?auto=format&fit=crop&w=500&q=80';
  static const String _quietStatementsUrl =
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=500&q=80';

  static const String _userAvatarUrl =
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80';

  // Saved states for suggested items
  bool _isWaistcoatSaved = false;
  bool _isEarringsSaved = false;

  final List<String> _profileMenuItems = const [
    'My Style Profile',
    'My Avatar',
    'Orders and Shopping History',
    'Privacy and Image Permissions',
    'Notification Preferences',
    'Account Settings',
    'Help and Support',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EC),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedBottomNavIndex,
          children: [
            // Tab 0: Home / Atelier (8th Screen Design)
            _buildHomeContent(),

            // Tab 1: Discover
            _buildPlaceholderTab('Discover', Icons.search_rounded, 'Explore curated collections and new arrivals.'),

            // Tab 2: Lookbook
            _buildPlaceholderTab('Lookbook', Icons.menu_book_outlined, 'Browse your styled edits and private lookbooks.'),

            // Tab 3: Saved
            _buildPlaceholderTab('Saved', Icons.bookmark_border_rounded, 'Your saved pieces, edits, and inspirations.'),

            // Tab 4: Profile (6th Screen View)
            _buildProfileContent(),
          ],
        ),
      ),

      // Persistent Bottom Navigation Taskbar (Option 2)
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
                index: 0,
                icon: Icons.home_outlined,
                selectedIcon: Icons.home_rounded,
                label: 'Home',
              ),
              _buildBottomNavItem(
                index: 1,
                icon: Icons.search_rounded,
                selectedIcon: Icons.search_rounded,
                label: 'Discover',
              ),
              _buildBottomNavItem(
                index: 2,
                icon: Icons.menu_book_outlined,
                selectedIcon: Icons.menu_book_rounded,
                label: 'Lookbook',
              ),
              _buildBottomNavItem(
                index: 3,
                icon: Icons.bookmark_border_rounded,
                selectedIcon: Icons.bookmark_rounded,
                label: 'Saved',
              ),
              _buildBottomNavItem(
                index: 4,
                icon: Icons.person_outline_rounded,
                selectedIcon: Icons.person_rounded,
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Tab 0: Main Home Atelier View (Matching Figma Screenshot)
  Widget _buildHomeContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            // Top App Bar Row: Hamburger Menu | EVOQE Logo | Shopping Bag Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.menu_rounded,
                    color: Color(0xFF201D19),
                    size: 24,
                  ),
                  onPressed: () {},
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

            // Eyebrow Greeting Label
            const Text(
              'GOOD AFTERNOON, ANANYA',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
                color: Color(0xFF888077),
              ),
            ),

            const SizedBox(height: 6),

            // Headline
            const Text(
              'Welcome to your atelier.',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 30,
                fontWeight: FontWeight.w400,
                color: Color(0xFF201D19),
                letterSpacing: -0.3,
              ),
            ),

            const SizedBox(height: 6),

            // Subtitle
            const Text(
              'A world of style, curated for you.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF6E6760),
              ),
            ),

            const SizedBox(height: 20),

            // Hero Banner Card: Daily Edit
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                color: const Color(0xFFE2DDD3),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: 1.2,
                    child: Image.network(
                      _heroImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(
                        color: const Color(0xFFDDD7CC),
                        child: const Center(
                          child: Icon(
                            Icons.person_outline_rounded,
                            size: 40,
                            color: Color(0xFF8C8278),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    color: const Color(0xFF3E3129),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18.0,
                      vertical: 8.0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ADVERTISEMENT',
                              style: TextStyle(
                                fontFamily: 'serif',
                                fontSize: 24,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFFF5F3EC),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'BEST SALES AND DISCOUNTS',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.0,
                                color: Color(0xFFC6BFB4),
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.north_east_rounded,
                          color: Color(0xFFF5F3EC),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Quick Action Buttons
            Column(
              children: [
                _buildQuickActionButton(
                  icon: Icons.auto_awesome,
                  label: 'Coordinate The Look Based On Saved Pieces',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TwelfthScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                _buildQuickActionButton(
                  icon: Icons.smart_toy_outlined,
                  label: 'Ask AI Style Assistant',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FourteenthScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Section 1: Suggested For You
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Popular Right Now',
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
                        'Explore',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF5A544D),
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(
                        Icons.north_east_rounded,
                        size: 13,
                        color: Color(0xFF5A544D),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            const Text(
              'Pieces with presence, chosen around your preferences.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF6E6760),
              ),
            ),

            const SizedBox(height: 16),

            // Product Grid (2 Items)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildProductCard(
                    imageUrl: _waistcoatImageUrl,
                    title: 'Linen waistcoat',
                    brand: 'Maison Vale · sample',
                    price: '₹2,400',
                    isSaved: _isWaistcoatSaved,
                    onSavedToggle: () {
                      setState(() {
                        _isWaistcoatSaved = !_isWaistcoatSaved;
                      });
                    },
                    onTryOnPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NinthScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildProductCard(
                    imageUrl: _earringsImageUrl,
                    title: 'Sculpted gold hoops',
                    brand: 'Forme Studio · sample',
                    price: '₹850',
                    isSaved: _isEarringsSaved,
                    onSavedToggle: () {
                      setState(() {
                        _isEarringsSaved = !_isEarringsSaved;
                      });
                    },
                    onTryOnPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TenthScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            const Text(
              'Illustrative products · sample prices',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF888077),
              ),
            ),

            const SizedBox(height: 28),
            const Divider(color: Color(0xFFD6CFC4), height: 1, thickness: 1),
            const SizedBox(height: 24),

            // Section 2: Trending Aesthetics
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Trending Aesthetics',
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
                        'All edits',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF5A544D),
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(
                        Icons.north_east_rounded,
                        size: 13,
                        color: Color(0xFF5A544D),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Aesthetics Grid (2 Items)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildAestheticCard(
                    imageUrl: _modernRomanticUrl,
                    title: 'Modern romantic',
                    subtitle: 'SOFTNESS & STRUCTURE',
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildAestheticCard(
                    imageUrl: _quietStatementsUrl,
                    title: 'Quiet statements',
                    subtitle: 'THE FINISHING TOUCH',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Tab 4: Profile View (Sixth Screen Content)
  Widget _buildProfileContent() {
    return SingleChildScrollView(
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
                    setState(() {
                      _selectedBottomNavIndex = 0; // Return to Home tab
                    });
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

            const SizedBox(height: 28),

            // Main Title
            const Text(
              'Your atelier, your rules.',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 32,
                fontWeight: FontWeight.w400,
                color: Color(0xFF201D19),
                letterSpacing: -0.3,
              ),
            ),

            const SizedBox(height: 24),

            // User Profile Header Card
            Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: const Color(0xFFE2DDD3),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(
                    _userAvatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFDDD7CC),
                      child: const Icon(
                        Icons.person_outline_rounded,
                        size: 36,
                        color: Color(0xFF8C8278),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ananya Sharma',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 22,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF201D19),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'ananya.sharma@example.com',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF888077),
                        ),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () {},
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Edit account',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF5A544D),
                              ),
                            ),
                            SizedBox(width: 3),
                            Icon(
                              Icons.north_east_rounded,
                              size: 13,
                              color: Color(0xFF5A544D),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Menu Options List
            Column(
              children: [
                ..._profileMenuItems.map((title) => Column(
                  children: [
                    const Divider(color: Color(0xFFD6CFC4), height: 1, thickness: 1),
                    InkWell(
                      onTap: title == 'My Avatar'
                          ? () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SeventhScreen(),
                                ),
                              )
                          : () {},
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF201D19),
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              size: 20,
                              color: Color(0xFF201D19),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )),

                // Log Out Row
                const Divider(color: Color(0xFFD6CFC4), height: 1, thickness: 1),
                InkWell(
                  onTap: () {},
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Log Out',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF201D19),
                          ),
                        ),
                        Icon(
                          Icons.logout_rounded,
                          size: 18,
                          color: Color(0xFF201D19),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(color: Color(0xFFD6CFC4), height: 1, thickness: 1),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Placeholder Tab Builder for Discover, Lookbook, and Saved
  Widget _buildPlaceholderTab(String title, IconData icon, String description) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.menu_rounded,
                    color: Color(0xFF201D19),
                    size: 24,
                  ),
                  onPressed: () {},
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
            const SizedBox(height: 80),
            Icon(
              icon,
              size: 56,
              color: const Color(0xFF888077),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'serif',
                fontSize: 28,
                fontWeight: FontWeight.w400,
                color: Color(0xFF201D19),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF6E6760),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFEFECE4),
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(
          color: const Color(0xFFCDC6BA),
          width: 0.8,
        ),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: const Color(0xFF201D19),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF201D19),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(
                Icons.north_east_rounded,
                size: 13,
                color: Color(0xFF201D19),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard({
    required String imageUrl,
    required String title,
    required String brand,
    required String price,
    required bool isSaved,
    required VoidCallback onSavedToggle,
    VoidCallback? onTryOnPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 0.95,
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
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFDDD7CC),
                      child: const Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 32,
                          color: Color(0xFF8C8278),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onSavedToggle,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF5F3EC),
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      ),
                      child: Icon(
                        isSaved
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
        Text(
          title,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            color: Color(0xFF201D19),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          brand,
          style: const TextStyle(
            fontSize: 11.5,
            color: Color(0xFF888077),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              price,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF201D19),
              ),
            ),
            GestureDetector(
              onTap: onTryOnPressed ?? () {},
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
                    size: 12,
                    color: Color(0xFF5A544D),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAestheticCard({
    required String imageUrl,
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 0.82,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
              color: const Color(0xFFE2DDD3),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFFDDD7CC),
                child: const Center(
                  child: Icon(
                    Icons.style_outlined,
                    size: 32,
                    color: Color(0xFF8C8278),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Color(0xFF201D19),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.8,
            color: Color(0xFF888077),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    final isSelected = index == _selectedBottomNavIndex;
    final color = isSelected ? const Color(0xFF201D19) : const Color(0xFF888077);

    return InkWell(
      onTap: () {
        if (index == 1) {
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
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EighteenthScreen(),
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
