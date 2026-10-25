import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import 'fashion_try_on.dart';
import 'complete_the_look.dart';

class FourteenthScreen extends StatefulWidget {
  const FourteenthScreen({super.key});

  @override
  State<FourteenthScreen> createState() => _FourteenthScreenState();
}

class _FourteenthScreenState extends State<FourteenthScreen> {
  String _selectedPromptTag = 'Dinner tonight';

  final TextEditingController _chatController = TextEditingController();
  final TextEditingController _occasionController =
      TextEditingController(text: 'Dinner');
  final TextEditingController _budgetController =
      TextEditingController(text: 'Under ₹10,000');

  static const String _outfitImageUrl =
      'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=500&q=80';

  @override
  void dispose() {
    _chatController.dispose();
    _occasionController.dispose();
    _budgetController.dispose();
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

                // Top Bar: Back | EVOQE Logo | Shopping Bag Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF201D19),
                        size: 24,
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

                // Title & Sparkles AI Icon Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: Text(
                        'Your private stylist.',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 30,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF201D19),
                          letterSpacing: -0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
                      Icons.auto_awesome_outlined,
                      size: 24,
                      color: Color(0xFF201D19),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Subtitle
                const Text(
                  'Demo conversation · illustrative styling suggestions',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888077),
                  ),
                ),

                const SizedBox(height: 16),

                // Active Filter Pills
                Row(
                  children: [
                    _buildPillTag('Dinner'),
                    const SizedBox(width: 10),
                    _buildPillTag('Under ₹10,000'),
                  ],
                ),

                const SizedBox(height: 20),

                // User Message Box ("YOU")
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'YOU',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                        color: Color(0xFF888077),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2DDD3),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: const Text(
                        'I need an elegant dinner look that feels modern and minimal.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF201D19),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // AI Assistant Response Box ("EVOQE STYLIST")
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'EVOQE STYLIST',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                        color: Color(0xFF888077),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: const Text(
                        'Let\'s explore a tailored silhouette, understated jewelry, and a warm neutral palette.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF201D19),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Stylist Recommendation Outfit Card
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFECE4),
                    borderRadius: BorderRadius.circular(4.0),
                    border: Border.all(
                      color: const Color(0xFFCDC6BA),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Model Outfit Image
                      Expanded(
                        flex: 4,
                        child: AspectRatio(
                          aspectRatio: 0.78,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.0),
                              color: const Color(0xFFE2DDD3),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.network(
                              _outfitImageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: const Color(0xFFDDD7CC),
                                child: const Icon(
                                  Icons.person_outline_rounded,
                                  size: 32,
                                  color: Color(0xFF8C8278),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Outfit Details
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'The considered evening',
                              style: TextStyle(
                                fontFamily: 'serif',
                                fontSize: 19,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF201D19),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Ivory tailoring · espresso flats\nGold hoops · warm rose lips',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF888077),
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '6 pieces · estimated ₹9,500',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF201D19),
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const TwelfthScreen(),
                                  ),
                                );
                              },
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Explore the coordinated edit',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF5A544D),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 2),
                                  Icon(
                                    Icons.north_east_rounded,
                                    size: 11,
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
                ),

                const SizedBox(height: 12),

                // Controls Bar: Regenerate | Refine | Try On ↗
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: const Row(
                        children: [
                          Icon(
                            Icons.refresh_rounded,
                            size: 14,
                            color: Color(0xFF201D19),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Regenerate',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF201D19),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'Refine',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF201D19),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NinthScreen(),
                          ),
                        );
                      },
                      child: const Row(
                        children: [
                          Text(
                            'Try On',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF201D19),
                            ),
                          ),
                          SizedBox(width: 2),
                          Icon(
                            Icons.north_east_rounded,
                            size: 11,
                            color: Color(0xFF201D19),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Chat Input Box Field
                TextField(
                  controller: _chatController,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF201D19),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Tell me what you have in mind...',
                    hintStyle: const TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF888077),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFEFECE4),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    suffixIcon: Container(
                      margin: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF3E3129),
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      ),
                      child: const Icon(
                        Icons.arrow_upward_rounded,
                        color: Color(0xFFF5F3EC),
                        size: 18,
                      ),
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

                const SizedBox(height: 36),

                // Section Title: Start with a feeling
                const Text(
                  'Start with a feeling',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF201D19),
                  ),
                ),

                const SizedBox(height: 16),

                // Prompt Tags Wraps
                Wrap(
                  spacing: 10.0,
                  runSpacing: 10.0,
                  children: [
                    'Dinner tonight',
                    'Under ₹10,000',
                    'Refresh my workwear',
                    'Style one piece',
                  ].map((tag) {
                    final isSelected = tag == _selectedPromptTag;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPromptTag = tag;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF4C5547)
                              : const Color(0xFFEFECE4),
                          borderRadius: BorderRadius.circular(6.0),
                          border: isSelected
                              ? null
                              : Border.all(
                                  color: const Color(0xFFCDC6BA),
                                  width: 1.0,
                                ),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? const Color(0xFFF5F3EC)
                                : const Color(0xFF201D19),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // Subtitle Note
                const Text(
                  'Sample prompts for a private styling conversation.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888077),
                  ),
                ),

                const SizedBox(height: 20),

                // Occasion Shortcut Input Field
                const Text(
                  'Occasion shortcut',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6E6760),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _occasionController,
                  style: const TextStyle(
                    fontSize: 14,
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

                const SizedBox(height: 16),

                // Budget Shortcut Input Field
                const Text(
                  'Budget shortcut',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6E6760),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _budgetController,
                  style: const TextStyle(
                    fontSize: 14,
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

                const SizedBox(height: 24),

                // Refine This Look Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFEFECE4),
                      foregroundColor: const Color(0xFF201D19),
                      side: const BorderSide(
                        color: Color(0xFFCDC6BA),
                        width: 1.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Refine this look',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF201D19),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPillTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEFECE4),
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(
          color: const Color(0xFFCDC6BA),
          width: 1.0,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
          color: Color(0xFF201D19),
        ),
      ),
    );
  }
}
