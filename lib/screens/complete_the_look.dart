import 'package:flutter/material.dart';
import 'welcome_screen.dart';

class TwelfthScreen extends StatefulWidget {
  const TwelfthScreen({super.key});

  @override
  State<TwelfthScreen> createState() => _TwelfthScreenState();
}

class _TwelfthScreenState extends State<TwelfthScreen> {
  bool _isWaistcoatFavorited = false;
  bool _isTrouserFavorited = false;

  static const String _outfitModelUrl =
      'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=500&q=80';
  static const String _flatlayAccessoriesUrl =
      'https://images.unsplash.com/photo-1548883354-7622d03aca27?auto=format&fit=crop&w=500&q=80';
  static const String _waistcoatUrl =
      'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?auto=format&fit=crop&w=500&q=80';
  static const String _trouserUrl =
      'https://images.unsplash.com/photo-1509631179647-0177331693ae?auto=format&fit=crop&w=500&q=80';

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

                // Main Title
                const Text(
                  'Everything, in harmony.',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF201D19),
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 20),

                // Hero Outfit Grid (Model + Accessories Flatlay)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column: Model Card
                    Expanded(
                      flex: 6,
                      child: AspectRatio(
                        aspectRatio: 0.78,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.0),
                            color: const Color(0xFFE2DDD3),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.network(
                            _outfitModelUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: const Color(0xFFDDD7CC),
                              child: const Icon(
                                Icons.person_outline_rounded,
                                size: 36,
                                color: Color(0xFF8C8278),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Right Column: Accessories Flatlay & Details
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AspectRatio(
                            aspectRatio: 1.0,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.0),
                                color: const Color(0xFFE2DDD3),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Image.network(
                                _flatlayAccessoriesUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  color: const Color(0xFFDDD7CC),
                                  child: const Icon(
                                    Icons.checkroom_outlined,
                                    size: 32,
                                    color: Color(0xFF8C8278),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            '6 pieces',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6E6760),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Sample total ₹9,500',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF888077),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Action Buttons Row: "Try On Avatar" & "Customize"
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3E3129),
                            foregroundColor: const Color(0xFFF5F3EC),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          ),
                          child: const Text(
                            'Try On Avatar',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
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
                            'Customize',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF201D19),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Section Header: Coordinated Pieces
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Your coordinated pieces',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF201D19),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: const Row(
                        children: [
                          Text(
                            'SEE ALL',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                              color: Color(0xFF5A544D),
                            ),
                          ),
                          SizedBox(width: 2),
                          Icon(
                            Icons.north_east_rounded,
                            size: 12,
                            color: Color(0xFF5A544D),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Coordinated Product Grid
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildCoordinatedItem(
                        imageUrl: _waistcoatUrl,
                        title: 'Linen waistcoat',
                        brand: 'Maison Vale',
                        price: '₹2,400',
                        isFavorited: _isWaistcoatFavorited,
                        onFavoriteToggle: () {
                          setState(() {
                            _isWaistcoatFavorited = !_isWaistcoatFavorited;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildCoordinatedItem(
                        imageUrl: _trouserUrl,
                        title: 'Fluid tailored trouser',
                        brand: 'Maison Vale',
                        price: '₹2,200',
                        isFavorited: _isTrouserFavorited,
                        onFavoriteToggle: () {
                          setState(() {
                            _isTrouserFavorited = !_isTrouserFavorited;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoordinatedItem({
    required String imageUrl,
    required String title,
    required String brand,
    required String price,
    required bool isFavorited,
    required VoidCallback onFavoriteToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 0.95,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
              color: const Color(0xFFE2DDD3),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Positioned.fill(
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
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onFavoriteToggle,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF5F3EC),
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      ),
                      child: Icon(
                        isFavorited
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 16,
                        color: isFavorited
                            ? const Color(0xFF8B2626)
                            : const Color(0xFF201D19),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            color: Color(0xFF201D19),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          brand,
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
              price,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF201D19),
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: const Row(
                children: [
                  Text(
                    'Replace',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF5A544D),
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(
                    Icons.north_east_rounded,
                    size: 12,
                    color: Color(0xFF5A544D),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
