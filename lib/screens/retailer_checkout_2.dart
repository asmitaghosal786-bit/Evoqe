import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import 'home_screen.dart';

class TwentyFirstScreen extends StatelessWidget {
  const TwentyFirstScreen({super.key});

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
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Main Title
                const Text(
                  'Checkout, thoughtfully.',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF201D19),
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 12),

                // Subtitle Paragraph
                const Text(
                  'You will complete purchases separately on each retailer\'s website. EVOQE does not collect payment or place orders in this demo.',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF6E6760),
                    height: 1.35,
                  ),
                ),

                const SizedBox(height: 24),

                // Eyebrow Label
                const Text(
                  'YOUR RETAILER GROUPS',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2,
                    color: Color(0xFF888077),
                  ),
                ),

                const SizedBox(height: 18),

                // Retailer Group 1: Maison Vale
                const Text(
                  'Maison Vale',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF201D19),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '2 items · sample subtotal ₹4,600',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF888077),
                  ),
                ),

                const SizedBox(height: 12),

                // Proceed to Maison Vale Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {},
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
                      'Proceed to Maison Vale',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF201D19),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Retailer Group 2: Forme Studio
                const Text(
                  'Forme Studio',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF201D19),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '1 item · sample subtotal ₹850',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF888077),
                  ),
                ),

                const SizedBox(height: 12),

                // Proceed to Forme Studio Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {},
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
                      'Proceed to Forme Studio',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF201D19),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Disclaimer Subtext
                const Text(
                  'Fictional sample retailers. No working checkout, stock reservation or purchase confirmation.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF888077),
                    height: 1.35,
                  ),
                ),

                const SizedBox(height: 28),

                // Back to Home Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const EighthScreen(initialTabIndex: 0),
                        ),
                        (route) => false,
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
                      'Back to Home',
                      style: TextStyle(
                        fontSize: 15,
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
