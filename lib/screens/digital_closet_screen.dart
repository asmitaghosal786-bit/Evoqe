import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../state/session_state.dart';
import '../models/garment_item.dart';
import '../models/lookbook_model.dart';
import '../widgets/living_closet/editorial_header.dart';
import '../widgets/living_closet/collection_section.dart';
import '../widgets/living_closet/style_studio_section.dart';
import '../widgets/living_closet/outfit_dna_section.dart';
import 'welcome_screen.dart';

/// Entry Point: EVOQE — The Living Closet
class DigitalClosetScreen extends StatefulWidget {
  final int initialSectionIndex;
  const DigitalClosetScreen({super.key, this.initialSectionIndex = 0});

  @override
  State<DigitalClosetScreen> createState() => _DigitalClosetScreenState();
}

class _DigitalClosetScreenState extends State<DigitalClosetScreen> {
  late int _activeSectionIndex;

  @override
  void initState() {
    super.initState();
    _activeSectionIndex = widget.initialSectionIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F3EC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF201D19)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const EvoqeHeaderLogo(),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // Living Closet Editorial Magazine Header & Section Selector
                LivingClosetEditorialHeader(
                  activeSectionIndex: _activeSectionIndex,
                  onSectionSelected: (index) {
                    setState(() {
                      _activeSectionIndex = index;
                    });
                  },
                ),

                const SizedBox(height: 8),

                // Section Content View (Renders active section content dynamically so scrolling fits exact content height)
                if (_activeSectionIndex == 0)
                  const CollectionSection()
                else if (_activeSectionIndex == 1)
                  const StyleStudioSection()
                else
                  const OutfitDnaSection(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _activeSectionIndex == 0
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF3E3129),
              foregroundColor: const Color(0xFFF5F3EC),
              elevation: 2,
              tooltip: 'Add Clothing',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddClothingCaptureScreen()),
                );
              },
              icon: const Icon(Icons.add_a_photo_outlined, size: 18),
              label: const Text(
                'Add Clothing',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, letterSpacing: 0.2),
              ),
            )
          : null,
    );
  }
}

/// Add Clothing Capture Screen (Camera / Gallery)
class AddClothingCaptureScreen extends StatefulWidget {
  const AddClothingCaptureScreen({super.key});

  @override
  State<AddClothingCaptureScreen> createState() => _AddClothingCaptureScreenState();
}

class _AddClothingCaptureScreenState extends State<AddClothingCaptureScreen> {
  String? _imagePath;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source);
      if (!mounted) return;
      if (picked != null) {
        setState(() {
          _imagePath = picked.path;
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not capture photo. Try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F3EC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF201D19)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const EvoqeHeaderLogo(),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add to Living Closet',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF201D19),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Photograph an individual clothing item clearly against a neutral background.',
                style: TextStyle(fontSize: 13, color: Color(0xFF6E6760)),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2DDD3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFCDC6BA)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _imagePath == null
                      ? const Center(
                          child: Icon(Icons.add_a_photo_outlined, size: 48, color: Color(0xFF8C8278)),
                        )
                      : Image.file(File(_imagePath!), fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 24),
              if (_imagePath == null) ...[
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3E3129),
                            foregroundColor: const Color(0xFFF5F3EC),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => _pickImage(ImageSource.camera),
                          child: const Text('Take Photo', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF201D19),
                            side: const BorderSide(color: Color(0xFFCDC6BA)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => _pickImage(ImageSource.gallery),
                          child: const Text('From Gallery', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3E3129),
                      foregroundColor: const Color(0xFFF5F3EC),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddClothingProcessingScreen(imagePath: _imagePath!),
                        ),
                      );
                    },
                    child: const Text('Process & Isolate Garment', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AddClothingProcessingScreen extends StatefulWidget {
  final String imagePath;
  const AddClothingProcessingScreen({super.key, required this.imagePath});

  @override
  State<AddClothingProcessingScreen> createState() => _AddClothingProcessingScreenState();
}

class _AddClothingProcessingScreenState extends State<AddClothingProcessingScreen> {
  bool _isProcessing = true;
  String? _cutoutPath;

  @override
  void initState() {
    super.initState();
    _process();
  }

  Future<void> _process() async {
    final cutout = await GarmentSegmentationService.isolateGarment(widget.imagePath);
    if (!mounted) return;
    setState(() {
      _cutoutPath = cutout;
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F3EC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF201D19)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const EvoqeHeaderLogo(),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Extracting Garment Cutout',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF201D19),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Removing background for your living wardrobe collection...',
                style: TextStyle(fontSize: 13, color: Color(0xFF6E6760)),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFECE4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFCDC6BA)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _isProcessing
                      ? const Center(
                          child: CircularProgressIndicator(color: Color(0xFF3E3129)),
                        )
                      : Image.file(File(_cutoutPath!), fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 24),
              if (!_isProcessing) ...[
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3E3129),
                      foregroundColor: const Color(0xFFF5F3EC),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GarmentEditDetailsScreen(
                            imagePath: widget.imagePath,
                            cutoutPath: _cutoutPath!,
                          ),
                        ),
                      );
                    },
                    child: const Text('Continue to Details', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Garment Details & Confirmation Screen
class GarmentEditDetailsScreen extends StatefulWidget {
  final String imagePath;
  final String cutoutPath;
  final GarmentItem? existingGarment;

  const GarmentEditDetailsScreen({
    super.key,
    required this.imagePath,
    required this.cutoutPath,
    this.existingGarment,
  });

  @override
  State<GarmentEditDetailsScreen> createState() => _GarmentEditDetailsScreenState();
}

class _GarmentEditDetailsScreenState extends State<GarmentEditDetailsScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _brandController;
  late final TextEditingController _tagsController;
  String _selectedCategory = 'Tops';
  String _primaryColor = 'Beige';

  final List<String> _categories = [
    'Tops',
    'Bottoms',
    'Dresses',
    'Outerwear',
    'Shoes',
    'Bags',
    'Accessories',
    'General',
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
    'Pink',
    'Yellow',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existingGarment?.name ?? '');
    _brandController = TextEditingController(text: widget.existingGarment?.brand ?? '');
    _tagsController = TextEditingController(text: widget.existingGarment?.tags.join(', ') ?? '');
    _selectedCategory = widget.existingGarment?.category ?? 'Tops';
    _primaryColor = widget.existingGarment?.primaryColor ?? 'Beige';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F3EC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF201D19)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const EvoqeHeaderLogo(),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.existingGarment != null ? 'Edit Garment Details' : 'Garment Details',
                style: const TextStyle(fontFamily: 'serif', fontSize: 28, color: Color(0xFF201D19)),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFECE4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFCDC6BA)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: File(widget.cutoutPath).existsSync()
                      ? Image.file(File(widget.cutoutPath), fit: BoxFit.contain)
                      : Image.network(widget.cutoutPath, fit: BoxFit.contain, errorBuilder: (context, error, trace) => const Icon(Icons.checkroom, size: 48)),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Item Name', filled: true, fillColor: Color(0xFFEFECE4)),
              ),
              const SizedBox(height: 14),
              const Text('Category', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF6E6760))),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                dropdownColor: const Color(0xFFF5F3EC),
                decoration: const InputDecoration(filled: true, fillColor: Color(0xFFEFECE4)),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _selectedCategory = v ?? 'General'),
              ),
              const SizedBox(height: 14),
              const Text('Primary Color', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF6E6760))),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _primaryColor,
                dropdownColor: const Color(0xFFF5F3EC),
                decoration: const InputDecoration(filled: true, fillColor: Color(0xFFEFECE4)),
                items: _colors.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _primaryColor = v ?? 'Beige'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _brandController,
                decoration: const InputDecoration(labelText: 'Brand (Optional)', filled: true, fillColor: Color(0xFFEFECE4)),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _tagsController,
                decoration: const InputDecoration(labelText: 'Tags (comma separated, e.g. Silk, Tailored)', filled: true, fillColor: Color(0xFFEFECE4)),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3E3129),
                    foregroundColor: const Color(0xFFF5F3EC),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    final session = context.read<SessionState>();
                    final tags = _tagsController.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
                    final name = _nameController.text.trim().isEmpty ? 'Garment Item' : _nameController.text.trim();

                    if (widget.existingGarment != null) {
                      widget.existingGarment!.name = name;
                      widget.existingGarment!.category = _selectedCategory;
                      widget.existingGarment!.primaryColor = _primaryColor;
                      widget.existingGarment!.brand = _brandController.text.trim().isEmpty ? null : _brandController.text.trim();
                      widget.existingGarment!.tags = tags;
                      session.updateGarment(widget.existingGarment!);
                    } else {
                      final garment = GarmentItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: name,
                        imagePath: widget.imagePath,
                        cutoutPath: widget.cutoutPath,
                        category: _selectedCategory,
                        primaryColor: _primaryColor,
                        brand: _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
                        tags: tags,
                        source: 'digital_closet',
                      );
                      session.addGarment(garment);
                    }

                    Navigator.popUntil(context, (route) => route.isFirst || route.settings.name == '/' || Navigator.canPop(context) == false);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const DigitalClosetScreen()),
                    );
                  },
                  child: const Text('Save Garment to Collection', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Garment Detail Screen (Supports Cutout/Original Toggle & Editing)
class GarmentDetailScreen extends StatefulWidget {
  final String garmentId;
  const GarmentDetailScreen({super.key, required this.garmentId});

  @override
  State<GarmentDetailScreen> createState() => _GarmentDetailScreenState();
}

class _GarmentDetailScreenState extends State<GarmentDetailScreen> {
  bool _showOriginalPhoto = false;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionState>();
    final garment = session.garments.firstWhere(
      (g) => g.id == widget.garmentId,
      orElse: () => GarmentItem(
        id: '',
        name: 'Item not found',
        imagePath: '',
        cutoutPath: '',
        category: 'General',
        primaryColor: 'Neutral',
        source: '',
      ),
    );

    if (garment.id.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F3EC),
        appBar: AppBar(backgroundColor: const Color(0xFFF5F3EC), elevation: 0),
        body: const Center(child: Text('Garment not found')),
      );
    }

    final displayImagePath = _showOriginalPhoto
        ? (garment.imagePath.isNotEmpty ? garment.imagePath : garment.cutoutPath)
        : (garment.cutoutPath.isNotEmpty ? garment.cutoutPath : garment.imagePath);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F3EC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF201D19)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const EvoqeHeaderLogo(),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF201D19)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GarmentEditDetailsScreen(
                    imagePath: garment.imagePath,
                    cutoutPath: garment.cutoutPath,
                    existingGarment: garment,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFA33A3A)),
            onPressed: () {
              session.deleteGarment(garment.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Garment deleted from collection.')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Garment Display Card with Cutout/Original Toggle
              Stack(
                children: [
                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFECE4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFCDC6BA)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: _buildGarmentImageWidget(displayImagePath),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _showOriginalPhoto = !_showOriginalPhoto;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xEBF5F3EC),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFCDC6BA)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _showOriginalPhoto ? Icons.auto_awesome : Icons.image,
                              size: 14,
                              color: const Color(0xFF3E3129),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _showOriginalPhoto ? 'Cutout Mode' : 'Original Photo',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF3E3129)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      garment.name,
                      style: const TextStyle(fontFamily: 'serif', fontSize: 26, color: Color(0xFF201D19)),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      garment.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: const Color(0xFF3E3129),
                    ),
                    onPressed: () => session.toggleFavorite(garment.id),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Category: ${garment.category} · Primary Color: ${garment.primaryColor}',
                style: const TextStyle(fontSize: 13.5, color: Color(0xFF6E6760)),
              ),
              if (garment.brand != null && garment.brand!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Brand: ${garment.brand}',
                  style: const TextStyle(fontSize: 13.5, color: Color(0xFF888077)),
                ),
              ],

              if (garment.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: garment.tags.map((t) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2DDD3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('#$t', style: const TextStyle(fontSize: 11, color: Color(0xFF3E3129))),
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 28),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3E3129),
                          foregroundColor: const Color(0xFFF5F3EC),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        icon: const Icon(Icons.auto_awesome_outlined, size: 18),
                        label: const Text('Analyze in Outfit DNA', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DigitalClosetScreen(initialSectionIndex: 2),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF201D19),
                    side: const BorderSide(color: Color(0xFFCDC6BA)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  icon: const Icon(Icons.bookmark_border_rounded, size: 18),
                  label: const Text('Save to Lookbook Draft', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  onPressed: () {
                    session.currentDraft.references.add(
                      LookbookReference(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        imagePath: garment.cutoutPath.isNotEmpty ? garment.cutoutPath : garment.imagePath,
                        label: garment.name,
                        category: garment.category,
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Garment saved to Lookbook draft!')),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGarmentImageWidget(String path) {
    Widget rawImage;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      rawImage = Image.network(path, fit: BoxFit.contain, errorBuilder: (context, error, trace) => const Icon(Icons.checkroom, size: 64, color: Color(0xFF8C8278)));
    } else if (path.isNotEmpty && File(path).existsSync()) {
      rawImage = Image.file(File(path), fit: BoxFit.contain, errorBuilder: (context, error, trace) => const Icon(Icons.checkroom, size: 64, color: Color(0xFF8C8278)));
    } else {
      rawImage = Container(
        color: const Color(0xFFE2DDD3),
        child: const Icon(Icons.checkroom, size: 64, color: Color(0xFF8C8278)),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFAF8F6F0),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18201D19),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4.0),
      child: rawImage,
    );
  }
}
