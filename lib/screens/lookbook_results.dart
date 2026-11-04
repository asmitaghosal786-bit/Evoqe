import 'dart:io';

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

class SeventeenthScreen extends StatefulWidget {
  const SeventeenthScreen({super.key, this.result});

  final LookbookApiResult? result;

  @override
  State<SeventeenthScreen> createState() => _SeventeenthScreenState();
}

class _SeventeenthScreenState extends State<SeventeenthScreen> {
  int _selectedFilterIndex = 0; // "Looks" active
  final Set<String> _bookmarkedLookTitles = {};
  late LookbookApiResult? _result = widget.result;
  bool _isRegenerating = false;
  String? _generationError;

  final List<String> _filterTabs = const ['Looks', 'Colors', 'Price range'];

  Future<void> _regenerateLookbook() async {
    final draft = context.read<SessionState>().currentDraft;
    final imagePath = draft.references
        .where((reference) => reference.imagePath.isNotEmpty)
        .map((reference) => reference.imagePath)
        .firstOrNull;
    if (imagePath == null && draft.aestheticDescription.trim().isEmpty) {
      setState(() {
        _generationError = 'Add a reference image or description first.';
      });
      return;
    }

    setState(() {
      _isRegenerating = true;
      _generationError = null;
    });
    try {
      final result = await EvoqeApi.analyzeLookbook(
        description: draft.aestheticDescription,
        image: imagePath == null ? null : File(imagePath),
      );
      if (mounted) setState(() => _result = result);
    } on EvoqeApiException catch (error) {
      if (mounted) setState(() => _generationError = error.message);
    } on FileSystemException catch (error) {
      if (mounted) {
        setState(
          () => _generationError = 'Could not read the selected image: $error',
        );
      }
    } finally {
      if (mounted) setState(() => _isRegenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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

                // Eyebrow Label
                Text(
                  'THE EVOQE LOOKBOOK',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2,
                    color: Color(0xFF888077),
                  ),
                ),

                const SizedBox(height: 6),

                // Main Title
                const Text(
                  'A new way to see you.',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF201D19),
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 6),

                // Subtitle
                Text(
                  _result == null
                      ? 'Generate a lookbook from your references and style notes.'
                      : 'AI-curated from your references and current Shopify catalog.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF888077)),
                ),

                const SizedBox(height: 20),

                // Filter Tabs Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: List.generate(_filterTabs.length, (index) {
                      final tab = _filterTabs[index];
                      final isSelected = index == _selectedFilterIndex;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedFilterIndex = index;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 24),
                          padding: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            border: isSelected
                                ? const Border(
                                    bottom: BorderSide(
                                      color: Color(0xFF201D19),
                                      width: 1.5,
                                    ),
                                  )
                                : null,
                          ),
                          child: Text(
                            tab,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? const Color(0xFF201D19)
                                  : const Color(0xFF888077),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 20),

                if (_result != null) ...[
                  Text(
                    _result!.summary,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: Color(0xFF6E6760),
                    ),
                  ),
                  if (_result!.aesthetics.isNotEmpty ||
                      _result!.colors.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        [
                          ..._result!.aesthetics,
                          ..._result!.colors,
                        ].join(' · '),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF888077),
                        ),
                      ),
                    ),
                  const SizedBox(height: 18),
                  if (_result!.products.isEmpty)
                    const Text(
                      'No matching products are in the connected catalog yet.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF888077),
                      ),
                    )
                  else
                    for (
                      var index = 0;
                      index < _result!.products.length;
                      index += 2
                    )
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildLookCard(_result!.products[index]),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: index + 1 < _result!.products.length
                                  ? _buildLookCard(_result!.products[index + 1])
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                ],
                if (_generationError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      _generationError!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8A4F32),
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // Refine My Lookbook Outlined Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: _isRegenerating ? null : _regenerateLookbook,
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
                    child: _isRegenerating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Regenerate My Lookbook',
                            style: TextStyle(
                              fontSize: 14.5,
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

  Widget _buildLookCard(CatalogProduct product) {
    final title = product.title;
    final description = [
      product.vendor,
      product.productType,
      product.formattedPrice,
    ].where((part) => part.isNotEmpty).join(' · ');
    final imageUrl = product.imageUrl;
    final isBookmarked = _bookmarkedLookTitles.contains(title);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 0.72,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
              color: const Color(0xFFE2DDD3),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Positioned.fill(
                  child: imageUrl == null
                      ? Container(
                          color: const Color(0xFFDDD7CC),
                          child: const Center(
                            child: Icon(Icons.image_outlined, size: 36),
                          ),
                        )
                      : Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: const Color(0xFFDDD7CC),
                                child: const Center(
                                  child: Icon(
                                    Icons.person_outline_rounded,
                                    size: 36,
                                    color: Color(0xFF8C8278),
                                  ),
                                ),
                              ),
                        ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isBookmarked) {
                          _bookmarkedLookTitles.remove(title);
                        } else {
                          _bookmarkedLookTitles.add(title);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xEBF5F3EC),
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      ),
                      child: Icon(
                        isBookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        size: 16,
                        color: const Color(0xFF201D19),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: Color(0xFF201D19),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(
            fontSize: 11.5,
            color: Color(0xFF888077),
            height: 1.35,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => product.isMakeup
                    ? EleventhScreen(product: product)
                    : product.isJewelry
                    ? TenthScreen(product: product)
                    : NinthScreen(product: product),
              ),
            );
          },
          child: const Row(
            children: [
              Text(
                'Try On',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF5A544D),
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
    );
  }
}
