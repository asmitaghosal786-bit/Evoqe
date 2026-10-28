import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/session_state.dart';
import '../models/lookbook_model.dart';
import 'welcome_screen.dart';
import 'lookbook_results.dart';

class SixteenthScreen extends StatelessWidget {
  const SixteenthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionState>();
    final draft = session.currentDraft;
    final analysis = LookbookAnalyzer.analyze(draft);

    // Get image paths from references if any exist
    final imageReferences = draft.references.where((r) => r.imagePath.isNotEmpty).toList();

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

                // Eyebrow Label
                const Text(
                  'YOUR INSPIRATION, INTERPRETED',
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
                  'View Your Curated Board',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF201D19),
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 6),

                // Subtitle
                const Text(
                  'Rule-based aesthetic analyzer',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888077),
                  ),
                ),

                const SizedBox(height: 20),

                // Inspiration Grid (Display reference images or placeholders)
                if (imageReferences.isNotEmpty) ...[
                  Row(
                    children: [
                      for (int i = 0; i < imageReferences.length && i < 2; i++) ...[
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 1.15,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.0),
                                color: const Color(0xFFE2DDD3),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Image.file(
                                File(imageReferences[i].imagePath),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: const Color(0xFFDDD7CC),
                                  child: const Icon(Icons.image, size: 32, color: Color(0xFF8C8278)),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (i == 0 && imageReferences.length > 1) const SizedBox(width: 12),
                      ],
                    ],
                  ),
                ] else ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFECE4),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFFCDC6BA)),
                    ),
                    child: const Center(
                      child: Text(
                        'No reference images uploaded. Analysis derived from description.',
                        style: TextStyle(fontSize: 12.5, color: Color(0xFF888077)),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Curated Aesthetic Title (Dynamic Headline)
                Text(
                  analysis.headline,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF201D19),
                  ),
                ),

                const SizedBox(height: 8),

                // Curated Description Paragraph (Dynamic Summary)
                Text(
                  analysis.summary,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF6E6760),
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 22),

                // Dominant Palette Section Label
                const Text(
                  'DOMINANT PALETTE',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.0,
                    color: Color(0xFF888077),
                  ),
                ),

                const SizedBox(height: 12),

                // Swatches Row
                Row(
                  children: List.generate(analysis.paletteColors.length, (index) {
                    final color = analysis.paletteColors[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 14.0),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFCDC6BA),
                            width: 1.0,
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 8),

                // Palette Names Subtitle
                Text(
                  analysis.paletteName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888077),
                  ),
                ),

                const SizedBox(height: 20),

                // Style Tag Pills
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: analysis.styleTags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFECE4),
                        borderRadius: BorderRadius.circular(4.0),
                        border: Border.all(
                          color: const Color(0xFFCDC6BA),
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF201D19),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // Action Buttons Row: Edit Preferences & Generate Looks
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
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
                            'Edit Preferences',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF201D19),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            session.saveCurrentDraft();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SeventeenthScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3E3129),
                            foregroundColor: const Color(0xFFF5F3EC),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          ),
                          child: const Text(
                            'Generate Looks',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFF5F3EC),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
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
