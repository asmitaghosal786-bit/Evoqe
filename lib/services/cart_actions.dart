import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/catalog_product.dart';
import '../screens/retailer_checkout_1.dart';
import '../state/session_state.dart';

Future<void> addProductToCart(
  BuildContext context,
  CatalogProduct? product,
) async {
  if (product == null) {
    _showCartMessage(
      context,
      'Open a live catalog product to add it to your bag.',
    );
    return;
  }
  final variants = product.variants
      .where(
        (variant) => variant['available'] == true && variant['id'] is String,
      )
      .toList();
  if (variants.isEmpty) {
    _showCartMessage(context, 'This product has no available variants.');
    return;
  }

  Map<String, dynamic>? selectedVariant = variants.first;
  if (variants.length > 1) {
    selectedVariant = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      backgroundColor: const Color(0xFFF5F3EC),
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                'Choose an available option',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 20,
                  color: Color(0xFF201D19),
                ),
              ),
            ),
            for (final variant in variants)
              ListTile(
                title: Text(variant['title']?.toString() ?? 'Option'),
                subtitle: Text(
                  _variantPrice(product, variant),
                  style: const TextStyle(color: Color(0xFF6E6760)),
                ),
                onTap: () => Navigator.pop(sheetContext, variant),
              ),
          ],
        ),
      ),
    );
    if (selectedVariant == null || !context.mounted) return;
  }

  try {
    context.read<SessionState>().addToCart(product, selectedVariant);
    _showCartMessage(context, '${product.title} added to your bag.');
  } on StateError catch (error) {
    _showCartMessage(context, error.message);
  }
}

void openShoppingBag(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const TwentiethScreen()),
  );
}

String _variantPrice(CatalogProduct product, Map<String, dynamic> variant) {
  final currency = variant['currency']?.toString() ?? product.currency;
  final price = variant['price']?.toString() ?? product.price;
  if (price == null) return 'Price unavailable';
  return '$currency $price';
}

void _showCartMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
