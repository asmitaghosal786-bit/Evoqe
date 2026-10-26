import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/session_state.dart';
import 'welcome_screen.dart';
import 'home_screen.dart';

class FifthScreen extends StatefulWidget {
  const FifthScreen({super.key});

  @override
  State<FifthScreen> createState() => _FifthScreenState();
}

class _FifthScreenState extends State<FifthScreen> {
  // Selection states for questionnaire sections
  final Set<String> _selectedAesthetics = {};
  final Set<String> _customAesthetics = {};

  final Set<String> _selectedWardrobe = {'Western'};
  final Set<String> _customWardrobe = {};

  final Set<String> _selectedBeauty = {'Natural finish'};
  final Set<String> _customBeauty = {};

  final Set<String> _selectedJewelry = {'Gold'};
  final Set<String> _customJewelry = {};

  final Set<String> _selectedSeason = {'Winter'};
  final Set<String> _customSeason = {};

  final Set<String> _selectedBudget = {'Under ₹5,000'};
  final Set<String> _customBudget = {};

  final Set<String> _selectedPalette = {'0xFFFAF8F5', '0xFFE2DDD3', '0xFF3E3129', '0xFF555E4E'};
  final Set<String> _customPalette = {};

  bool _showCompleteQuestionnaire = false;
  double _progress = 0.5;

  final _scrollController = ScrollController();
  final _questionnaireKey = GlobalKey();

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

  static const List<String> _defaultPaletteHexes = [
    '0xFFFAF8F5',
    '0xFFE2DDD3',
    '0xFF3E3129',
    '0xFF555E4E',
  ];

  @override
  void initState() {
    super.initState();
    final p = context.read<SessionState>().currentUser;
    if (p != null) {
      if (p.aesthetics.isNotEmpty) {
        _selectedAesthetics.addAll(p.aesthetics);
      }
      if (p.customAesthetics.isNotEmpty) {
        _customAesthetics.addAll(p.customAesthetics);
      }
      if (p.wardrobe.isNotEmpty) {
        _selectedWardrobe.clear();
        _selectedWardrobe.addAll(p.wardrobe);
      }
      if (p.customWardrobe.isNotEmpty) {
        _customWardrobe.addAll(p.customWardrobe);
      }
      if (p.beauty.isNotEmpty) {
        _selectedBeauty.clear();
        _selectedBeauty.addAll(p.beauty);
      }
      if (p.customBeauty.isNotEmpty) {
        _customBeauty.addAll(p.customBeauty);
      }
      if (p.jewelry.isNotEmpty) {
        _selectedJewelry.clear();
        _selectedJewelry.addAll(p.jewelry);
      }
      if (p.customJewelry.isNotEmpty) {
        _customJewelry.addAll(p.customJewelry);
      }
      if (p.season.isNotEmpty) {
        _selectedSeason.clear();
        _selectedSeason.addAll(p.season);
      }
      if (p.customSeason.isNotEmpty) {
        _customSeason.addAll(p.customSeason);
      }
      if (p.budget.isNotEmpty) {
        _selectedBudget.clear();
        _selectedBudget.addAll(p.budget);
      }
      if (p.customBudget.isNotEmpty) {
        _customBudget.addAll(p.customBudget);
      }
      if (p.palette.isNotEmpty) {
        _selectedPalette.clear();
        _selectedPalette.addAll(p.palette);
      }
      if (p.customPalette.isNotEmpty) {
        _customPalette.addAll(p.customPalette);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _setProgress(double val) {
    if (val > _progress) {
      setState(() {
        _progress = val;
      });
    }
  }

  void _onContinuePressed() {
    _setProgress(0.8);
    setState(() {
      _showCompleteQuestionnaire = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_questionnaireKey.currentContext != null) {
        Scrollable.ensureVisible(
          _questionnaireKey.currentContext!,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Future<void> _saveAndComplete() async {
    _setProgress(1.0);
    final session = context.read<SessionState>();
    await session.updateProfile((p) {
      p.aesthetics = Set.from(_selectedAesthetics);
      p.customAesthetics = Set.from(_customAesthetics);
      p.wardrobe = Set.from(_selectedWardrobe);
      p.customWardrobe = Set.from(_customWardrobe);
      p.beauty = Set.from(_selectedBeauty);
      p.customBeauty = Set.from(_customBeauty);
      p.jewelry = Set.from(_selectedJewelry);
      p.customJewelry = Set.from(_customJewelry);
      p.season = Set.from(_selectedSeason);
      p.customSeason = Set.from(_customSeason);
      p.budget = Set.from(_selectedBudget);
      p.customBudget = Set.from(_customBudget);
      p.palette = Set.from(_selectedPalette);
      p.customPalette = Set.from(_customPalette);
    });

    if (!session.hasCompletedOnboarding) {
      await session.completeOnboarding();
    }

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const EighthScreen(),
      ),
      (route) => false,
    );
  }

  Future<void> _showAddCustomDialog({
    required String title,
    required String label,
    required ValueChanged<String> onAdded,
  }) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF5F3EC),
        title: Text(title, style: const TextStyle(fontFamily: 'serif', color: Color(0xFF201D19))),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: label,
            hintStyle: const TextStyle(color: Color(0xFF888077)),
            filled: true,
            fillColor: const Color(0xFFEFECE4),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.0),
              borderSide: const BorderSide(color: Color(0xFFCDC6BA)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.0),
              borderSide: const BorderSide(color: Color(0xFF3E3129)),
            ),
          ),
        ),
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
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      onAdded(result);
    }
  }

  Future<void> _showAddColorDialog() async {
    final List<Color> presetColors = const [
      Color(0xFFE8D7C1),
      Color(0xFF8B5A2B),
      Color(0xFFD4AF37),
      Color(0xFF708238),
      Color(0xFF2F4F4F),
      Color(0xFF7B68EE),
      Color(0xFFCD5C5C),
      Color(0xFFD8BFD8),
      Color(0xFF202020),
      Color(0xFFFFFFFF),
    ];

    Color selectedColor = presetColors.first;
    final hexController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFFF5F3EC),
          title: const Text('Add Custom Color', style: TextStyle(fontFamily: 'serif', color: Color(0xFF201D19))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Choose from palette or enter hex:', style: TextStyle(fontSize: 12.5, color: Color(0xFF6E6760))),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: presetColors.map((color) {
                  final isSelected = selectedColor.toARGB32() == color.toARGB32();
                  return GestureDetector(
                    onTap: () {
                      setDialogState(() {
                        selectedColor = color;
                        hexController.text = '0xFF${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase().substring(2)}';
                      });
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? const Color(0xFF3E3129) : const Color(0xFFCDC6BA),
                          width: isSelected ? 2.5 : 1.0,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: hexController,
                decoration: InputDecoration(
                  labelText: 'Hex Code (e.g. 0xFF5733)',
                  labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF888077)),
                  filled: true,
                  fillColor: const Color(0xFFEFECE4),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.0),
                    borderSide: const BorderSide(color: Color(0xFFCDC6BA)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.0),
                    borderSide: const BorderSide(color: Color(0xFF3E3129)),
                  ),
                ),
              ),
            ],
          ),
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
              onPressed: () {
                Color colorToAdd = selectedColor;
                final hexText = hexController.text.trim();
                if (hexText.isNotEmpty) {
                  String cleanHex = hexText.replaceAll('#', '').replaceAll('0x', '').replaceAll('0X', '');
                  if (cleanHex.length == 6) {
                    cleanHex = 'FF$cleanHex';
                  }
                  final parsedValue = int.tryParse(cleanHex, radix: 16);
                  if (parsedValue != null) {
                    colorToAdd = Color(parsedValue);
                  }
                }
                final hexStr = '0x${colorToAdd.toARGB32().toRadixString(16).toUpperCase().padLeft(8, '0')}';
                setState(() {
                  _customPalette.add(hexStr);
                  _selectedPalette.add(hexStr);
                });
                Navigator.pop(ctx);
              },
              child: const Text('Add Color'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final baseAesthetics = ['Minimal', 'Coquette', 'Formal', 'Partywear', 'Athleisure'];
    final allAesthetics = [...baseAesthetics, ..._customAesthetics];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EC),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
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

                // Progress Bar Line driven by _progress
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: _progress),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Stack(
                      children: [
                        Container(
                          height: 2.0,
                          width: double.infinity,
                          color: const Color(0xFFD6CFC4),
                        ),
                        FractionallySizedBox(
                          widthFactor: value.clamp(0.0, 1.0),
                          child: Container(
                            height: 2.0,
                            color: const Color(0xFF201D19),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Main Title & Subtitle
                const Text(
                  'Style Questionnaire',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 30,
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

                // Grid of Aesthetics
                ..._buildAestheticGridRows(allAesthetics),

                const SizedBox(height: 20),

                // Continue Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _onContinuePressed,
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

                // Complete Style Questionnaire Header & Sections (Visible only after clicking Continue)
                if (_showCompleteQuestionnaire) ...[
                  Text(
                    'YOUR COMPLETE STYLE QUESTIONNAIRE',
                    key: _questionnaireKey,
                    style: const TextStyle(
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

                  _buildChipGroup(
                    options: ['Western', 'Traditional', 'Athleisure', 'Travel', 'Formal', 'Casual', 'Occasion'],
                    customOptions: _customWardrobe,
                    selectedOptions: _selectedWardrobe,
                    isSingleSelect: false,
                    categoryName: 'Wardrobe',
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

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ...[..._defaultPaletteHexes, ..._customPalette].map((hexStr) {
                          final color = Color(int.parse(hexStr));
                          final isSelected = _selectedPalette.contains(hexStr);
                          return Padding(
                            padding: const EdgeInsets.only(right: 14.0),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedPalette.remove(hexStr);
                                  } else {
                                    _selectedPalette.add(hexStr);
                                  }
                                });
                              },
                              child: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF201D19) : const Color(0xFFCDC6BA),
                                    width: isSelected ? 2.5 : 1.0,
                                  ),
                                  boxShadow: isSelected
                                      ? const [BoxShadow(color: Color(0x26000000), blurRadius: 4, offset: Offset(0, 2))]
                                      : null,
                                ),
                                child: isSelected
                                    ? Center(
                                        child: Icon(
                                          Icons.check,
                                          size: 16,
                                          color: (color.computeLuminance() > 0.5) ? Colors.black87 : Colors.white,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          );
                        }),
                        // Add Color Swatch Button
                        GestureDetector(
                          onTap: _showAddColorDialog,
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFFFF),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFCDC6BA),
                                width: 1.0,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.add,
                                size: 20,
                                color: Color(0xFF201D19),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Select your preferred color palette swatches or add custom colors.',
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

                  _buildChipGroup(
                    options: ['Natural finish', 'Soft glam', 'Bold glam', 'Bronzed', 'Experimental'],
                    customOptions: _customBeauty,
                    selectedOptions: _selectedBeauty,
                    isSingleSelect: false,
                    categoryName: 'Beauty preferences',
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

                  _buildChipGroup(
                    options: ['Gold', 'Silver', 'Rose Gold', 'Oxidized'],
                    customOptions: _customJewelry,
                    selectedOptions: _selectedJewelry,
                    isSingleSelect: false,
                    categoryName: 'Jewelry preferences',
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

                  _buildChipGroup(
                    options: ['Winter', 'Fall', 'Summer', 'Spring'],
                    customOptions: _customSeason,
                    selectedOptions: _selectedSeason,
                    isSingleSelect: false,
                    categoryName: 'Season',
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

                  _buildChipGroup(
                    options: ['Under ₹5,000', '₹5,000–₹10,000', '₹10,000–₹20,000', 'Flexible'],
                    customOptions: _customBudget,
                    selectedOptions: _selectedBudget,
                    isSingleSelect: true,
                    categoryName: 'Budget',
                  ),

                  const SizedBox(height: 24),
                  const Divider(color: Color(0xFFD6CFC4), thickness: 1),
                  const SizedBox(height: 24),

                  // Save All Preferences Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _saveAndComplete,
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
                ],

                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAestheticGridRows(List<String> aesthetics) {
    final listWithExplore = [...aesthetics, 'EXPLORE_MORE_CARD'];
    List<Widget> rows = [];
    for (int i = 0; i < listWithExplore.length; i += 2) {
      final title1 = listWithExplore[i];
      final title2 = (i + 1 < listWithExplore.length) ? listWithExplore[i + 1] : null;

      Widget card1 = title1 == 'EXPLORE_MORE_CARD'
          ? _buildExploreMoreCard()
          : _buildAestheticCard(title: title1);

      Widget? card2 = title2 == null
          ? null
          : (title2 == 'EXPLORE_MORE_CARD'
              ? _buildExploreMoreCard()
              : _buildAestheticCard(title: title2));

      rows.add(
        Row(
          children: [
            Expanded(child: card1),
            const SizedBox(width: 12),
            Expanded(child: card2 ?? const SizedBox()),
          ],
        ),
      );
      if (i + 2 < listWithExplore.length) {
        rows.add(const SizedBox(height: 14));
      }
    }
    return rows;
  }

  Widget _buildAestheticCard({required String title}) {
    final isSelected = _selectedAesthetics.contains(title);
    String imageUrl = _minimalImageUrl;
    final lower = title.toLowerCase();
    if (lower == 'coquette') {
      imageUrl = _coquetteImageUrl;
    } else if (lower == 'formal') {
      imageUrl = _formalImageUrl;
    } else if (lower == 'partywear') {
      imageUrl = _partywearImageUrl;
    } else if (lower == 'athleisure') {
      imageUrl = _athleisureImageUrl;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedAesthetics.remove(title);
          } else {
            _selectedAesthetics.add(title);
          }
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.25,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: const Color(0xFFE2DDD3),
                border: Border.all(
                  color: isSelected ? const Color(0xFF3E3129) : const Color(0xFFCDC6BA),
                  width: isSelected ? 2.0 : 1.0,
                ),
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
                          child: Icon(Icons.style_outlined,
                              size: 32, color: Color(0xFF8C8278)),
                        ),
                      ),
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF3E3129),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: Color(0xFFF5F3EC),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? const Color(0xFF201D19) : const Color(0xFF5A544D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExploreMoreCard() {
    return GestureDetector(
      onTap: () {
        _showAddCustomDialog(
          title: 'Explore More Aesthetics',
          label: 'Enter aesthetic name (e.g. Bohemian)',
          onAdded: (name) {
            if (name.isNotEmpty) {
              final lower = name.toLowerCase();
              final all = ['minimal', 'coquette', 'formal', 'partywear', 'athleisure', ..._customAesthetics.map((e) => e.toLowerCase())];
              if (!all.contains(lower)) {
                setState(() {
                  _customAesthetics.add(name);
                  _selectedAesthetics.add(name);
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('This aesthetic already exists.')),
                );
              }
            }
          },
        );
      },
      child: Column(
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
      ),
    );
  }

  Widget _buildChipGroup({
    required List<String> options,
    required Set<String> customOptions,
    required Set<String> selectedOptions,
    required bool isSingleSelect,
    required String categoryName,
  }) {
    final allItems = [...options, ...customOptions, 'Add more'];

    return Wrap(
      spacing: 8.0,
      runSpacing: 10.0,
      children: allItems.map((item) {
        if (item == 'Add more') {
          return _buildSelectablePill(
            title: 'Add more',
            isSelected: false,
            isAction: true,
            onTap: () {
              _showAddCustomDialog(
                title: 'Add $categoryName Option',
                label: 'Enter new option',
                onAdded: (val) {
                  if (val.isNotEmpty) {
                    final lowerVal = val.toLowerCase();
                    final allExisting = [...options.map((e) => e.toLowerCase()), ...customOptions.map((e) => e.toLowerCase())];
                    if (!allExisting.contains(lowerVal)) {
                      setState(() {
                        customOptions.add(val);
                        if (isSingleSelect) {
                          selectedOptions.clear();
                          selectedOptions.add(val);
                        } else {
                          selectedOptions.add(val);
                        }
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('This option already exists.')),
                      );
                    }
                  }
                },
              );
            },
          );
        }

        final isSelected = selectedOptions.contains(item);
        return _buildSelectablePill(
          title: item,
          isSelected: isSelected,
          isAction: false,
          onTap: () {
            setState(() {
              if (isSingleSelect) {
                selectedOptions.clear();
                selectedOptions.add(item);
              } else {
                if (isSelected) {
                  selectedOptions.remove(item);
                } else {
                  selectedOptions.add(item);
                }
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildSelectablePill({
    required String title,
    required bool isSelected,
    required bool isAction,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4C5547)
              : (isAction ? const Color(0xFFFFFFFF) : const Color(0xFFEFECE4)),
          borderRadius: BorderRadius.circular(6.0),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isAction ? const Color(0xFFCDC6BA) : const Color(0xFFCDC6BA)),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isAction) ...[
              const Icon(Icons.add, size: 14, color: Color(0xFF201D19)),
              const SizedBox(width: 4),
            ],
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? const Color(0xFFF5F3EC)
                    : (isAction ? const Color(0xFF201D19) : const Color(0xFF201D19)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
