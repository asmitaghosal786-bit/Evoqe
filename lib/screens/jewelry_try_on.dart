import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/security/secure_media_store.dart';
import '../models/catalog_product.dart';
import '../services/cart_actions.dart';
import '../services/evoqe_api.dart';
import '../state/session_state.dart';
import '../widgets/secure_image.dart';
import 'welcome_screen.dart';

class TenthScreen extends StatefulWidget {
  const TenthScreen({super.key, this.product});

  final CatalogProduct? product;

  @override
  State<TenthScreen> createState() => _TenthScreenState();
}

class _TenthScreenState extends State<TenthScreen> {
  bool _isItemSaved = false;
  bool _isTryingOn = false;
  String? _resultUrl;
  String? _tryOnMessage;

  static const String _jewelryModelUrl =
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=800&q=80';
  static const String _earringsThumbnailUrl =
      'https://images.unsplash.com/photo-1630019852942-f89202989a59?auto=format&fit=crop&w=300&q=80';

  Future<void> _startTryOn() async {
    final product = widget.product;
    final user = context.read<SessionState>().currentUser;
    final selfieName = user?.selfiePath;
    final selfieMatchesGender =
        user?.selfieGender == null || user?.selfieGender == user?.gender;
    if (product == null) {
      setState(
        () => _tryOnMessage = 'Select a catalog jewelry item to try it on.',
      );
      return;
    }
    if (user == null || selfieName == null || !selfieMatchesGender) {
      setState(
        () => _tryOnMessage = 'Add or update your profile selfie in profile settings to use jewelry try-on.',
      );
      return;
    }

    final imageBytes = await context.read<SecureMediaStore>().load(selfieName);
    if (!mounted) return;
    if (imageBytes == null) {
      setState(
        () => _tryOnMessage = 'The saved selfie could not be opened. Update it in profile settings.',
      );
      return;
    }
    setState(() {
      _isTryingOn = true;
      _resultUrl = null;
      _tryOnMessage = 'Uploading your selfie securely…';
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
            status.error ?? 'YouCam could not process this selfie.',
          );
        }
        setState(() => _tryOnMessage = 'Creating your jewelry try-on…');
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
    final selfieMatchesGender =
        user?.selfieGender == null || user?.selfieGender == user?.gender;
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

                // Main Jewelry Try-On Image Stage
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
                                      const SizedBox.shrink(),
                                )
                              : user?.selfiePath != null && selfieMatchesGender
                              ? SecureImage(
                                  fileName: user?.selfiePath,
                                  placeholder: Image.network(
                                    _jewelryModelUrl,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Image.network(
                                  _jewelryModelUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        color: const Color(0xFFDDD7CC),
                                        child: const Center(
                                          child: Icon(
                                            Icons.person_outline_rounded,
                                            size: 48,
                                            color: Color(0xFF8C8278),
                                          ),
                                        ),
                                      ),
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
                              widget.product == null
                                  ? 'JEWELRY PREVIEW DEMO'
                                  : 'AI JEWELRY VIRTUAL TRY-ON',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: Color(0xFF3E3129),
                              ),
                            ),
                          ),
                        ),

                        // Bottom Right Save Item Button
                        Positioned(
                          right: 14,
                          bottom: 14,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isItemSaved = !_isItemSaved;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xEBF5F3EC),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _isItemSaved
                                        ? Icons.bookmark_rounded
                                        : Icons.bookmark_border_rounded,
                                    size: 14,
                                    color: const Color(0xFF201D19),
                                  ),
                                  const SizedBox(width: 5),
                                  const Text(
                                    'Save Item',
                                    style: TextStyle(
                                      fontSize: 11.5,
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

                // Product Item Summary Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                        widget.product?.imageUrl ?? _earringsThumbnailUrl,
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
                            widget.product?.title ?? 'Sculpted gold hoops',
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
                                ? 'Gold tone · 18 mm · Forme Studio · sample \$850'
                                : '${widget.product!.vendor} · ${widget.product!.formattedPrice}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF888077),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Disclaimer Note
                const Text(
                  'Illustrative preview · not a precise scale or fit simulation',
                  style: TextStyle(fontSize: 11, color: Color(0xFF888077)),
                ),

                const SizedBox(height: 16),

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
                          const Icon(Icons.diamond_outlined, size: 18),
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

                // Secondary Actions: See Similar Pieces
                Center(
                  child: GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'See similar pieces',
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
                      'Save look',
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
