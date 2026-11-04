class CatalogProduct {
  const CatalogProduct({
    required this.id,
    required this.storeDomain,
    required this.title,
    required this.description,
    required this.vendor,
    required this.productType,
    required this.productUrl,
    required this.imageUrl,
    required this.price,
    required this.currency,
    required this.available,
    required this.shopifyTags,
    required this.shopifyMetadata,
    required this.styleAttributes,
    required this.variants,
  });

  final int id;
  final String storeDomain;
  final String title;
  final String description;
  final String vendor;
  final String productType;
  final String? productUrl;
  final String? imageUrl;
  final String? price;
  final String currency;
  final bool available;
  final List<String> shopifyTags;
  final Map<String, dynamic> shopifyMetadata;
  final Map<String, dynamic> styleAttributes;
  final List<Map<String, dynamic>> variants;

  factory CatalogProduct.fromJson(Map<String, dynamic> json) {
    return CatalogProduct(
      id: json['id'] as int,
      storeDomain: json['store_domain'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      vendor: json['vendor'] as String? ?? '',
      productType: json['product_type'] as String? ?? '',
      productUrl: json['product_url'] as String?,
      imageUrl: json['image_url'] as String?,
      price: json['price']?.toString(),
      currency: json['currency'] as String? ?? 'USD',
      available: json['available'] as bool? ?? false,
      shopifyTags: (json['shopify_tags'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(),
      shopifyMetadata: Map<String, dynamic>.from(
        json['shopify_metadata'] as Map? ?? const {},
      ),
      styleAttributes: Map<String, dynamic>.from(
        json['style_attributes'] as Map? ?? const {},
      ),
      variants: (json['variants'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((variant) => Map<String, dynamic>.from(variant))
          .toList(),
    );
  }

  List<Map<String, dynamic>> get makeupVariants => variants
      .where(
        (variant) =>
            variant['makeup_effects_status'] == 'ready' &&
            variant['makeup_effects'] is Map,
      )
      .toList();

  bool get isMakeup {
    const makeupProductTypes = {
      'blush',
      'eyeliner',
      'eyeshadow',
      'lipstick',
      'palette',
      'skin tint',
    };
    final metadataCollections =
        shopifyMetadata['collections'] as List? ?? const [];
    final searchable = [
      title,
      productType,
      ...shopifyTags,
      ...metadataCollections.whereType<Map>().map(
        (collection) => collection['title'],
      ),
    ].join(' ').toLowerCase();
    return makeupProductTypes.contains(productType.trim().toLowerCase()) ||
        RegExp(
          r'\b(lipstick|lip color|lip tint|lip gloss|foundation|skin tint|concealer|blush|bronzer|contour|highlighter|eyeshadow|eye shadow|eyeliner|eye liner|mascara|eyelash|eyebrow|brow|make[\s-]?up)\b',
        ).hasMatch(searchable);
  }

  bool get isJewelry {
    const jewelryProductTypes = {'earrings', 'necklaces'};
    final metadataCollections =
        shopifyMetadata['collections'] as List? ?? const [];
    final searchable = [
      productType,
      ...shopifyTags,
      ...metadataCollections.whereType<Map>().map(
        (collection) => collection['title'],
      ),
    ].join(' ').toLowerCase();
    return jewelryProductTypes.contains(productType.trim().toLowerCase()) ||
        RegExp(r'\b(jewelry|jewellery|necklace|earring|bracelet|ring)\b')
            .hasMatch(searchable);
  }

  String get formattedPrice {
    if (price == null) return 'Price unavailable';
    return '\$$price';
  }

  Map<String, String> toDiscoverCard() {
    final gallery = shopifyMetadata['media'] as List? ?? const [];
    final galleryImages = gallery.whereType<Map>().toList();
    final firstGalleryImage = galleryImages.isEmpty
        ? null
        : galleryImages.first['url'];
    return {
      'id': id.toString(),
      'storeDomain': storeDomain,
      'title': title,
      'brand': vendor,
      'price': formattedPrice,
      'imageUrl': imageUrl ?? firstGalleryImage?.toString() ?? '',
      'productType': productType,
    };
  }
}
