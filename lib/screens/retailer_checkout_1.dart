import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/evoqe_api.dart';
import '../state/session_state.dart';
import 'discover.dart';
import 'welcome_screen.dart';

class TwentiethScreen extends StatefulWidget {
  const TwentiethScreen({super.key});

  @override
  State<TwentiethScreen> createState() => _TwentiethScreenState();
}

class _TwentiethScreenState extends State<TwentiethScreen> {
  bool _isCheckingOut = false;

  Future<void> _checkout(List<ShoppingCartLine> lines) async {
    if (lines.isEmpty || _isCheckingOut) return;
    setState(() => _isCheckingOut = true);
    try {
      final checkoutUrl = await EvoqeApi.createCheckout(
        storeDomain: lines.first.product.storeDomain,
        lines: lines
            .map(
              (line) => <String, Object>{
                'variant_id': line.variantId,
                'quantity': line.quantity,
              },
            )
            .toList(),
      );
      final launched = await launchUrl(
        Uri.parse(checkoutUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        throw const EvoqeApiException(
          'Your device could not open Shopify checkout.',
        );
      }
    } on EvoqeApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } on PlatformException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not open Shopify checkout: ${error.message ?? error.code}',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCheckingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionState>();
    final lines = session.cart;
    final total = lines.fold<double>(
      0,
      (sum, line) => sum + line.unitPrice * line.quantity,
    );
    final currency = lines.isEmpty ? '' : lines.first.currency;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EC),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF201D19),
                      ),
                      onPressed: () {
                        if (Navigator.canPop(context)) Navigator.pop(context);
                      },
                    ),
                    const EvoqeHeaderLogo(),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'YOUR CHOSEN PIECES',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2,
                    color: Color(0xFF888077),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'The shopping bag.',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF201D19),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${lines.length} ${lines.length == 1 ? 'item' : 'items'} · ${lines.isEmpty ? 'Shopify checkout' : lines.first.product.storeDomain}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF888077),
                  ),
                ),
                const SizedBox(height: 20),
                if (lines.isEmpty)
                  _buildEmptyBag()
                else ...[
                  for (final line in List<ShoppingCartLine>.from(lines))
                    _buildBagItem(line, session),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      const Text(
                        'Estimated total',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 24,
                          color: Color(0xFF201D19),
                        ),
                      ),
                      Text(
                        _formatPrice(total, currency),
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF201D19),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Shipping and taxes are calculated by Shopify at checkout.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF888077)),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isCheckingOut ? null : () => _checkout(lines),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3E3129),
                        foregroundColor: const Color(0xFFF5F3EC),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: _isCheckingOut
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Continue to Shopify checkout',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.north_east_rounded, size: 16),
                              ],
                            ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                const Text(
                  'Your order and payment are completed securely on the Shopify store.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF888077),
                    height: 1.35,
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

  Widget _buildEmptyBag() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: 48,
              color: Color(0xFF8C8278),
            ),
            const SizedBox(height: 12),
            const Text(
              'Your bag is empty.',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 20,
                color: Color(0xFF201D19),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ThirteenthScreen()),
              ),
              child: const Text('Explore Discover'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBagItem(ShoppingCartLine line, SessionState session) {
    final imageUrl = line.product.imageUrl;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: const Color(0xFFE2DDD3),
                ),
                clipBehavior: Clip.antiAlias,
                child: imageUrl == null
                    ? const Icon(Icons.image_outlined)
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            const Icon(Icons.image_outlined),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            line.product.title,
                            style: const TextStyle(
                              fontFamily: 'serif',
                              fontSize: 19,
                              color: Color(0xFF201D19),
                            ),
                          ),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: () => session.removeFromCart(line),
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: Color(0xFF201D19),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${line.product.vendor} · ${line.variantTitle}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF888077),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              onPressed: line.quantity <= 1
                                  ? null
                                  : () => session.setCartQuantity(
                                      line,
                                      line.quantity - 1,
                                    ),
                              icon: const Icon(Icons.remove, size: 16),
                            ),
                            Text('${line.quantity}'),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              onPressed: line.quantity >= 20
                                  ? null
                                  : () => session.setCartQuantity(
                                      line,
                                      line.quantity + 1,
                                    ),
                              icon: const Icon(Icons.add, size: 16),
                            ),
                          ],
                        ),
                        Text(
                          _formatPrice(
                            line.unitPrice * line.quantity,
                            line.currency,
                          ),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF201D19),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(color: Color(0xFFD6CFC4), height: 1),
      ],
    );
  }

  String _formatPrice(double amount, String currency) {
    final value = amount.toStringAsFixed(2).replaceFirst(RegExp(r'\.00$'), '');
    return '$currency $value';
  }
}
