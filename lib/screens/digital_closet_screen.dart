import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../state/session_state.dart';
import '../models/garment_item.dart';
import '../models/lookbook_model.dart';
import 'welcome_screen.dart';

/// Screen A: Digital Closet Dashboard
class DigitalClosetScreen extends StatefulWidget {
  const DigitalClosetScreen({super.key});

  @override
  State<DigitalClosetScreen> createState() => _DigitalClosetScreenState();
}

class _DigitalClosetScreenState extends State<DigitalClosetScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _favoritesOnly = false;

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

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionState>();
    final allGarments = session.garments;

    final filtered = allGarments.where((g) {
      if (_selectedCategory != 'All' && g.category != _selectedCategory) return false;
      if (_favoritesOnly && !g.isFavorite) return false;
      if (_searchQuery.isNotEmpty && !g.name.toLowerCase().contains(_searchQuery.toLowerCase())) return false;
      return true;
    }).toList();

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
            icon: Icon(_favoritesOnly ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: const Color(0xFF201D19)),
            onPressed: () => setState(() => _favoritesOnly = !_favoritesOnly),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Digital Closet',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 28,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF201D19),
                    ),
                  ),
                  Text(
                    '${allGarments.length} items',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF888077)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search wardrobe...',
                  hintStyle: const TextStyle(color: Color(0xFF888077), fontSize: 13.5),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF888077)),
                  filled: true,
                  fillColor: const Color(0xFFEFECE4),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
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
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF3E3129) : const Color(0xFFEFECE4),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFCDC6BA)),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? const Color(0xFFF5F3EC) : const Color(0xFF201D19),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.checkroom_outlined, size: 56, color: Color(0xFF8C8278)),
                            const SizedBox(height: 12),
                            const Text(
                              'No wardrobe items found',
                              style: TextStyle(fontFamily: 'serif', fontSize: 18, color: Color(0xFF201D19)),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Upload photographs of clothes you own to build your digital closet.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12.5, color: Color(0xFF888077)),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.78,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final garment = filtered[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => GarmentDetailScreen(garmentId: garment.id),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFECE4),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFCDC6BA)),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: garment.cutoutPath.isNotEmpty && File(garment.cutoutPath).existsSync()
                                        ? Image.file(File(garment.cutoutPath), fit: BoxFit.contain)
                                        : garment.imagePath.isNotEmpty && File(garment.imagePath).existsSync()
                                            ? Image.file(File(garment.imagePath), fit: BoxFit.contain)
                                            : Container(
                                                color: const Color(0xFFE2DDD3),
                                                child: const Icon(Icons.checkroom, size: 40, color: Color(0xFF8C8278)),
                                              ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      color: const Color(0xCCF5F3EC),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            garment.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF201D19)),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${garment.category} · ${garment.primaryColor}',
                                            style: const TextStyle(fontSize: 11, color: Color(0xFF888077)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
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
                                          size: 16,
                                          color: const Color(0xFF3E3129),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3E3129),
        foregroundColor: const Color(0xFFF5F3EC),
        tooltip: 'Add Clothing',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddClothingCaptureScreen()),
          );
        },
        child: const Icon(Icons.add_photo_alternate_outlined),
      ),
    );
  }
}

/// Screen B: Add Clothing (Capture & Isolate)
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
                'Add to Digital Closet',
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
                'Extracting Garment',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF201D19),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Removing background for your digital wardrobe...',
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

/// Screen C: Garment Details & Confirmation
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
  String _selectedCategory = 'Tops';
  String _primaryColor = 'Neutral';

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
    'Neutral',
    'Black',
    'White',
    'Beige',
    'Brown',
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
    _nameController = TextEditingController(text: widget.existingGarment?.name ?? 'New Garment');
    _brandController = TextEditingController(text: widget.existingGarment?.brand ?? '');
    _selectedCategory = widget.existingGarment?.category ?? 'Tops';
    _primaryColor = widget.existingGarment?.primaryColor ?? 'Neutral';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
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
              const Text(
                'Garment Details',
                style: TextStyle(fontFamily: 'serif', fontSize: 28, color: Color(0xFF201D19)),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 160,
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFECE4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFCDC6BA)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.file(File(widget.cutoutPath), fit: BoxFit.contain),
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
                onChanged: (v) => setState(() => _primaryColor = v ?? 'Neutral'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _brandController,
                decoration: const InputDecoration(labelText: 'Brand (Optional)', filled: true, fillColor: Color(0xFFEFECE4)),
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
                    if (widget.existingGarment != null) {
                      widget.existingGarment!.name = _nameController.text.trim();
                      widget.existingGarment!.category = _selectedCategory;
                      widget.existingGarment!.primaryColor = _primaryColor;
                      widget.existingGarment!.brand = _brandController.text.trim().isEmpty ? null : _brandController.text.trim();
                      session.updateGarment(widget.existingGarment!);
                    } else {
                      final garment = GarmentItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: _nameController.text.trim(),
                        imagePath: widget.imagePath,
                        cutoutPath: widget.cutoutPath,
                        category: _selectedCategory,
                        primaryColor: _primaryColor,
                        brand: _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
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
                  child: const Text('Save Look', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Screen D: View a Garment Details
class GarmentDetailScreen extends StatelessWidget {
  final String garmentId;
  const GarmentDetailScreen({super.key, required this.garmentId});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionState>();
    final garment = session.garments.firstWhere(
      (g) => g.id == garmentId,
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
            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFA33A3A)),
            onPressed: () {
              session.deleteGarment(garment.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Garment deleted.')),
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
              SizedBox(
                height: 280,
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFECE4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFCDC6BA)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: garment.cutoutPath.isNotEmpty && File(garment.cutoutPath).existsSync()
                      ? Image.file(File(garment.cutoutPath), fit: BoxFit.contain)
                      : const Icon(Icons.checkroom, size: 64, color: Color(0xFF8C8278)),
                ),
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
              const SizedBox(height: 8),
              Text(
                'Category: ${garment.category} · Color: ${garment.primaryColor}',
                style: const TextStyle(fontSize: 14, color: Color(0xFF888077)),
              ),
              if (garment.brand != null && garment.brand!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Brand: ${garment.brand}',
                  style: const TextStyle(fontSize: 14, color: Color(0xFF888077)),
                ),
              ],
              const SizedBox(height: 32),
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
                    session.currentDraft.references.add(
                      LookbookReference(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        imagePath: garment.cutoutPath,
                        label: garment.name,
                        category: garment.category,
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Garment added to current Lookbook draft!')),
                    );
                  },
                  child: const Text('Save to Lookbook', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
