import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/session_state.dart';
import '../../models/garment_item.dart';
import '../../screens/digital_closet_screen.dart';
import '../../screens/live_try_on_flow.dart';
import 'personal_collections_view.dart';

class CollectionSection extends StatefulWidget {
  const CollectionSection({super.key});

  @override
  State<CollectionSection> createState() => _CollectionSectionState();
}

class _CollectionSectionState extends State<CollectionSection> {
  String _selectedCategory = 'All';
  String _selectedColor = 'All Colors';
  String _searchQuery = '';
  bool _favoritesOnly = false;
  bool _isEditorialView = false;

  final List<String> _categories = [
    'All',
    'Tops',
    'Bottoms',
    'Dresses',
    'Outerwear',
    'Shoes',
    'Bags',
    'Accessories',
    'General',
  ];

  final List<String> _colorOptions = [
    'All Colors',
    'Neutral',
    'Black',
    'White',
    'Beige',
    'Brown',
    'Espresso',
    'Navy',
    'Blue',
    'Green',
    'Red',
    'Pink',
    'Yellow',
  ];

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionState>();
    final allGarments = session.garments;
    final isCutoutMode = session.showCutoutMode;

    final filtered = allGarments.where((g) {
      if (_selectedCategory != 'All' && g.category != _selectedCategory) return false;
      if (_favoritesOnly && !g.isFavorite) return false;
      if (_selectedColor != 'All Colors') {
        final matchesPrimary = g.primaryColor.toLowerCase().contains(_selectedColor.toLowerCase());
        final matchesSecondary = g.secondaryColor != null && g.secondaryColor!.toLowerCase().contains(_selectedColor.toLowerCase());
        if (!matchesPrimary && !matchesSecondary) return false;
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final nameMatch = g.name.toLowerCase().contains(query);
        final brandMatch = g.brand?.toLowerCase().contains(query) ?? false;
        final tagsMatch = g.tags.any((t) => t.toLowerCase().contains(query));
        if (!nameMatch && !brandMatch && !tagsMatch) return false;
      }
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Toolbar: View Toggles & Search
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search collection...',
                  hintStyle: const TextStyle(color: Color(0xFF888077), fontSize: 13),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF888077), size: 18),
                  filled: true,
                  fillColor: const Color(0xFFEFECE4),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFCDC6BA)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF3E3129)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            // Favorite filter
            IconButton(
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
              icon: Icon(
                _favoritesOnly ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: const Color(0xFF3E3129),
                size: 20,
              ),
              onPressed: () => setState(() => _favoritesOnly = !_favoritesOnly),
              tooltip: 'Favorites only',
            ),
            // Grid vs Editorial View Toggle
            IconButton(
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
              icon: Icon(
                _isEditorialView ? Icons.grid_on_rounded : Icons.dashboard_outlined,
                color: const Color(0xFF3E3129),
                size: 20,
              ),
              onPressed: () => setState(() => _isEditorialView = !_isEditorialView),
              tooltip: _isEditorialView ? 'Switch to Grid View' : 'Switch to Editorial View',
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Subheader: Quick Stats & Personal Collections Trigger
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '${filtered.length} of ${allGarments.length} garments',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontStyle: FontStyle.italic,
                  fontSize: 12.5,
                  color: Color(0xFF6E6760),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PersonalCollectionsScreen()),
                );
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.collections_bookmark_outlined, size: 14, color: Color(0xFF3E3129)),
                  SizedBox(width: 4),
                  Text(
                    'Personal Collections',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3E3129),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Categories Scroll
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: _categories.map((cat) {
              final isSelected = _selectedCategory == cat;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF3E3129) : const Color(0xFFEFECE4),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFCDC6BA)),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? const Color(0xFFF5F3EC) : const Color(0xFF201D19),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 8),

        // Color Filter Selector Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              const Text(
                'Color: ',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF888077)),
              ),
              ..._colorOptions.map((col) {
                final isSelected = _selectedColor == col;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = col),
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF555E4E) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF555E4E) : const Color(0xFFCDC6BA),
                      ),
                    ),
                    child: Text(
                      col,
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected ? Colors.white : const Color(0xFF6E6760),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Garment Display: Grid or Editorial View
        filtered.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Column(
                    children: [
                      const Icon(Icons.checkroom_outlined, size: 48, color: Color(0xFF8C8278)),
                      const SizedBox(height: 12),
                      const Text(
                        'No matching wardrobe garments',
                        style: TextStyle(fontFamily: 'serif', fontSize: 16, color: Color(0xFF201D19)),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Try clearing search or filters to see your closet items.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF888077)),
                      ),
                    ],
                  ),
                ),
              )
            : _isEditorialView
                ? _buildEditorialView(context, filtered, isCutoutMode)
                : _buildGridView(context, filtered, isCutoutMode),
      ],
    );
  }

  /// Grid View layout
  Widget _buildGridView(BuildContext context, List<GarmentItem> garments, bool isCutoutMode) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 14,
        childAspectRatio: 0.74,
      ),
      itemCount: garments.length,
      itemBuilder: (context, index) {
        final garment = garments[index];
        return _buildGarmentCard(context, garment, isCutoutMode);
      },
    );
  }

  /// Editorial View layout featuring asymmetric proportions & magazine captions
  Widget _buildEditorialView(BuildContext context, List<GarmentItem> garments, bool isCutoutMode) {
    return Column(
      children: List.generate(garments.length, (index) {
        final garment = garments[index];
        final isEven = index % 2 == 0;
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEFECE4),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFCDC6BA)),
          ),
          child: Row(
            textDirection: isEven ? TextDirection.ltr : TextDirection.rtl,
            children: [
              // Garment cutout / photo with respected aspect ratio
              Expanded(
                flex: 5,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => GarmentDetailScreen(garmentId: garment.id)),
                    );
                  },
                  child: AspectRatio(
                    aspectRatio: 0.85,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F3EC),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _buildGarmentImage(garment, isCutoutMode),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Editorial metadata & description
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EDIT ${index + 1} · ${garment.category.toUpperCase()}',
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 10,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF888077),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      garment.name,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF201D19),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${garment.primaryColor}${garment.secondaryColor != null ? ' / ${garment.secondaryColor}' : ''} ${garment.brand != null ? '· ${garment.brand}' : ''}',
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF6E6760)),
                    ),
                    if (garment.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: garment.tags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2DDD3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text(
                              '#$tag',
                              style: const TextStyle(fontSize: 10, color: Color(0xFF3E3129)),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => GarmentDetailScreen(garmentId: garment.id)),
                            );
                          },
                          child: const Text(
                            'Inspect Garment →',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3E3129),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LiveTryOnAvatarResultScreen(
                                  garmentImagePath: garment.cutoutPath.isNotEmpty ? garment.cutoutPath : garment.imagePath,
                                ),
                              ),
                            );
                          },
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Try-On Avatar',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF3E3129),
                                ),
                              ),
                              SizedBox(width: 2),
                              Icon(
                                Icons.north_east_rounded,
                                size: 12,
                                color: Color(0xFF3E3129),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildGarmentCard(BuildContext context, GarmentItem garment, bool isCutoutMode) {
    final session = context.watch<SessionState>();
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => GarmentDetailScreen(garmentId: garment.id)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEFECE4),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFCDC6BA)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              bottom: 40,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildGarmentImage(garment, isCutoutMode),
              ),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: () => session.toggleFavorite(garment.id),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xEBF5F3EC),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    garment.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    size: 14,
                    color: const Color(0xFF3E3129),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                color: const Color(0xFDF5F3EC),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      garment.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontWeight: FontWeight.w500,
                        fontSize: 12.5,
                        color: Color(0xFF201D19),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${garment.category} · ${garment.primaryColor}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 10, color: Color(0xFF888077)),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LiveTryOnAvatarResultScreen(
                                  garmentImagePath: garment.cutoutPath.isNotEmpty ? garment.cutoutPath : garment.imagePath,
                                ),
                              ),
                            );
                          },
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Try-On',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF3E3129),
                                ),
                              ),
                              SizedBox(width: 1),
                              Icon(
                                Icons.north_east_rounded,
                                size: 10,
                                color: Color(0xFF3E3129),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGarmentImage(GarmentItem garment, bool isCutoutMode) {
    final imagePath = isCutoutMode
        ? (garment.cutoutPath.isNotEmpty ? garment.cutoutPath : garment.imagePath)
        : (garment.imagePath.isNotEmpty ? garment.imagePath : garment.cutoutPath);

    Widget rawImage;
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      rawImage = Image.network(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, trace) => const Center(
          child: Icon(Icons.checkroom, size: 36, color: Color(0xFF8C8278)),
        ),
      );
    } else if (imagePath.isNotEmpty && File(imagePath).existsSync()) {
      rawImage = Image.file(
        File(imagePath),
        fit: BoxFit.contain,
        errorBuilder: (context, error, trace) => const Center(
          child: Icon(Icons.checkroom, size: 36, color: Color(0xFF8C8278)),
        ),
      );
    } else {
      rawImage = Container(
        color: const Color(0xFFE2DDD3),
        child: const Center(
          child: Icon(Icons.checkroom, size: 36, color: Color(0xFF8C8278)),
        ),
      );
    }

    // Cutout Clipping / Sticker Visual Styling
    return Container(
      decoration: BoxDecoration(
        color: isCutoutMode ? const Color(0xFAF8F6F0) : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: isCutoutMode ? Border.all(color: Colors.white, width: 1.5) : null,
        boxShadow: const [
          BoxShadow(
            color: Color(0x12201D19),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(3.0),
      child: rawImage,
    );
  }
}
