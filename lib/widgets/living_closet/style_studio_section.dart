import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/session_state.dart';
import '../../models/garment_item.dart';
import '../../models/saved_outfit.dart';

class StyleStudioSection extends StatefulWidget {
  const StyleStudioSection({super.key});

  @override
  State<StyleStudioSection> createState() => _StyleStudioSectionState();
}

class _StyleStudioSectionState extends State<StyleStudioSection> {
  final List<CanvasPosition> _selectedPositions = [];
  String? _activeGarmentId;
  String _outfitName = 'My Editorial Fit';
  String _selectedOccasion = 'Smart Casual';

  final List<String> _occasions = [
    'Everyday',
    'Smart Casual',
    'Evening',
    'Formal',
    'Weekend',
    'Travel',
  ];

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionState>();
    final allGarments = session.garments;

    // Garments currently on canvas
    final canvasGarments = _selectedPositions.map((pos) {
      final g = allGarments.firstWhere(
        (item) => item.id == pos.garmentId,
        orElse: () => GarmentItem(
          id: pos.garmentId,
          name: 'Unknown Item',
          imagePath: '',
          cutoutPath: '',
          category: 'General',
          primaryColor: 'Neutral',
          source: '',
        ),
      );
      return {'position': pos, 'garment': g};
    }).toList();

    // Smart Suggestions based on canvas contents
    final smartSuggestions = _computeSmartSuggestions(allGarments);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Studio Title Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Style Studio',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF201D19),
                    ),
                  ),
                  Text(
                    '${_selectedPositions.length} items on canvas',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF888077)),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_selectedPositions.isNotEmpty)
                  IconButton(
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    icon: const Icon(Icons.refresh_rounded, color: Color(0xFF8C8278), size: 20),
                    tooltip: 'Reset Canvas',
                    onPressed: () {
                      setState(() {
                        _selectedPositions.clear();
                        _activeGarmentId = null;
                      });
                    },
                  ),
                const SizedBox(width: 4),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3E3129),
                    foregroundColor: const Color(0xFFF5F3EC),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  icon: const Icon(Icons.save_alt_rounded, size: 15),
                  label: const Text('Save Outfit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  onPressed: _selectedPositions.isEmpty ? null : () => _showSaveOutfitDialog(context),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Styling Canvas Area
        Container(
          height: 320,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFEFECE4),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFCDC6BA)),
          ),
          child: Stack(
            children: [
              // Canvas Background Desk Aesthetics
              Positioned.fill(
                child: CustomPaint(
                  painter: _StudioGridPainter(),
                ),
              ),

              if (_selectedPositions.isEmpty)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.brush_outlined, size: 40, color: Color(0xFF8C8278)),
                      const SizedBox(height: 8),
                      const Text(
                        'Your Editorial Canvas is empty',
                        style: TextStyle(fontFamily: 'serif', fontSize: 16, color: Color(0xFF201D19)),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Select garments from the drawer below to compose an outfit.',textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Color(0xFF888077)),
                      ),
                    ],
                  ),
                )
              else
                // Render Interactive Placed Garments
                ...canvasGarments.map((entry) {
                  final pos = entry['position'] as CanvasPosition;
                  final garment = entry['garment'] as GarmentItem;
                  final isActive = _activeGarmentId == garment.id;

                  return Positioned(
                    left: pos.dx * 220,
                    top: pos.dy * 180,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _activeGarmentId = garment.id;
                        });
                      },
                      onPanUpdate: (details) {
                        setState(() {
                          pos.dx = (pos.dx + details.delta.dx / 220).clamp(0.05, 0.75);
                          pos.dy = (pos.dy + details.delta.dy / 180).clamp(0.05, 0.75);
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 100 * pos.scale,
                        height: 110 * pos.scale,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFAF8F6F0),
                          border: Border.all(
                            color: isActive ? const Color(0xFF3E3129) : Colors.white,
                            width: isActive ? 2.0 : 1.5,
                          ),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3E3129).withValues(alpha: isActive ? 0.25 : 0.15),
                              blurRadius: isActive ? 10 : 6,
                              offset: const Offset(2, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: _buildGarmentImage(garment),
                            ),
                            if (isActive)
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedPositions.removeWhere((p) => p.garmentId == garment.id);
                                      if (_activeGarmentId == garment.id) _activeGarmentId = null;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFA33A3A),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close, size: 12, color: Colors.white),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Garment Drawer & Smart Suggestions Section
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'GARMENT DRAWER',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 10,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF888077),
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: allGarments.map((garment) {
                  final isAlreadyAdded = _selectedPositions.any((p) => p.garmentId == garment.id);
                  return GestureDetector(
                    onTap: () {
                      if (!isAlreadyAdded) {
                        setState(() {
                          _selectedPositions.add(
                            CanvasPosition(
                              garmentId: garment.id,
                              dx: 0.1 + (_selectedPositions.length * 0.18) % 0.6,
                              dy: 0.1 + (_selectedPositions.length * 0.15) % 0.5,
                            ),
                          );
                          _activeGarmentId = garment.id;
                        });
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: 80,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isAlreadyAdded ? const Color(0xFFCDC6BA) : const Color(0xFFEFECE4),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isAlreadyAdded ? const Color(0xFF3E3129) : const Color(0xFFCDC6BA),
                        ),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 60,
                            child: _buildGarmentImage(garment),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            garment.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isAlreadyAdded ? FontWeight.w600 : FontWeight.w400,
                              color: const Color(0xFF201D19),
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

        // Smart Suggestions Panel
        if (smartSuggestions.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEFECE4),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFCDC6BA)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.auto_awesome_outlined, size: 16, color: Color(0xFF3E3129)),
                    SizedBox(width: 6),
                    Text(
                      'Smart Stylist Suggestions',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF201D19),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Based on garments currently on canvas, EVOQE recommends these matching items from your closet:',
                  style: TextStyle(fontSize: 11.5, color: Color(0xFF6E6760)),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: smartSuggestions.map((sug) {
                      final garment = sug['garment'] as GarmentItem;
                      final reason = sug['reason'] as String;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPositions.add(
                              CanvasPosition(
                                garmentId: garment.id,
                                dx: 0.1 + (_selectedPositions.length * 0.18) % 0.6,
                                dy: 0.1 + (_selectedPositions.length * 0.15) % 0.5,
                              ),
                            );
                            _activeGarmentId = garment.id;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.all(8),
                          width: 140,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F3EC),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFCDC6BA)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 50,
                                width: double.infinity,
                                child: _buildGarmentImage(garment),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                garment.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF201D19)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                reason,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 9.5, color: Color(0xFF888077)),
                              ),
                              const SizedBox(height: 6),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text('+ Add to canvas', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF3E3129))),
                                ],
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
          ),
        ],
      ],
    );
  }

  List<Map<String, dynamic>> _computeSmartSuggestions(List<GarmentItem> allGarments) {
    if (_selectedPositions.isEmpty) return [];

    final activeGarments = allGarments.where((g) => _selectedPositions.any((p) => p.garmentId == g.id)).toList();
    final activeCategories = activeGarments.map((g) => g.category).toSet();
    final activeColors = activeGarments.map((g) => g.primaryColor).toSet();

    final unadded = allGarments.where((g) => !_selectedPositions.any((p) => p.garmentId == g.id)).toList();

    List<Map<String, dynamic>> suggestions = [];

    for (final candidate in unadded) {
      if (!activeCategories.contains(candidate.category)) {
        String reason = 'Completes category (${candidate.category})';
        if (activeColors.contains(candidate.primaryColor) || candidate.primaryColor == 'Neutral' || candidate.primaryColor == 'Black' || candidate.primaryColor == 'Beige') {
          reason = 'Harmonious ${candidate.primaryColor} pairing with current items';
        }
        suggestions.add({'garment': candidate, 'reason': reason});
      }
    }

    return suggestions.take(4).toList();
  }

  void _showSaveOutfitDialog(BuildContext context) {
    final nameController = TextEditingController(text: _outfitName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF5F3EC),
        title: const Text('Save Outfit Composition', style: TextStyle(fontFamily: 'serif', color: Color(0xFF201D19))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Outfit Name',
                filled: true,
                fillColor: Color(0xFFEFECE4),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedOccasion,
              decoration: const InputDecoration(
                labelText: 'Occasion',
                filled: true,
                fillColor: Color(0xFFEFECE4),
              ),
              items: _occasions.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
              onChanged: (v) => _selectedOccasion = v ?? 'Smart Casual',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF888077))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3E3129),
              foregroundColor: const Color(0xFFF5F3EC),
            ),
            onPressed: () {
              final name = nameController.text.trim().isEmpty ? 'Untitled Outfit' : nameController.text.trim();
              final savedOutfit = SavedOutfit(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: name,
                occasion: _selectedOccasion,
                positions: List.from(_selectedPositions),
              );

              final session = context.read<SessionState>();
              session.saveOutfitComposition(savedOutfit);

              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Saved "$name" to your Outfits and Lookbook!')),
              );
            },
            child: const Text('Save Outfit'),
          ),
        ],
      ),
    );
  }

  Widget _buildGarmentImage(GarmentItem garment) {
    final path = garment.cutoutPath.isNotEmpty ? garment.cutoutPath : garment.imagePath;
    Widget rawImage;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      rawImage = Image.network(path, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.checkroom, size: 24));
    } else if (path.isNotEmpty && File(path).existsSync()) {
      rawImage = Image.file(File(path), fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.checkroom, size: 24));
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

class _StudioGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCDC6BA).withOpacity(0.3)
      ..strokeWidth = 0.5;

    const double step = 24.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
