import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/session_state.dart';
import '../data/security/secure_media_store.dart';
import 'welcome_screen.dart';
import 'digital_style_profile_avatar.dart';
import 'home_screen.dart';
import 'personal_style_questionnaire.dart';
import 'better_deals.dart';
import 'saved_looks.dart';
import 'discover.dart';
import 'lookbook.dart';

class SixthScreen extends StatefulWidget {
  const SixthScreen({super.key});

  @override
  State<SixthScreen> createState() => _SixthScreenState();
}

class _SixthScreenState extends State<SixthScreen> {
  int _selectedBottomNavIndex = 4; // Profile tab is active in the design

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EC),
      body: SafeArea(
        child: ProfileContentWidget(
          onBackPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
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
                context,
                index: 0,
                icon: Icons.home_outlined,
                label: 'Home',
              ),
              _buildBottomNavItem(
                context,
                index: 1,
                icon: Icons.search_rounded,
                label: 'Discover',
              ),
              _buildBottomNavItem(
                context,
                index: 2,
                icon: Icons.menu_book_outlined,
                label: 'Lookbook',
              ),
              _buildBottomNavItem(
                context,
                index: 3,
                icon: Icons.bookmark_border_rounded,
                label: 'Saved',
              ),
              _buildBottomNavItem(
                context,
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

  Widget _buildBottomNavItem(
    BuildContext context, {
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

/// Reusable Profile Content Widget used by SixthScreen and Home tab 4
class ProfileContentWidget extends StatelessWidget {
  final VoidCallback? onBackPressed;

  const ProfileContentWidget({super.key, this.onBackPressed});

  final List<String> _menuItems = const [
    'My Style Profile',
    'My Avatar',
    'Orders and Shopping History',
    'Privacy and Image Permissions',
    'Notification Preferences',
    'Account Settings',
    'Help and Support',
  ];

  void _showEditAccountBottomSheet(BuildContext context) {
    final session = context.read<SessionState>();
    final user = session.currentUser;
    final nameController = TextEditingController(text: user?.name ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF5F3EC),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Account',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF201D19),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  filled: true,
                  fillColor: const Color(0xFFEFECE4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.0),
                    borderSide: const BorderSide(color: Color(0xFFCDC6BA)),
                  ),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Name cannot be empty' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  filled: true,
                  fillColor: const Color(0xFFEFECE4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.0),
                    borderSide: const BorderSide(color: Color(0xFFCDC6BA)),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Email cannot be empty';
                  if (!val.contains('@') || !val.contains('.')) return 'Enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3E3129),
                    foregroundColor: const Color(0xFFF5F3EC),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      await session.updateProfile((p) {
                        p.name = nameController.text.trim();
                        p.email = emailController.text.trim();
                      });
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Account updated successfully')),
                        );
                      }
                    }
                  },
                  child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF5F3EC),
        title: const Text('Log Out', style: TextStyle(fontFamily: 'serif', color: Color(0xFF201D19))),
        content: const Text('Are you sure you want to log out of EVOQE?', style: TextStyle(color: Color(0xFF6E6760))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF888077))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3E3129),
              foregroundColor: const Color(0xFFF5F3EC),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<SessionState>().logOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const EvoqeHomeScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionState>();
    final user = session.currentUser;
    final userName = user?.name ?? 'Guest User';
    final userEmail = user?.email ?? 'No email associated';

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
                  onPressed: onBackPressed ?? () => Navigator.pop(context),
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
                fontSize: 30,
                fontWeight: FontWeight.w400,
                color: Color(0xFF201D19),
                letterSpacing: -0.3,
              ),
            ),

            const SizedBox(height: 24),

            // User Profile Header Card
            Row(
              children: [
                // Profile Image / Avatar
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: const Color(0xFFE2DDD3),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: const Center(
                    child: Icon(
                      Icons.person_outline_rounded,
                      size: 36,
                      color: Color(0xFF8C8278),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // User Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 22,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF201D19),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        userEmail,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF888077),
                        ),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () => _showEditAccountBottomSheet(context),
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
                      context,
                      title,
                      onTap: () {
                        if (title == 'My Avatar') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SeventhScreen(),
                            ),
                          );
                        } else if (title == 'My Style Profile') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const StyleProfileScreen(),
                            ),
                          );
                        } else if (title == 'Orders and Shopping History') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OrdersAndHistoryScreen(),
                            ),
                          );
                        } else if (title == 'Privacy and Image Permissions') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PrivacyPermissionsScreen(),
                            ),
                          );
                        } else if (title == 'Notification Preferences') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationPreferencesScreen(),
                            ),
                          );
                        } else if (title == 'Account Settings') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AccountSettingsScreen(),
                            ),
                          );
                        } else if (title == 'Help and Support') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HelpSupportScreen(),
                            ),
                          );
                        }
                      },
                    )),

                // Log Out Row
                _buildLogOutRow(context),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItemRow(BuildContext context, String title, {VoidCallback? onTap}) {
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

  Widget _buildLogOutRow(BuildContext context) {
    return Column(
      children: [
        const Divider(color: Color(0xFFD6CFC4), height: 1, thickness: 1),
        InkWell(
          onTap: () => _showLogOutDialog(context),
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
}

/// 1. My Style Profile Screen
class StyleProfileScreen extends StatelessWidget {
  const StyleProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<SessionState>().currentUser;
    final aesthetics = user?.aesthetics ?? {};
    final wardrobe = user?.wardrobe ?? {};
    final beauty = user?.beauty ?? {};
    final jewelry = user?.jewelry ?? {};
    final season = user?.season ?? {};
    final budget = user?.budget ?? {};
    final palette = user?.palette ?? {};

    final hasPreferences = aesthetics.isNotEmpty ||
        wardrobe.isNotEmpty ||
        beauty.isNotEmpty ||
        jewelry.isNotEmpty ||
        season.isNotEmpty ||
        budget.isNotEmpty ||
        palette.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F3EC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF201D19)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Style Profile',
          style: TextStyle(fontFamily: 'serif', color: Color(0xFF201D19), fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!hasPreferences) ...[
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.0),
                    child: Text(
                      'No style preferences saved yet.',
                      style: TextStyle(fontSize: 14, color: Color(0xFF888077)),
                    ),
                  ),
                ),
              ] else ...[
                if (aesthetics.isNotEmpty) ...[
                  _buildSectionTitle('Aesthetics'),
                  _buildChipsList(aesthetics),
                  const SizedBox(height: 20),
                ],
                if (wardrobe.isNotEmpty) ...[
                  _buildSectionTitle('Wardrobe Preferences'),
                  _buildChipsList(wardrobe),
                  const SizedBox(height: 20),
                ],
                if (palette.isNotEmpty) ...[
                  _buildSectionTitle('Color Palette'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    children: palette.map((hex) {
                      final color = Color(int.parse(hex));
                      return Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFCDC6BA)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],
                if (beauty.isNotEmpty) ...[
                  _buildSectionTitle('Beauty Preferences'),
                  _buildChipsList(beauty),
                  const SizedBox(height: 20),
                ],
                if (jewelry.isNotEmpty) ...[
                  _buildSectionTitle('Jewelry Preferences'),
                  _buildChipsList(jewelry),
                  const SizedBox(height: 20),
                ],
                if (season.isNotEmpty) ...[
                  _buildSectionTitle('Season'),
                  _buildChipsList(season),
                  const SizedBox(height: 20),
                ],
                if (budget.isNotEmpty) ...[
                  _buildSectionTitle('Budget'),
                  _buildChipsList(budget),
                  const SizedBox(height: 20),
                ],
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3E3129),
                    foregroundColor: const Color(0xFFF5F3EC),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FifthScreen()),
                    );
                  },
                  child: const Text('Edit Preferences', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'serif',
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: Color(0xFF201D19),
      ),
    );
  }

  Widget _buildChipsList(Set<String> items) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: items.map((item) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFEFECE4),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFCDC6BA)),
          ),
          child: Text(
            item,
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF201D19)),
          ),
        )).toList(),
      ),
    );
  }
}

/// 2. Orders and Shopping History Screen
class OrdersAndHistoryScreen extends StatelessWidget {
  const OrdersAndHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F3EC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF201D19)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Orders and Shopping History',
          style: TextStyle(fontFamily: 'serif', color: Color(0xFF201D19), fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shopping_bag_outlined, size: 64, color: Color(0xFF8C8278)),
              const SizedBox(height: 16),
              const Text(
                'No completed orders yet',
                style: TextStyle(fontFamily: 'serif', fontSize: 22, color: Color(0xFF201D19)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your purchases, order tracking, and history will appear here once you complete a checkout.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF888077)),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3E3129),
                    foregroundColor: const Color(0xFFF5F3EC),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TwentiethScreen()),
                    );
                  },
                  child: const Text('Explore Better Deals'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 3. Privacy and Image Permissions Screen
class PrivacyPermissionsScreen extends StatelessWidget {
  const PrivacyPermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F3EC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF201D19)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Privacy and Image Permissions',
          style: TextStyle(fontFamily: 'serif', color: Color(0xFF201D19), fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Data & Privacy',
                style: TextStyle(fontFamily: 'serif', fontSize: 22, color: Color(0xFF201D19)),
              ),
              const SizedBox(height: 12),
              const Text(
                'EVOQE respects your privacy. Photos, body measurements, and style preferences are stored securely on your local device and used strictly to generate your virtual try-ons and style recommendations.',
                style: TextStyle(fontSize: 13.5, color: Color(0xFF6E6760), height: 1.4),
              ),
              const SizedBox(height: 24),
              _buildPermissionItem(
                icon: Icons.camera_alt_outlined,
                title: 'Camera & Photo Library',
                description: 'Used only when you choose to capture or upload outfit & body profile photos.',
              ),
              const SizedBox(height: 16),
              _buildPermissionItem(
                icon: Icons.person_outline_rounded,
                title: 'Body Measurements & Avatar',
                description: 'Stored locally to power virtual try-on and fit recommendations.',
              ),
              const SizedBox(height: 16),
              _buildPermissionItem(
                icon: Icons.style_outlined,
                title: 'Style Questionnaire Preferences',
                description: 'Guides your daily atelier edits and product discovery curation.',
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFA33A3A),
                    side: const BorderSide(color: Color(0xFFA33A3A)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    final store = context.read<SecureMediaStore>();
                    final session = context.read<SessionState>();
                    final user = session.currentUser;
                    if (user != null) {
                      for (final path in user.bodyPhotoPaths.values) {
                        if (path != null) {
                          try {
                            await store.delete(path);
                          } catch (_) {}
                        }
                      }
                      await session.updateProfile((p) {
                        p.bodyPhotoPaths = {'front': null, 'left': null, 'right': null, 'back': null};
                      });
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Stored body photos cleared successfully.')),
                      );
                    }
                  },
                  child: const Text('Clear Stored Body Photos', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionItem({required IconData icon, required String title, required String description}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFECE4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFCDC6BA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: const Color(0xFF3E3129)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF201D19))),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(fontSize: 12.5, color: Color(0xFF6E6760))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 4. Notification Preferences Screen
class NotificationPreferencesScreen extends StatelessWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionState>();
    final user = session.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F3EC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF201D19)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notification Preferences',
          style: TextStyle(fontFamily: 'serif', color: Color(0xFF201D19), fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            const Text(
              'Manage Alerts',
              style: TextStyle(fontFamily: 'serif', fontSize: 22, color: Color(0xFF201D19)),
            ),
            const SizedBox(height: 6),
            const Text(
              'Choose what notifications you would like to receive from your private atelier.',
              style: TextStyle(fontSize: 13, color: Color(0xFF6E6760)),
            ),
            const SizedBox(height: 20),
            _buildSwitchTile(
              context,
              title: 'Style Recommendations',
              subtitle: 'Daily curated edits and tailored look suggestions.',
              value: user?.notifyStyleRecommendations ?? true,
              onChanged: (val) {
                session.updateProfile((p) => p.notifyStyleRecommendations = val);
              },
            ),
            _buildSwitchTile(
              context,
              title: 'New Looks & Lookbook Updates',
              subtitle: 'Updates when new seasonal collections drop.',
              value: user?.notifyLookbookUpdates ?? true,
              onChanged: (val) {
                session.updateProfile((p) => p.notifyLookbookUpdates = val);
              },
            ),
            _buildSwitchTile(
              context,
              title: 'Shopping & Deal Alerts',
              subtitle: 'Price drops and better deals on your wishlist items.',
              value: user?.notifyDealAlerts ?? true,
              onChanged: (val) {
                session.updateProfile((p) => p.notifyDealAlerts = val);
              },
            ),
            _buildSwitchTile(
              context,
              title: 'Wishlist Updates',
              subtitle: 'Availability notices for saved pieces.',
              value: user?.notifyWishlistUpdates ?? true,
              onChanged: (val) {
                session.updateProfile((p) => p.notifyWishlistUpdates = val);
              },
            ),
            _buildSwitchTile(
              context,
              title: 'Order & Checkout Updates',
              subtitle: 'Delivery notices and checkout confirmations.',
              value: user?.notifyOrderUpdates ?? true,
              onChanged: (val) {
                session.updateProfile((p) => p.notifyOrderUpdates = val);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFECE4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFCDC6BA)),
      ),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF201D19))),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF6E6760))),
        value: value,
        activeThumbColor: const Color(0xFF3E3129),
        onChanged: onChanged,
      ),
    );
  }
}

/// 5. Account Settings Screen
class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F3EC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF201D19)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Account Settings',
          style: TextStyle(fontFamily: 'serif', color: Color(0xFF201D19), fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            ListTile(
              title: const Text('My Style Profile', style: TextStyle(fontWeight: FontWeight.w500)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StyleProfileScreen())),
            ),
            const Divider(),
            ListTile(
              title: const Text('Privacy & Image Permissions', style: TextStyle(fontWeight: FontWeight.w500)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPermissionsScreen())),
            ),
            const Divider(),
            ListTile(
              title: const Text('Notification Preferences', style: TextStyle(fontWeight: FontWeight.w500)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationPreferencesScreen())),
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}

/// 6. Help and Support Screen
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F3EC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF201D19)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Help and Support',
          style: TextStyle(fontFamily: 'serif', color: Color(0xFF201D19), fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(fontFamily: 'serif', fontSize: 22, color: Color(0xFF201D19)),
            ),
            const SizedBox(height: 16),
            _buildFaqItem(
              question: 'How does virtual try-on work?',
              answer: 'Virtual try-on uses your front, left, right, and rear profile photos along with your height, weight, and sizing measurements to render accurate clothing drapes on your digital avatar.',
            ),
            _buildFaqItem(
              question: 'How do I edit my style questionnaire?',
              answer: 'Go to Profile -> My Style Profile and tap "Edit Preferences" at the bottom to update your aesthetics, wardrobe, beauty, jewelry, season, budget, and color preferences.',
            ),
            _buildFaqItem(
              question: 'Are my photos secure?',
              answer: 'Yes. All captured body profile photos are stored securely on your local device.',
            ),
            const SizedBox(height: 24),
            const Text(
              'Contact Atelier Support',
              style: TextStyle(fontFamily: 'serif', fontSize: 18, color: Color(0xFF201D19)),
            ),
            const SizedBox(height: 8),
            const Text(
              'support@evoqe.com',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF3E3129)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem({required String question, required String answer}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFECE4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFCDC6BA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF201D19))),
          const SizedBox(height: 6),
          Text(answer, style: const TextStyle(fontSize: 12.5, color: Color(0xFF6E6760), height: 1.35)),
        ],
      ),
    );
  }
}
