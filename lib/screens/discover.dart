import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  // Camera Visual Search state
  File? _visualSearchFile;
  String? _visualSearchSampleUrl;
  String? _visualSearchTitle;
  bool _isVisualSearchActive = false;

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
        'matchScore': '98% Match',
      },
      {
        'title': 'The sculpted blazer',
        'brand': 'Atelier Nine',
        'price': '₹4,800',
        'imageUrl':
            'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=500&q=80',
        'matchScore': '94% Match',
      },
      {
        'title': 'Fluid tailored trouser',
        'brand': 'Maison Vale',
        'price': '₹2,200',
        'imageUrl':
            'https://images.unsplash.com/photo-1509631179647-0177331693ae?auto=format&fit=crop&w=500&q=80',
        'matchScore': '91% Match',
      },
      {
        'title': 'Draped silk blouse',
        'brand': 'Linen & Line',
        'price': '₹3,100',
        'imageUrl':
            'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=500&q=80',
        'matchScore': '87% Match',
      },
      {
        'title': 'Arc shoulder bag',
        'brand': 'Atelier Nine',
        'price': '₹1,800',
        'imageUrl':
            'https://images.unsplash.com/photo-1548883354-7622d03aca27?auto=format&fit=crop&w=500&q=80',
        'matchScore': '83% Match',
      },
      {
        'title': 'The pointed flat',
        'brand': 'Linen & Line',
        'price': '₹1,600',
        'imageUrl':
            'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?auto=format&fit=crop&w=500&q=80',
        'matchScore': '79% Match',
      },
    ],
    1: [
      {
        'title': 'Velvet matte lipstick',
        'brand': 'Maison Beauty',
        'price': '₹1,200',
        'imageUrl':
            'https://images.unsplash.com/photo-1586495777744-4413f21062fa?auto=format&fit=crop&w=500&q=80',
        'matchScore': '97% Match',
      },
      {
        'title': 'Luminous skin tint',
        'brand': 'Atelier Glow',
        'price': '₹2,100',
        'imageUrl':
            'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=500&q=80',
        'matchScore': '93% Match',
      },
      {
        'title': 'Sculpting bronzer palette',
        'brand': 'Forme Make-up',
        'price': '₹2,800',
        'imageUrl':
            'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?auto=format&fit=crop&w=500&q=80',
        'matchScore': '88% Match',
      },
      {
        'title': 'Rose petal blush',
        'brand': 'Maison Beauty',
        'price': '₹1,500',
        'imageUrl':
            'https://images.unsplash.com/photo-1596704017254-9b121068fb31?auto=format&fit=crop&w=500&q=80',
        'matchScore': '85% Match',
      },
      {
        'title': 'Precision eye defining pen',
        'brand': 'Atelier Glow',
        'price': '₹950',
        'imageUrl':
            'https://images.unsplash.com/photo-1571781926291-c477ebfd024b?auto=format&fit=crop&w=500&q=80',
        'matchScore': '81% Match',
      },
      {
        'title': 'Dewy highlighter glow',
        'brand': 'Forme Make-up',
        'price': '₹1,800',
        'imageUrl':
            'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?auto=format&fit=crop&w=500&q=80',
        'matchScore': '78% Match',
      },
    ],
    2: [
      {
        'title': 'Sculpted gold hoops',
        'brand': 'Forme Studio',
        'price': '₹850',
        'imageUrl':
            'https://images.unsplash.com/photo-1630019852942-f89202989a59?auto=format&fit=crop&w=500&q=80',
        'matchScore': '99% Match',
      },
      {
        'title': 'Layered chain necklace',
        'brand': 'Aura Jewels',
        'price': '₹3,400',
        'imageUrl':
            'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?auto=format&fit=crop&w=500&q=80',
        'matchScore': '95% Match',
      },
      {
        'title': 'Signet statement ring',
        'brand': 'Forme Studio',
        'price': '₹1,500',
        'imageUrl':
            'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?auto=format&fit=crop&w=500&q=80',
        'matchScore': '90% Match',
      },
      {
        'title': 'Pearl drop earrings',
        'brand': 'Aura Jewels',
        'price': '₹2,600',
        'imageUrl':
            'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?auto=format&fit=crop&w=500&q=80',
        'matchScore': '86% Match',
      },
      {
        'title': 'Geometric cuff bracelet',
        'brand': 'Forme Studio',
        'price': '₹1,900',
        'imageUrl':
            'https://images.unsplash.com/photo-1611591475271-18e472620a23?auto=format&fit=crop&w=500&q=80',
        'matchScore': '82% Match',
      },
      {
        'title': 'Delicate pavé band',
        'brand': 'Aura Jewels',
        'price': '₹2,200',
        'imageUrl':
            'https://images.unsplash.com/photo-1605100804763-247f67b3557e?auto=format&fit=crop&w=500&q=80',
        'matchScore': '77% Match',
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _visualSearchFile = null;
      _visualSearchSampleUrl = null;
      _visualSearchTitle = null;
      _isVisualSearchActive = false;
    });
  }

  Future<void> _showVisualSearchOptions() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF5F3EC),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'VISUAL MATCH SEARCH',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: Color(0xFF201D19),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Snap or upload a photo of any outfit, garment, or accessory to find visually similar pieces in the catalog.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF888077),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFECE4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.camera_alt_outlined, color: Color(0xFF201D19), size: 20),
                  ),
                  title: const Text(
                    'Take a Photo',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF201D19),
                    ),
                  ),
                  subtitle: const Text(
                    'Use camera to snap product or texture',
                    style: TextStyle(fontSize: 12, color: Color(0xFF888077)),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickVisualSearchImage(ImageSource.camera);
                  },
                ),
                const Divider(color: Color(0xFFE2DDD3), height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFECE4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.photo_library_outlined, color: Color(0xFF201D19), size: 20),
                  ),
                  title: const Text(
                    'Choose from Gallery',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF201D19),
                    ),
                  ),
                  subtitle: const Text(
                    'Upload photo from your device library',
                    style: TextStyle(fontSize: 12, color: Color(0xFF888077)),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickVisualSearchImage(ImageSource.gallery);
                  },
                ),
                const Divider(color: Color(0xFFE2DDD3), height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFECE4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.auto_awesome_outlined, color: Color(0xFF201D19), size: 20),
                  ),
                  title: const Text(
                    'Try Sample Fashion Image',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF201D19),
                    ),
                  ),
                  subtitle: const Text(
                    'Instant visual match preview',
                    style: TextStyle(fontSize: 12, color: Color(0xFF888077)),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _processVisualSearch(
                      sampleUrl: 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?auto=format&fit=crop&w=500&q=80',
                      sampleName: 'Linen Waistcoat Sample',
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickVisualSearchImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        imageQuality: 85,
      );
      if (image != null) {
        _processVisualSearch(imageFile: File(image.path));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open ${source == ImageSource.camera ? "camera" : "gallery"}. Try sample image.'),
          backgroundColor: const Color(0xFF201D19),
        ),
      );
    }
  }

  Future<void> _processVisualSearch({File? imageFile, String? sampleUrl, String? sampleName}) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFFF5F3EC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFECE4),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFCDC6BA)),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF201D19)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'VISUAL MATCH ANALYSIS',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: Color(0xFF201D19),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Scanning silhouette, color palette & fabric texture...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF888077),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 1300));
    if (!mounted) return;
    Navigator.pop(context); // Close analysis dialog

    setState(() {
      _visualSearchFile = imageFile;
      _visualSearchSampleUrl = sampleUrl;
      _visualSearchTitle = sampleName ?? (imageFile != null ? 'Uploaded Photo' : 'Visual Match');
      _isVisualSearchActive = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Visual match complete! Showing catalog recommendations.'),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFF201D19),
      ),
    );
  }

  List<Map<String, String>> _getFilteredProducts() {
    final rawProducts = _categoryProducts[_selectedCategoryIndex] ?? _categoryProducts[0]!;
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty || _isVisualSearchActive) {
      return rawProducts;
    }

    return rawProducts.where((p) {
      final title = p['title']?.toLowerCase() ?? '';
      final brand = p['brand']?.toLowerCase() ?? '';
      return title.contains(query) || brand.contains(query);
    }).toList();
  }

  String _getControlCountText(int resultCount) {
    if (_isVisualSearchActive) {
      return '$resultCount visual matches found';
    }
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      return '$resultCount results for "$query"';
    }
    return '24 illustrative pieces';
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _getFilteredProducts();

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

              // Search Box Field with Camera Option inside
              TextField(
                controller: _searchController,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF201D19),
                ),
                decoration: InputDecoration(
                  hintText: _isVisualSearchActive
                      ? 'Visual match search active...'
                      : 'Search clothing, styles or textures',
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
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF201D19),
                    size: 20,
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_searchController.text.isNotEmpty || _isVisualSearchActive)
                        IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Color(0xFF888077),
                            size: 18,
                          ),
                          onPressed: _clearSearch,
                          tooltip: 'Clear search',
                        ),
                      Container(
                        height: 20,
                        width: 1,
                        color: const Color(0xFFCDC6BA),
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                      ),
                      IconButton(
                        icon: Icon(
                          _isVisualSearchActive
                              ? Icons.camera_alt
                              : Icons.camera_alt_outlined,
                          color: _isVisualSearchActive
                              ? const Color(0xFF201D19)
                              : const Color(0xFF5A544D),
                          size: 20,
                        ),
                        onPressed: _showVisualSearchOptions,
                        tooltip: 'Camera / Upload photo for visual match',
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.0),
                    borderSide: BorderSide(
                      color: _isVisualSearchActive
                          ? const Color(0xFF201D19)
                          : const Color(0xFFCDC6BA),
                      width: _isVisualSearchActive ? 1.4 : 1.0,
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

              // Visual Search Active Badge Banner
              if (_isVisualSearchActive) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFECE4),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFCDC6BA)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: _visualSearchFile != null
                            ? Image.file(
                                _visualSearchFile!,
                                width: 36,
                                height: 36,
                                fit: BoxFit.cover,
                              )
                            : (_visualSearchSampleUrl != null
                                ? Image.network(
                                    _visualSearchSampleUrl!,
                                    width: 36,
                                    height: 36,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 36,
                                    height: 36,
                                    color: const Color(0xFFCDC6BA),
                                    child: const Icon(Icons.camera_alt, size: 20, color: Color(0xFF201D19)),
                                  )),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.auto_awesome, size: 12, color: Color(0xFF201D19)),
                                SizedBox(width: 4),
                                Text(
                                  'VISUAL MATCH ACTIVE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                    color: Color(0xFF201D19),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _visualSearchTitle ?? 'Image visual matches',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF201D19),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _clearSearch,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFCDC6BA),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 14,
                            color: Color(0xFF201D19),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

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

              // Control Bar: Count + Filter & Sort Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getControlCountText(filteredProducts.length),
                    style: const TextStyle(
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
                      _buildProductGrid(filteredProducts),
                      const SizedBox(height: 12),
                      Text(
                        _isVisualSearchActive
                            ? 'Visual similarity matches · Powered by EVOQE Style AI'
                            : 'Illustrative products · sample prices',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF888077),
                        ),
                      ),
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

  Widget _buildProductGrid(List<Map<String, String>> products) {
    if (products.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        alignment: Alignment.center,
        child: Column(
          children: [
            const Icon(Icons.search_off_rounded, size: 40, color: Color(0xFF888077)),
            const SizedBox(height: 12),
            Text(
              'No matching pieces found for "${_searchController.text}"',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF201D19),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try adjusting your query or use Camera Visual Match',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF888077),
              ),
            ),
          ],
        ),
      );
    }

    List<Widget> rows = [];
    for (int i = 0; i < products.length; i += 2) {
      final p1 = products[i];
      final p2 = (i + 1 < products.length) ? products[i + 1] : null;

      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildDiscoverProductCard(p1)),
            const SizedBox(width: 14),
            Expanded(
              child: p2 != null
                  ? _buildDiscoverProductCard(p2)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      );
      rows.add(const SizedBox(height: 20));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
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
            child: Stack(
              children: [
                Positioned.fill(
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
                if (_isVisualSearchActive)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF201D19).withOpacity(0.88),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            size: 10,
                            color: Color(0xFFF5F3EC),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            product['matchScore'] ?? '92% Match',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFF5F3EC),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
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
