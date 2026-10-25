import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import 'retailer_checkout_2.dart';

class TwentiethScreen extends StatefulWidget {
  const TwentiethScreen({super.key});

  @override
  State<TwentiethScreen> createState() => _TwentiethScreenState();
}

class _TwentiethScreenState extends State<TwentiethScreen> {
  int _waistcoatQty = 1;
  int _trouserQty = 1;
  int _hoopsQty = 1;

  static const String _waistcoatUrl =
      'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?auto=format&fit=crop&w=300&q=80';
  static const String _trouserUrl =
      'https://images.unsplash.com/photo-1509631179647-0177331693ae?auto=format&fit=crop&w=300&q=80';
  static const String _hoopsUrl =
      'https://images.unsplash.com/photo-1630019852942-f89202989a59?auto=format&fit=crop&w=300&q=80';

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
                  'YOUR CHOSEN PIECES',
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
                  'The shopping bag.',
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
                  '3 illustrative items · sample prices',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF888077),
                  ),
                ),

                const SizedBox(height: 20),

                // Item 1: Linen waistcoat
                _buildBagItemCard(
                  imageUrl: _waistcoatUrl,
                  title: 'Linen waistcoat',
                  subtitle: 'Maison Vale · sample product',
                  spec: 'Ivory · M',
                  price: '₹2,400',
                  quantity: _waistcoatQty,
                  onIncrement: () => setState(() => _waistcoatQty++),
                  onDecrement: () {
                    if (_waistcoatQty > 1) {
                      setState(() => _waistcoatQty--);
                    }
                  },
                ),

                // Item 2: Tailored trouser
                _buildBagItemCard(
                  imageUrl: _trouserUrl,
                  title: 'Tailored trouser',
                  subtitle: 'Maison Vale · sample product',
                  spec: 'Taupe · M',
                  price: '₹2,200',
                  quantity: _trouserQty,
                  onIncrement: () => setState(() => _trouserQty++),
                  onDecrement: () {
                    if (_trouserQty > 1) {
                      setState(() => _trouserQty--);
                    }
                  },
                ),

                // Item 3: Sculpted gold hoops
                _buildBagItemCard(
                  imageUrl: _hoopsUrl,
                  title: 'Sculpted gold hoops',
                  subtitle: 'Forme Studio · sample product',
                  spec: 'Gold tone · 18 mm',
                  price: '₹850',
                  quantity: _hoopsQty,
                  onIncrement: () => setState(() => _hoopsQty++),
                  onDecrement: () {
                    if (_hoopsQty > 1) {
                      setState(() => _hoopsQty--);
                    }
                  },
                ),

                const SizedBox(height: 20),

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
                      '₹5,450',
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

                // Subtext disclaimer
                const Text(
                  'Shipping unavailable · taxes not included',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888077),
                  ),
                ),

                const SizedBox(height: 24),

                // Primary CTA: Proceed to Retailer ↗
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TwentyFirstScreen(),
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
                          'Proceed to Retailer',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.north_east_rounded,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Footer Disclaimer Note
                const Text(
                  'Separate retailer checkout. Final prices and delivery are confirmed by each retailer.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF888077),
                    height: 1.35,
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

  Widget _buildBagItemCard({
    required String imageUrl,
    required String title,
    required String subtitle,
    required String spec,
    required String price,
    required int quantity,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Thumbnail
              Container(
                width: 72,
                height: 72,
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
                      size: 32,
                      color: Color(0xFF8C8278),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Item Details & Controls
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
                        GestureDetector(
                          onTap: () {},
                          child: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: Color(0xFF201D19),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF888077),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      spec,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF888077),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: onDecrement,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.0),
                                child: Text(
                                  '-',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF201D19),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$quantity',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF201D19),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: onIncrement,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.0),
                                child: Text(
                                  '+',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF201D19),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          price,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF201D19),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
