import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import 'fashion_try_on.dart';

class FourteenthScreen extends StatefulWidget {
  const FourteenthScreen({super.key});

  @override
  State<FourteenthScreen> createState() => _FourteenthScreenState();
}

class _FourteenthScreenState extends State<FourteenthScreen> {
  bool _isOutfitSaved = false;

  final TextEditingController _chatController = TextEditingController();
  final TextEditingController _occasionController =
      TextEditingController(text: 'Dinner');
  final TextEditingController _budgetController =
      TextEditingController(text: 'Under ₹10,000');
  final TextEditingController _aestheticController =
      TextEditingController(text: 'Formal');
  final TextEditingController _itemNeededController =
      TextEditingController(text: 'Suit');

  static const String _outfitImageUrl =
      'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=500&q=80';

  @override
  void dispose() {
    _chatController.dispose();
    _occasionController.dispose();
    _budgetController.dispose();
    _aestheticController.dispose();
    _itemNeededController.dispose();
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Expanded(
                                  child: Text(
                                    'The formal dinner',
                                    style: TextStyle(
                                      fontFamily: 'serif',
                                      fontSize: 19,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF201D19),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isOutfitSaved = !_isOutfitSaved;
                                    });
                                  },
                                  child: Icon(
                                    _isOutfitSaved
                                        ? Icons.bookmark_rounded
                                        : Icons.bookmark_border_rounded,
                                    size: 18,
                                    color: const Color(0xFF201D19),
                                  ),
                                ),
                              ],
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
                              onTap: () {},
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.refresh_rounded,
                                    size: 12,
                                    color: Color(0xFF5A544D),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Regenerate new look',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF5A544D),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
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
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Try on the coordinated edit',
                                      style: TextStyle(
                                        fontSize: 11.5,
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

                const SizedBox(height: 16),

                // Refresh Button Row outside card
                GestureDetector(
                  onTap: () {},
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        size: 16,
                        color: Color(0xFF201D19),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Refresh',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF201D19),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Occasion Shortcut Input Field
                const Text(
                  'Occasion',
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
                  'Budget',
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

                const SizedBox(height: 16),

                // Aesthetic Input Field
                const Text(
                  'Aesthetic',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6E6760),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _aestheticController,
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

                // Item Needed Input Field
                const Text(
                  'Item Needed',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6E6760),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _itemNeededController,
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

                // Chat Input Field
                const Text(
                  'Chat here with our assistant',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6E6760),
                  ),
                ),
                const SizedBox(height: 6),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
