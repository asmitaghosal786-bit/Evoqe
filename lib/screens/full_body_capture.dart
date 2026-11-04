import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../data/security/photo_picker.dart';
import '../data/security/secure_media_store.dart';
import '../state/session_state.dart';
import '../widgets/secure_image.dart';
import '../widgets/default_avatar.dart';
import 'selfie_capture.dart';
import 'welcome_screen.dart';
import 'personal_style_questionnaire.dart';

class FourthScreen extends StatefulWidget {
  const FourthScreen({super.key, this.genderChanged = false});

  final bool genderChanged;

  @override
  State<FourthScreen> createState() => _FourthScreenState();
}

class _FourthScreenState extends State<FourthScreen> {
  bool _useAvatarInstead = false;

  static const _slots = ['front', 'left', 'right', 'back'];
  late final Map<String, String?> _photos; // encrypted file names
  final Set<String> _refreshedSlots = {};
  bool _hasStalePhotos = false;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    final p = context.read<SessionState>().currentUser;
    _photos = {for (final s in _slots) s: p?.bodyPhotoPaths[s]};
    _useAvatarInstead = p?.useAvatarInsteadOfPhoto ?? false;
    _hasStalePhotos =
        p?.bodyPhotoGender != null &&
        p?.bodyPhotoGender != p?.gender &&
        _photos.values.any((photo) => photo != null);
    if (widget.genderChanged) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Gender changed. Please update your full-body profile photos and selfie.',
            ),
            backgroundColor: Color(0xFF3E3129),
            behavior: SnackBarBehavior.floating,
          ),
        );
      });
    }
  }

  bool get _canContinue =>
      _useAvatarInstead ||
      (_photos.values.every((p) => p != null) &&
          (!_hasStalePhotos || _refreshedSlots.length == _slots.length));

  double get _progress {
    if (_useAvatarInstead) return 1.0;
    int uploadedCount = _photos.values.where((p) => p != null).length;
    return uploadedCount / 4.0;
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
        if (mounted) {
          setState(() {
            _photos[slot] = name;
            _refreshedSlots.add(slot);
          });
        }
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
          _refreshedSlots.remove(slot);
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

  Future<void> _savePreferences() async {
    if (!_canContinue) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please upload all 4 profile photos to continue.',
            style: TextStyle(color: Color(0xFFF5F3EC)),
          ),
          backgroundColor: Color(0xFF3E3129),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await context.read<SessionState>().updateProfile((p) {
      p.useAvatarInsteadOfPhoto = _useAvatarInstead;
      for (final slot in _slots) {
        p.bodyPhotoPaths[slot] = _photos[slot];
      }
      if (!_useAvatarInstead) {
        p.bodyPhotoGender = p.gender;
      }
    });

    if (!mounted) return;

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
                  'A Silhouette Of You',
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
                      ? 'Your default avatar follows the gender saved in your style profile.'
                      : 'Upload photos of your 4 profiles (front, left, right, and back)',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6E6760),
                  ),
                ),
                if (widget.genderChanged)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your gender changed. Replace all four profile photos to use them again, or choose the updated default avatar. Please also update your selfie.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8A4F32),
                            height: 1.35,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ThirdScreen(),
                              ),
                            );
                          },
                          child: const Text('Update selfie photo'),
                        ),
                      ],
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

                const SizedBox(height: 28),

                // Save and Continue Button
                Opacity(
                  opacity: _canContinue ? 1.0 : 0.5,
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _savePreferences,
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
                                : 'Save and continue',
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard({required String slot, required String title}) {
    final saved = _photos[slot];
    final gender = context.read<SessionState>().currentUser?.gender;
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
                    child: _useAvatarInstead
                        ? DefaultAvatar(gender: gender, profile: slot)
                        : saved != null
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
}
