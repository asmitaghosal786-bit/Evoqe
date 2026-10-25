import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import 'product_discovery_price_comparison.dart';

class TwentiethScreen extends StatefulWidget {
  const TwentiethScreen({super.key});

  @override
  State<TwentiethScreen> createState() => _TwentiethScreenState();
}

class _TwentiethScreenState extends State<TwentiethScreen> {
  // Selection state for Item 1 (Waistcoat): true = keep original, false = choose suggestion
  bool _waistcoatKeepOriginal = true;
  // Selection state for Item 2 (Trouser): true = keep original, false = choose suggestion
  bool _trouserKeepOriginal = true;

  static const String _waistcoatImageUrl =
      'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?auto=format&fit=crop&w=500&q=80';
  static const String _trouserImageUrl =
      'https://images.unsplash.com/photo-1509631179647-0177331693ae?auto=format&fit=crop&w=500&q=80';

  @override
  Widget build(BuildContext context) {
    final int waistcoatPrice = _waistcoatKeepOriginal ? 2400 : 1900;
    final int trouserPrice = _trouserKeepOriginal ? 2200 : 1900;
    final int sampleTotal = waistcoatPrice + trouserPrice;

    int suggestionsChosen = 0;
    if (!_waistcoatKeepOriginal) suggestionsChosen++;
    if (!_trouserKeepOriginal) suggestionsChosen++;

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

                // Eyebrow Label
                const Text(
                  'A CONSIDERED CHOICE',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2,
                    color: Color(0xFF888077),
                  ),
                ),

                const SizedBox(height: 6),

                // Main Title
                const Text(
                  'A better deal, perhaps.',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF201D19),
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle
                const Text(
                  'Compare your saved pieces. Suggestions are optional; nothing is replaced unless you choose.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF6E6760),
                    height: 1.35,
                  ),
                ),

                const SizedBox(height: 24),

                // Product Item 1: Linen Waistcoat
                _buildProductDealItem(
                  imageUrl: _waistcoatImageUrl,
                  title: 'Linen waistcoat',
                  savedChoice: 'Saved choice · Maison Vale',
                  originalPrice: '₹2,400',
                  originalDetails: 'Ivory · M · Original item',
                  keepOriginal: _waistcoatKeepOriginal,
                  onToggleKeepOriginal: (val) {
                    setState(() {
                      _waistcoatKeepOriginal = val;
                    });
                  },
                  suggestionTitle: 'Choose suggestion',
                  suggestionDetails: 'Atelier Noma · Linen-blend vest\nSimilar, not identical · Save ₹500',
                  suggestionPrice: '₹1,900',
                ),

                const SizedBox(height: 16),
                const Divider(color: Color(0xFFD6CFC4), height: 1, thickness: 1),
                const SizedBox(height: 16),

                // Product Item 2: Tailored Trouser
                _buildProductDealItem(
                  imageUrl: _trouserImageUrl,
                  title: 'Tailored trouser',
                  savedChoice: 'Saved choice · Maison Vale',
                  originalPrice: '₹2,200',
                  originalDetails: 'Taupe · M · Original item',
                  keepOriginal: _trouserKeepOriginal,
                  onToggleKeepOriginal: (val) {
                    setState(() {
                      _trouserKeepOriginal = val;
                    });
                  },
                  suggestionTitle: 'Choose suggestion',
                  suggestionDetails: 'Rive Studio · Relaxed trouser\nSimilar cut, not identical · Save ₹300',
                  suggestionPrice: '₹1,900',
                ),

                const SizedBox(height: 20),
                const Divider(color: Color(0xFFD6CFC4), height: 1, thickness: 1),
                const SizedBox(height: 20),

                // Summary Total Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Text(
                      '2 selected · sample total',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF6E6760),
                      ),
                    ),
                    Text(
                      '₹$sampleTotal',
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF201D19),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _waistcoatKeepOriginal && _trouserKeepOriginal
                      ? 'Both originals kept · Save ₹800 if you choose both suggestions'
                      : suggestionsChosen == 2
                          ? 'Both suggestions chosen · You saved ₹800'
                          : '1 suggestion chosen · Save more if you choose both',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888077),
                  ),
                ),

                const SizedBox(height: 24),

                // Disclaimer Text
                const Text(
                  'Demo prices · fictional retailers · shipping extra. Sizes & availability unverified. Not a live market feed.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF888077),
                    height: 1.35,
                  ),
                ),

                const SizedBox(height: 28),

                // Continue to Finalize Wishlist Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NineteenthScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3E3129),
                      foregroundColor: const Color(0xFFF5F3EC),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Continue to Finalize Wishlist',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.1,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductDealItem({
    required String imageUrl,
    required String title,
    required String savedChoice,
    required String originalPrice,
    required String originalDetails,
    required bool keepOriginal,
    required ValueChanged<bool> onToggleKeepOriginal,
    required String suggestionTitle,
    required String suggestionDetails,
    required String suggestionPrice,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Thumbnail
            Container(
              width: 90,
              height: 110,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                color: const Color(0xFFE2DDD3),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFFDDD7CC),
                  child: const Icon(
                    Icons.image_outlined,
                    size: 28,
                    color: Color(0xFF8C8278),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Product Details & Original Option
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF201D19),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    savedChoice,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF888077),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        originalPrice,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF201D19),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    originalDetails,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF888077),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => onToggleKeepOriginal(true),
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF3E3129),
                              width: 1.5,
                            ),
                          ),
                          child: keepOriginal
                              ? Center(
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF3E3129),
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Keep original',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF201D19),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Suggestion Option Row
        GestureDetector(
          onTap: () => onToggleKeepOriginal(false),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF3E3129),
                    width: 1.5,
                  ),
                ),
                child: !keepOriginal
                    ? Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF3E3129),
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          suggestionTitle,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF201D19),
                          ),
                        ),
                        Text(
                          suggestionPrice,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF201D19),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      suggestionDetails,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF888077),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
