import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/session_state.dart';
import '../../models/garment_item.dart';

class OutfitDnaSection extends StatefulWidget {
  final String? initialGarmentId;
  const OutfitDnaSection({super.key, this.initialGarmentId});

  @override
  State<OutfitDnaSection> createState() => _OutfitDnaSectionState();
}

class _OutfitDnaSectionState extends State<OutfitDnaSection> {
  String? _selectedGarmentId;

  @override
  void initState() {
    super.initState();
    _selectedGarmentId = widget.initialGarmentId;
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionState>();
    final allGarments = session.garments;

    if (allGarments.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Add garments to your collection first to analyze your Outfit DNA.',
            style: TextStyle(fontFamily: 'serif', fontSize: 16, color: Color(0xFF6E6760)),
          ),
        ),
      );
    }

    final selectedGarment = allGarments.firstWhere(
      (g) => g.id == (_selectedGarmentId ?? allGarments.first.id),
      orElse: () => allGarments.first,
    );

    // Auto-generated outfit concepts by style direction
    final outfitConcepts = _generateOutfitConcepts(selectedGarment, allGarments);

    // Underused pieces
    final underusedPieces = allGarments.where((g) => g.wearCount <= 2 && g.id != selectedGarment.id).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Magazine Editorial Section Header
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'OUTFIT DNA · EDITORIAL ANALYSIS',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      color: Color(0xFF888077),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${allGarments.length} GARMENTS',
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 10,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF888077),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Garment Harmony & Proportions',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 24,
                fontWeight: FontWeight.w400,
                color: Color(0xFF201D19),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'An editorial study of color palettes, silhouette pairings, and stylistic directions.',
              style: TextStyle(
                fontFamily: 'serif',
                fontStyle: FontStyle.italic,
                fontSize: 12.5,
                color: Color(0xFF6E6760),
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),
        const Divider(color: Color(0xFFD6CFC4), height: 1, thickness: 1),
        const SizedBox(height: 18),

        // 01 / ANCHOR SELECTION CAROUSEL
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '01 · ANCHOR GARMENT SELECTION',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 10,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
                color: Color(0xFF888077),
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: allGarments.map((garment) {
                  final isSelected = garment.id == selectedGarment.id;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedGarmentId = garment.id;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.all(6),
                      width: 88,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF3E3129) : const Color(0xFFEFECE4),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF3E3129) : const Color(0xFFCDC6BA),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF3E3129).withValues(alpha: 0.12),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                )
                              ]
                            : null,
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 62,
                            child: _buildGarmentImage(garment),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            garment.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected ? const Color(0xFFF5F3EC) : const Color(0xFF201D19),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Selected Anchor Garment Card (Editorial Feature Spread)
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFEFECE4),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFCDC6BA)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cutout display frame
              SizedBox(
                width: 90,
                height: 120,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F3EC),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFCDC6BA)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: _buildGarmentImage(selectedGarment),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'FEATURED ANCHOR',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 9,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF888077),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3E3129),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(
                            selectedGarment.category.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFF5F3EC),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedGarment.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF201D19),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tone: ${selectedGarment.primaryColor}${selectedGarment.secondaryColor != null ? ' / ${selectedGarment.secondaryColor}' : ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF6E6760)),
                    ),
                    if (selectedGarment.brand != null && selectedGarment.brand!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Atelier: ${selectedGarment.brand}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF888077)),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: selectedGarment.tags.map((t) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2DDD3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(
                            '#$t',
                            style: const TextStyle(fontSize: 9.5, color: Color(0xFF3E3129)),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // 02 / COMPLEMENTARY PAIRINGS STRIP
        Builder(
          builder: (context) {
            final List<GarmentItem> complementaryItems = allGarments.where((g) {
              if (g.id == selectedGarment.id) return false;
              final categoryDiffers = g.category != selectedGarment.category;
              final colorMatches = g.primaryColor == selectedGarment.primaryColor ||
                  g.primaryColor == 'Neutral' ||
                  g.primaryColor == 'Black' ||
                  g.primaryColor == 'Beige' ||
                  g.primaryColor == 'White' ||
                  selectedGarment.primaryColor == 'Neutral' ||
                  selectedGarment.primaryColor == 'Beige';
              return categoryDiffers && colorMatches;
            }).toList();

            if (complementaryItems.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '02 · HARMONIOUS PAIRING PIECES',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 10,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF888077),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Matching garments from your closet with color and silhouette synergy:',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6E6760)),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: complementaryItems.map((item) {
                      return Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.all(8),
                        width: 105,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFECE4),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFCDC6BA)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 65,
                              width: double.infinity,
                              child: _buildGarmentImage(item),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'serif',
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF201D19),
                              ),
                            ),
                            Text(
                              '${item.category} · ${item.primaryColor}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 9.5, color: Color(0xFF888077)),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            );
          },
        ),

        // 03 / GENERATED OUTFIT CONCEPTS SPREAD
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '03 · CURATED EDITORIAL EDITS',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 10,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
                color: Color(0xFF888077),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Curated outfit pairings built exclusively from your saved wardrobe items:',
              style: TextStyle(fontSize: 12, color: Color(0xFF6E6760)),
            ),
            const SizedBox(height: 12),

            Column(
              children: List.generate(outfitConcepts.length, (index) {
                final concept = outfitConcepts[index];
                final direction = concept['direction'] as String;
                final items = concept['items'] as List<GarmentItem>;
                final rationale = concept['rationale'] as String;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFECE4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFCDC6BA)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  'EDIT 0${index + 1}',
                                  style: const TextStyle(
                                    fontFamily: 'serif',
                                    fontSize: 10,
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF888077),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF3E3129),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      direction.toUpperCase(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.4,
                                        color: Color(0xFFF5F3EC),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${items.length} PIECES',
                            style: const TextStyle(
                              fontFamily: 'serif',
                              fontSize: 9.5,
                              letterSpacing: 0.8,
                              color: Color(0xFF888077),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Asymmetric items cutout collage grid
                      Row(
                        children: items.map((item) {
                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(right: 6),
                              height: 80,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F3EC),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: const Color(0xFFCDC6BA)),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: _buildGarmentImage(item),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F3EC),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFCDC6BA)),
                        ),
                        child: Text(
                          'Styling Note: "$rationale"',
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontStyle: FontStyle.italic,
                            fontSize: 11,
                            color: Color(0xFF6E6760),
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // 04 / ARCHIVAL REVIVALS (Discover Underused Pieces)
        if (underusedPieces.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEFECE4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFCDC6BA)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '04 · ARCHIVAL REVIVALS',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 10,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF888077),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Wardrobe pieces ready for fresh styling pairing in your next edit:',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6E6760)),
                ),
                const SizedBox(height: 10),
                Column(
                  children: underusedPieces.take(3).map((piece) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F3EC),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFFCDC6BA)),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: _buildGarmentImage(piece),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  piece.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'serif',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF201D19),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Pair with ${selectedGarment.name} for a crisp ${piece.primaryColor.toLowerCase()} statement accent.',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF6E6760)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  List<Map<String, dynamic>> _generateOutfitConcepts(GarmentItem anchor, List<GarmentItem> allGarments) {
    List<Map<String, dynamic>> concepts = [];

    // Directions
    final directions = ['Everyday Minimal', 'Smart Casual', 'Evening Statement', 'Classic Tailored'];

    for (int i = 0; i < directions.length; i++) {
      final direction = directions[i];
      final items = <GarmentItem>[anchor];

      for (final other in allGarments) {
        if (items.length >= 3) break;
        if (other.id == anchor.id) continue;
        if (!items.any((it) => it.category == other.category)) {
          items.add(other);
        }
      }

      String rationale = 'Combines ${anchor.primaryColor} ${anchor.category.toLowerCase()} with complementary textures for effortless ${direction.toLowerCase()} balance.';
      if (anchor.category == 'Outerwear') {
        rationale = 'Structured ${anchor.name} anchors fluid base layers, creating a sophisticated ${direction.toLowerCase()} silhouette.';
      } else if (anchor.category == 'Bottoms') {
        rationale = 'Tailored ${anchor.name} anchors clean proportion and versatile ${direction.toLowerCase()} elegance.';
      }

      concepts.add({
        'direction': direction,
        'items': items,
        'rationale': rationale,
      });
    }

    return concepts;
  }

  Widget _buildGarmentImage(GarmentItem garment) {
    final path = garment.cutoutPath.isNotEmpty ? garment.cutoutPath : garment.imagePath;
    Widget rawImage;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      rawImage = Image.network(path, fit: BoxFit.contain, errorBuilder: (context, error, trace) => const Icon(Icons.checkroom, size: 24));
    } else if (path.isNotEmpty && File(path).existsSync()) {
      rawImage = Image.file(File(path), fit: BoxFit.contain, errorBuilder: (context, error, trace) => const Icon(Icons.checkroom, size: 24));
    } else {
      rawImage = Container(
        color: const Color(0xFFE2DDD3),
        child: const Icon(Icons.checkroom, size: 24, color: Color(0xFF8C8278)),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFAF8F6F0),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x15201D19),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(2.0),
      child: rawImage,
    );
  }
}
