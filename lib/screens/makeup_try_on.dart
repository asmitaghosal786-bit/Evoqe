import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/security/secure_media_store.dart';
import '../models/catalog_product.dart';
import '../services/cart_actions.dart';
import '../services/evoqe_api.dart';
import '../state/session_state.dart';
import '../widgets/secure_image.dart';
import 'welcome_screen.dart';

class EleventhScreen extends StatefulWidget {
  const EleventhScreen({super.key, this.product});

  final CatalogProduct? product;

  @override
  State<EleventhScreen> createState() => _EleventhScreenState();
}

class _EleventhScreenState extends State<EleventhScreen> {
  int _selectedShadeIndex = 3; // "Warm Rose 04" in screenshot (4th item)
  bool _isShadeApplied = false;
  bool _isLookSaved = false;
  bool _isTryingOn = false;
  String? _makeupResultUrl;
  String? _tryOnMessage;

  static const String _makeupModelUrl =
      'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?auto=format&fit=crop&w=800&q=80';

  static const List<Map<String, dynamic>> _demoShades = [
    {'name': 'Dusty Rose 01', 'color': Color(0xFFB56566)},
    {'name': 'Soft Nude 02', 'color': Color(0xFFC89A82)},
    {'name': 'Deep Berry 03', 'color': Color(0xFF702D38)},
    {'name': 'Warm Rose 04', 'color': Color(0xFF9E2B2B)},
    {'name': 'Velvet Peach 05', 'color': Color(0xFFD6A28C)},
  ];

  List<Map<String, dynamic>> get _shades {
    final product = widget.product;
    if (product == null) return _demoShades;
    return product.variants
        .where((variant) => variant['swatch_hex'] is String)
        .map((variant) {
          final swatch = variant['swatch_hex'] as String;
          final hex = int.tryParse(swatch.replaceFirst('#', ''), radix: 16);
          return <String, dynamic>{
            'name': variant['title']?.toString() ?? 'Shade',
            'color': Color(hex == null ? 0xFFB8A99A : 0xFF000000 | hex),
            'variant': variant,
          };
        })
        .toList();
  }

  Future<void> _startMakeupTryOn(Map<String, dynamic> variant) async {
    final product = widget.product;
    final user = context.read<SessionState>().currentUser;
    final selfieName = user?.selfiePath;
    final variantId = variant['id'];
    if (product == null || selfieName == null || variantId is! String) {
      return;
    }
    if (user?.selfieGender != null && user?.selfieGender != user?.gender) {
      setState(
        () => _tryOnMessage = 'Update your profile selfie in profile settings to use makeup try-on.',
      );
      return;
    }

    final selfieBytes = await context.read<SecureMediaStore>().load(selfieName);
    if (!mounted) return;
    if (selfieBytes == null) {
      setState(
        () => _tryOnMessage = 'Your saved profile selfie is unavailable. Update it in profile settings.',
      );
      return;
    }

    setState(() {
      _isTryingOn = true;
      _makeupResultUrl = null;
      _tryOnMessage = 'Applying makeup…';
    });
    try {
      final taskId = await EvoqeApi.startMakeupTryOn(
        productId: product.id,
        variantId: variantId,
        storeDomain: product.storeDomain,
        selfieBytes: selfieBytes,
      );
      for (var attempt = 0; attempt < 60; attempt++) {
        await Future.delayed(const Duration(seconds: 3));
        if (!mounted) return;
        final task = await EvoqeApi.getMakeupTryOnStatus(taskId);
        if (task.status == 'success' && task.resultUrl != null) {
          setState(() {
            _makeupResultUrl = task.resultUrl;
            _tryOnMessage = null;
          });
          return;
        }
        if (task.status == 'error') {
          throw EvoqeApiException(
            task.error ?? 'YouCam could not process this selfie.',
          );
        }
        setState(() {
          _tryOnMessage = 'Applying makeup…';
        });
      }
      setState(() {
        _tryOnMessage =
            'This is taking longer than expected. Please try again shortly.';
      });
    } on EvoqeApiException catch (error) {
      if (mounted) {
        setState(() {
          _tryOnMessage = error.message;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTryingOn = false;
        });
      }
    }
  }

  Widget _imagePlaceholder(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) => _profileImagePlaceholder();

  Widget _profileImagePlaceholder() {
    return Container(
      color: const Color(0xFFDDD7CC),
      child: const Center(
        child: Icon(
          Icons.person_outline_rounded,
          size: 48,
          color: Color(0xFF8C8278),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<SessionState>().currentUser;
    final profileSelfieName = user?.selfiePath;
    final selfieMatchesGender =
        user?.selfieGender == null || user?.selfieGender == user?.gender;
    final canUseProfileSelfie =
        profileSelfieName != null && selfieMatchesGender;
    final shades = _shades;
    final selectedShadeIndex = shades.isEmpty
        ? 0
        : _selectedShadeIndex < shades.length
        ? _selectedShadeIndex
        : 0;
    final currentShade = shades.isEmpty
        ? <String, dynamic>{
            'name': 'Swatch unavailable',
            'color': const Color(0xFFD6CFC4),
          }
        : shades[selectedShadeIndex];
    final currentVariant = currentShade['variant'] as Map<String, dynamic>?;
    final hasMakeupEffect =
        currentVariant?['makeup_effects_status'] == 'ready' &&
        currentVariant?['makeup_effects'] is Map;

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

                // Main Makeup Try-On Image Stage
                AspectRatio(
                  aspectRatio: 0.95,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.0),
                      color: const Color(0xFFE2DDD3),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: _makeupResultUrl != null
                              ? Image.network(
                                  _makeupResultUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: _imagePlaceholder,
                                )
                              : canUseProfileSelfie
                              ? SecureImage(
                                  fileName: profileSelfieName,
                                  placeholder: _profileImagePlaceholder(),
                                )
                              : Image.network(
                                  widget.product?.imageUrl ?? _makeupModelUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: _imagePlaceholder,
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
                            child: Text(
                              _makeupResultUrl != null
                                  ? 'YOUCAM MAKEUP RESULT'
                                  : canUseProfileSelfie
                                  ? 'PROFILE SELFIE'
                                  : widget.product == null
                                  ? 'MAKEUP PREVIEW DEMO'
                                  : 'SHOPIFY PRODUCT',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: Color(0xFF3E3129),
                              ),
                            ),
                          ),
                        ),

                        // Bottom Right Reset Button
                        Positioned(
                          right: 14,
                          bottom: 14,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedShadeIndex = widget.product == null
                                    ? 3
                                    : 0;
                                _isShadeApplied = false;
                                _makeupResultUrl = null;
                                _tryOnMessage = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xEBF5F3EC),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.refresh_rounded,
                                    size: 13,
                                    color: Color(0xFF201D19),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Reset',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF201D19),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Color Swatches Row & Counter
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: List.generate(shades.length, (index) {
                        final shade = shades[index];
                        final isSelected = index == selectedShadeIndex;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedShadeIndex = index;
                              _makeupResultUrl = null;
                              _tryOnMessage = null;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: shade['color'] as Color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF201D19)
                                    : const Color(0xFFCDC6BA),
                                width: isSelected ? 2.5 : 1.0,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    Text(
                      shades.isEmpty
                          ? 'No shade swatches'
                          : '${selectedShadeIndex + 1} / ${shades.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF888077),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Product Summary Header
                Text(
                  widget.product?.title ?? 'Soft satin lip color',
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF201D19),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    currentShade['name'],
                    widget.product?.vendor ?? 'Muse Beauty',
                    currentVariant?['price'] != null
                        ? '\$${currentVariant?['price']}'
                        : widget.product?.formattedPrice ?? 'sample \$650',
                  ].join(' · '),
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF888077),
                  ),
                ),
                if (widget.product != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      hasMakeupEffect
                          ? 'YouCam effect ready for this shade'
                          : currentVariant?['makeup_effects_status'] ==
                                'needs_swatch'
                          ? 'This variant needs a valid Shopify swatch hex'
                          : 'Makeup effect is pending catalog generation',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF888077),
                      ),
                    ),
                  ),
                if (widget.product != null && !canUseProfileSelfie)
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      'Add or update your profile selfie in profile settings to use makeup try-on.',
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.35,
                        color: Color(0xFF5A544D),
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // Primary Try-On Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed:
                        !hasMakeupEffect ||
                            _isTryingOn ||
                            !canUseProfileSelfie ||
                            currentVariant == null
                        ? null
                        : () => _startMakeupTryOn(currentVariant),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3E3129),
                      foregroundColor: const Color(0xFFF5F3EC),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    child: Text(
                      _isTryingOn
                          ? 'Processing…'
                          : !hasMakeupEffect
                          ? 'Effect Pending'
                          : 'Start Try-On',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
                if (_tryOnMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      _tryOnMessage!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF5A544D),
                      ),
                    ),
                  ),

                const SizedBox(height: 12),

                // Action Buttons Row: "Apply Shade" & "View Product"
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isShadeApplied = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3E3129),
                            foregroundColor: const Color(0xFFF5F3EC),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          ),
                          child: Text(
                            _isShadeApplied ? 'Shade Applied' : 'Apply Shade',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: widget.product?.productUrl == null
                              ? null
                              : () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Open this product on ${widget.product!.storeDomain}: ${widget.product!.productUrl}',
                                      ),
                                    ),
                                  );
                                },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFEFECE4),
                            foregroundColor: const Color(0xFF201D19),
                            side: const BorderSide(
                              color: Color(0xFFCDC6BA),
                              width: 1.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'View Product',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF201D19),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

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

                // Secondary Actions: See Similar Shades
                Center(
                  child: GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Similar-shade recommendations are not available yet.',
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'See similar shades',
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
                    onPressed: () {
                      setState(() {
                        _isLookSaved = !_isLookSaved;
                      });
                    },
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
                    child: Text(
                      _isLookSaved ? 'Look Saved' : 'Save Look',
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
}
