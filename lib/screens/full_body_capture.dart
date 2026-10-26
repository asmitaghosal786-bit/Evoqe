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
  bool _useAvatarInstead = false;
  bool _showQuestionnaire = false;

  int? _selectedFitIndex; // null when unselected; 0: Relaxed, 1: Tailored, 2: Close-fitting
  int? _selectedSkintoneIndex; // null when unselected
  int? _selectedUndertoneIndex; // null when unselected

  final _heightController = TextEditingController();
  String _heightUnit = 'cm';

  final _weightController = TextEditingController();
  String _weightUnit = 'kg';

  final _clothingSizeController = TextEditingController();
  final _bustSizeController = TextEditingController();
  final _hipSizeController = TextEditingController();
  final _shoeSizeController = TextEditingController();

  final _scrollController = ScrollController();
  final _questionnaireKey = GlobalKey();

  final _heightKey = GlobalKey();
  final _weightKey = GlobalKey();
  final _bustKey = GlobalKey();
  final _hipKey = GlobalKey();

  double _progress = 0.0;
  bool _hasAttemptedSave = false;

  String? _heightError;
  String? _weightError;
  String? _bustError;
  String? _hipError;

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
    _scrollController.addListener(_onScroll);

    final p = context.read<SessionState>().currentUser;
    _photos = {for (final s in _slots) s: p?.bodyPhotoPaths[s]};
    _useAvatarInstead = p?.useAvatarInsteadOfPhoto ?? false;
    if (p == null) return;

    String fmt(double v) =>
        v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

    if (p.heightCm != null) {
      _heightController.text = fmt(p.heightCm!);
      _heightUnit = 'cm';
    }
    if (p.weightKg != null) {
      _weightController.text = fmt(p.weightKg!);
      _weightUnit = 'kg';
    }
    if (p.clothingSize != null) _clothingSizeController.text = p.clothingSize!;
    if (p.bustSize != null) _bustSizeController.text = p.bustSize!;
    if (p.hipSize != null) _hipSizeController.text = p.hipSize!;
    if (p.shoeSize != null) _shoeSizeController.text = p.shoeSize!;
    _selectedFitIndex = p.fitIndex;
    _selectedSkintoneIndex = p.skinToneIndex;
    _selectedUndertoneIndex = p.undertoneIndex;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _clothingSizeController.dispose();
    _bustSizeController.dispose();
    _hipSizeController.dispose();
    _shoeSizeController.dispose();
    super.dispose();
  }

  void _setProgress(double val) {
    if (val > _progress) {
      setState(() {
        _progress = val;
      });
    }
  }

  void _onScroll() {
    if (_progress >= 0.5) return;
    final ctx = _questionnaireKey.currentContext;
    if (ctx != null) {
      final renderBox = ctx.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize) {
        final position = renderBox.localToGlobal(Offset.zero);
        final screenHeight = MediaQuery.of(context).size.height;
        if (position.dy < screenHeight - 50) {
          _setProgress(0.5);
        }
      }
    }
  }

  void _revealQuestionnaireAndScroll() {
    _setProgress(0.5);
    setState(() {
      _showQuestionnaire = true;
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

  void _toggleHeightUnit() {
    final currentText = _heightController.text.trim();
    final v = double.tryParse(currentText);
    setState(() {
      if (_heightUnit == 'cm') {
        _heightUnit = 'in';
        if (v != null) {
          final converted = v / 2.54;
          _heightController.text = converted == converted.roundToDouble()
              ? converted.toStringAsFixed(0)
              : converted.toStringAsFixed(1);
        }
      } else {
        _heightUnit = 'cm';
        if (v != null) {
          final converted = v * 2.54;
          _heightController.text = converted == converted.roundToDouble()
              ? converted.toStringAsFixed(0)
              : converted.toStringAsFixed(1);
        }
      }
    });
    if (_hasAttemptedSave) _validateInputs();
  }

  void _toggleWeightUnit() {
    final currentText = _weightController.text.trim();
    final v = double.tryParse(currentText);
    setState(() {
      if (_weightUnit == 'kg') {
        _weightUnit = 'lb';
        if (v != null) {
          final converted = v / 0.45359237;
          _weightController.text = converted == converted.roundToDouble()
              ? converted.toStringAsFixed(0)
              : converted.toStringAsFixed(1);
        }
      } else {
        _weightUnit = 'kg';
        if (v != null) {
          final converted = v * 0.45359237;
          _weightController.text = converted == converted.roundToDouble()
              ? converted.toStringAsFixed(0)
              : converted.toStringAsFixed(1);
        }
      }
    });
    if (_hasAttemptedSave) _validateInputs();
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
          const SnackBar(
            content: Text(
              'Could not save the photo. Try again.',
              style: TextStyle(color: Color(0xFFF5F3EC)),
            ),
            backgroundColor: Color(0xFF3E3129),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _deletePhotoForSlot(String slot) async {
    final fileName = _photos[slot];
    if (fileName == null) return;
    try {
      final store = context.read<SecureMediaStore>();
      final session = context.read<SessionState>();
      await store.delete(fileName);
      await session.updateProfile((p) => p.bodyPhotoPaths[slot] = null);
      if (mounted) {
        setState(() {
          _photos[slot] = null;
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not delete photo.',
              style: TextStyle(color: Color(0xFFF5F3EC)),
            ),
            backgroundColor: Color(0xFF3E3129),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  double? _toCm(String value, String unit) {
    final v = double.tryParse(value.trim());
    if (v == null) return null;
    if (unit == 'in') return v * 2.54;
    return v; // cm
  }

  double? _toKg(String value, String unit) {
    final v = double.tryParse(value.trim());
    if (v == null) return null;
    if (unit == 'lb') return v * 0.45359237;
    return v; // kg
  }

  String? _clean(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : t;
  }

  bool _validateInputs() {
    bool isValid = true;
    _heightError = null;
    _weightError = null;
    _bustError = null;
    _hipError = null;

    final heightText = _heightController.text.trim();
    if (heightText.isNotEmpty) {
      final cm = _toCm(heightText, _heightUnit);
      if (cm == null || cm < 90 || cm > 250) {
        _heightError = 'Height must be 90 - 250 cm';
        isValid = false;
      }
    }

    final weightText = _weightController.text.trim();
    if (weightText.isNotEmpty) {
      final kg = _toKg(weightText, _weightUnit);
      if (kg == null || kg < 25 || kg > 250) {
        _weightError = 'Weight must be 25 - 250 kg';
        isValid = false;
      }
    }

    final bustText = _bustSizeController.text.trim();
    if (bustText.isNotEmpty) {
      final numberRegex = RegExp(r'^\d*\.?\d+$');
      if (!numberRegex.hasMatch(bustText)) {
        _bustError = 'Numbers only';
        isValid = false;
      }
    }

    final hipText = _hipSizeController.text.trim();
    if (hipText.isNotEmpty) {
      final numberRegex = RegExp(r'^\d*\.?\d+$');
      if (!numberRegex.hasMatch(hipText)) {
        _hipError = 'Numbers only';
        isValid = false;
      }
    }

    return isValid;
  }

  void _scrollToFirstError() {
    GlobalKey? firstKey;
    if (_heightError != null) {
      firstKey = _heightKey;
    } else if (_weightError != null) {
      firstKey = _weightKey;
    } else if (_bustError != null) {
      firstKey = _bustKey;
    } else if (_hipError != null) {
      firstKey = _hipKey;
    }

    if (firstKey?.currentContext != null) {
      Scrollable.ensureVisible(
        firstKey!.currentContext!,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _savePreferences() async {
    if (_useAvatarInstead) {
      await context.read<SessionState>().updateProfile((p) {
        p.useAvatarInsteadOfPhoto = true;
      });
      _setProgress(1.0);
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;

      // TODO(nav): first-time onboarding flow.
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FifthScreen()),
      );
      return;
    }

    setState(() {
      _hasAttemptedSave = true;
    });

    if (!_validateInputs()) {
      setState(() {});
      _scrollToFirstError();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please check the highlighted fields.',
            style: TextStyle(color: Color(0xFFF5F3EC)),
          ),
          backgroundColor: Color(0xFF3E3129),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await context.read<SessionState>().updateProfile((p) {
      p.useAvatarInsteadOfPhoto = false;
      p.heightCm = _toCm(_heightController.text, _heightUnit);
      p.weightKg = _toKg(_weightController.text, _weightUnit);
      p.clothingSize = _clean(_clothingSizeController);
      p.bustSize = _clean(_bustSizeController);
      p.hipSize = _clean(_hipSizeController);
      p.shoeSize = _clean(_shoeSizeController);
      p.fitIndex = _selectedFitIndex;
      p.skinToneIndex = _selectedSkintoneIndex;
      p.undertoneIndex = _selectedUndertoneIndex;
    });

    _setProgress(1.0);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    // TODO(nav): first-time onboarding flow.
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FifthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
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

                // Step Progress Bar driven by _progress
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

                // Main Section Headline
                const Text(
                  'Virtual Try-On',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 30,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF201D19),
                    height: 1.15,
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 16),

                // Option Toggle Buttons ("Upload photos" / "Use default avatar")
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _useAvatarInstead = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: !_useAvatarInstead
                              ? const Color(0xFF4C5547)
                              : const Color(0xFFEFECE4),
                          borderRadius: BorderRadius.circular(6.0),
                          border: !_useAvatarInstead
                              ? null
                              : Border.all(
                                  color: const Color(0xFFCDC6BA),
                                  width: 1.0,
                                ),
                        ),
                        child: Text(
                          'Upload photos',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: !_useAvatarInstead
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
                          _useAvatarInstead = true;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: _useAvatarInstead
                              ? const Color(0xFF4C5547)
                              : const Color(0xFFEFECE4),
                          borderRadius: BorderRadius.circular(6.0),
                          border: _useAvatarInstead
                              ? null
                              : Border.all(
                                  color: const Color(0xFFCDC6BA),
                                  width: 1.0,
                                ),
                        ),
                        child: Text(
                          'Use default avatar',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: _useAvatarInstead
                                ? const Color(0xFFF5F3EC)
                                : const Color(0xFF201D19),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Instruction Text
                Text(
                  _useAvatarInstead
                      ? 'Default avatar mode enabled. You can skip photo uploads and questions.'
                      : 'Click yourself in front, left, right and back profile and upload',
                  style: const TextStyle(
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
                        title: 'Front Profile',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildProfileCard(
                        slot: 'left',
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
                        title: 'Side Profile (Right)',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildProfileCard(
                        slot: 'back',
                        title: 'Rear Profile',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Continue Button (Photo Section)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _useAvatarInstead
                        ? _savePreferences
                        : _revealQuestionnaireAndScroll,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3E3129),
                      foregroundColor: const Color(0xFFF5F3EC),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _useAvatarInstead
                              ? 'Continue with default avatar'
                              : 'Continue to complete your avatar',
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _useAvatarInstead
                              ? Icons.arrow_forward_rounded
                              : Icons.arrow_downward_rounded,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Questionnaire Section (Rendered ONLY in upload photos mode after clicking continue)
                if (!_useAvatarInstead && _showQuestionnaire) ...[
                  // Questionnaire Section Eyebrow Header
                  Text(
                    'YOUR COMPLETE AVATAR QUESTIONNAIRE',
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 6,
                        child: _buildInputField(
                          fieldKey: _heightKey,
                          label: 'Height',
                          controller: _heightController,
                          hintText: '183',
                          errorText: _heightError,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          onChanged: (_) {
                            if (_hasAttemptedSave) {
                              setState(() => _validateInputs());
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 5,
                        child: _buildUnitToggle(
                          unit: _heightUnit,
                          onTap: _toggleHeightUnit,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 6,
                        child: _buildInputField(
                          fieldKey: _weightKey,
                          label: 'Weight',
                          controller: _weightController,
                          hintText: '80',
                          errorText: _weightError,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          onChanged: (_) {
                            if (_hasAttemptedSave) {
                              setState(() => _validateInputs());
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 5,
                        child: _buildUnitToggle(
                          unit: _weightUnit,
                          onTap: _toggleWeightUnit,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildInputField(
                          label: 'Clothing size',
                          controller: _clothingSizeController,
                          hintText: 'M / UK 10',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInputField(
                          fieldKey: _bustKey,
                          label: 'Bust size',
                          controller: _bustSizeController,
                          hintText: '32',
                          errorText: _bustError,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          onChanged: (_) {
                            if (_hasAttemptedSave) {
                              setState(() => _validateInputs());
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildInputField(
                          fieldKey: _hipKey,
                          label: 'Hip Size',
                          controller: _hipSizeController,
                          hintText: '32',
                          errorText: _hipError,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          onChanged: (_) {
                            if (_hasAttemptedSave) {
                              setState(() => _validateInputs());
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInputField(
                          label: 'Shoe size',
                          controller: _shoeSizeController,
                          hintText: 'EU 38',
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
                            _selectedSkintoneIndex =
                                _selectedSkintoneIndex == index ? null : index;
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
                              _selectedUndertoneIndex =
                                  _selectedUndertoneIndex == index
                                      ? null
                                      : index;
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard({
    required String slot,
    required String title,
  }) {
    final saved = _photos[slot];
    return Column(
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
            child: Stack(
              children: [
                Positioned.fill(
                  child: InkWell(
                    onTap: _isBusy ? null : () => _showSourceSheet(slot),
                    child: saved != null
                        ? SecureImage(
                            fileName: saved,
                            placeholder: const Center(
                              child: Icon(
                                Icons.person_outline_rounded,
                                size: 32,
                                color: Color(0xFF8C8278),
                              ),
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 28,
                              color: Color(0xFF8C8278),
                            ),
                          ),
                  ),
                ),
                if (_useAvatarInstead)
                  Positioned.fill(
                    child: Container(
                      color: const Color(0x66F5F3EC),
                    ),
                  ),
                if (saved != null)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () => _deletePhotoForSlot(slot),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xEBF5F3EC),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: Color(0xFF201D19),
                        ),
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
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF5A544D),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    Key? fieldKey,
    required String label,
    required TextEditingController controller,
    String? hintText,
    String? errorText,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      key: fieldKey,
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
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: const TextStyle(
            fontSize: 14.5,
            color: Color(0xFF201D19),
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Color(0xFF888077),
              fontSize: 14,
            ),
            filled: true,
            fillColor: const Color(0xFFEFECE4),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            errorText: errorText,
            errorStyle: const TextStyle(
              fontSize: 11.5,
              color: Color(0xFFA33A3A),
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.0),
              borderSide: const BorderSide(
                color: Color(0xFFA33A3A),
                width: 1.0,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.0),
              borderSide: const BorderSide(
                color: Color(0xFFA33A3A),
                width: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUnitToggle({
    required String unit,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Unit',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6E6760),
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4.0),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEFECE4),
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(
                color: const Color(0xFFCDC6BA),
                width: 1.0,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF201D19),
                  ),
                ),
                const Icon(
                  Icons.swap_vert_rounded,
                  size: 18,
                  color: Color(0xFF6E6760),
                ),
              ],
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
          _selectedFitIndex = _selectedFitIndex == index ? null : index;
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
            color:
                isSelected ? const Color(0xFFF5F3EC) : const Color(0xFF201D19),
          ),
        ),
      ),
    );
  }
}
