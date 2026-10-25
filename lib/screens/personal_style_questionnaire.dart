import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import 'user_profile_settings.dart';

class FifthScreen extends StatefulWidget {
  const FifthScreen({super.key});

  @override
  State<FifthScreen> createState() => _FifthScreenState();
}

class _FifthScreenState extends State<FifthScreen> {
  // Selection states for questionnaire sections
  final Set<String> _selectedWardrobe = {'Western'};
  final Set<String> _selectedBeauty = {'Natural finish'};
  final Set<String> _selectedJewelry = {'Gold'};
  final Set<String> _selectedSeason = {'Winter'};
  final Set<String> _selectedBudget = {'Under ₹5,000'};

  // High quality Unsplash URLs matching aesthetic cards
  static const String _minimalImageUrl =
      'https://images.unsplash.com/photo-1548883354-7622d03aca27?auto=format&fit=crop&w=500&q=80';
  static const String _coquetteImageUrl =
      'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=500&q=80';
  static const String _formalImageUrl =
      'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?auto=format&fit=crop&w=500&q=80';
  static const String _partywearImageUrl =
      'https://images.unsplash.com/photo-1566174053879-31528523f8ae?auto=format&fit=crop&w=500&q=80';
  static const String _athleisureImageUrl =
      'https://images.unsplash.com/photo-1518310383802-640c2de311b2?auto=format&fit=crop&w=500&q=80';

  final List<Color> _paletteColors = const [
    Color(0xFFFAF8F5),
    Color(0xFFE2DDD3),
    Color(0xFF3E3129),
    Color(0xFF555E4E),
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

                const SizedBox(height: 24),

                // Eyebrow Label
                const Text(
                  'YOUR STYLE, IN YOUR WORDS',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.0,
                    color: Color(0xFF888077),
                  ),
                ),

                const SizedBox(height: 8),

                // Progress Bar Line
                Stack(
                  children: [
                    Container(
                      height: 2.0,
                      width: double.infinity,
                      color: const Color(0xFFD6CFC4),
                    ),
                    FractionallySizedBox(
                      widthFactor: 0.3,
                      child: Container(
                        height: 2.0,
                        color: const Color(0xFF201D19),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Main Title & Subtitle
                const Text(
                  'Style Questionnaire',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 34,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF201D19),
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'What draws you in?',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF201D19),
                  ),
                ),

                const SizedBox(height: 16),

                // 3x2 Grid of Aesthetics
                Row(
                  children: [
                    Expanded(
                      child: _buildAestheticCard(
                        imageUrl: _minimalImageUrl,
                        title: 'Minimal',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildAestheticCard(
                        imageUrl: _coquetteImageUrl,
                        title: 'Coquette',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _buildAestheticCard(
                        imageUrl: _formalImageUrl,
                        title: 'Formal',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildAestheticCard(
                        imageUrl: _partywearImageUrl,
                        title: 'Partywear',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _buildAestheticCard(
                        imageUrl: _athleisureImageUrl,
                        title: 'Athleisure',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildExploreMoreCard(),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Continue Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3E3129),
                      foregroundColor: const Color(0xFFF5F3EC),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // Complete Style Questionnaire Header
                const Text(
                  'YOUR COMPLETE STYLE QUESTIONNAIRE',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.0,
                    color: Color(0xFF888077),
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'All questions are optional. These preferences guide your edits; nothing here defines or limits your style.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF6E6760),
                    height: 1.35,
                  ),
                ),

                const SizedBox(height: 16),
                const Divider(color: Color(0xFFD6CFC4), thickness: 1),
                const SizedBox(height: 20),

                // Section: Your wardrobe
                const Text(
                  'Your wardrobe',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF201D19),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Choose the categories you would like to explore.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF888077),
                  ),
                ),

                const SizedBox(height: 16),

                Wrap(
                  spacing: 8.0,
                  runSpacing: 10.0,
                  children: [
                    'Western',
                    'Traditional',
                    'Athleisure',
                    'Travel',
                    'Formal',
                    'Casual',
                    'Occasion',
                    'Add more'
                  ].map((category) {
                    final isSelected = _selectedWardrobe.contains(category);
                    return _buildSelectablePill(
                      title: category,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedWardrobe.remove(category);
                          } else {
                            _selectedWardrobe.add(category);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),
                const Divider(color: Color(0xFFD6CFC4), thickness: 1),
                const SizedBox(height: 20),

                // Section: Favorite palettes
                const Text(
                  'Favorite palettes',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF201D19),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: List.generate(_paletteColors.length, (index) {
                    final color = _paletteColors[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 14.0),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFCDC6BA),
                            width: 1.0,
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Ivory · warm taupe · espresso · muted olive',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888077),
                  ),
                ),

                const SizedBox(height: 20),
                const Divider(color: Color(0xFFD6CFC4), thickness: 1),
                const SizedBox(height: 20),

                // Section: Beauty preferences
                const Text(
                  'Beauty preferences',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF201D19),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Optional. Your chosen makeup tones, not inferred identity.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6E6760),
                  ),
                ),

                const SizedBox(height: 16),

                Wrap(
                  spacing: 8.0,
                  runSpacing: 10.0,
                  children: [
                    'Natural finish',
                    'Soft glam',
                    'Bold glam',
                    'Bronzed',
                    'Experimental',
                    'Add more'
                  ].map((option) {
                    final isSelected = _selectedBeauty.contains(option);
                    return _buildSelectablePill(
                      title: option,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedBeauty.remove(option);
                          } else {
                            _selectedBeauty.add(option);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),
                const Divider(color: Color(0xFFD6CFC4), thickness: 1),
                const SizedBox(height: 20),

                // Section: Jewelry preferences
                const Text(
                  'Jewelry preferences',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF201D19),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Metals and silhouettes you enjoy wearing.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6E6760),
                  ),
                ),

                const SizedBox(height: 16),

                Wrap(
                  spacing: 8.0,
                  runSpacing: 10.0,
                  children: [
                    'Gold',
                    'Silver',
                    'Rose Gold',
                    'Oxidized',
                    'Add more'
                  ].map((option) {
                    final isSelected = _selectedJewelry.contains(option);
                    return _buildSelectablePill(
                      title: option,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedJewelry.remove(option);
                          } else {
                            _selectedJewelry.add(option);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),
                const Divider(color: Color(0xFFD6CFC4), thickness: 1),
                const SizedBox(height: 20),

                // Section: Season
                const Text(
                  'Season',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF201D19),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Tell us what your wardrobe needs to cover.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6E6760),
                  ),
                ),

                const SizedBox(height: 16),

                Wrap(
                  spacing: 8.0,
                  runSpacing: 10.0,
                  children: [
                    'Winter',
                    'Fall',
                    'Summer',
                    'Spring',
                    'Add more'
                  ].map((season) {
                    final isSelected = _selectedSeason.contains(season);
                    return _buildSelectablePill(
                      title: season,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedSeason.remove(season);
                          } else {
                            _selectedSeason.add(season);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),
                const Divider(color: Color(0xFFD6CFC4), thickness: 1),
                const SizedBox(height: 20),

                // Section: Your budget
                const Text(
                  'Your budget',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF201D19),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Optional. Used to shape suggestions, not to assess you. INR is the default.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6E6760),
                    height: 1.35,
                  ),
                ),

                const SizedBox(height: 16),

                Wrap(
                  spacing: 8.0,
                  runSpacing: 10.0,
                  children: [
                    'Under ₹5,000',
                    '₹5,000–₹10,000',
                    '₹10,000–₹20,000',
                    'Flexible',
                    'Add more'
                  ].map((budget) {
                    final isSelected = _selectedBudget.contains(budget);
                    return _buildSelectablePill(
                      title: budget,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedBudget.remove(budget);
                          } else {
                            _selectedBudget.add(budget);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),
                const Divider(color: Color(0xFFD6CFC4), thickness: 1),
                const SizedBox(height: 24),

                // Save All Preferences Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SixthScreen(),
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
                      'Save all preferences',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Footer Disclaimer Text
                const Center(
                  child: Text(
                    'You can edit or remove any preference in My Style Profile.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF888077),
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

  Widget _buildAestheticCard({required String imageUrl, required String title}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1.25,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: const Color(0xFFE2DDD3),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFFDDD7CC),
                child: const Center(
                  child: Icon(Icons.style_outlined,
                      size: 32, color: Color(0xFF8C8278)),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: Color(0xFF5A544D),
          ),
        ),
      ],
    );
  }

  Widget _buildExploreMoreCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1.25,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: const Color(0xFFFFFFFF),
              border: Border.all(
                color: const Color(0xFFCDC6BA),
                width: 1.0,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.add,
                size: 38,
                color: Color(0xFF201D19),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Explore more aesthetics',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF5A544D),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectablePill({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4C5547) : const Color(0xFFEFECE4),
          borderRadius: BorderRadius.circular(6.0),
          border: isSelected
              ? null
              : Border.all(
                  color: const Color(0xFFCDC6BA),
                  width: 1.0,
                ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? const Color(0xFFF5F3EC) : const Color(0xFF201D19),
          ),
        ),
      ),
    );
  }
}
