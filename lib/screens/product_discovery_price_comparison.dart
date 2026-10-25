import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import 'fashion_try_on.dart';
import 'retailer_checkout_1.dart';

class NineteenthScreen extends StatelessWidget {
  const NineteenthScreen({super.key});

  static const String _waistcoatImageUrl =
      'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?auto=format&fit=crop&w=500&q=80';

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

                // Eyebrow Label
                const Text(
                  'FIND THE FEELING',
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
                  'Finalize Your Wishlist.',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF201D19),
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 6),

                // Subtitle
                const Text(
                  'Illustrative products · sample prices',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888077),
                  ),
                ),

                const SizedBox(height: 20),

                // Featured Comparison Card
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Thumbnail
                    Expanded(
                      flex: 4,
                      child: AspectRatio(
                        aspectRatio: 0.9,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.0),
                            color: const Color(0xFFE2DDD3),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.network(
                            _waistcoatImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: const Color(0xFFDDD7CC),
                              child: const Icon(
                                Icons.image_outlined,
                                size: 32,
                                color: Color(0xFF8C8278),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Product Information
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Linen waistcoat',
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF201D19),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Vale · Maison Vale',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF888077),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            '₹2,400',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF201D19),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Ivory · S–L · sample',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF888077),
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
                              children: [
                                Text(
                                  'View product page',
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
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Description Note below card
                const Text(
                  'Similar ivory palette, linen texture and clean four-button front.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6E6760),
                    height: 1.35,
                  ),
                ),

                const SizedBox(height: 16),

                const Divider(
                  color: Color(0xFFD6CFC4),
                  height: 1,
                  thickness: 1,
                ),

                const SizedBox(height: 16),

                // View All Products Action Link
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'View All Products',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF201D19),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Section Title: Your complete look
                const Text(
                  'Your complete look',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF201D19),
                  ),
                ),

                const SizedBox(height: 16),

                // Item 1: Linen waistcoat
                _buildLookItemRow(
                  title: 'Linen waistcoat',
                  price: '₹2,400',
                ),

                // Item 2: Tailored trouser
                _buildLookItemRow(
                  title: 'Tailored trouser',
                  price: '₹2,200',
                ),

                const SizedBox(height: 20),

                // View Final Wishlist Action Link
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'View Final Wishlist',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF201D19),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Estimated Total Header Row
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      'Estimated total',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 28,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF201D19),
                      ),
                    ),
                    Text(
                      '₹9,500',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF201D19),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Excludes shipping disclaimer
                const Text(
                  'Excludes shipping, taxes and retailer adjustments.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF888077),
                  ),
                ),

                const SizedBox(height: 24),

                // Wish to Buy Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TwentiethScreen(),
                        ),
                      );
                    },
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
                      'Wish to Buy',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF201D19),
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

  Widget _buildLookItemRow({
    required String title,
    required String price,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF201D19),
                ),
              ),
              Row(
                children: [
                  Text(
                    '$price · Replace',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF6E6760),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: Color(0xFF201D19),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(
          color: Color(0xFFD6CFC4),
          height: 1,
          thickness: 1,
        ),
      ],
    );
  }
}
