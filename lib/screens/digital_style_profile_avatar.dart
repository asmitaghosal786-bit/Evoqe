import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/session_state.dart';
import '../widgets/default_avatar.dart';
import '../widgets/secure_image.dart';
import 'welcome_screen.dart';
import 'selfie_capture.dart';
import 'full_body_capture.dart';

enum _GenderChangeChoice { cancel, capturePhotos, useDefaultAvatar }

class SeventhScreen extends StatefulWidget {
  const SeventhScreen({super.key});

  @override
  State<SeventhScreen> createState() => _SeventhScreenState();
}

class _SeventhScreenState extends State<SeventhScreen> {
  String? _originalGender;
  String _selectedGender = 'Female';

  @override
  void initState() {
    super.initState();
    final gender = context.read<SessionState>().currentUser?.gender;
    _originalGender = gender;
    _selectedGender = gender ?? 'Female';
  }

  Future<void> _selectGender(String gender) async {
    if (gender == _selectedGender || gender == _originalGender) {
      setState(() => _selectedGender = gender);
      return;
    }

    setState(() => _selectedGender = gender);
    final choice = await showDialog<_GenderChangeChoice>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Change avatar gender?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Choose how you want to update your profile for this gender.',
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, _GenderChangeChoice.cancel),
              child: const Text('Cancel changing'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(
                dialogContext,
                _GenderChangeChoice.capturePhotos,
              ),
              child: const Text('Continue changing avatar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(
                dialogContext,
                _GenderChangeChoice.useDefaultAvatar,
              ),
              child: const Text('Use default avatar for new gender'),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;

    if (choice == null || choice == _GenderChangeChoice.cancel) {
      setState(() => _selectedGender = _originalGender ?? gender);
      return;
    }

    await _saveGenderAndAvatar(gender);
    if (!mounted || choice == _GenderChangeChoice.useDefaultAvatar) return;

    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ThirdScreen(
          genderChanged: true,
          initialGender: gender,
          showDefaultAvatar: true,
        ),
      ),
    );
  }

  Future<void> _saveGenderAndAvatar(String gender) async {
    await context.read<SessionState>().updateProfile((profile) {
      if (profile.selfiePath != null && profile.selfieGender == null) {
        profile.selfieGender = profile.gender ?? 'Unknown';
      }
      if (profile.bodyPhotoPaths.values.any((path) => path != null) &&
          profile.bodyPhotoGender == null) {
        profile.bodyPhotoGender = profile.gender ?? 'Unknown';
      }
      profile.gender = gender;
      profile.useAvatarInsteadOfPhoto = true;
    });
    _originalGender = gender;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<SessionState>().currentUser;
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
                  'YOUR STYLE PORTRAIT',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.0,
                    color: Color(0xFF888077),
                  ),
                ),

                const SizedBox(height: 8),

                // Main Title
                const Text(
                  'Your Virtual Avatar',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF201D19),
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Avatar gender',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF201D19),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _genderChoice('Male'),
                    const SizedBox(width: 12),
                    _genderChoice('Female'),
                  ],
                ),
                const SizedBox(height: 20),

                // Avatar previews: portrait and front profile.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 108,
                      child: _buildAvatarImage(
                        imagePath: user?.selfiePath,
                        photoGender: user?.selfieGender,
                        useAvatar: user?.useAvatarInsteadOfPhoto ?? true,
                        profile: 'portrait',
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 106,
                      child: _buildAvatarImage(
                        imagePath: user?.bodyPhotoPaths['front'],
                        photoGender: user?.bodyPhotoGender,
                        useAvatar: user?.useAvatarInsteadOfPhoto ?? true,
                        profile: 'front',
                      ),
                    ),
                    const Spacer(flex: 30),
                  ],
                ),

                const SizedBox(height: 22),

                const Divider(
                  color: Color(0xFFD6CFC4),
                  height: 1,
                  thickness: 1,
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Your avatar profile is up to date.'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3E3129),
                      foregroundColor: const Color(0xFFF5F3EC),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text('Save avatar profile'),
                  ),
                ),
                const SizedBox(height: 14),

                // Change Uploaded Photos for Face Button
                _buildOutlinedActionButton(
                  label: 'Change Uploaded Photos for Face',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ThirdScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 14),

                // Change Uploaded Photos for Figure Button
                _buildOutlinedActionButton(
                  label: 'Change Uploaded Photos for Figure',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FourthScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 22),

                // Footer Disclaimer
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Center(
                    child: Text(
                      'Your avatar is a visual preview, not an exact representation of body shape or garment fit.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF7C746C),
                        height: 1.45,
                      ),
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

  Widget _genderChoice(String gender) {
    final selected = _selectedGender == gender;
    return Expanded(
      child: GestureDetector(
        onTap: () => _selectGender(gender),
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF4C5547) : const Color(0xFFEFECE4),
            borderRadius: BorderRadius.circular(6),
            border: selected
                ? null
                : Border.all(color: const Color(0xFFCDC6BA)),
          ),
          child: Text(
            gender,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected
                  ? const Color(0xFFF5F3EC)
                  : const Color(0xFF201D19),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarImage({
    required String? imagePath,
    required String? photoGender,
    required bool useAvatar,
    required String profile,
  }) {
    final photoMatchesGender =
        photoGender == null || photoGender == _selectedGender;
    return AspectRatio(
      aspectRatio: 108 / 154,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: !useAvatar && imagePath != null && photoMatchesGender
            ? SecureImage(
                fileName: imagePath,
                placeholder: DefaultAvatar(
                  gender: _selectedGender,
                  profile: profile,
                  showLabel: true,
                ),
              )
            : DefaultAvatar(
                gender: _selectedGender,
                profile: profile,
                showLabel: true,
              ),
      ),
    );
  }

  Widget _buildOutlinedActionButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFFF5F3EC),
          foregroundColor: const Color(0xFF201D19),
          side: const BorderSide(color: Color(0xFF8C8278), width: 1.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.0),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF201D19),
          ),
        ),
      ),
    );
  }
}
