import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/security/secure_media_store.dart';
import '../models/catalog_product.dart';
import '../services/cart_actions.dart';
import '../services/evoqe_api.dart';
import '../state/session_state.dart';
import '../widgets/secure_image.dart';
import '../widgets/default_avatar.dart';
import 'welcome_screen.dart';

class NinthScreen extends StatefulWidget {
  const NinthScreen({super.key, this.product});

  final CatalogProduct? product;

  @override
  State<NinthScreen> createState() => _NinthScreenState();
}

class _NinthScreenState extends State<NinthScreen> {
  String _selectedProfile = 'front';
  bool _isTryingOn = false;
  String? _resultUrl;
  String? _tryOnMessage;

  static const String _waistcoatThumbnailUrl =
      'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?auto=format&fit=crop&w=300&q=80';

  Future<void> _startTryOn() async {
    final product = widget.product;
    final session = context.read<SessionState>();
    final user = session.currentUser;
    final photoName = user?.bodyPhotoPaths[_selectedProfile];
    final photosMatchGender =
        user?.bodyPhotoGender == null || user?.bodyPhotoGender == user?.gender;
    if (product == null) {
      setState(() => _tryOnMessage = 'Select a catalog product to try it on.');
      return;
    }
    if (user == null || photoName == null || !photosMatchGender) {
      setState(
        () => _tryOnMessage = 'Add or update this profile photo in your profile settings to use virtual try-on.',
      );
      return;
    }

    final imageBytes = await context.read<SecureMediaStore>().load(photoName);
    if (!mounted) return;
    if (imageBytes == null) {
      setState(
        () => _tryOnMessage = 'The saved profile photo could not be opened. Update it in profile settings.',
      );
      return;
    }
    setState(() {
      _isTryingOn = true;
      _resultUrl = null;
      _tryOnMessage = 'Uploading your profile photo securely…';
    });
    try {
      final task = await EvoqeApi.startProductTryOn(
        productId: product.id,
        storeDomain: product.storeDomain,
        userImage: imageBytes,
        gender: user.gender,
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
            _tryOnMessage = null;
          });
          return;
        }
        if (status.status == 'error') {
          throw EvoqeApiException(
            status.error ?? 'YouCam could not process this profile photo.',
          );
        }
        setState(() => _tryOnMessage = 'Creating your virtual try-on…');
      }
      setState(
        () => _tryOnMessage =
            'This is taking longer than expected. Please try again shortly.',
      );
    } on EvoqeApiException catch (error) {
      if (mounted) setState(() => _tryOnMessage = error.message);
    } finally {
      if (mounted) setState(() => _isTryingOn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<SessionState>().currentUser;
    final selectedPhoto = user?.bodyPhotoPaths[_selectedProfile];
    final photosMatchGender =
        user?.bodyPhotoGender == null || user?.bodyPhotoGender == user?.gender;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EC),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // Top Bar: Back | EVOQE Logo | Shopping Bag Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF201D19),
                        size: 24,
                      ),
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const EvoqeHeaderLogo(),
                    IconButton(
                      icon: const Icon(
                        Icons.shopping_bag_outlined,
                        color: Color(0xFF201D19),
                        size: 22,
                      ),
                      onPressed: () => openShoppingBag(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Main Virtual Try-On Image Stage
                AspectRatio(
                  aspectRatio: 0.82,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.0),
                      color: const Color(0xFFE2DDD3),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: _resultUrl != null
                              ? Image.network(
                                  _resultUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      DefaultAvatar(
                                        gender: user?.gender,
                                        profile: _selectedProfile,
                                      ),
                                )
                              : selectedPhoto != null && photosMatchGender
                              ? SecureImage(
                                  fileName: selectedPhoto,
                                  placeholder: DefaultAvatar(
                                    gender: user?.gender,
                                    profile: _selectedProfile,
                                  ),
                                )
                              : DefaultAvatar(
                                  gender: user?.gender,
                                  profile: _selectedProfile,
                                  showLabel: true,
                                ),
                        ),

                        // Top Left Demo Badge
                        Positioned(
                          top: 14,
                          left: 14,
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
                              'ILLUSTRATIVE VIRTUAL TRY-ON DEMO',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: Color(0xFF3E3129),
                              ),
                            ),
                          ),
                        ),

                        // Left Carousel Navigation Arrow
                        Positioned(
                          left: 10,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: Color(0xEBF5F3EC),
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(2.0),
                                ),
                              ),
                              child: const Icon(
                                Icons.chevron_left_rounded,
                                color: Color(0xFF201D19),
                                size: 20,
                              ),
                            ),
                          ),
                        ),

                        // Right Carousel Navigation Arrow
                        Positioned(
                          right: 10,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: Color(0xEBF5F3EC),
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(2.0),
                                ),
                              ),
                              child: const Icon(
                                Icons.chevron_right_rounded,
                                color: Color(0xFF201D19),
                                size: 20,
                              ),
                            ),
                          ),
                        ),

                        // Bottom Left Avatar Mode Badge
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
                            child: Text(
                              !photosMatchGender
                                  ? 'Update profile photos in settings'
                                  : '${_profileLabel(_selectedProfile)} profile',
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

                const SizedBox(height: 18),

                // Product Item Summary Row
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.0),
                        color: const Color(0xFFE2DDD3),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        widget.product?.imageUrl ?? _waistcoatThumbnailUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(color: const Color(0xFFDDD7CC)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product?.title ?? 'Linen waistcoat',
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF201D19),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            widget.product == null
                                ? 'Maison Vale · sample \$2,400'
                                : '${widget.product!.vendor} · ${widget.product!.formattedPrice}',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF888077),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Select which saved onboarding profile photo to use.
                Row(
                  children: ['front', 'back', 'left', 'right'].map((profile) {
                    final selected = profile == _selectedProfile;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: SizedBox(
                            width: double.infinity,
                            child: Text(
                              _profileLabel(profile),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          selected: selected,
                          onSelected: (_) => setState(() {
                            _selectedProfile = profile;
                            _resultUrl = null;
                            _tryOnMessage = null;
                          }),
                          selectedColor: const Color(0xFF3E3129),
                          backgroundColor: const Color(0xFFEFECE4),
                          labelStyle: TextStyle(
                            fontSize: 11,
                            color: selected
                                ? const Color(0xFFF5F3EC)
                                : const Color(0xFF201D19),
                          ),
                          side: BorderSide(
                            color: selected
                                ? const Color(0xFF3E3129)
                                : const Color(0xFFCDC6BA),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (!photosMatchGender)
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text(
                      'Update your profile photos in profile settings before using virtual try-on.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF8A4F32)),
                    ),
                  ),

                const SizedBox(height: 20),

                // Primary Try-On Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isTryingOn ? null : _startTryOn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3E3129),
                      foregroundColor: const Color(0xFFF5F3EC),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isTryingOn ? 'Applying…' : 'Try-On',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                        SizedBox(width: 8),
                        if (_isTryingOn)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          const Icon(Icons.crop_free_rounded, size: 18),
                      ],
                    ),
                  ),
                ),
                if (_tryOnMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _tryOnMessage!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8A4F32),
                    ),
                  ),
                ],

                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => addProductToCart(context, widget.product),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF201D19),
                      side: const BorderSide(color: Color(0xFF8C8278)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text('Add to bag'),
                  ),
                ),

                const SizedBox(height: 20),

                // Secondary Actions: See Similar Fits
                Center(
                  child: GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'See similar fits',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF201D19),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Save Look Outlined Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFF5F3EC),
                      foregroundColor: const Color(0xFF201D19),
                      side: const BorderSide(
                        color: Color(0xFF8C8278),
                        width: 1.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Save Look',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF201D19),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _profileLabel(String profile) => switch (profile) {
    'front' => 'Front',
    'back' => 'Back',
    'left' => 'Left',
    'right' => 'Right',
    _ => 'Front',
  };
}
