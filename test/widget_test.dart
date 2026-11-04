import 'package:flutter_test/flutter_test.dart';
import 'package:evoqe/main.dart';
import 'package:evoqe/models/catalog_product.dart';
import 'package:evoqe/models/user_profile.dart';

void main() {
  test('catalog product exposes synced makeup variant effects', () {
    final product = CatalogProduct.fromJson({
      'id': 42,
      'store_domain': 'demo.myshopify.com',
      'title': 'Velvet Lip Color',
      'vendor': 'Demo Beauty',
      'product_type': 'Lipstick',
      'price': '25.00',
      'currency': 'USD',
      'available': true,
      'shopify_tags': [],
      'shopify_metadata': {
        'collections': [
          {'title': 'Makeup'},
        ],
      },
      'style_attributes': {},
      'variants': [
        {
          'id': 'gid://shopify/ProductVariant/42',
          'title': 'Rose',
          'swatch_hex': '#A14C60',
          'makeup_effects_status': 'ready',
          'makeup_effects': {
            'version': '1.0',
            'effects': [
              {'category': 'lip_color'},
            ],
          },
        },
      ],
    });

    expect(product.isMakeup, isTrue);
    expect(product.makeupVariants, hasLength(1));
    expect(product.makeupVariants.single['swatch_hex'], '#A14C60');
    expect(product.formattedPrice, '\$25.00');
  });

  test('Shopify product types route makeup and jewelry correctly', () {
    CatalogProduct product(String type) => CatalogProduct.fromJson({
      'id': 42,
      'store_domain': 'demo.myshopify.com',
      'title': type,
      'product_type': type,
      'price': '25.00',
      'currency': 'USD',
      'shopify_tags': [],
      'shopify_metadata': {},
      'style_attributes': {},
      'variants': [],
    });

    for (final productType in [
      'Blush',
      'Eyeliner',
      'Eyeshadow',
      'Lipstick',
      'Palette',
      'Skin Tint',
    ]) {
      expect(product(productType).isMakeup, isTrue);
    }
    expect(product('Earrings').isJewelry, isTrue);
    expect(product('Necklaces').isJewelry, isTrue);
    expect(product('Bags').isMakeup, isFalse);
    expect(product('Blazers').isJewelry, isFalse);
  });

  test('gender capture metadata persists with the local profile', () {
    final profile = UserProfile(
      name: 'Test',
      email: 'test@example.com',
      selfiePath: 'selfie.bin',
      selfieGender: 'Female',
      gender: 'Male',
      bodyPhotoGender: 'Female',
      bodyPhotoPaths: const {
        'front': 'front.bin',
        'left': 'left.bin',
        'right': 'right.bin',
        'back': 'back.bin',
      },
    );

    final restored = UserProfile.fromJson(profile.toJson());
    expect(restored.gender, 'Male');
    expect(restored.selfieGender, 'Female');
    expect(restored.bodyPhotoGender, 'Female');
  });

  testWidgets('Evoqe app loads home screen components', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const EvoqeApp());

    // Verify key titles and buttons render.
    expect(find.text('EVOQE'), findsWidgets);
  });
}
