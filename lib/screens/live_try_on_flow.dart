import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../state/session_state.dart';
import '../models/garment_item.dart';
import '../models/lookbook_model.dart';
import 'welcome_screen.dart';

/// Screen A: Capture a Garment for Live Try-On
class LiveTryOnCaptureScreen extends StatefulWidget {
  const LiveTryOnCaptureScreen({super.key});

  @override
  State<LiveTryOnCaptureScreen> createState() => _LiveTryOnCaptureScreenState();
}

class _LiveTryOnCaptureScreenState extends State<LiveTryOnCaptureScreen> {
  String? _capturedImagePath;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source);
      if (!mounted) return;
      if (picked != null) {
        setState(() {
          _capturedImagePath = picked.path;
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
                'Capture an Item',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF201D19),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Photograph a clothing item on a hanger, rack, or laid flat in store.',
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
                  child: _capturedImagePath == null
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt_outlined, size: 48, color: Color(0xFF8C8278)),
                              SizedBox(height: 12),
                              Text('No photo captured yet', style: TextStyle(color: Color(0xFF8C8278), fontSize: 13)),
                            ],
                          ),
                        )
                      : Image.file(File(_capturedImagePath!), fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 24),
              if (_capturedImagePath == null) ...[
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => _pickImage(ImageSource.camera),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3E3129),
                            foregroundColor: const Color(0xFFF5F3EC),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
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
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF201D19),
                            side: const BorderSide(color: Color(0xFFCDC6BA)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => setState(() => _capturedImagePath = null),
                          child: const Text('Retake', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
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
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LiveTryOnIsolateScreen(imagePath: _capturedImagePath!),
                              ),
                            );
                          },
                          child: const Text('Isolate Garment', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Screen B: Isolate the Garment (Background Removal & Cutout Review)
class LiveTryOnIsolateScreen extends StatefulWidget {
  final String imagePath;
  const LiveTryOnIsolateScreen({super.key, required this.imagePath});

  @override
  State<LiveTryOnIsolateScreen> createState() => _LiveTryOnIsolateScreenState();
}

class _LiveTryOnIsolateScreenState extends State<LiveTryOnIsolateScreen> {
  bool _isProcessing = true;
  String? _cutoutPath;

  @override
  void initState() {
    super.initState();
    _processIsolation();
  }

  Future<void> _processIsolation() async {
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
                'Isolate Garment',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF201D19),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Removing background to create a clean clothing cutout.',
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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: Color(0xFF3E3129)),
                              SizedBox(height: 16),
                              Text('Isolating garment from background...', style: TextStyle(color: Color(0xFF6E6760))),
                            ],
                          ),
                        )
                      : Image.file(File(_cutoutPath!), fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 24),
              if (!_isProcessing) ...[
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF201D19),
                            side: const BorderSide(color: Color(0xFFCDC6BA)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Retake', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
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
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LiveTryOnPersonSelectScreen(garmentImagePath: _cutoutPath!),
                              ),
                            );
                          },
                          child: const Text('Continue to Try-On', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF3E3129),
                      side: const BorderSide(color: Color(0xFF3E3129)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      final garment = GarmentItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: 'In-store garment',
                        imagePath: widget.imagePath,
                        cutoutPath: _cutoutPath!,
                        category: 'General',
                        primaryColor: 'Neutral',
                        source: 'live_try_on',
                      );
                      context.read<SessionState>().addGarment(garment);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Garment saved to Digital Closet!')),
                      );
                    },
                    child: const Text('Save to Digital Closet', style: TextStyle(fontWeight: FontWeight.w600)),
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

/// Screen C: Select the Person Image for Virtual Try-On
class LiveTryOnPersonSelectScreen extends StatefulWidget {
  final String garmentImagePath;
  const LiveTryOnPersonSelectScreen({super.key, required this.garmentImagePath});

  @override
  State<LiveTryOnPersonSelectScreen> createState() => _LiveTryOnPersonSelectScreenState();
}

class _LiveTryOnPersonSelectScreenState extends State<LiveTryOnPersonSelectScreen> {
  String? _personImagePath;

  Future<void> _pickPersonImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source);
      if (!mounted) return;
      if (picked != null) {
        setState(() {
          _personImagePath = picked.path;
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not load photo. Try again.')),
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
                'Select Your Photo',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF201D19),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose a clear, well-lit photo of yourself to preview the garment.',
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
                  child: _personImagePath == null
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_outline_rounded, size: 48, color: Color(0xFF8C8278)),
                              SizedBox(height: 12),
                              Text('No person photo selected', style: TextStyle(color: Color(0xFF8C8278), fontSize: 13)),
                            ],
                          ),
                        )
                      : Image.file(File(_personImagePath!), fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 24),
              if (_personImagePath == null) ...[
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
                          onPressed: () => _pickPersonImage(ImageSource.camera),
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
                          onPressed: () => _pickPersonImage(ImageSource.gallery),
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
                          builder: (_) => LiveTryOnResultScreen(
                            personImagePath: _personImagePath!,
                            garmentImagePath: widget.garmentImagePath,
                          ),
                        ),
                      );
                    },
                    child: const Text('Generate Virtual Try-On', style: TextStyle(fontWeight: FontWeight.w600)),
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

/// Screen D: Virtual Try-On Result Screen
class LiveTryOnResultScreen extends StatefulWidget {
  final String personImagePath;
  final String garmentImagePath;

  const LiveTryOnResultScreen({
    super.key,
    required this.personImagePath,
    required this.garmentImagePath,
  });

  @override
  State<LiveTryOnResultScreen> createState() => _LiveTryOnResultScreenState();
}

class _LiveTryOnResultScreenState extends State<LiveTryOnResultScreen> {
  bool _isGenerating = true;
  bool _showOriginal = false;

  @override
  void initState() {
    super.initState();
    _runTryOn();
  }

  Future<void> _runTryOn() async {
    await VirtualTryOnService.performTryOn(
      personImagePath: widget.personImagePath,
      garmentImagePath: widget.garmentImagePath,
    );
    if (!mounted) return;
    setState(() {
      _isGenerating = false;
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
                'Virtual Try-On Result',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF201D19),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'AI simulated try-on preview (Demo preview mode).',
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
                  child: _isGenerating
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: Color(0xFF3E3129)),
                              SizedBox(height: 16),
                              Text('Rendering virtual garment transfer...', style: TextStyle(color: Color(0xFF6E6760))),
                            ],
                          ),
                        )
                      : Stack(
                          children: [
                            Positioned.fill(
                              child: Image.file(
                                File(widget.personImagePath),
                                fit: BoxFit.cover,
                              ),
                            ),
                            if (!_showOriginal)
                              Positioned(
                                bottom: 20,
                                right: 20,
                                child: Container(
                                  width: 90,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white, width: 2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Image.file(File(widget.garmentImagePath), fit: BoxFit.cover),
                                ),
                              ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
              if (!_isGenerating) ...[
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF201D19),
                            side: const BorderSide(color: Color(0xFFCDC6BA)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => setState(() => _showOriginal = !_showOriginal),
                          child: Text(_showOriginal ? 'Show Try-On Result' : 'Compare with Original', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3E3129),
                            foregroundColor: const Color(0xFFF5F3EC),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            final garment = GarmentItem(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              name: 'Live try-on garment',
                              imagePath: widget.personImagePath,
                              cutoutPath: widget.garmentImagePath,
                              category: 'General',
                              primaryColor: 'Neutral',
                              source: 'live_try_on',
                            );
                            context.read<SessionState>().addGarment(garment);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Garment saved to Digital Closet!')),
                            );
                          },
                          child: const Text('Save to Closet', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF3E3129),
                      side: const BorderSide(color: Color(0xFF3E3129)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      final session = context.read<SessionState>();
                      session.currentDraft.references.add(
                        LookbookReference(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          imagePath: widget.garmentImagePath,
                          label: 'Live Try-On Look',
                          category: 'Try-On',
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Added to current Lookbook draft!')),
                      );
                    },
                    child: const Text('Save to Lookbook', style: TextStyle(fontWeight: FontWeight.w600)),
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
