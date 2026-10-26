import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../data/security/photo_picker.dart';
import '../data/security/secure_media_store.dart';
import '../state/session_state.dart';
import '../widgets/secure_image.dart';
import 'welcome_screen.dart';
import 'personal_style_questionnaire.dart';

class FourthScreen extends StatefulWidget {
  const FourthScreen({super.key});

  @override
  State<FourthScreen> createState() => _FourthScreenState();
}

class _FourthScreenState extends State<FourthScreen> {
  int _selectedFitIndex = 0; // 0: Relaxed, 1: Tailored, 2: Close-fitting
  int _selectedSkintoneIndex = 5; // Selected 6th dark shade in screenshot
  int _selectedUndertoneIndex = 1; // Selected 2nd undertone

  final _heightController = TextEditingController(text: '183');
  final _heightUnitController = TextEditingController(text: 'cm');
  final _weightController = TextEditingController(text: '80');
  final _weightUnitController = TextEditingController(text: 'kg');

  final _clothingSizeController = TextEditingController(text: 'M / UK 10');
  final _bustSizeController = TextEditingController(text: '32');
  final _hipSizeController = TextEditingController(text: '32');
  final _shoeSizeController = TextEditingController(text: 'EU 38');

  // Profile images matching front, left side, right side, and rear profile shots
  static const String _frontProfileUrl =
      'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=500&q=80';
  static const String _leftProfileUrl =
      'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?auto=format&fit=crop&w=500&q=80';
  static const String _rightProfileUrl =
      'https://images.unsplash.com/photo-1509631179647-0177331693ae?auto=format&fit=crop&w=500&q=80';
  static const String _rearProfileUrl =
      'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?auto=format&fit=crop&w=500&q=80';

  final List<Color> _skintoneColors = const [
    Color(0xFFFAF0E6),
    Color(0xFFEAD5C3),
    Color(0xFFCFA085),
    Color(0xFFB37D5C),
    Color(0xFF6E4A3B),
    Color(0xFF3D261D),
  ];

  final List<Color> _undertoneColors = const [
    Color(0xFFD8CDD6),
    Color(0xFFE8DFC8),
    Color(0xFFE0BE9B),
    Color(0xFFB3B89E),
  ];

  static const _slots = ['front', 'left', 'right', 'back'];
  late final Map<String, String?> _photos; // encrypted file names
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    final p = context.read<SessionState>().currentUser;
    _photos = {for (final s in _slots) s: p?.bodyPhotoPaths[s]};
    if (p == null) return;

    String fmt(double v) =>
        v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

    // Saved values are always stored in cm / kg.
    if (p.heightCm != null) {
      _heightController.text = fmt(p.heightCm!);
      _heightUnitController.text = 'cm';
    }
    if (p.weightKg != null) {
      _weightController.text = fmt(p.weightKg!);
      _weightUnitController.text = 'kg';
    }
    if (p.clothingSize != null) _clothingSizeController.text = p.clothingSize!;
    if (p.bustSize != null) _bustSizeController.text = p.bustSize!;
    if (p.hipSize != null) _hipSizeController.text = p.hipSize!;
    if (p.shoeSize != null) _shoeSizeController.text = p.shoeSize!;
    _selectedFitIndex = p.fitIndex ?? _selectedFitIndex;
    _selectedSkintoneIndex = p.skinToneIndex ?? _selectedSkintoneIndex;
    _selectedUndertoneIndex = p.undertoneIndex ?? _selectedUndertoneIndex;
  }

  Future<void> _showSourceSheet(String slot) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: const Color(0xFFF5F3EC),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source != null) await _pickForSlot(slot, source);
  }

  /// The big "Upload Photo" box fills the first empty slot.
  Future<void> _pickNextEmpty() {
    final slot = _slots.firstWhere((s) => _photos[s] == null,
        orElse: () => 'front');
    return _showSourceSheet(slot);
  }

  Future<void> _pickForSlot(String slot, ImageSource source) async {
    if (_isBusy) return;
    final store = context.read<SecureMediaStore>();
    final session = context.read<SessionState>();
    setState(() => _isBusy = true);
    try {
      final name = await PhotoPicker(store)
          .pick(source: source, replacing: _photos[slot]);
      if (name != null) {
        await session.updateProfile((p) => p.bodyPhotoPaths[slot] = name);
        if (mounted) setState(() => _photos[slot] = name);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save the photo. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  double? _toCm(String value, String unit) {
    final v = double.tryParse(value.trim());
    if (v == null) return null;
    final u = unit.trim().toLowerCase();
    if (u.startsWith('in')) return v * 2.54;
    if (u.startsWith('ft')) return v * 30.48;
    return v; // cm
  }

  double? _toKg(String value, String unit) {
    final v = double.tryParse(value.trim());
    if (v == null) return null;
    return unit.trim().toLowerCase().startsWith('lb') ? v * 0.45359237 : v;
  }

  String? _clean(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : t;
  }

  Future<void> _savePreferences() async {
    await context.read<SessionState>().updateProfile((p) {
      p.heightCm = _toCm(_heightController.text, _heightUnitController.text);
      p.weightKg = _toKg(_weightController.text, _weightUnitController.text);
      p.clothingSize = _clean(_clothingSizeController);
      p.bustSize = _clean(_bustSizeController);
      p.hipSize = _clean(_hipSizeController);
      p.shoeSize = _clean(_shoeSizeController);
      p.fitIndex = _selectedFitIndex;
      p.skinToneIndex = _selectedSkintoneIndex;
      p.undertoneIndex = _selectedUndertoneIndex;
    });
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FifthScreen()),
    );
  }

  @override
  void dispose() {
    _heightController.dispose();
    _heightUnitController.dispose();
    _weightController.dispose();
    _weightUnitController.dispose();
    _clothingSizeController.dispose();
    _bustSizeController.dispose();
    _hipSizeController.dispose();
    _shoeSizeController.dispose();
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

                // Step Eyebrow Label
                const Text(
                  'CREATE THE VIRTUAL YOU.',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.0,
                    color: Color(0xFF888077),
                  ),
                ),

                const SizedBox(height: 8),

                // Step Progress Bar
                Stack(
                  children: [
                    Container(
                      height: 2.0,
                      width: double.infinity,
                      color: const Color(0xFFD6CFC4),
                    ),
                    FractionallySizedBox(
                      widthFactor: 0.25,
                      child: Container(
                        height: 2.0,
                        color: const Color(0xFF201D19),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Main Section Headline
                const Text(
                  'Virtual Try-On\nExperience',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF201D19),
                    height: 1.15,
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 20),

                // Dashed Upload Photo Box
                GestureDetector(
                  onTap: _isBusy ? null : _pickNextEmpty,
                  child: CustomPaint(
                    painter: _DashedRectPainter(),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFECE4),
                        borderRadius: BorderRadius.circular(8.0),
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
                            'Upload Photo',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF201D19),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'JPG or PNG · private by default',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF888077),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ),

                const SizedBox(height: 18),

                // Instruction Text
                const Text(
                  'Click yourself in front, left, right and back profile and upload',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6E6760),
                  ),
                ),

                const SizedBox(height: 16),

                // Section Subtitle
                const Text(
                  'Your Profiles:',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF201D19),
                  ),
                ),

                const SizedBox(height: 14),

                // 2x2 Profiles Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildProfileCard(
                        slot: 'front',
                        imageUrl: _frontProfileUrl,
                        title: 'Front Profile',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildProfileCard(
                        slot: 'left',
                        imageUrl: _leftProfileUrl,
                        title: 'Side Profile (Left)',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _buildProfileCard(
                        slot: 'right',
                        imageUrl: _rightProfileUrl,
                        title: 'Side Profile (Right)',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildProfileCard(
                        slot: 'back',
                        imageUrl: _rearProfileUrl,
                        title: 'Rear Profile',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Continue to Complete Avatar Button
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
                          'Continue to complete your avatar',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_downward_rounded,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // Questionnaire Section Eyebrow Header
                const Text(
                  'YOUR COMPLETE AVATAR QUESTIONNAIRE',
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

                // Section: Your Dimensions
                const Text(
                  'Your dimensions',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF201D19),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Input your height and weight',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF888077),
                  ),
                ),

                const SizedBox(height: 16),

                // Dimensions Input Fields
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: _buildInputField(
                        label: 'Height',
                        controller: _heightController,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 5,
                      child: _buildInputField(
                        label: 'Unit',
                        controller: _heightUnitController,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: _buildInputField(
                        label: 'Weight',
                        controller: _weightController,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 5,
                      child: _buildInputField(
                        label: 'Unit',
                        controller: _weightUnitController,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                const Divider(color: Color(0xFFD6CFC4), thickness: 1),
                const SizedBox(height: 20),

                // Section: Fit & Sizing
                const Text(
                  'Fit & sizing',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF201D19),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Optional, user-provided sizing helps suggest a fit. Virtual previews do not guarantee sizing.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6E6760),
                    height: 1.35,
                  ),
                ),

                const SizedBox(height: 16),

                // Fit Options Pills (Relaxed / Tailored / Close-fitting)
                Row(
                  children: [
                    _buildFitOptionPill('Relaxed', 0),
                    const SizedBox(width: 8),
                    _buildFitOptionPill('Tailored', 1),
                    const SizedBox(width: 8),
                    _buildFitOptionPill('Close-fitting', 2),
                  ],
                ),

                const SizedBox(height: 20),

                // Sizing Inputs Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        label: 'Clothing size',
                        controller: _clothingSizeController,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInputField(
                        label: 'Bust size',
                        controller: _bustSizeController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        label: 'Hip Size',
                        controller: _hipSizeController,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInputField(
                        label: 'Shoe size',
                        controller: _shoeSizeController,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                const Divider(color: Color(0xFFD6CFC4), thickness: 1),
                const SizedBox(height: 20),

                // Section: Skintone
                const Text(
                  'Skintone',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF201D19),
                  ),
                ),

                const SizedBox(height: 16),

                // Skintone Color Swatches
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(_skintoneColors.length, (index) {
                    final color = _skintoneColors[index];
                    final isSelected = index == _selectedSkintoneIndex;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedSkintoneIndex = index;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF201D19)
                                : const Color(0xFFCDC6BA),
                            width: isSelected ? 2.5 : 1.0,
                          ),
                          boxShadow: isSelected
                              ? const [
                                  BoxShadow(
                                    color: Color(0x26000000),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 20),
                const Divider(color: Color(0xFFD6CFC4), thickness: 1),
                const SizedBox(height: 20),

                // Section: Skin Undertone
                const Text(
                  'Skin Undertone',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF201D19),
                  ),
                ),

                const SizedBox(height: 16),

                // Skin Undertone Swatches
                Row(
                  children: List.generate(_undertoneColors.length, (index) {
                    final color = _undertoneColors[index];
                    final isSelected = index == _selectedUndertoneIndex;
                    return Padding(
                      padding: const EdgeInsets.only(right: 18.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedUndertoneIndex = index;
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF201D19)
                                  : const Color(0xFFCDC6BA),
                              width: isSelected ? 2.5 : 1.0,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 24),
                const Divider(color: Color(0xFFD6CFC4), thickness: 1),
                const SizedBox(height: 24),

                // Save All Preferences Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _savePreferences,
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

  Widget _buildProfileCard({
    required String slot,
    required String imageUrl,
    required String title,
  }) {
    final saved = _photos[slot];
    return GestureDetector(
      onTap: _isBusy ? null : () => _showSourceSheet(slot),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.1,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: const Color(0xFFE2DDD3),
              ),
              clipBehavior: Clip.antiAlias,
              child: saved != null
                  ? SizedBox.expand(
                child: SecureImage(
                  fileName: saved,
                  placeholder: const Center(
                    child: Icon(Icons.person_outline_rounded,
                        size: 32, color: Color(0xFF8C8278)),
                  ),
                ),
              )
                  : Image.network(
                imageUrl, // sample image until the user adds one
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFFDDD7CC),
                  child: const Center(
                    child: Icon(Icons.person_outline_rounded,
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
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF5A544D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6E6760),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: const TextStyle(
            fontSize: 14.5,
            color: Color(0xFF201D19),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFEFECE4),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
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
      ],
    );
  }

  Widget _buildFitOptionPill(String title, int index) {
    final isSelected = index == _selectedFitIndex;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFitIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
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
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: isSelected ? const Color(0xFFF5F3EC) : const Color(0xFF201D19),
          ),
        ),
      ),
    );
  }
}

/// Custom painter to draw a clean dashed border for the photo upload box
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
      const Radius.circular(8.0),
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
