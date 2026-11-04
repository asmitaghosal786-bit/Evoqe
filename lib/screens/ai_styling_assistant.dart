import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/catalog_product.dart';
import '../services/cart_actions.dart';
import '../services/evoqe_api.dart';
import '../state/session_state.dart';
import 'welcome_screen.dart';
import 'fashion_try_on.dart';
import 'jewelry_try_on.dart';
import 'makeup_try_on.dart';

class FourteenthScreen extends StatefulWidget {
  const FourteenthScreen({super.key});

  @override
  State<FourteenthScreen> createState() => _FourteenthScreenState();
}

class _FourteenthScreenState extends State<FourteenthScreen> {
  bool _isOutfitSaved = false;
  bool _isSendingMessage = false;
  String? _assistantReply;
  String? _assistantError;
  String? _lastAssistantMessage;
  List<CatalogProduct> _assistantProducts = const [];

  final TextEditingController _chatController = TextEditingController();
  final TextEditingController _occasionController = TextEditingController(
    text: 'Dinner',
  );
  final TextEditingController _budgetController = TextEditingController(
    text: 'Under \$10,000',
  );
  final TextEditingController _aestheticController = TextEditingController(
    text: 'Formal',
  );
  final TextEditingController _itemNeededController = TextEditingController(
    text: 'Suit',
  );

  @override
  void dispose() {
    _chatController.dispose();
    _occasionController.dispose();
    _budgetController.dispose();
    _aestheticController.dispose();
    _itemNeededController.dispose();
    super.dispose();
  }

  Future<void> _sendAssistantMessage({String? prompt}) async {
    final message = (prompt ?? _chatController.text).trim();
    if (message.isEmpty || _isSendingMessage) return;
    final user = context.read<SessionState>().currentUser;
    setState(() {
      _isSendingMessage = true;
      _assistantError = null;
    });
    try {
      final result = await EvoqeApi.sendAssistantMessage(
        message: message,
        preferences: {
          'occasion': _occasionController.text.trim(),
          'budget': _budgetController.text.trim(),
          'aesthetic': _aestheticController.text.trim(),
          'item_needed': _itemNeededController.text.trim(),
          if (user != null) 'user_aesthetics': user.aesthetics.join(', '),
        },
      );
      if (!mounted) return;
      setState(() {
        _lastAssistantMessage = message;
        _assistantReply = result.reply;
        _assistantProducts = result.products;
        if (prompt == null) _chatController.clear();
      });
    } on EvoqeApiException catch (error) {
      if (mounted) setState(() => _assistantError = error.message);
    } finally {
      if (mounted) setState(() => _isSendingMessage = false);
    }
  }

  Future<void> _regenerateAssistantReply() async {
    final previousMessage = _lastAssistantMessage;
    if (previousMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ask the stylist for a recommendation first.'),
        ),
      );
      return;
    }
    await _sendAssistantMessage(prompt: previousMessage);
  }

  void _openRecommendedTryOn() {
    if (_assistantProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ask the stylist for a product recommendation first.'),
        ),
      );
      return;
    }
    final product = _assistantProducts.first;
    final screen = product.isMakeup
        ? EleventhScreen(product: product)
        : product.isJewelry
        ? TenthScreen(product: product)
        : NinthScreen(product: product);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final featuredProduct = _assistantProducts.isEmpty
        ? null
        : _assistantProducts.first;
    final featuredImageUrl = featuredProduct?.imageUrl;
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

                const SizedBox(height: 24),

                // Title & Sparkles AI Icon Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: Text(
                        'Your private stylist.',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 30,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF201D19),
                          letterSpacing: -0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
                      Icons.auto_awesome_outlined,
                      size: 24,
                      color: Color(0xFF201D19),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Stylist Recommendation Outfit Card
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFECE4),
                    borderRadius: BorderRadius.circular(4.0),
                    border: Border.all(
                      color: const Color(0xFFCDC6BA),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Model Outfit Image
                      Expanded(
                        flex: 4,
                        child: AspectRatio(
                          aspectRatio: 0.78,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.0),
                              color: const Color(0xFFE2DDD3),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: featuredImageUrl == null
                                ? const Center(
                                    child: Icon(
                                      Icons.auto_awesome_outlined,
                                      size: 32,
                                      color: Color(0xFF8C8278),
                                    ),
                                  )
                                : Image.network(
                                    featuredImageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              color: const Color(0xFFDDD7CC),
                                              child: const Icon(
                                                Icons.person_outline_rounded,
                                                size: 32,
                                                color: Color(0xFF8C8278),
                                              ),
                                            ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Outfit Details
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    featuredProduct?.title ?? 'Your next look',
                                    style: const TextStyle(
                                      fontFamily: 'serif',
                                      fontSize: 19,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF201D19),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isOutfitSaved = !_isOutfitSaved;
                                    });
                                  },
                                  child: Icon(
                                    _isOutfitSaved
                                        ? Icons.bookmark_rounded
                                        : Icons.bookmark_border_rounded,
                                    size: 18,
                                    color: const Color(0xFF201D19),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              featuredProduct == null
                                  ? 'Share your plans and preferences to receive live recommendations.'
                                  : '${featuredProduct.vendor} · ${featuredProduct.productType}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF888077),
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              featuredProduct?.formattedPrice ?? 'Recommendations use your connected Shopify catalog.',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF201D19),
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: _regenerateAssistantReply,
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.refresh_rounded,
                                    size: 12,
                                    color: Color(0xFF5A544D),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Regenerate new look',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF5A544D),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: _openRecommendedTryOn,
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Try on the coordinated edit',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF5A544D),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 2),
                                  Icon(
                                    Icons.north_east_rounded,
                                    size: 11,
                                    color: Color(0xFF5A544D),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Refresh Button Row outside card
                GestureDetector(
                  onTap: _regenerateAssistantReply,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        size: 16,
                        color: Color(0xFF201D19),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Refresh',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF201D19),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Occasion Shortcut Input Field
                const Text(
                  'Occasion',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6E6760),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _occasionController,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF201D19),
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFEFECE4),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: const BorderSide(
                        color: Color(0xFFCDC6BA),
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: const BorderSide(
                        color: Color(0xFF3E3129),
                        width: 1.2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Budget Shortcut Input Field
                const Text(
                  'Budget',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6E6760),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _budgetController,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF201D19),
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFEFECE4),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: const BorderSide(
                        color: Color(0xFFCDC6BA),
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: const BorderSide(
                        color: Color(0xFF3E3129),
                        width: 1.2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Aesthetic Input Field
                const Text(
                  'Aesthetic',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6E6760),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _aestheticController,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF201D19),
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFEFECE4),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: const BorderSide(
                        color: Color(0xFFCDC6BA),
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: const BorderSide(
                        color: Color(0xFF3E3129),
                        width: 1.2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Item Needed Input Field
                const Text(
                  'Item Needed',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6E6760),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _itemNeededController,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF201D19),
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFEFECE4),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: const BorderSide(
                        color: Color(0xFFCDC6BA),
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: const BorderSide(
                        color: Color(0xFF3E3129),
                        width: 1.2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Chat Input Field
                const Text(
                  'Chat here with our assistant',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6E6760),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _chatController,
                  onSubmitted: (_) => _sendAssistantMessage(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF201D19),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Tell me what you have in mind...',
                    hintStyle: const TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF888077),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFEFECE4),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    suffixIcon: GestureDetector(
                      onTap: _isSendingMessage ? null : _sendAssistantMessage,
                      child: Container(
                        margin: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFF3E3129),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(Radius.circular(4.0)),
                        ),
                        child: _isSendingMessage
                            ? const Padding(
                                padding: EdgeInsets.all(8),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFFF5F3EC),
                                ),
                              )
                            : const Icon(
                                Icons.arrow_upward_rounded,
                                color: Color(0xFFF5F3EC),
                                size: 18,
                              ),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: const BorderSide(
                        color: Color(0xFFCDC6BA),
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: const BorderSide(
                        color: Color(0xFF3E3129),
                        width: 1.2,
                      ),
                    ),
                  ),
                ),

                if (_assistantError != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _assistantError!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8A4F32),
                    ),
                  ),
                ],
                if (_assistantReply != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFECE4),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFFCDC6BA)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _assistantReply!,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF201D19),
                            height: 1.4,
                          ),
                        ),
                        for (final product in _assistantProducts)
                          _buildRecommendedProduct(product),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendedProduct(CatalogProduct product) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          if (product.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                product.imageUrl!,
                width: 52,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox(
                  width: 52,
                  height: 64,
                  child: Icon(Icons.image_outlined),
                ),
              ),
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF201D19),
                  ),
                ),
                Text(
                  '${product.vendor} · ${product.formattedPrice}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF6E6760),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
