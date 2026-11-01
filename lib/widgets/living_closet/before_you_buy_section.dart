import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../state/session_state.dart';
import '../../models/garment_item.dart';
import '../../screens/live_try_on_flow.dart';

class BeforeYouBuySection extends StatefulWidget {
  const BeforeYouBuySection({super.key});

  @override
  State<BeforeYouBuySection> createState() => _BeforeYouBuySectionState();
}

class _BeforeYouBuySectionState extends State<BeforeYouBuySection> {
  String? _sourceImagePath;
  String? _cutoutPath;
  bool _isProcessing = false;
  String _itemCategory = 'Outerwear';
  String _itemColor = 'Beige';

  final List<String> _categories = [
    'Tops',
    'Bottoms',
    'Dresses',
    'Outerwear',
    'Shoes',
    'Bags',
    'Accessories',
  ];

  final List<String> _colors = [
    'Beige',
    'Black',
    'White',
    'Brown',
    'Espresso',
    'Navy',
    'Blue',
    'Green',
    'Red',
  ];

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source);
      if (!mounted) return;
      if (picked != null) {
        setState(() {
          _sourceImagePath = picked.path;
          _isProcessing = true;
        });

        final cutout = await GarmentSegmentationService.isolateGarment(picked.path);
        if (!mounted) return;

        setState(() {
          _cutoutPath = cutout;
          _isProcessing = false;
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not capture image. Try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionState>();
    final closetGarments = session.garments;

    // Matching wardrobe items
    final matchingWardrobeItems = closetGarments.where((g) {
      final isDifferentCategory = g.category != _itemCategory;
      final isHarmoniousColor = g.primaryColor == _itemColor ||
          g.primaryColor == 'Neutral' ||
          g.primaryColor == 'Black' ||
          g.primaryColor == 'White' ||
          g.primaryColor == 'Beige' ||
          _itemColor == 'Beige' ||
          _itemColor == 'Black';
      return isDifferentCategory && isHarmoniousColor;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Header
        const Text(
          'Before You Buy',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 22,
            fontWeight: FontWeight.w400,
            color: Color(0xFF201D19),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Test physical store items against your digital closet before purchasing.',
          style: TextStyle(fontSize: 12.5, color: Color(0xFF6E6760)),
        ),

        const SizedBox(height: 16),

        // Garment Capture Box
        if (_sourceImagePath == null) ...[
          GestureDetector(
            onTap: () => _pickImage(ImageSource.camera),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFEFECE4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFCDC6BA)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.add_a_photo_outlined, size: 40, color: Color(0xFF3E3129)),
                  const SizedBox(height: 10),
                  const Text(
                    'Capture Item In Store',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF201D19),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Photograph a garment on a rack or hanger to test wardrobe matches.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Color(0xFF888077)),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3E3129),
                          foregroundColor: const Color(0xFFF5F3EC),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        icon: const Icon(Icons.camera_alt_outlined, size: 16),
                        label: const Text('Take Photo'),
                        onPressed: () => _pickImage(ImageSource.camera),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF201D19),
                          side: const BorderSide(color: Color(0xFFCDC6BA)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        icon: const Icon(Icons.photo_library_outlined, size: 16),
                        label: const Text('From Gallery'),
                        onPressed: () => _pickImage(ImageSource.gallery),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          // Cutout Preview & Metadata
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFECE4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFCDC6BA)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  height: 120,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F3EC),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _isProcessing
                        ? const Center(child: CircularProgressIndicator(color: Color(0xFF3E3129)))
                        : (_cutoutPath != null && File(_cutoutPath!).existsSync()
                            ? Image.file(File(_cutoutPath!), fit: BoxFit.contain)
                            : Image.file(File(_sourceImagePath!), fit: BoxFit.cover)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'NEW POTENTIAL ITEM',
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 9.5,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF888077),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _sourceImagePath = null;
                                _cutoutPath = null;
                              });
                            },
                            child: const Text('Retake', style: TextStyle(fontSize: 11, color: Color(0xFFA33A3A))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _itemCategory,
                              isDense: true,
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                filled: true,
                                fillColor: Color(0xFFF5F3EC),
                              ),
                              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 11)))).toList(),
                              onChanged: (v) => setState(() => _itemCategory = v ?? 'Outerwear'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _itemColor,
                              isDense: true,
                              decoration: const InputDecoration(
                                labelText: 'Primary Color',
                                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                filled: true,
                                fillColor: Color(0xFFF5F3EC),
                              ),
                              items: _colors.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 11)))).toList(),
                              onChanged: (v) => setState(() => _itemColor = v ?? 'Beige'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3E3129),
                            foregroundColor: const Color(0xFFF5F3EC),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                          icon: const Icon(Icons.add, size: 14),
                          label: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Add to Digital Closet',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),
                          onPressed: () {
                            final item = GarmentItem(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              name: 'In-Store Item ($_itemCategory)',
                              imagePath: _sourceImagePath!,
                              cutoutPath: _cutoutPath ?? _sourceImagePath!,
                              category: _itemCategory,
                              primaryColor: _itemColor,
                              source: 'digital_closet',
                            );
                            session.addGarment(item);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Item saved to your Digital Closet!')),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Works With Your Wardrobe Section
          Container(
            padding: const EdgeInsets.all(16),
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
                    const Text(
                      'Works With Your Wardrobe',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF201D19),
                      ),
                    ),
                    Text(
                      '${matchingWardrobeItems.length} matches',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF555E4E)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'This ${_itemCategory.toLowerCase()} complements ${matchingWardrobeItems.length} pieces you already own:',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6E6760)),
                ),
                const SizedBox(height: 12),
                matchingWardrobeItems.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Text('No direct matches found. Try selecting another color or category.', style: TextStyle(fontSize: 12, color: Color(0xFF888077))),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: matchingWardrobeItems.map((g) {
                            return Container(
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.all(8),
                              width: 100,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F3EC),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFCDC6BA)),
                              ),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 60,
                                    child: _buildGarmentImage(g),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    g.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF201D19)),
                                  ),
                                  Text(
                                    g.category,
                                    style: const TextStyle(fontSize: 10, color: Color(0xFF888077)),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Shopping Decision Support Summary
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE2DDD3),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFCDC6BA)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Shopping Decision Analysis',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF201D19),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '· Versatility Rating: High (${matchingWardrobeItems.length} complementary pairings).\n'
                  '· Color Synergy: $_itemColor pairs smoothly with your neutral base.\n'
                  '· Wardrobe Gap: Fills your $_itemCategory options without duplicating items.',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF201D19), height: 1.4),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3E3129),
                      foregroundColor: const Color(0xFFF5F3EC),
                    ),
                    icon: const Icon(Icons.person_outline, size: 16),
                    label: const Text('Try-On With Avatar', style: TextStyle(fontWeight: FontWeight.w600)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LiveTryOnAvatarResultScreen(garmentImagePath: _cutoutPath ?? _sourceImagePath!),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGarmentImage(GarmentItem garment) {
    final path = garment.cutoutPath.isNotEmpty ? garment.cutoutPath : garment.imagePath;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(path, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.checkroom, size: 24));
    } else if (path.isNotEmpty && File(path).existsSync()) {
      return Image.file(File(path), fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.checkroom, size: 24));
    } else {
      return Container(
        color: const Color(0xFFE2DDD3),
        child: const Icon(Icons.checkroom, size: 24, color: Color(0xFF8C8278)),
      );
    }
  }
}
