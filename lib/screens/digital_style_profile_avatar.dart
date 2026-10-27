import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/session_state.dart';
import 'welcome_screen.dart';
import 'selfie_capture.dart';
import 'full_body_capture.dart';

class SeventhScreen extends StatefulWidget {
  const SeventhScreen({super.key});

  @override
  State<SeventhScreen> createState() => _SeventhScreenState();
}

class _SeventhScreenState extends State<SeventhScreen> {
  // Portrait (close-up) and full-body avatar previews
  static const String _portraitImageUrl =
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=500&q=80';
  static const String _fullBodyImageUrl =
      'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=500&q=80';

  void _showEditAvatarBottomSheet(BuildContext context) {
    final session = context.read<SessionState>();
    final user = session.currentUser;

    final heightController = TextEditingController(text: user?.heightCm?.toString() ?? '');
    final weightController = TextEditingController(text: user?.weightKg?.toString() ?? '');
    final clothingController = TextEditingController(text: user?.clothingSize ?? '');
    final bustController = TextEditingController(text: user?.bustSize ?? '');
    final hipController = TextEditingController(text: user?.hipSize ?? '');
    final shoeController = TextEditingController(text: user?.shoeSize ?? '');
    int? selectedFitIndex = user?.fitIndex;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF5F3EC),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit Avatar Details',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF201D19),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: heightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Height (cm)', filled: true, fillColor: Color(0xFFEFECE4)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: weightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Weight (kg)', filled: true, fillColor: Color(0xFFEFECE4)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: clothingController,
                        decoration: const InputDecoration(labelText: 'Clothing size', filled: true, fillColor: Color(0xFFEFECE4)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: shoeController,
                        decoration: const InputDecoration(labelText: 'Shoe size', filled: true, fillColor: Color(0xFFEFECE4)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: bustController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Bust size', filled: true, fillColor: Color(0xFFEFECE4)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: hipController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Hip size', filled: true, fillColor: Color(0xFFEFECE4)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Fit Preference', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF6E6760))),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildFitOption('Relaxed', 0, selectedFitIndex, (i) => setModalState(() => selectedFitIndex = i)),
                    const SizedBox(width: 8),
                    _buildFitOption('Tailored', 1, selectedFitIndex, (i) => setModalState(() => selectedFitIndex = i)),
                    const SizedBox(width: 8),
                    _buildFitOption('Close-fitting', 2, selectedFitIndex, (i) => setModalState(() => selectedFitIndex = i)),
                  ],
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
                      await session.updateProfile((p) {
                        p.heightCm = double.tryParse(heightController.text.trim());
                        p.weightKg = double.tryParse(weightController.text.trim());
                        p.clothingSize = clothingController.text.trim().isEmpty ? null : clothingController.text.trim();
                        p.bustSize = bustController.text.trim().isEmpty ? null : bustController.text.trim();
                        p.hipSize = hipController.text.trim().isEmpty ? null : hipController.text.trim();
                        p.shoeSize = shoeController.text.trim().isEmpty ? null : shoeController.text.trim();
                        p.fitIndex = selectedFitIndex;
                      });
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Avatar details updated successfully')),
                        );
                      }
                    },
                    child: const Text('Save Avatar Details', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFitOption(String title, int index, int? selectedIndex, ValueChanged<int?> onTap) {
    final isSelected = index == selectedIndex;
    return GestureDetector(
      onTap: () => onTap(isSelected ? null : index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4C5547) : const Color(0xFFEFECE4),
          borderRadius: BorderRadius.circular(6.0),
          border: isSelected ? null : Border.all(color: const Color(0xFFCDC6BA)),
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

                const SizedBox(height: 20),

                // Avatar Previews: Portrait + Full Body
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 108,
                      child: _buildAvatarImage(
                        imageUrl: _portraitImageUrl,
                        fallbackIcon: Icons.person_outline_rounded,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 106,
                      child: _buildAvatarImage(
                        imageUrl: _fullBodyImageUrl,
                        fallbackIcon: Icons.accessibility_new_rounded,
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

                const SizedBox(height: 14),

                // Edit Avatar Details Button
                _buildOutlinedActionButton(
                  label: 'Edit Avatar Details',
                  onPressed: () => _showEditAvatarBottomSheet(context),
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

  Widget _buildAvatarImage({
    required String imageUrl,
    required IconData fallbackIcon,
  }) {
    return AspectRatio(
      aspectRatio: 108 / 154,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2.0),
          color: const Color(0xFFE2DDD3),
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: const Color(0xFFDDD7CC),
            child: Center(
              child: Icon(
                fallbackIcon,
                size: 40,
                color: const Color(0xFF8C8278),
              ),
            ),
          ),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: const Color(0xFFDDD7CC),
              child: const Center(
                child: Icon(
                  Icons.image_outlined,
                  size: 32,
                  color: Color(0xFF8C8278),
                ),
              ),
            );
          },
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
          side: const BorderSide(
            color: Color(0xFF8C8278),
            width: 1.0,
          ),
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
