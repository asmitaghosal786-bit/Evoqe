import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../data/security/secure_media_store.dart';
import '../services/evoqe_api.dart';
import '../state/session_state.dart';
import '../models/garment_item.dart';
import '../widgets/secure_image.dart';
import 'welcome_screen.dart';
import 'home_screen.dart';

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
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 85,
      );
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
                              Icon(
                                Icons.camera_alt_outlined,
                                size: 48,
                                color: Color(0xFF8C8278),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'No photo captured yet',
                                style: TextStyle(
                                  color: Color(0xFF8C8278),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Image.file(
                          File(_capturedImagePath!),
                          fit: BoxFit.cover,
                        ),
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Take Photo',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => _pickImage(ImageSource.gallery),
                          child: const Text(
                            'From Gallery',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () =>
                              setState(() => _capturedImagePath = null),
                          child: const Text(
                            'Retake',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LiveTryOnIsolateScreen(
                                  imagePath: _capturedImagePath!,
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            'Isolate Garment',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
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
    final cutout = await GarmentSegmentationService.isolateGarment(
      widget.imagePath,
    );
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
                'Preparing this photo as a clothing reference.',
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
                              CircularProgressIndicator(
                                color: Color(0xFF3E3129),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Preparing garment reference...',
                                style: TextStyle(color: Color(0xFF6E6760)),
                              ),
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Retake',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LiveTryOnPersonSelectScreen(
                                  garmentImagePath: _cutoutPath!,
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            'Continue to Try-On',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
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

/// Screen C: Select the Person Image for Virtual Try-On
class LiveTryOnPersonSelectScreen extends StatefulWidget {
  final String garmentImagePath;
  const LiveTryOnPersonSelectScreen({
    super.key,
    required this.garmentImagePath,
  });

  @override
  State<LiveTryOnPersonSelectScreen> createState() =>
      _LiveTryOnPersonSelectScreenState();
}

class _LiveTryOnPersonSelectScreenState
    extends State<LiveTryOnPersonSelectScreen> {
  String? _personImagePath;

  Future<void> _pickPersonImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 85,
      );
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
                              Icon(
                                Icons.person_outline_rounded,
                                size: 48,
                                color: Color(0xFF8C8278),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'No person photo selected',
                                style: TextStyle(
                                  color: Color(0xFF8C8278),
                                  fontSize: 13,
                                ),
                              ),
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => _pickPersonImage(ImageSource.camera),
                          child: const Text(
                            'Take Photo',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () =>
                              _pickPersonImage(ImageSource.gallery),
                          child: const Text(
                            'From Gallery',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LiveTryOnAvatarResultScreen(
                            garmentImagePath: widget.garmentImagePath,
                            personImagePath: _personImagePath,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Generate Virtual Try-On',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
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

/// Screen D: Virtual Try-On Result Screen on User's Avatar
class LiveTryOnAvatarResultScreen extends StatefulWidget {
  final String garmentImagePath;
  final String? personImagePath;

  const LiveTryOnAvatarResultScreen({
    super.key,
    required this.garmentImagePath,
    this.personImagePath,
  });

  @override
  State<LiveTryOnAvatarResultScreen> createState() =>
      _LiveTryOnAvatarResultScreenState();
}

class _LiveTryOnAvatarResultScreenState
    extends State<LiveTryOnAvatarResultScreen> {
  bool _isGenerating = true;
  String? _resultUrl;
  String? _error;

  @override
  void initState() {
    super.initState();
    _runAvatarTryOn();
  }

  Future<void> _runAvatarTryOn() async {
    try {
      final session = context.read<SessionState>();
      final user = session.currentUser;
      if (EvoqeApi.storeDomain.isEmpty) {
        throw const EvoqeApiException(
          'Set SHOPIFY_STORE_DOMAIN to use custom garment try-on.',
        );
      }

      final Uint8List? userImage;
      if (widget.personImagePath != null) {
        userImage = await File(widget.personImagePath!).readAsBytes();
      } else {
        final profilePhoto = user?.selfiePath ?? user?.bodyPhotoPaths['front'];
        userImage = profilePhoto == null
            ? null
            : await context.read<SecureMediaStore>().load(profilePhoto);
      }
      if (userImage == null || userImage.isEmpty) {
        throw const EvoqeApiException(
          'Choose a person photo or add a profile selfie before trying on.',
        );
      }

      final garmentFile = File(widget.garmentImagePath);
      if (!await garmentFile.exists()) {
        throw const EvoqeApiException(
          'The selected garment photo is unavailable.',
        );
      }
      final garmentImage = await garmentFile.readAsBytes();
      final task = await EvoqeApi.startCustomFashionTryOn(
        storeDomain: EvoqeApi.storeDomain,
        userImage: userImage,
        referenceImage: garmentImage,
        gender: user?.gender,
      );
      for (var attempt = 0; attempt < 60; attempt++) {
        await Future.delayed(const Duration(seconds: 3));
        if (!mounted) return;
        final status = await EvoqeApi.getProductTryOnStatus(
          taskId: task.taskId,
          taskType: task.taskType,
        );
        if (status.status == 'success' && status.resultUrl != null) {
          setState(() {
            _resultUrl = status.resultUrl;
            _isGenerating = false;
          });
          return;
        }
        if (status.status == 'error') {
          throw EvoqeApiException(
            status.error ?? 'YouCam could not process this try-on.',
          );
        }
      }
      throw const EvoqeApiException(
        'This try-on is taking longer than expected. Please try again shortly.',
      );
    } on EvoqeApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } on FileSystemException catch (error) {
      if (mounted) {
        setState(() => _error = 'Could not load a selected photo: $error');
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionState>();
    final user = session.currentUser;
    final avatarPhoto = user?.selfiePath ?? user?.bodyPhotoPaths['front'];
    const defaultAvatarUrl =
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=600&q=80';

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
                'Avatar Try-On',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF201D19),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your selected garment and profile photo are sent to YouCam only for this try-on.',
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
                              CircularProgressIndicator(
                                color: Color(0xFF3E3129),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Fitting garment onto your avatar...',
                                style: TextStyle(color: Color(0xFF6E6760)),
                              ),
                            ],
                          ),
                        )
                      : _resultUrl != null
                      ? Image.network(
                          _resultUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Center(
                            child: Text(
                              'The try-on result could not be displayed.',
                            ),
                          ),
                        )
                      : Stack(
                          children: [
                            Positioned.fill(
                              child: widget.personImagePath != null
                                  ? Image.file(
                                      File(widget.personImagePath!),
                                      fit: BoxFit.cover,
                                    )
                                  : avatarPhoto != null
                                  ? SecureImage(
                                      fileName: avatarPhoto,
                                      placeholder: Image.network(
                                        defaultAvatarUrl,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Image.network(
                                      defaultAvatarUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, trace) =>
                                          Container(
                                            color: const Color(0xFFDDD7CC),
                                            child: const Center(
                                              child: Icon(
                                                Icons.person_outline_rounded,
                                                size: 64,
                                                color: Color(0xFF8C8278),
                                              ),
                                            ),
                                          ),
                                    ),
                            ),
                            Positioned(
                              bottom: 20,
                              right: 20,
                              child: Container(
                                width: 95,
                                height: 125,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F3EC),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.12,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Image.file(
                                  File(widget.garmentImagePath),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            Positioned(
                              left: 14,
                              bottom: 14,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xEBF5F3EC),
                                  borderRadius: BorderRadius.circular(2.0),
                                ),
                                child: const Text(
                                  'AI-generated try-on',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF201D19),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8A4F32),
                    ),
                  ),
                ),
              if (!_isGenerating) ...[
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF201D19),
                            side: const BorderSide(color: Color(0xFFCDC6BA)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const EighthScreen(initialTabIndex: 0),
                              ),
                              (route) => false,
                            );
                          },
                          child: const Text(
                            'Return to Home',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            final savedLook = SavedLook(
                              id: DateTime.now().millisecondsSinceEpoch
                                  .toString(),
                              title: 'Avatar Try-On Look',
                              category: 'Avatar Try-On',
                              imagePath:
                                  _resultUrl ??
                                  widget.personImagePath ??
                                  avatarPhoto ??
                                  defaultAvatarUrl,
                              garmentImagePath: widget.garmentImagePath,
                            );
                            context.read<SessionState>().saveLook(savedLook);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Look saved to Saved page!'),
                              ),
                            );
                          },
                          child: const Text(
                            'Save the Look',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
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
