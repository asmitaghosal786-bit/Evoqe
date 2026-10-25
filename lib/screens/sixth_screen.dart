import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'seventh_screen.dart';
import 'eighth_screen.dart';
import 'thirteenth_screen.dart';
import 'fifteenth_screen.dart';
import 'eighteenth_screen.dart';

class SixthScreen extends StatefulWidget {
  const SixthScreen({super.key});

  @override
  State<SixthScreen> createState() => _SixthScreenState();
}

class _SixthScreenState extends State<SixthScreen> {
  int _selectedBottomNavIndex = 4; // Profile tab is active in the design

  static const String _userAvatarUrl =
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80';

  final List<String> _menuItems = const [
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

                const SizedBox(height: 28),

                // Main Title
                const Text(
                  'Your atelier, your rules.',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF201D19),
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 24),

                // User Profile Header Card
                Row(
                  children: [
                    // Profile Image
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

                    // User Details
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

                // Menu Options List with Dividers
                Column(
                  children: [
                    ..._menuItems.map((title) => _buildMenuItemRow(
                      title,
                      onTap: title == 'My Avatar'
                          ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SeventhScreen(),
                        ),
                      )
                          : null,
                    )),

                    // Log Out Row (With Logout icon instead of Chevron)
                    _buildLogOutRow(),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),

      // Bottom Navigation Bar
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
                label: 'Home',
              ),
              _buildBottomNavItem(
                index: 1,
                icon: Icons.search_rounded,
                label: 'Discover',
              ),
              _buildBottomNavItem(
                index: 2,
                icon: Icons.menu_book_outlined,
                label: 'Lookbook',
              ),
              _buildBottomNavItem(
                index: 3,
                icon: Icons.bookmark_border_rounded,
                label: 'Saved',
              ),
              _buildBottomNavItem(
                index: 4,
                icon: Icons.person_outline_rounded,
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItemRow(String title, {VoidCallback? onTap}) {
    return Column(
      children: [
        const Divider(color: Color(0xFFD6CFC4), height: 1, thickness: 1),
        InkWell(
          onTap: onTap ?? () {},
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
    );
  }

  Widget _buildLogOutRow() {
    return Column(
      children: [
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
    );
  }

  Widget _buildBottomNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = index == _selectedBottomNavIndex;
    final color = isSelected ? const Color(0xFF201D19) : const Color(0xFF888077);

    return InkWell(
      onTap: () {
        if (index == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EighthScreen(),
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
            icon,
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
