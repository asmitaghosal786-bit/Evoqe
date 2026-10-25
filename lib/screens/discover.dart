import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import 'home_screen.dart';
import 'fashion_try_on.dart';
import 'jewelry_try_on.dart';
import 'makeup_try_on.dart';
import 'lookbook.dart';
import 'saved_looks.dart';

class ThirteenthScreen extends StatefulWidget {
  const ThirteenthScreen({super.key});

  @override
  State<ThirteenthScreen> createState() => _ThirteenthScreenState();
}

class _ThirteenthScreenState extends State<ThirteenthScreen> {
  int _selectedBottomNavIndex = 1; // Discover tab active
  int _selectedCategoryIndex = 0; // "Outfits" active

  final TextEditingController _searchController = TextEditingController();
  final Set<String> _savedProductTitles = {};

  final List<String> _categories = const [
    'Outfits',
    'Make-up',
    'Jewlery',
  ];

  final Map<int, List<Map<String, String>>> _categoryProducts = {
    0: [
      {
        'title': 'Linen waistcoat',
        'brand': 'Maison Vale',
        'price': '₹2,400',
        'imageUrl':
            'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?auto=format&fit=crop&w=500&q=80',
      },
      {
        'title': 'The sculpted blazer',
        'brand': 'Atelier Nine',
        'price': '₹4,800',
        'imageUrl':
            'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=500&q=80',
      },
      {
        'title': 'Fluid tailored trouser',
        'brand': 'Maison Vale',
        'price': '₹2,200',
        'imageUrl':
            'https://images.unsplash.com/photo-1509631179647-0177331693ae?auto=format&fit=crop&w=500&q=80',
      },
      {
        'title': 'Draped silk blouse',
        'brand': 'Linen & Line',
        'price': '₹3,100',
        'imageUrl':
            'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=500&q=80',
      },
      {
        'title': 'Arc shoulder bag',
        'brand': 'Atelier Nine',
        'price': '₹1,800',
        'imageUrl':
            'https://images.unsplash.com/photo-1548883354-7622d03aca27?auto=format&fit=crop&w=500&q=80',
      },
      {
        'title': 'The pointed flat',
        'brand': 'Linen & Line',
        'price': '₹1,600',
        'imageUrl':
            'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?auto=format&fit=crop&w=500&q=80',
      },
    ],
    1: [
      {
        'title': 'Velvet matte lipstick',
        'brand': 'Maison Beauty',
        'price': '₹1,200',
        'imageUrl':
            'https://images.unsplash.com/photo-1586495777744-4413f21062fa?auto=format&fit=crop&w=500&q=80',
      },
      {
        'title': 'Luminous skin tint',
        'brand': 'Atelier Glow',
        'price': '₹2,100',
        'imageUrl':
            'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=500&q=80',
      },
      {
        'title': 'Sculpting bronzer palette',
        'brand': 'Forme Make-up',
        'price': '₹2,800',
        'imageUrl':
            'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?auto=format&fit=crop&w=500&q=80',
      },
      {
        'title': 'Rose petal blush',
        'brand': 'Maison Beauty',
        'price': '₹1,500',
        'imageUrl':
            'https://images.unsplash.com/photo-1596704017254-9b121068fb31?auto=format&fit=crop&w=500&q=80',
      },
      {
        'title': 'Precision eye defining pen',
        'brand': 'Atelier Glow',
        'price': '₹950',
        'imageUrl':
            'https://images.unsplash.com/photo-1571781926291-c477ebfd024b?auto=format&fit=crop&w=500&q=80',
      },
      {
        'title': 'Dewy highlighter glow',
        'brand': 'Forme Make-up',
        'price': '₹1,800',
        'imageUrl':
            'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?auto=format&fit=crop&w=500&q=80',
      },
    ],
    2: [
      {
        'title': 'Sculpted gold hoops',
        'brand': 'Forme Studio',
        'price': '₹850',
        'imageUrl':
            'https://images.unsplash.com/photo-1630019852942-f89202989a59?auto=format&fit=crop&w=500&q=80',
      },
      {
        'title': 'Layered chain necklace',
        'brand': 'Aura Jewels',
        'price': '₹3,400',
        'imageUrl':
            'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?auto=format&fit=crop&w=500&q=80',
      },
      {
        'title': 'Signet statement ring',
        'brand': 'Forme Studio',
        'price': '₹1,500',
        'imageUrl':
            'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?auto=format&fit=crop&w=500&q=80',
      },
      {
        'title': 'Pearl drop earrings',
        'brand': 'Aura Jewels',
        'price': '₹2,600',
        'imageUrl':
            'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?auto=format&fit=crop&w=500&q=80',
      },
      {
        'title': 'Geometric cuff bracelet',
        'brand': 'Forme Studio',
        'price': '₹1,900',
        'imageUrl':
            'https://images.unsplash.com/photo-1611591475271-18e472620a23?auto=format&fit=crop&w=500&q=80',
      },
      {
        'title': 'Delicate pavé band',
        'brand': 'Aura Jewels',
        'price': '₹2,200',
        'imageUrl':
            'https://images.unsplash.com/photo-1605100804763-247f67b3557e?auto=format&fit=crop&w=500&q=80',
      },
    ],
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentProducts = _categoryProducts[_selectedCategoryIndex] ?? _categoryProducts[0]!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Top Bar: EVOQE Logo | Shopping Bag Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 24), // Empty space balancing shopping bag
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

              const SizedBox(height: 20),

              // Main Title
              const Text(
                'Discover your next piece.',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF201D19),
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: 12),

              // Eyebrow Label
              const Text(
                'BASED ON YOUR STYLE',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                  color: Color(0xFF888077),
                ),
              ),

              const SizedBox(height: 8),

              // Search Box Field (Stable)
              TextField(
                controller: _searchController,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF201D19),
                ),
                decoration: InputDecoration(
                  hintText: 'Search clothing, styles or textures',
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
                  suffixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF201D19),
                    size: 20,
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

              // Category Tabs Row (Stable)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: List.generate(_categories.length, (index) {
                    final category = _categories[index];
                    final isSelected = index == _selectedCategoryIndex;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategoryIndex = index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 20),
                        padding: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          border: isSelected
                              ? const Border(
                                  bottom: BorderSide(
                                    color: Color(0xFF201D19),
                                    width: 1.5,
                                  ),
                                )
                              : null,
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isSelected
                                ? const Color(0xFF201D19)
                                : const Color(0xFF888077),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 14),

              // Control Bar: Count + Filter & Sort Controls (Stable)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '24 illustrative pieces',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF888077),
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: const Row(
                          children: [
                            Text(
                              'Filter',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF201D19),
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.grid_view_rounded,
                              size: 14,
                              color: Color(0xFF201D19),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () {},
                        child: const Row(
                          children: [
                            Text(
                              'Sort',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF201D19),
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.swap_vert_rounded,
                              size: 15,
                              color: Color(0xFF201D19),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // SCROLLABLE PRODUCTS GRID ONLY
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProductGridRow(currentProducts[0], currentProducts[1]),
                      const SizedBox(height: 12),
                      const Text(
                        'Illustrative products · sample prices',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF888077),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildProductGridRow(currentProducts[2], currentProducts[3]),
                      const SizedBox(height: 20),
                      _buildProductGridRow(currentProducts[4], currentProducts[5]),
                      const SizedBox(height: 16),
                      const Text(
                        'Illustrative products from fictional retailers. Sample prices, not live inventory.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF888077),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Taskbar Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF5F3EC),
          border: Border(
            top: BorderSide(
              color: Color(0xFFD6CFC4),
              width: 1.0,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(
                0,
                Icons.home_outlined,
                Icons.home_rounded,
                'Home',
              ),
              _buildBottomNavItem(
                1,
                Icons.search_rounded,
                Icons.search_rounded,
                'Discover',
              ),
              _buildBottomNavItem(
                2,
                Icons.menu_book_outlined,
                Icons.menu_book_rounded,
                'Lookbook',
              ),
              _buildBottomNavItem(
                3,
                Icons.bookmark_border_rounded,
                Icons.bookmark_rounded,
                'Saved',
              ),
              _buildBottomNavItem(
                4,
                Icons.person_outline_rounded,
                Icons.person_rounded,
                'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductGridRow(
    Map<String, String> product1,
    Map<String, String> product2,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildDiscoverProductCard(product1)),
        const SizedBox(width: 14),
        Expanded(child: _buildDiscoverProductCard(product2)),
      ],
    );
  }

  Widget _buildDiscoverProductCard(Map<String, String> product) {
    final title = product['title']!;
    final brand = product['brand']!;
    final price = product['price']!;
    final imageUrl = product['imageUrl']!;
    final isSaved = _savedProductTitles.contains(title);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 0.92,
          child: Container(
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
                child: const Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 32,
                    color: Color(0xFF8C8278),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF201D19),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  if (isSaved) {
                    _savedProductTitles.remove(title);
                  } else {
                    _savedProductTitles.add(title);
                  }
                });
              },
              child: Icon(
                isSaved
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                size: 16,
                color: const Color(0xFF201D19),
              ),
            ),
          ],
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
              onTap: () {
                if (_selectedCategoryIndex == 1) {
                  // Make-up -> EleventhScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EleventhScreen(),
                    ),
                  );
                } else if (_selectedCategoryIndex == 2) {
                  // Jewlery -> TenthScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TenthScreen(),
                    ),
                  );
                } else {
                  // Outfits -> NinthScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NinthScreen(),
                    ),
                  );
                }
              },
              child: const Row(
                children: [
                  Text(
                    'Try-On',
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

  Widget _buildBottomNavItem(
    int index,
    IconData icon,
    IconData selectedIcon,
    String label,
  ) {
    final isSelected = index == _selectedBottomNavIndex;
    final color = isSelected ? const Color(0xFF201D19) : const Color(0xFF888077);

    return InkWell(
      onTap: () {
        if (index == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EighthScreen(initialTabIndex: 0),
            ),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FifteenthScreen(),
            ),
          );
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EighteenthScreen(),
            ),
          );
        } else if (index == 4) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EighthScreen(initialTabIndex: 4),
            ),
          );
        } else {
          setState(() {
            _selectedBottomNavIndex = index;
          });
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? selectedIcon : icon,
            size: 22,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
